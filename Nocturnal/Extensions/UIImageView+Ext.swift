//
//  UIImageView+Ext.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/7/18.
//

import UIKit

extension UIImageView {
    
    func createBasicImageView(backgroundColor: UIColor, tintColor: UIColor) -> UIImageView {
        let imageView = UIImageView()
         imageView.contentMode = .scaleAspectFit
         imageView.backgroundColor = backgroundColor
         imageView.tintColor = tintColor
         imageView.clipsToBounds = true
         return imageView
    }
}
