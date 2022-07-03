//
//  UIButton+Ext.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit

extension UIButton {
    
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
    
    func attributedTitle(for firstPart: String, secondPart: String) {
        
        let atts: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(white: 1, alpha: 0.6), .font: UIFont.systemFont(ofSize: 16)]
        
        let attributedTitle = NSMutableAttributedString(string: "\(firstPart)", attributes: atts)
        
        let boldAtts: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(white: 1, alpha: 0.9), .font: UIFont.boldSystemFont(ofSize: 16)]
        
        attributedTitle.append(NSAttributedString(string: "\(secondPart)", attributes: boldAtts))
        
        setAttributedTitle(attributedTitle, for: .normal)
    }
}
