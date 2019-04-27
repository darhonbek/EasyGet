//
//  CartViewController.swift
//  Test
//
//  Created by Darkhonbek Mamataliev on 21/4/19.
//  Copyright © 2019 Darkhonbek Mamataliev. All rights reserved.
//

import Foundation
import UIKit

class CartViewController: UIViewController {
    fileprivate var products: [Product]

    fileprivate lazy var tableView: UITableView = {
        var tableView = UITableView(frame: view.bounds)
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ProductCell.self, forCellReuseIdentifier: "Product Cell")

        return tableView
    }()

    fileprivate lazy var checkoutButton:  UIBarButtonItem = {
        let doneButton = UIBarButtonItem(
            title: "Checkout",
            style: .plain,
            target: self,
            action: #selector(touchUpInside(checkoutButton:))
        )

        return doneButton
    }()

    // MARK: - Lifecycle

    init(products: [Product]) {
        self.products = products

        super.init(nibName: nil, bundle: nil)

        addTotalCell()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        view.addSubview(tableView)
        setupNavigationBar()
    }

    // MARK: -

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = checkoutButton
        navigationItem.title = "Cart"
    }

    @objc func touchUpInside(checkoutButton: UIBarButtonItem) {
        let totalPrice = products.last?.price.description ?? "error"

        let alertController = UIAlertController(
            title: "Payment confirmation",
            message: "Total: $\(totalPrice)",
            preferredStyle: .actionSheet
        )

        let paymentSuccessfulAlertController = UIAlertController(
            title: "Checkout successful ✅",
            message: "",
            preferredStyle: .alert
        )

        let action = UIAlertAction(
            title: "Checkout",
            style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.present(paymentSuccessfulAlertController, animated: true, completion: nil)

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    paymentSuccessfulAlertController.dismiss(animated: true, completion: nil)
                    self.products = []
                    self.navigationController?.popToRootViewController(animated: true)
                }
        }

        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }

    private func addTotalCell() {
        var totalPrice = 0.0

        for product in products {
            totalPrice += product.price
        }

        let product = Product(id: "Total", name: "Total", price: totalPrice)
        products.append(product)
    }
}

// MARK: -

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }
}

// MARK: -

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "Product Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ProductCell
        cell.product = products[indexPath.row]

        // FIXME: - debug image download
        if let imageUrl = products[indexPath.row].imageUrl {
            cell.productImageView.loadImage(from: imageUrl)
        }

        return cell
    }
}
