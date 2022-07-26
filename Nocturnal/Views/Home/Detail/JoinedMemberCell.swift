//
//  JoinedMemberCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/7/15.
//

import UIKit
import Kingfisher

class JoinedMemberCell: UICollectionViewCell {
    
    private let profileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.setDimensions(height: 40, width: 40)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .lightGray
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.fillSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImageView.layer.cornerRadius = 40/2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(imageURLString: String) {
        if let url = URL(string: imageURLString) {
            profileImageView.kf.setImage(with: url)
        } else {
            profileImageView.image = UIImage(systemName: "person")
        }
    }
}
