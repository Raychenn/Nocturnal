//
//  SettingProfileCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/29.
//

import UIKit

class DeleteAccountCell: UITableViewCell {
    
    private let deleteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "trash")
        imageView.tintColor = .red
        return imageView
    }()
    
    private let deleteLabel: UILabel = {
       let label = UILabel()
        label.text = "Delete Account"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "#1C242F")
        
        addSubview(deleteImageView)
        deleteImageView.centerY(inView: self)
        deleteImageView.anchor(left: leftAnchor, paddingLeft: 10)
        
        addSubview(deleteLabel)
        deleteLabel.centerY(inView: deleteImageView)
        deleteLabel.anchor(left: deleteImageView.rightAnchor, paddingLeft: 10)
    }
    
}
