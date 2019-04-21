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
    fileprivate var cart: [Product]

    fileprivate lazy var tableView: UITableView = {
        var tableView = UITableView(frame: view.bounds)
        tableView.dataSource = self
        tableView.delegate = self

        return tableView
    }()

    // MARK: - Lifecycle

    init(cart: [Product]) {
        self.cart = cart

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        view.addSubview(tableView)
    }
}

// MARK: -

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
}

// MARK: -

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "Cart Item Cell"
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)

        let product = cart[indexPath.row]
        cell.textLabel?.text = product.name

        return cell
    }
}
