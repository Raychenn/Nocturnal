//
//  ProfileHeader.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol ProfileHeaderDelegate: AnyObject {
    func profileHeader(_ header: ProfileHeader, wantsToBlockUserWith id: String)
    func profileHeader(_ header: ProfileHeader, wantsToUnblockUserWith id: String)
}

class ProfileHeader: UICollectionReusableView {
    
    // MARK: - Propeties
    
    weak var delegate: ProfileHeaderDelegate?
        
     let profileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightBlue
        imageView.image = UIImage(named: "profileImage")
        return imageView
    }()
    
     lazy var blockUserButton: UIButton = {
       let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        button.setImage(UIImage(systemName: "eye", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapBackUser), for: .touchUpInside)
        return button
    }()
    
    var shouldBlockUser = false
    
    var user: User?
        
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
    
    // MARK: - Selector
    
    @objc func didTapBackUser() {
        guard let user = user else {
            print("no user in profile header")
            return
        }
        
        self.shouldBlockUser = !shouldBlockUser

//        blockUserButton.setImage( shouldBlockUser ? UIImage(systemName: "eye.slash"): UIImage(systemName: "eye"), for: .normal)
        
        if shouldBlockUser {
            delegate?.profileHeader(self, wantsToBlockUserWith: user.id ?? "")

        } else {
            delegate?.profileHeader(self, wantsToUnblockUserWith: user.id ?? "")
        }
    }
    
    // MARK: - Helpers
    
    func configureHeader(user: User) {
        if let profileUrl = URL(string: user.profileImageURL) {
            profileImageView.kf.setImage(with: profileUrl)
        } else {
            profileImageView.image = UIImage(named: "profileImage")
        }
        
        guard let currentUserId = Auth.auth().currentUser?.uid, let userId = user.id else {
            print("no current user id")
            return
        }
        
        blockUserButton.isHidden = currentUserId == userId ? true: false
        blockUserButton.setImage( shouldBlockUser ? UIImage(systemName: "eye.slash"): UIImage(systemName: "eye"), for: .normal)
        
    }

    func setupUI() {
        addSubview(profileImageView)
        profileImageView.fillSuperview()
        
        addSubview(blockUserButton)
        blockUserButton.anchor(bottom: bottomAnchor, right: rightAnchor, paddingBottom: 30, paddingRight: 30)
    }
}
