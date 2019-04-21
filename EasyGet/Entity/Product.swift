//
//  Product.swift
//  EasyGet
//
//  Created by Darkhonbek Mamataliev on 21/4/19.
//  Copyright © 2019 Darkhonbek Mamataliev. All rights reserved.
//

import Foundation
import UIKit

class Product {
    var id: String
    var name: String
    var price: Double
    var image: UIImage?

    init(id: String, name: String, price: Double, image: UIImage? = nil) {
        self.id = id
        self.name = name
        self.price = price
        self.image = image
    }
}
