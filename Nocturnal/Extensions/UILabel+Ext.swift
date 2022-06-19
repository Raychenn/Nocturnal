//
//  UILabel+Ext.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/18.
//

import UIKit

extension UILabel {
    func attributedText( firstPart: String, secondPart: String) {
        
        let atts: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.primaryBlue, .font: UIFont.systemFont(ofSize: 17, weight: .heavy)]
        
        let attributedTitle = NSMutableAttributedString(string: "\(firstPart) ", attributes: atts)
        
        let boldAtts: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black, .font: UIFont.boldSystemFont(ofSize: 15)]
        
        attributedTitle.append(NSAttributedString(string: "\(secondPart)", attributes: boldAtts))
        
        attributedText = attributedTitle
    }
}
