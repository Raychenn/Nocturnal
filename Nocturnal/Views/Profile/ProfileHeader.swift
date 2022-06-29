//
//  ProfileHeader.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/22.
//

import UIKit
import FirebaseFirestore

class ProfileHeader: UICollectionReusableView {
    
    // MARK: - Propeties
        
     let profileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
         imageView.clipsToBounds = true
        imageView.backgroundColor = .lightBlue
        imageView.image = UIImage(named: "profileImage")
        return imageView
    }()
        
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configureHeader(user: User) {
        guard let profileUrl = URL(string: user.profileImageURL) else { return }
        profileImageView.kf.setImage(with: profileUrl)
    }

    func setupUI() {
        addSubview(profileImageView)
        profileImageView.fillSuperview()
    }
}
