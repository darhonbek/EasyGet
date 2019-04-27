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

    lazy var tableView: UITableView = {
        var tableView = UITableView(frame: view.bounds)
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ProductCell.self, forCellReuseIdentifier: "Product Cell")

        return tableView
    }()

    // MARK: - Lifecycle

    init(products: [Product]) {
        self.products = products

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        view.addSubview(tableView)
        title = "Cart"
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

        return cell
    }
}
