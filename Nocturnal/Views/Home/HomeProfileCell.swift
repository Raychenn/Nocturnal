//
//  HomeProfileCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/7/16.
//

import UIKit
import Kingfisher

class HomeProfileCell: UICollectionViewCell {
    
    private let nameLabel: UILabel = {
        let label = UILabel()
         label.text = "Loading Name"
         label.textColor = .white
         label.font = .satisfyRegular(size: 25)
        return label
    }()
    
    private let profileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lightGray
        imageView.tintColor = .black
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(nameLabel)
        nameLabel.anchor(top: topAnchor, left: leftAnchor,
                         paddingTop: 8, paddingLeft: 20)
        
        contentView.addSubview(profileImageView)
        profileImageView.centerY(inView: contentView)
        profileImageView.anchor(right: contentView.rightAnchor, paddingRight: 20)
        profileImageView.setDimensions(height: 60, width: 60)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImageView.layer.cornerRadius = 60/2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(user: User) {
        self.nameLabel.text = user.name
        
        if let profileURL = URL(string: user.profileImageURL) {
            self.profileImageView.kf.setImage(with: profileURL)
        } else {
            self.profileImageView.image = UIImage(systemName: "person")
        }
    }
}
