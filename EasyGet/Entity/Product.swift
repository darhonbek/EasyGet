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
    var imageUrl: String?

    init(id: String, name: String, price: Double, imageUrl: String? = nil) {
        self.id = id
        self.name = name
        self.price = price
        self.imageUrl = imageUrl
    }
}
