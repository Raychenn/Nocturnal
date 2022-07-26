//
//  AuthButton.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/18.
//

import UIKit
class AuthButton: UIButton, Buzzable {
    
    var title: String? {
        didSet {
            setTitle(title, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        setTitleColor(.white, for: .normal)
        backgroundColor = .systemPurple.withAlphaComponent(0.6)
        layer.cornerRadius = 5
        setHeight(50)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
//        isEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
