//
//  ConversationCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/21.
//

import UIKit
import Kingfisher

class ConversationCell: UITableViewCell {
    
    // MARK: - Properties
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .darkGray
        label.text = "Loading time"
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .darkGray
        label.text = "Loading user name"
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.text = "Loading message"
        return label
    }()
    
    // MARK: - Life Cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    func setupCellUI() {
        
        addSubview(profileImageView)
        profileImageView.setDimensions(height: 50, width: 50)
        profileImageView.layer.cornerRadius = 50/2
        profileImageView.centerY(inView: self)
        profileImageView.anchor(left: leftAnchor, paddingLeft: 12)
        
        let vStack = UIStackView(arrangedSubviews: [usernameLabel, messageLabel])
        vStack.axis = .vertical
        vStack.spacing = 4
        addSubview(vStack)
        vStack.centerY(inView: profileImageView)
        vStack.anchor(left: profileImageView.rightAnchor, right: rightAnchor, paddingLeft: 12, paddingRight: 16)
        
        addSubview(timestampLabel)
        timestampLabel.anchor(top: topAnchor, right: rightAnchor, paddingTop: 20, paddingRight: 12)
    }
    
    func configureCell(conversation: Conversation) {
        if let profileURL = URL(string: conversation.user.profileImageURL) {
            profileImageView.kf.setImage(with: profileURL, placeholder: UIImage(systemName: "person.fill"))
        }
        
        timestampLabel.text = Date.dateTimeFormatter.string(from: conversation.message.sentTime.dateValue())
        usernameLabel.text = conversation.user.name
        messageLabel.text = conversation.message.text
    }
}
