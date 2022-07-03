//
//  EditProfileHeader.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/23.
//

import UIKit
import Kingfisher

protocol EditProfileHeaderDelegate: AnyObject {
    func updateProfileImage(header: EditProfileHeader)
}

class EditProfileHeader: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    
    static let identifier = "EditProfileHeader"
    
    weak var delegate: EditProfileHeaderDelegate?
    
     lazy var profileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
         imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "profileImage")
        return imageView
    }()
    
    private lazy var editProfileButton: UIButton = {
       let button = UIButton()
        button.setTitle("Edit my picture", for: .normal)
        button.setTitleColor(.lightBlue, for: .normal)
        button.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life Cycle
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(profileImageView)
        profileImageView.fillSuperview()
        contentView.addSubview(editProfileButton)
        editProfileButton.centerX(inView: self)
        editProfileButton.anchor(bottom: bottomAnchor, paddingBottom: 10)
        editProfileButton.setDimensions(height: 50, width: 200)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selector
    
    @objc func didTapEditButton() {
        delegate?.updateProfileImage(header: self)
    }
    
    // MARK: - Helpers
    
     func configureHeader(imageURL: String) {
        guard let url = URL(string: imageURL) else { return }
        
        profileImageView.kf.setImage(with: url)
    }
}
