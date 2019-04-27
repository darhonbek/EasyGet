//
//  UIImageView+ImageDownload.swift
//  EasyGet
//
//  Created by Darkhonbek Mamataliev on 28/4/19.
//  Copyright © 2019 Darkhonbek Mamataliev. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImage(from imageUrl: String) {
        if let url = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print(error)

                    return
                }

                DispatchQueue.main.async {
                    if let data = data {
                        self.image = UIImage(data: data)
                    }
                }
            }
        }
    }
}
