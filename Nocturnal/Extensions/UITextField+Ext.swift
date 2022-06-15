//
//  UITextField+Ext.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit

extension UITextField {
    
    func setLeftPaddingPoints(amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func makeTextField(withPlaceholder placeholder: String, isSecureTextEntry: Bool) -> UITextField {
        
        let field = UITextField()
         field.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [ .foregroundColor: UIColor.lightGray ])
        field.borderStyle = .none
        field.font = UIFont.systemFont(ofSize: 16)
        field.textColor = .white
        field.keyboardAppearance = .dark
        field.isSecureTextEntry = isSecureTextEntry
        
        return field
    }
}
