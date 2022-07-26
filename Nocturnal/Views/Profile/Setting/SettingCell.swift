//
//  SettingCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/28.
//

import UIKit

class SettingCell: UITableViewCell {
    
    // MARK: - Properties
    
    private let symbolImageView: UIImageView = {
        let imageView = UIImageView()
         imageView.contentMode = .scaleAspectFill
         imageView.clipsToBounds = true
        imageView.tintColor = .lightGray
        imageView.setDimensions(height: 25, width: 25)
         return imageView
    }()
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        label.text = "Privacy policy"
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(title: String, symbolName: String) {
        titleLabel.text = title
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        symbolImageView.image = UIImage(systemName: symbolName, withConfiguration: config)
    }
    
    private func setupCellUI() {
        contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "#1C242F")
        
        addSubview(symbolImageView)
        symbolImageView.centerY(inView: self)
        symbolImageView.anchor(left: leftAnchor, paddingLeft: 10)
        
        addSubview(titleLabel)
        titleLabel.centerY(inView: symbolImageView)
        titleLabel.anchor(left: symbolImageView.rightAnchor, paddingLeft: 10)
    }
    
}
