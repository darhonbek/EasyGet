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

class ScannerViewController: UIViewController {
    fileprivate var databaseReference: DatabaseReference!
    fileprivate var captureSession: AVCaptureSession!
    fileprivate var audioPlayer: AVAudioPlayer?
    
    fileprivate lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        return previewLayer
    }()
    
    fileprivate lazy var backButton:  UIBarButtonItem = {
        let backButton = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(touchUpInside(backbutton:))
        )
        
        return backButton
    }()
    
    fileprivate lazy var doneButton:  UIBarButtonItem = {
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: self,
            action: #selector(touchUpInside(donebutton:))
        )
        
        return doneButton
    }()
    
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
    
    // MARK: - Lifecycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCamera()
        setupAudio()
        view.layer.addSublayer(previewLayer)
        setupNavigationBar()
        
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
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.title = "Scan Products"
    }
    
    // MARK: - Actions
    
    @objc func touchUpInside(backbutton: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func touchUpInside(donebutton: UIBarButtonItem) {
        let cartViewController = CartViewController()
        navigationController?.pushViewController(cartViewController, animated: true)
    }
    
    fileprivate func didDetect(productDescription: String) {
        playScannerSound()
        
        let alertAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: { action in
                self.startCaptureSession()
        }
        )
        
        let alertController = UIAlertController(
            title: "Added to cart ✅",
            message: productDescription,
            preferredStyle: .alert
        )
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
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

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        stopCaptureSession()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            didDetect(productDescription: stringValue)
        }
    }
}
