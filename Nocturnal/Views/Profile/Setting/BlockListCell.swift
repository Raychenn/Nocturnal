//
//  BlockListCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/30.
//

import UIKit
import Kingfisher

class BlockListCell: UITableViewCell {

    // MARK: - Properties
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tintColor = .lightGray
        imageView.setDimensions(height: 60, width: 60)
         return imageView
    }()
    
    private let nameLabel: UILabel = {
       let label = UILabel()
        label.text = "Loading BlockedUser"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    // MARK: - Life Cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImageView.layer.cornerRadius = 60/2
    }
    
    // MARK: - Heleprs
    
    func configureCell(user: User) {
        guard let profileUrl = URL(string: user.profileImageURL) else {
            print("no profile Url")
            return
        }
        profileImageView.kf.setImage(with: profileUrl)
        nameLabel.text = user.name
    }
    
    func setupCellUI() {
        contentView.addSubview(profileImageView)
        profileImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10)
        
        contentView.addSubview(nameLabel)
        nameLabel.centerY(inView: profileImageView)
        nameLabel.anchor(left: profileImageView.rightAnchor, paddingLeft: 10)
    }
}
