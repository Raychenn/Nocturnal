//
//  ProfileHeader.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/22.
//

import UIKit

class ProfileHeader: UITableViewHeaderFooterView {
    
    static let identifier = "ProfileHeader"
    
    private let profileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightBlue
        imageView.image = UIImage(named: "profileImage")
        return imageView
    }()
    
    private let genderLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.text = "Male"
        return label
    }()
    
    private let genderImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "gender")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        imageView.setDimensions(height: 50, width: 50)
        return imageView
    }()
    
    private let zodiacLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.text = "Scorpion"
        return label
    }()
    
    private let zodiacImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "zodiac")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        imageView.setDimensions(height: 50, width: 50)
        return imageView
    }()
    
    private let ageTitleLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.text = "27"
        return label
    }()
    
    private let ageImageView: UIImageView = {
        let imageView = UIImageView()
         imageView.contentMode = .scaleAspectFill
         imageView.image = UIImage(named: "age")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
         imageView.setDimensions(height: 50, width: 50)
         return imageView
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(profileImageView)
        profileImageView.fillSuperview()
        let topStack = UIStackView(arrangedSubviews: [genderLabel, zodiacLabel, ageTitleLabel])
        topStack.axis = .horizontal
        topStack.distribution = .equalCentering
        profileImageView.addSubview(topStack)
        
        topStack.anchor(left: profileImageView.leftAnchor, right: profileImageView.rightAnchor, paddingLeft: 25, paddingRight: 35)
        
        let bottomStack = UIStackView(arrangedSubviews: [genderImageView, zodiacImageView, ageImageView])
        bottomStack.axis = .horizontal
        bottomStack.distribution = .equalCentering
        addSubview(bottomStack)
        bottomStack.anchor(top: topStack.bottomAnchor,
                           left: profileImageView.leftAnchor,
                           bottom: profileImageView.bottomAnchor,
                           right: profileImageView.rightAnchor,
                           paddingTop: 8,
                           paddingLeft: 25, paddingBottom: 30, paddingRight: 25)
        
        let gradientView = UIView()
        gradientView.frame = self.frame
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.darkGray.cgColor, UIColor.black.cgColor]
        gradient.locations = [0, 1]
        gradientView.layer.addSublayer(gradient)
        self.insertSubview(gradientView, aboveSubview: profileImageView)
    }
}
