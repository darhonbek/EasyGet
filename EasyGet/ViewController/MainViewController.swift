//
//  MainViewController.swift
//  Test
//
//  Created by Darkhonbek Mamataliev on 19/4/19.
//  Copyright © 2019 Darkhonbek Mamataliev. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    private var marginsGuide: UILayoutGuide!

    fileprivate lazy var scanButton: UIButton = {
        var button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tap here to scan products", for: .normal)
        button.addTarget(self, action: #selector(touchUpInside(scanButton:)), for: .touchUpInside)

        return button
    }()

    // MARK: - Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        if #available(iOS 11, *) {
            marginsGuide = view.safeAreaLayoutGuide
        } else {
            marginsGuide = view.layoutMarginsGuide
        }

        title = "EasyGet"
        view.addSubview(scanButton)
        view.backgroundColor = .white
        setupScanButtonConstraints()
    }

    // MARK: -

    private func setupScanButtonConstraints() {
        NSLayoutConstraint.activate(
            [scanButton.centerXAnchor.constraint(equalTo: marginsGuide.centerXAnchor),
             scanButton.centerYAnchor.constraint(equalTo: marginsGuide.centerYAnchor),]
        )
    }

    @objc private func touchUpInside(scanButton: UIButton) {
        openScannerViewController()
    }

    private func openScannerViewController() {
        let scannerViewController = ScannerViewController()
        navigationController?.pushViewController(scannerViewController, animated: true)
    }
}

