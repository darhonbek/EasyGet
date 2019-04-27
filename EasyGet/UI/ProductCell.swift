//
//  ProductCell.swift
//  EasyGet
//
//  Created by Darkhonbek Mamataliev on 28/4/19.
//  Copyright © 2019 Darkhonbek Mamataliev. All rights reserved.
//

import Foundation
import UIKit


class ProductCell: UITableViewCell {
    var product: Product? {
        didSet {
            nameLabel.text = product?.name
            priceLabel.text = "$" + (product?.price.description ?? "")
        }
    }

    lazy var productImageView: UIImageView = {
        var imageView = UIImageView(image: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    fileprivate lazy var nameLabel: VerticalAlignedLabel = {
        var label = VerticalAlignedLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.font = UIFont.systemFont(ofSize: 20.0)
        label.contentMode = .top

        return label
    }()

    fileprivate lazy var priceLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right

        return label
    }()

    // MARK: - Lifecycle

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupView()
    }

    // MARK: -

    private func setupView() {
        contentView.addSubview(productImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        
        NSLayoutConstraint.activate(
            [productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0),
             productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.0),
             productImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.0),
             productImageView.widthAnchor.constraint(equalToConstant: 120.0),
             
             nameLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10.0),
             nameLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -10.0),
             nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.0),
             nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.0),
             
             priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10.0),
             priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20.0),
             priceLabel.widthAnchor.constraint(equalToConstant: 80.0)]
        )
    }
}

class VerticalAlignedLabel: UILabel {

    override func drawText(in rect: CGRect) {
        var newRect = rect
        switch contentMode {
        case .top:
            newRect.size.height = sizeThatFits(rect.size).height
        case .bottom:
            let height = sizeThatFits(rect.size).height
            newRect.origin.y += rect.size.height - height
            newRect.size.height = height - 15.0
        default:
            ()
        }

        super.drawText(in: newRect)
    }
}
