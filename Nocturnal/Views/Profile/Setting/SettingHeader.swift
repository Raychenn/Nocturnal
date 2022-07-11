//
//  SettingHeader.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/29.
//

import UIKit
import Kingfisher

class SettingHeader: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    
    static let identifier = "SettingHeader"
    
    private let topBackgroundView: UIView = {
       let view = UIView()
        view.backgroundColor = .deepBlue
        return view
    }()
    
    private let bottomBackgroundView: UIView = {
        let view = UIView()
         view.backgroundColor = .black
         return view
     }()
    
    private let profileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private let nameLabel: UILabel = {
       let label = UILabel()
        label.text = "Loading Name"
        label.font = .systemFont(ofSize: 25, weight: .heavy)
        label.textColor = .white
        return label
    }()
    
    // MARK: - Life Cycle
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImageView.layer.cornerRadius = 70/2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configureHeader(user: User) {
        guard let profileUrl = URL(string: user.profileImageURL) else { return }
        profileImageView.kf.setImage(with: profileUrl)
        nameLabel.text = user.name
    }
    
    private func setupUI() {
        backgroundColor = UIColor.hexStringToUIColor(hex: "#1C242F")
        addSubview(topBackgroundView)
        topBackgroundView.anchor(top: topAnchor,
                                 left: leftAnchor,
                                 right: rightAnchor,
                                 height: 130)
        
        addSubview(bottomBackgroundView)
        bottomBackgroundView.anchor(top: topBackgroundView.bottomAnchor,
                                    left: leftAnchor,
                                    right: rightAnchor,
                                     height: 100)
        
        addSubview(profileImageView)
        profileImageView.setDimensions(height: 70, width: 70)
        profileImageView.centerYAnchor.constraint(equalTo: bottomBackgroundView.topAnchor).isActive = true
        profileImageView.anchor(left: leftAnchor, paddingLeft: 13)
        
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.bottomAnchor,
                         left: leftAnchor, paddingTop: 8, paddingLeft: 10)
    }

}
