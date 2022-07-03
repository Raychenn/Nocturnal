//
//  NotificationCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/18.
//

import UIKit
import Kingfisher

protocol NotificationCellDelegate: AnyObject {
    func cell(_ cell: NotificationCell, wantsToAccept uid: String)
    func cell(_ cell: NotificationCell, wantsToDeny uid: String)
}

class NotificationCell: UITableViewCell {
    
    // MARK: - Properties
    weak var delegate: NotificationCellDelegate?
    
    private lazy var profileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .lightGray
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImageView))
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    
    private lazy var eventImageView: UIImageView = {
        let imageView = UIImageView()
         imageView.contentMode = .scaleAspectFill
         imageView.isUserInteractionEnabled = true
         imageView.backgroundColor = .lightGray
         let tap = UITapGestureRecognizer(target: self, action: #selector(didTapEventImageView))
         imageView.addGestureRecognizer(tap)
         return imageView
     }()
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .heavy)
        label.textColor = .deepBlue
        label.numberOfLines = 0
        label.attributedText(firstPart: "User name", secondPart: "loading description messages")
        return label
    }()
    
    private let timeLabel: UILabel = {
       let label = UILabel()
        label.text = "loading time"
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.textColor = .white
        
        return label
    }()
    
    private lazy var permissionButton: UIButton = {
       let button = UIButton()
        button.setTitle("Accept", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = .deepBlue
        button.addTarget(self, action: #selector(didTapPermissionButton), for: .touchUpInside)
        return button
    }()
    
    var notification: Notification?
        
    var applicantId: String?
    // MARK: - Life Cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
//        permissionButton.setTitle(nil, for: .normal)
//        permissionButton.removeTarget(nil, action: nil, for: .allEvents)
    }
    
    // MARK: - Selector
    
    @objc func didTapEventImageView() {
        print("didTapEventImageView")
    }
    
    @objc func didTapProfileImageView() {
        print("didTapProfileImageView")
    }
    
    @objc func didTapPermissionButton() {
        
        guard let applicantId = applicantId else {
            print("applicantId nil")
            return
        }
    
        guard var notification = notification else {
            print("notification nil")
            return
        }
        
        notification.isRequestPermitted = !notification.isRequestPermitted
        self.notification?.isRequestPermitted = notification.isRequestPermitted
        
        print("notification isRequestPermitted \(notification.isRequestPermitted)")
        
        permissionButton.setTitle(notification.isRequestPermitted ? "Deny": "Accept", for: .normal)
        permissionButton.backgroundColor = notification.isRequestPermitted ? .red: .deepBlue
        if notification.isRequestPermitted {
            delegate?.cell(self, wantsToAccept: applicantId)
        } else {
            delegate?.cell(self, wantsToDeny: applicantId)
        }
    }
    
    // MARK: - Herpers
    func configueCell(with notification: Notification, user: User, event: Event) {
        self.notification = notification
        guard let type = NotificationType(rawValue: notification.type) else { return }
        
        if type == .failureJoinedEventResponse || type == .successJoinedEventResponse {
            permissionButton.isHidden = true
            eventImageView.isHidden = false
            titleLabel.attributedText(firstPart: user.name, secondPart: "\(type.description)")
        } else {
            permissionButton.isHidden = false
            eventImageView.isHidden = false
        }
        permissionButton.setTitle(notification.isRequestPermitted ? "Deny": "Accept", for: .normal)
        permissionButton.backgroundColor = notification.isRequestPermitted ? .red: .deepBlue
        if type == .joinEventRequest {
            eventImageView.isHidden = true
            titleLabel.attributedText(firstPart: user.name, secondPart: " \(type.description) to join \(event.title)")
        }
        
        timeLabel.text = "\(Date.dateTimeFormatter.string(from: notification.sentTime.dateValue()))"
        guard let profileUrl = URL(string: user.profileImageURL), let eventUrl = URL(string: event.eventImageURL) else {
            print("no profileImageURL")
            return
        }
        
        profileImageView.kf.setImage(with: profileUrl)
        eventImageView.kf.setImage(with: eventUrl)
    }
    
    private func setupCellUI() {
        // add shadow on cell
        backgroundColor = .clear
        layer.masksToBounds = false
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowColor = UIColor.white.cgColor
        contentView.backgroundColor = .black
        contentView.layer.cornerRadius = 8
        
        [profileImageView,
         eventImageView,
         titleLabel,
         timeLabel,
         permissionButton].forEach({contentView.addSubview($0)})
        
        profileImageView.setDimensions(height: 48, width: 48)
        profileImageView.layer.cornerRadius = 48/2
        profileImageView.layer.masksToBounds = true
        profileImageView.anchor(top: contentView.topAnchor,
                                left: contentView.leftAnchor,
                                paddingTop: 8, paddingLeft: 8)
        
        eventImageView.setDimensions(height: 48, width: 48)
        eventImageView.centerY(inView: self)
        eventImageView.anchor(right: contentView.rightAnchor, paddingRight: 16)
        
        titleLabel.anchor(top: contentView.topAnchor,
                          left: profileImageView.rightAnchor,
                          right: permissionButton.leftAnchor,
                          paddingTop: 8,
                          paddingLeft: 8,
                          paddingRight: 16)

        timeLabel.anchor(top: titleLabel.bottomAnchor,
                         left: profileImageView.rightAnchor,
                         bottom: contentView.bottomAnchor,
                         paddingTop: 8, paddingLeft: 8, paddingBottom: 8)
        
        permissionButton.centerY(inView: profileImageView)
        permissionButton.setDimensions(height: 32, width: 88)
        permissionButton.anchor(right: contentView.rightAnchor, paddingRight: 8)
    }
}
