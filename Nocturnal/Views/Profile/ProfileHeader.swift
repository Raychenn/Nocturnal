//
//  ProfileHeader.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/22.
//

import UIKit
import FirebaseFirestore

class ProfileHeader: UITableViewHeaderFooterView {
    
    // MARK: - Propeties
    
    static let identifier = "ProfileHeader"
    
     let profileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightBlue
        imageView.image = UIImage(named: "profileImage")
        return imageView
    }()
    
    var user: User?
    
    // MARK: - Life Cycle
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
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
