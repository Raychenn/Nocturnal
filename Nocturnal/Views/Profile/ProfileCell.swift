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
}

class ProfileCell: UITableViewCell {
    
    weak var delegate: ProfileCellDelegate?
    
    private let usernameLabel = UILabel().makeBasicSemiboldLabel(fontSize: 25, text: "Evie Sharon")
    
    private let countryLabel: UILabel = {
       let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 35)
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
        collectionView.backgroundColor = .red
        collectionView.register(EventPhotosCell.self, forCellWithReuseIdentifier: EventPhotosCell.identifier)
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
    
    var joinedEvents: [Event] = []

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
   
    // MARK: - Helpers
    
    func configureCell(with user: User, joinedEventsURL: [String]) {
        usernameLabel.text = user.name
        let country = Country(rawValue: user.country.lowercased()) ?? .usa
        let flag = flag(country: country.countryCode)
        countryLabel.text = flag
    
        self.joinedEventsURL = joinedEventsURL
        
    }
    
    func setupCellUI() {
        collectionView.dataSource = self
        collectionView.delegate = self
        backgroundColor = UIColor.darkGray
        layer.cornerRadius = 25
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        contentView.addSubview(usernameLabel)
        usernameLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 20)
        
        contentView.addSubview(countryLabel)
        countryLabel.anchor(top: usernameLabel.bottomAnchor, left: contentView.leftAnchor, paddingTop: 8, paddingLeft: 25)
        
        contentView.addSubview(editProfileButton)
        editProfileButton.setDimensions(height: 40, width: 40)
        editProfileButton.centerY(inView: countryLabel)
        
        contentView.addSubview(conversationButton)
        conversationButton.centerY(inView: countryLabel)
        conversationButton.anchor(left: editProfileButton.rightAnchor, right: contentView.rightAnchor, paddingLeft: 12, paddingRight: 15)
        conversationButton.setDimensions(height: 50, width: 50)
        
        contentView.addSubview(joinedEventsTitleLabel)
        joinedEventsTitleLabel.anchor(top: countryLabel.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 10)
        
        contentView.addSubview(collectionView)
        collectionView.anchor(top: joinedEventsTitleLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 10, height: 150)
        
        contentView.addSubview(bioTitleLabel)
        bioTitleLabel.anchor(top: collectionView.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 10)
        
        contentView.addSubview(bioLabel)
        bioLabel.anchor(top: bioTitleLabel.bottomAnchor,
                        left: contentView.leftAnchor,
                        bottom: contentView.bottomAnchor,
                        right: contentView.rightAnchor,
                        paddingTop: 10,
                        paddingLeft: 10,
                        paddingBottom: 100,
                        paddingRight: 10)
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
