//
//  ScannerViewController.swift
//  Test
//
//  Created by Darkhonbek Mamataliev on 20/4/19.
//  Copyright © 2019 Darkhonbek Mamataliev. All rights reserved.
//

import AVFoundation
import UIKit

import FirebaseDatabase
import FloatingPanel

class ScannerViewController: UIViewController {
    fileprivate var cart: [Product]
    fileprivate var databaseReference: DatabaseReference!
    fileprivate var captureSession: AVCaptureSession!
    fileprivate var audioPlayer: AVAudioPlayer?

    private var isScanningInProgress: Bool
    private let supportedCodeTypes = [
        AVMetadataObject.ObjectType.upce,
        AVMetadataObject.ObjectType.code39,
        AVMetadataObject.ObjectType.code39Mod43,
        AVMetadataObject.ObjectType.code93,
        AVMetadataObject.ObjectType.code128,
        AVMetadataObject.ObjectType.ean8,
        AVMetadataObject.ObjectType.ean13,
        AVMetadataObject.ObjectType.aztec,
        AVMetadataObject.ObjectType.pdf417,
        AVMetadataObject.ObjectType.itf14,
        AVMetadataObject.ObjectType.dataMatrix,
        AVMetadataObject.ObjectType.interleaved2of5,
        AVMetadataObject.ObjectType.qr
    ]

    fileprivate lazy var cartViewController: CartViewController = {
        return CartViewController(cart: cart)
    }()

    fileprivate lazy var floatingPanelController: FloatingPanelController = {
        var controller = FloatingPanelController()
        controller.surfaceView.backgroundColor = .clear
        controller.surfaceView.cornerRadius = 9.0
        controller.surfaceView.shadowHidden = false
        controller.set(contentViewController: cartViewController)
        controller.track(scrollView: cartViewController.tableView)
        controller.delegate = self

        return controller
    }()

    fileprivate lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill

        return previewLayer
    }()

    fileprivate lazy var checkoutButton:  UIBarButtonItem = {
        let checkoutButton = UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: self,
            action: #selector(touchUpInside(checkoutButton:))
        )

        return checkoutButton
    }()

    // MARK: - Lifecycle
    
    init() {
        isScanningInProgress = false
        cart = []

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCamera()
        setupAudio()
        setupNavigationBar()
        view.layer.addSublayer(previewLayer)
        floatingPanelController.addPanel(toParent: self, animated: true)

        databaseReference = Database.database().reference()

        // FIXME: - Workaround to populate database
        //        databaseReference.child("products").child("1").setValue(
        //            ["name": "Milk",
        //             "price": 2.5,
        //             "imageUrl": "https://firebasestorage.googleapis.com/v0/b/easyget-dcd23.appspot.com/o/milk.jpg?alt=media&token=0640789e-707a-43a0-a623-95717f652f5a"]
        //        )
        //        databaseReference.child("products").child("2").setValue(
        //            ["name": "Bread",
        //             "price": 1.0,
        //             "imageUrl": "https://firebasestorage.googleapis.com/v0/b/easyget-dcd23.appspot.com/o/bread.jpg?alt=media&token=0d24f1ad-f276-4720-b3b2-8bb28f3dc533"]
        //        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startCaptureSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopCaptureSession()
    }


    // MARK: - Orientation

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    // MARK: -

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = checkoutButton
        navigationItem.title = "Scan Products"
    }

    // MARK: - Actions

    @objc func touchUpInside(checkoutButton: UIBarButtonItem) {
        // FIXME: - Update button destination
        let cartViewController = CartViewController(cart: cart)
        navigationController?.pushViewController(cartViewController, animated: true)
    }

    // FIXME: - Refactor

    fileprivate func didDetect(productCode: String, completionHandler: @escaping (Product?) -> Void) {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        playScannerSound()

        databaseReference.child("products").child(productCode).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary,
                let name = value["name"] as? String,
                let price = value["price"] as? Double,
                let imageUrl = value["imageUrl"] as? String {
                let url = URL(fileURLWithPath: imageUrl)

                // FIXME: - Image load should be async
                let image = self.loadImageFrom(url: url)

                let product = Product(id: productCode, name: name, price: price, image: image)
                completionHandler(product)
            }
        }) { _ in
            completionHandler(nil)
        }
    }

    fileprivate func showItemAddedPopup(for product: Product?, completionHandler: @escaping () -> Void) {
        if let product = product {
            cart.append(product)
            let alertController = UIAlertController(
                title: "Item Added to Cart ✅",
                message: "🛒 \(product.name)\n💲 \(product.price)",
                preferredStyle: .alert
            )
            self.present(alertController, animated: true)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                alertController.dismiss(animated: true, completion: nil)
                completionHandler()
            }
        } else {
            completionHandler()
        }
    }

    private func loadImageFrom(url: URL) -> UIImage? {
        do {
            let data = try Data(contentsOf: url)
            let image = UIImage(data: data)

            return image
        } catch {
            return nil
        }
    }
}

// MARK: - FloatingPanelControllerDelegate

extension ScannerViewController: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return CartFloatingPanelLayout()
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if !isScanningInProgress {
            isScanningInProgress = true

            if let metadataObject = metadataObjects.first,
                let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                let code = readableObject.stringValue {
                didDetect(productCode: code) { product in
                    self.showItemAddedPopup(for: product, completionHandler: {
                        self.isScanningInProgress = false
                    })
                }
            } else {
                isScanningInProgress = false
            }
        }
    }
}

// MARK: - Audio

extension ScannerViewController {
    fileprivate func setupAudio() {
        guard let url = Bundle.main.url(forResource: "Beep", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    fileprivate func playScannerSound() {
        audioPlayer?.play()
    }
}

// MARK: - Camera

extension ScannerViewController {
    fileprivate func setupCamera() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            let metadataOutput = AVCaptureMetadataOutput()

            if captureSession.canAddInput(videoInput) && captureSession.canAddOutput(metadataOutput) {
                captureSession.addInput(videoInput)
                captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = supportedCodeTypes
            } else {
                showCameraNotSupportedWarning()

                return
            }
        } catch {
            return
        }
    }

    fileprivate func startCaptureSession() {
        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }

    fileprivate func stopCaptureSession() {
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }

    fileprivate func showCameraNotSupportedWarning() {
        let alertController = UIAlertController(
            title: "Scanning not supported",
            message: "Your device does not support scanning a code from an item. Please use a device with a camera.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
        captureSession = nil
    }
}
