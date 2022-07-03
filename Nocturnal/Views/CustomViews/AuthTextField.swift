//
//  AuthTextField.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/18.
//

import UIKit

class CustomTextField: UITextField {
    
    init(placeholder: String) {
        super.init(frame: .zero)
      
        borderStyle = .none
        textColor = .white
        keyboardAppearance = .dark
        keyboardType = .emailAddress
        font = .systemFont(ofSize: 16)
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.7)])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
