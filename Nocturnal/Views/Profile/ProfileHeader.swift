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
    
    private let genderLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .lightBlue
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
    
    private let zodiaContentImageView: UIImageView = {
        let imageView = UIImageView()
         imageView.contentMode = .scaleAspectFill
         imageView.tintColor = .white
         imageView.setDimensions(height: 50, width: 50)
         return imageView
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
        label.textColor = .lightBlue
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
        let gender = Gender(rawValue: user.gender) ?? .male
        genderLabel.text = gender.description
        zodiaContentImageView.image = UIImage(named: calculateZodiac())?.withRenderingMode(.alwaysTemplate)
        ageTitleLabel.text = "\(calculateAge())"
    }
    
    func calculateAge() -> Int {
        guard let user = user else {
            print("user is nil")
            return 0
        }
        
        let calendar = Calendar(identifier: .gregorian)
        let birthday = user.birthday.dateValue()
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: Date())
        let age = ageComponents.year ?? 18
        return age
    }
    
    func calculateZodiac() -> String {
        guard let user = user else {
            print("user is nil")
            return ""
        }
        
        return getZodiacSign(user.birthday.dateValue())
    }
    
    func setupUI() {
        addSubview(profileImageView)
        profileImageView.fillSuperview()
        let topStack = UIStackView(arrangedSubviews: [genderLabel, zodiaContentImageView, ageTitleLabel])
        topStack.axis = .horizontal
        topStack.distribution = .equalCentering
        addSubview(topStack)
        
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
    }
}
