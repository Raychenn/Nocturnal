//
//  DateHeaderLabel.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/20.
//

import UIKit
class DateHeaderLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .black
        font = .systemFont(ofSize: 14)
        textColor = .white
        textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        layer.cornerRadius = originalContentSize.height / 2
        layer.masksToBounds = true
        return CGSize(width: originalContentSize.width + 16, height: originalContentSize.height  + 12)
    }
}
