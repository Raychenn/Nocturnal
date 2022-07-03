//
//  UICollectionView+Ext.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/16.
//

import UIKit

extension UICollectionViewCell {
    
     static var id: String {
        return String(describing: self)
    }
    
}

extension UICollectionReusableView {
    
    static var identifier: String {
        
        return String(describing: self)
    }
}
