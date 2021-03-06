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
    
    private let dateLabel: UILabel = {
        let label = UILabel()
//        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .lightGray
        label.text = "Jun 4 . 7:00 PM"
        return label
    }()
    
    private let addressImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "mappin")
        imageView.setDimensions(height: 20, width: 20)
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .lightGray
//        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = "Loading Address"
        return label
    }()
    
    private let styleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "scribble")
        imageView.setDimensions(height: 20, width: 20)
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let styleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
//        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = "Event Style: Loading"
        return label
    }()
    
    private let feesImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "dollarsign.circle")
        imageView.setDimensions(height: 20, width: 20)
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let feeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
//        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = "$15.50"
        return label
    }()
    
    private lazy var hostProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.setDimensions(height: 50, width: 50)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapUserProfile))
        imageView.addGestureRecognizer(tap)
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private let hostNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.text = "Host: Ray Chen"
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var chatButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        button.setImage( UIImage(systemName: "message.fill", withConfiguration: config), for: .normal)
        button.tintColor = .lightGray
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
    
    private let joinedMembersLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = "Joined Members: 7"
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var viewAllMemberButton: UIButton = {
        let button = UIButton()
        button.setTitle("View All", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .clear
        button.layer.borderColor = UIColor.deepBlue.cgColor
        button.layer.borderWidth = 1.3
        button.addTarget(self, action: #selector(didTapViewAllButton), for: .touchUpInside)
        
        return button
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
    
    @objc func didTapViewAllButton() {
        print("view all")
    }
    
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

    func configureCell(with event: Event, host: User) {
        backgroundColor = UIColor.hexStringToUIColor(hex: "#161616")
        self.hostProfileImageView.kf.setImage(with: URL(string: host.profileImageURL)!)
        self.hostNameLabel.text = host.name
        self.event = event
        titleLabel.text = event.title
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        let formattedDateString = Date.dateTimeFormatter.string(from: event.startingDate.dateValue())
        dateLabel.text = "\(formattedDateString)"
        let location = CLLocation(latitude: event.destinationLocation.latitude, longitude: event.destinationLocation.longitude)
        CLGeocoder().reverseGeocodeLocation(location, preferredLocale: nil) { [weak self] (clPlacemark: [CLPlacemark]?, error: Error?) in
            guard let place = clPlacemark?.first else {
                print("No placemark from Apple: \(String(describing: error))")
                return
            }
            
            let mkPlacemark = MKPlacemark(placemark: place)
            
            self?.addressLabel.text = mkPlacemark.title ?? "no address"
        }
        
        styleLabel.text = "Event Style: \(event.style)"
        feeLabel.text = "$\(String(event.fee))"
        joinedMembersLabel.text = "Joined Members: \(event.participants.count)"
        guard let uid = Auth.auth().currentUser?.uid else {
            print("uid in nil")
            return
        }
        chatButton.isHidden = uid == event.hostID
        deleteImageView.isHidden = uid != event.hostID
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
        
        let styleStack = UIStackView(arrangedSubviews: [styleImageView, styleLabel])
        styleStack.axis = .horizontal
        styleStack.spacing = 8
        
        let feeStack = UIStackView(arrangedSubviews: [feesImageView, feeLabel])
        feeStack.axis = .horizontal
        feeStack.spacing = 8
        
        let joinedMemberStack = UIStackView(arrangedSubviews: [joinedMembersImageView, joinedMembersLabel])
        joinedMemberStack.axis = .horizontal
        joinedMemberStack.spacing = 8
        
        let parentVStack = UIStackView(arrangedSubviews: [dateStack,
                                                          styleStack,
                                                          feeStack,
                                                          joinedMemberStack,
                                                          addressStack
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
        
        contentView.addSubview(hostProfileImageView)
        hostProfileImageView.anchor(top: parentVStack.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, paddingTop: 30, paddingLeft: 8, paddingBottom: 10)

        contentView.addSubview(hostNameLabel)
        hostNameLabel.centerY(inView: hostProfileImageView)
        hostNameLabel.anchor(left: hostProfileImageView.rightAnchor, paddingLeft: 25)

        contentView.addSubview(chatButton)
        chatButton.anchor(top: parentVStack.bottomAnchor, left: hostProfileImageView.rightAnchor, paddingTop: 8, paddingLeft: 2)

        contentView.addSubview(playMusicButton)
        playMusicButton.centerY(inView: hostProfileImageView)
        playMusicButton.anchor(right: contentView.rightAnchor, paddingRight: 8)
    }
    
}
