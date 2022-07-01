//
//  BioCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/28.
//

import Foundation
import UIKit
class BioCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    private let bioTitleLabel = UILabel().makeBasicSemiboldLabel(fontSize: 22, text: "Bio")
    
     let bioLabel: UILabel = {
       let label = UILabel()
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.text = "This is my personal bio description This is my personal bio descriptionThis is my personal bio descriptionThis is my personal bio descriptionThis"
        return label
    }()
    
    // MARK: - Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func setupCellUI() {
        backgroundColor = UIColor.darkGray
        layer.cornerRadius = 20
        
        contentView.addSubview(bioTitleLabel)
        bioTitleLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, paddingTop: 16, paddingLeft: 10)
//        bioTitleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        contentView.addSubview(bioLabel)
        bioLabel.anchor(top: bioTitleLabel.bottomAnchor, left: bioTitleLabel.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingBottom: 15, paddingRight: 10)
    }
    
    func configureCell(bioText: String) {
        if bioText.isEmpty || bioText == "" {
            bioLabel.text = "No Bio Available"
        } else {
            bioLabel.text = bioText
        }
    }
}
