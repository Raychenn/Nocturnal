//
//  ProfileCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/22.
//

import UIKit

protocol ProfileCellDelegate: AnyObject {
    func didTapEditProfile(cell: ProfileCell)
    func didTapOpenConversation(cell: ProfileCell)
    func didTapSelectedEvent(cell: ProfileCell, event: Event)
    func didTapSetting(cell: ProfileCell)
}

class ProfileCell: UITableViewCell {
    
    // MARK: - Properties
    
    weak var delegate: ProfileCellDelegate?
    
    private let genderLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .lightGray
        label.text = "Gender"
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
         imageView.setDimensions(height: 15, width: 15)
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
    
    private let joinedEventsTitleLabel = UILabel().makeBasicSemiboldLabel(fontSize: 22, text: "Joined Events")
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 30
    
        layout.sectionInset = .init(top: 0, left: 10, bottom: 0, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EventPhotosCell.self, forCellWithReuseIdentifier: EventPhotosCell.identifier)
        collectionView.backgroundColor = .darkGray
        return collectionView
    }()
    
    private let bioTitleLabel = UILabel().makeBasicSemiboldLabel(fontSize: 22, text: "Bio")
    
    private let bioLabel: UILabel = {
       let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.text = "This is my personal bio description This is my personal bio descriptionThis is my personal bio descriptionThis is my personal bio descriptionThis"
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
         button.setImage(UIImage(named: "settings")?.withRenderingMode(.alwaysTemplate), for: .normal)
         button.tintColor = .black
         button.addTarget(self, action: #selector(didTapSettingsButton), for: .touchUpInside)
         return button
     }()
    
    let collectionViewStack = UIStackView()
    
    private var joinedEventsURL: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var user: User? {
        didSet {
            fetchEvents()
        }
    }
    
    var joinedEvents: [Event] = [] {
        didSet {
            print("joinedEvents.count \(joinedEvents.count)")
            if joinedEvents.count == 0 {
                collectionViewStack.removeArrangedSubview(collectionView)
                collectionViewStack.isHidden = true
               
            } else {
                collectionViewStack.addArrangedSubview(collectionView)
                collectionViewStack.isHidden = false
       
            }
        }
    }

    // MARK: - Life Cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - API
    
    private func fetchEvents() {
        guard let user = user else { return }
        
        EventService.shared.fetchEvents(fromEventIds: user.joinedEventsId) { result in
            switch result {
            case .success(let events):
                self.joinedEvents = events
            case .failure(let error):
                print("Fail to fetch events \(error)")
            }
        }
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
    
    func configureCell(with user: User, joinedEventsURL: [String]) {
        let gender = Gender(rawValue: user.gender) ?? .male
        genderLabel.text = "Gender"
        print("gender descrip \(gender.description)")
        genderImageView.image = UIImage(named: "Male")
        zodiaContentImageView.image = UIImage(named: calculateZodiac())?.withRenderingMode(.alwaysTemplate)
        ageContentLabel.text = "\(calculateAge()) years old"
        usernameLabel.text = user.name
        print(user.country)
        let country = Country(rawValue: user.country) ?? .unspecified
        if country == .unspecified {
            let character: Character = "🌍"
            
            countryLabel.text = String(character)
        } else {
            let flag = flag(country: country.countryCode)
            countryLabel.text = flag
        }

        self.joinedEventsURL = joinedEventsURL
    }
    
    func setupCellUI() {
        collectionView.dataSource = self
        collectionView.delegate = self
        backgroundColor = UIColor.darkGray
        layer.cornerRadius = 25
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
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
        usernameLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 20)
        
        countryStack.anchor(top: usernameLabel.bottomAnchor,
                            left: usernameLabel.leftAnchor,
                            paddingTop: 5)
        
        genderStack.anchor(top: countryStack.bottomAnchor,
                           left: usernameLabel.leftAnchor,
                           paddingTop: 5)
        
        zodiacStack.anchor(top: genderStack.bottomAnchor,
                           left: usernameLabel.leftAnchor,
                           paddingTop: 5)
        
        ageStack.anchor(top: zodiacStack.bottomAnchor,
                        left: usernameLabel.leftAnchor,
                        paddingTop: 5)
        
        contentView.addSubview(editProfileButton)
        editProfileButton.setDimensions(height: 25, width: 25)
        editProfileButton.centerY(inView: usernameLabel)
        
        contentView.addSubview(conversationButton)
        conversationButton.centerY(inView: usernameLabel)
        conversationButton.anchor(left: editProfileButton.rightAnchor, right: contentView.rightAnchor, paddingLeft: 12, paddingRight: 15)
        conversationButton.setDimensions(height: 25, width: 25)
        
        contentView.addSubview(settingsButton)
        settingsButton.centerY(inView: usernameLabel)
        settingsButton.setDimensions(height: 25, width: 25)
        settingsButton.anchor(right: editProfileButton.leftAnchor, paddingRight: 12)
        
        contentView.addSubview(bioTitleLabel)
        bioTitleLabel.anchor(top: ageStack.bottomAnchor, left: usernameLabel.leftAnchor, paddingTop: 10)

        contentView.addSubview(bioLabel)
        bioLabel.anchor(top: bioTitleLabel.bottomAnchor,
                        left: usernameLabel.leftAnchor,
                        right: contentView.rightAnchor,
                        paddingTop: 10,
                        paddingRight: 10)

        contentView.addSubview(joinedEventsTitleLabel)
        joinedEventsTitleLabel.anchor(top: bioLabel.bottomAnchor, left: contentView.leftAnchor, paddingTop: 10, paddingLeft: 10)

        collectionViewStack.addArrangedSubview(collectionView)
        contentView.addSubview(collectionViewStack)
        collectionViewStack.anchor(top: joinedEventsTitleLabel.bottomAnchor, left: usernameLabel.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 10)
        
//        contentView.addSubview(collectionView)
//        collectionView.anchor(top: joinedEventsTitleLabel.bottomAnchor, left: usernameLabel.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingBottom: 10, height: 150)
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
}
// MARK: - UICollectionViewDataSource
extension ProfileCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return joinedEventsURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: EventPhotosCell.identifier, for: indexPath) as? EventPhotosCell else { return UICollectionViewCell() }
        
        let eventImageURL = joinedEventsURL[indexPath.item]
        photoCell.configurePhotoCell(imageURL: eventImageURL)
        
        return photoCell
    }
    
}
// MARK: - UICollectionViewDelegate
extension ProfileCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedEvent = joinedEvents[indexPath.item]
        delegate?.didTapSelectedEvent(cell: self, event: selectedEvent)
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension ProfileCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size.height * 0.8
        return CGSize(width: size, height: size)
    }
}
