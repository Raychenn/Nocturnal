//
//  ProfileCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/22.
//

import UIKit
import FirebaseAuth

protocol ProfileCellDelegate: AnyObject {
    func didTapEditProfile(cell: ProfileCell)
    func didTapOpenConversation(cell: ProfileCell)
    func didTapSetting(cell: ProfileCell)
}

class ProfileCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    weak var delegate: ProfileCellDelegate?
    
    private let genderLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textColor = .lightGray
        label.text = "Gender: "
        return label
    }()
    
    private let genderImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "gender")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        imageView.setDimensions(height: 20, width: 20)
        return imageView
    }()
    
    private let zodiaContentImageView: UIImageView = {
        let imageView = UIImageView()
         imageView.contentMode = .scaleAspectFill
         imageView.tintColor = .white
         imageView.setDimensions(height: 18, width: 18)
         return imageView
    }()
    
    private let zodiacLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .lightGray
        label.text = "Zodiac Sign: "
        return label
    }()
    
    private let ageTitleLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .lightGray
        label.text = "Age: "
        return label
    }()
    
    private let ageContentLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .lightGray
        label.text = "15 years old"
        return label
    }()
    
    private let usernameLabel = UILabel().makeBasicSemiboldLabel(fontSize: 25, text: "Evie Sharon")
    
    private let countryTitleLabel: UILabel = {
        let label = UILabel()
         label.textColor = .lightGray
         label.font = .systemFont(ofSize: 18)
         label.text = "Country: "
         return label
     }()
    
    private let countryLabel: UILabel = {
       let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14)
        label.text = "Norway"
        return label
    }()
    
    private lazy var editProfileButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "editing")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var conversationButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "chat")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(didTapConversationButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton()
         let config = UIImage.SymbolConfiguration(pointSize: 30)
         button.setImage(UIImage(systemName: "gear", withConfiguration: config), for: .normal)
         button.tintColor = .black
         button.addTarget(self, action: #selector(didTapSettingsButton), for: .touchUpInside)
         return button
     }()
    
    var user: User?

    // MARK: - Life Cycle
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func didTapEditButton() {
        delegate?.didTapEditProfile(cell: self)
    }
    
    @objc func didTapConversationButton() {
        delegate?.didTapOpenConversation(cell: self)
    }
    
    @objc func didTapSettingsButton() {
        delegate?.didTapSetting(cell: self)
    }
   
    // MARK: - Helpers
    
    func configureCell(with user: User) {
        let gender = Gender(rawValue: user.gender) ?? .male
        genderImageView.image = UIImage(named: gender.getDescription)
        zodiaContentImageView.image = UIImage(named: calculateZodiac())?.withRenderingMode(.alwaysTemplate)
        ageContentLabel.text = "\(user.age) years old"
        usernameLabel.text = user.name
        let country = Country(rawValue: user.country) ?? .unspecified
        if country == .unspecified {
            let character: Character = "🌍"
            
            countryLabel.text = String(character)
        } else {
            let flag = flag(country: country.countryCode)
            countryLabel.text = flag
        }

        guard let currentUid = Auth.auth().currentUser?.uid else {
            print("current uid nil")
            return
        }
        
        settingsButton.isHidden = user.id ?? "" == currentUid ? false: true
        editProfileButton.isHidden = user.id ?? "" == currentUid ? false: true
        conversationButton.isHidden = user.id ?? "" == currentUid ? false: true
    }
    func setupCellUI() {
        backgroundColor = UIColor.darkGray
        layer.cornerRadius = 25
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        contentView.addSubview(conversationButton)
        conversationButton.anchor(top: contentView.topAnchor,
                                  right: contentView.rightAnchor,
                                  paddingTop: 20,
                                  paddingRight: 10)
        conversationButton.setDimensions(height: 25, width: 25)
        
        contentView.addSubview(editProfileButton)
        editProfileButton.centerY(inView: conversationButton)
        editProfileButton.anchor(right: conversationButton.leftAnchor, paddingRight: 12)
        editProfileButton.setDimensions(height: 25, width: 25)
            
        contentView.addSubview(settingsButton)
        settingsButton.centerY(inView: conversationButton)
        settingsButton.setDimensions(height: 30, width: 30)
        settingsButton.anchor(right: editProfileButton.leftAnchor, paddingRight: 12)
        
        let countryStack = UIStackView(arrangedSubviews: [countryTitleLabel, countryLabel])
        countryStack.axis = .horizontal
        countryStack.spacing = 5
        
        let genderStack = UIStackView(arrangedSubviews: [genderLabel, genderImageView])
        genderStack.axis = .horizontal
        genderStack.spacing = 5
        let zodiacStack = UIStackView(arrangedSubviews: [zodiacLabel, zodiaContentImageView])
        zodiacStack.axis = .horizontal
        zodiacStack.spacing = 5
        
        let ageStack = UIStackView(arrangedSubviews: [ageTitleLabel, ageContentLabel])
        ageStack.axis = .horizontal
        ageStack.spacing = 5
        
        [countryStack, genderStack, zodiacStack, ageStack].forEach({ contentView.addSubview($0) })
        
        contentView.addSubview(usernameLabel)
        usernameLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: settingsButton.leftAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 10)
        usernameLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        countryTitleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        zodiacLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        genderLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        countryStack.anchor(top: usernameLabel.bottomAnchor, left: usernameLabel.leftAnchor, paddingTop: 15)
        genderStack.anchor(top: countryStack.bottomAnchor,
                           left: usernameLabel.leftAnchor,
                           paddingTop: 5)
        zodiacStack.anchor(top: genderStack.bottomAnchor,
                           left: usernameLabel.leftAnchor,
                           paddingTop: 5)
        ageStack.anchor(top: zodiacStack.bottomAnchor,
                        left: usernameLabel.leftAnchor,
                        paddingTop: 5)
    }
    
    func calculateZodiac() -> String {
        guard let user = user else {
            print("user is nil")
            return ""
        }
        return getZodiacSign(user.birthday.dateValue())
    }
}
