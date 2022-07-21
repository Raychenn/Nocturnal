//
//  DetailDescriptionCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/16.
//

import UIKit
import Kingfisher
import CoreLocation
import Contacts
import MapKit
import FirebaseAuth

protocol DetailInfoCellDelegate: AnyObject {
    func playMusic(cell: DetailInfoCell, musicURL: String)
    func openChatRoom(cell: DetailInfoCell)
    func tappedHostProfile(cell: DetailInfoCell)
    func deleteEvent(cell: DetailInfoCell)
}

class DetailInfoCell: UITableViewCell {
    
    // MARK: - Properties
    weak var delegate: DetailInfoCellDelegate?
    
    var event: Event?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .medium)
        label.text = "The beginng's Guide to create Animated"
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    private let dateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "calendar")
        imageView.setDimensions(height: 20, width: 20)
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let dateLabel: UILabel = UILabel().makeBasicLabel()
    
    private let addressImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "mappin")
        imageView.setDimensions(height: 20, width: 20)
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let addressLabel: UILabel = UILabel().makeBasicLabel()
    
    private let styleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "scribble")
        imageView.setDimensions(height: 20, width: 20)
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let styleLabel: UILabel = UILabel().makeBasicLabel()
    
    private let feesImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "dollarsign.circle")
        imageView.setDimensions(height: 20, width: 20)
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let feeLabel: UILabel = UILabel().makeBasicLabel()
    
    private let playMusicImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "music.note")
        imageView.setDimensions(height: 20, width: 20)
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let playMusicLabel: UILabel = UILabel().makeBasicLabel()
    
    private lazy var hostProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.setDimensions(height: 50, width: 50)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapUserProfile))
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    
    private let hostNameLabel: UILabel = UILabel().makeBasicBoldLabel(fontSize: 17)
    
    private lazy var chatButton: UIButton = {
        let button = UIButton()
        button.setImage( UIImage(named: "messaging"), for: .normal)
        button.addTarget(self, action: #selector(didTapChatButton), for: .touchUpInside)
        return button
    }()
    
    private let joinedMembersImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "person")
        imageView.setDimensions(height: 20, width: 20)
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let musicLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = "Experience Music"
        return label
    }()
    
    private lazy var playMusicButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 140, weight: .bold, scale: .large)
        button.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: largeConfig), for: .normal)
        button.tintColor = .lightBlue
        button.addTarget(self, action: #selector(didPlayMusicButton), for: .touchUpInside)
        button.setDimensions(height: 50, width: 50)
        return button
    }()
    
    private lazy var deleteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapDeleteImageView))
        imageView.addGestureRecognizer(tap)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        imageView.image = UIImage(systemName: "ellipsis", withConfiguration: largeConfig)
        imageView.tintColor = .white
        imageView.setDimensions(height: 30, width: 30)
        return imageView
    }()
    
    private let whosComingLabel: UILabel = UILabel().makeBasicLabel(text: "Who's coming: ")
    
    private let emptyJoinedMembersLabel: UILabel = UILabel().makeBasicLabel(text: "No joined member yet")
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(JoinedMemberCell.self, forCellWithReuseIdentifier: JoinedMemberCell.id)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
        
    var joinedMemberProfileURLs: [String] = [] {
        didSet {
            self.presentJoinedMemberCollection(shouldShow: joinedMemberProfileURLs.count == 0)
        }
    }
    
    // MARK: - Life Cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCellUI()
    }
    
    override func layoutSubviews() {
         super.layoutSubviews()
         let bottomSpace: CGFloat = 15.0 // Let's assume the space you want is 10
         self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: bottomSpace, right: 0))
        hostProfileImageView.layer.cornerRadius = 50/2
        hostProfileImageView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func didPlayMusicButton() {
        guard let event = event else { return }
        delegate?.playMusic(cell: self, musicURL: event.eventMusicURL)
    }
    
    @objc func didTapUserProfile() {
        delegate?.tappedHostProfile(cell: self)
    }
    
    @objc func didTapChatButton() {
        delegate?.openChatRoom(cell: self)
    }
    
    @objc func didTapDeleteImageView() {
        delegate?.deleteEvent(cell: self)
    }
    
    // MARK: - Heleprs

    func configureCell(with event: Event, host: User, joinedMemberProfileURLs: [String]) {
        backgroundColor = .deepGray
        if let profileUrl = URL(string: host.profileImageURL) {
            self.hostProfileImageView.kf.setImage(with: profileUrl, placeholder: UIImage(systemName: "person"))
        } else {
            self.hostProfileImageView.image = UIImage(systemName: "person")
        }
        self.hostNameLabel.text = host.name
        self.event = event
        titleLabel.text = event.title
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        let formattedDateString = Date.dateTimeFormatter.string(from: event.startingDate.dateValue())
        dateLabel.text = "\(formattedDateString)"
        let location = CLLocation(latitude: event.destinationLocation.latitude, longitude: event.destinationLocation.longitude)
        configureAddressLabel(with: location)
        styleLabel.text = "Event Style: \(event.style)"
        feeLabel.text = "$\(String(event.fee))"
        chatButton.isHidden = uid == event.hostID
        deleteImageView.isHidden = uid != event.hostID
        self.joinedMemberProfileURLs = joinedMemberProfileURLs
    }
    
    private func configureAddressLabel(with location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location, preferredLocale: nil) { [weak self] (clPlacemark: [CLPlacemark]?, error: Error?) in
            guard let place = clPlacemark?.first else {
                print("No placemark from Apple: \(String(describing: error))")
                return
            }
            let mkPlacemark = MKPlacemark(placemark: place)
            self?.addressLabel.text = mkPlacemark.title ?? "no address"
        }
    }
    
    private func presentJoinedMemberCollection(shouldShow: Bool) {
        if shouldShow {
            emptyJoinedMembersLabel.isHidden = false
            collectionView.isHidden = true
        } else {
            emptyJoinedMembersLabel.isHidden = true
            collectionView.isHidden = false
            collectionView.reloadData()
        }
    }

    private func setupCellUI() {
        contentView.addSubview(titleLabel)
        titleLabel.anchor(top: contentView.topAnchor,
                          left: contentView.leftAnchor,
                          right: contentView.rightAnchor,
                          paddingTop: 10,
                          paddingLeft: 8,
                          paddingRight: 8)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        contentView.addSubview(deleteImageView)
        deleteImageView.anchor(top: contentView.topAnchor,
                            right: contentView.rightAnchor,
                            paddingTop: 10,
                            paddingRight: 10)
        
        let dateStack = UIStackView(arrangedSubviews: [dateImageView, dateLabel])
        dateStack.axis = .horizontal
        dateStack.spacing = 8
        
        let addressStack = UIStackView(arrangedSubviews: [addressImageView, addressLabel])
        addressStack.axis = .horizontal
        addressStack.spacing = 8
        addressStack.alignment = .center
        addressLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        
        let playMusicStack = UIStackView(arrangedSubviews: [playMusicImageView, playMusicLabel])
        playMusicStack.axis = .horizontal
        playMusicStack.spacing = 8
        playMusicStack.alignment = .center
        
        let styleStack = UIStackView(arrangedSubviews: [styleImageView, styleLabel])
        styleStack.axis = .horizontal
        styleStack.spacing = 8
        
        let feeStack = UIStackView(arrangedSubviews: [feesImageView, feeLabel])
        feeStack.axis = .horizontal
        feeStack.spacing = 8
        
        let parentVStack = UIStackView(arrangedSubviews: [dateStack,
                                                          styleStack,
                                                          feeStack,
                                                          addressStack,
                                                          playMusicStack
                                                          ])
        parentVStack.axis = .vertical
        parentVStack.spacing = 8
        parentVStack.distribution = .fillProportionally
        contentView.addSubview(parentVStack)
        parentVStack.anchor(top: titleLabel.bottomAnchor,
                            left: contentView.leftAnchor,
                            right: contentView.rightAnchor,
                            paddingTop: 10,
                            paddingLeft: 8,
                            paddingRight: 8)
        
        contentView.addSubview(whosComingLabel)
        whosComingLabel.anchor(top: parentVStack.bottomAnchor, left: contentView.leftAnchor, paddingTop: 25, paddingLeft: 10)
        
        contentView.addSubview(emptyJoinedMembersLabel)
        emptyJoinedMembersLabel.centerY(inView: whosComingLabel)
        emptyJoinedMembersLabel.anchor(left: whosComingLabel.rightAnchor, paddingLeft: 5)
        
        contentView.addSubview(collectionView)
        collectionView.centerY(inView: whosComingLabel)
        collectionView.anchor(left: whosComingLabel.rightAnchor, right: contentView.rightAnchor, paddingLeft: 10, paddingRight: 10, height: 40)
        
        contentView.addSubview(hostProfileImageView)
        hostProfileImageView.anchor(top: collectionView.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, paddingTop: 30, paddingLeft: 8, paddingBottom: 10)

        contentView.addSubview(hostNameLabel)
        hostNameLabel.centerY(inView: hostProfileImageView)
        hostNameLabel.anchor(left: hostProfileImageView.rightAnchor, paddingLeft: 10)

        contentView.addSubview(chatButton)
        chatButton.centerY(inView: hostNameLabel)
        chatButton.anchor(right: contentView.rightAnchor, paddingRight: 15)
        chatButton.setDimensions(height: 30, width: 30)

        contentView.addSubview(playMusicButton)
        playMusicButton.centerY(inView: playMusicStack)
        playMusicButton.anchor(right: contentView.rightAnchor, paddingRight: 15)
        playMusicButton.setDimensions(height: 33, width: 33)
    }
    
}
// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension DetailInfoCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return joinedMemberProfileURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let profileCell = collectionView.dequeueReusableCell(withReuseIdentifier: JoinedMemberCell.id, for: indexPath) as? JoinedMemberCell else {
            return UICollectionViewCell()
        }
        
        let profileImageURL = self.joinedMemberProfileURLs[indexPath.item]
        
        profileCell.configureCell(imageURLString: profileImageURL)
        
        return profileCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 40, height: 40)
    }
    
}
