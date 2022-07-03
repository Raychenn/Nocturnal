//
//  ChatCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/20.
//

import UIKit

class ChatCell: UITableViewCell {

    let messageLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20)
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    let profileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "cat")
        return imageView
    }()
    
    let contentMessageView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    let senderImage: UIImage = {
        let image = UIImage(named: "chat_bubble_sent")!.withRenderingMode(.alwaysTemplate).resizableImage(withCapInsets: UIEdgeInsets(top: 20, left: 30, bottom: 20, right: 30))
        return image
    }()
    
    let receiverImage: UIImage = {
         let image = UIImage(named: "chat_bubble_received")!.withRenderingMode(.alwaysTemplate).resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 24, bottom: 22, right: 24))
        return image
    }()
    
    var bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var leadingConst = NSLayoutConstraint()

    var trailingConst = NSLayoutConstraint()
     
    var messageLabelWidthConst = NSLayoutConstraint()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        addSubview(profileImageView)
        addSubview(bubbleImageView)
        addSubview(contentMessageView)
        addSubview(messageLabel)
        
        contentMessageView.backgroundColor = .clear
        contentMessageView.layer.cornerRadius = 10
        contentMessageView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            profileImageView.widthAnchor.constraint(equalToConstant: 35),
            profileImageView.heightAnchor.constraint(equalToConstant: 35),
            
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
//            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            
            contentMessageView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: 13),
            contentMessageView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: 13),
            contentMessageView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: -13),
            contentMessageView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: -13),
            
            bubbleImageView.topAnchor.constraint(equalTo: contentMessageView.topAnchor),
            bubbleImageView.leadingAnchor.constraint(equalTo: contentMessageView.leadingAnchor),
            bubbleImageView.trailingAnchor.constraint(equalTo: contentMessageView.trailingAnchor),
            bubbleImageView.bottomAnchor.constraint(equalTo: contentMessageView.bottomAnchor)
        ])
        
        leadingConst = messageLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15)
        trailingConst = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        
        messageLabelWidthConst = messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250)
        messageLabelWidthConst.isActive = true
        
        leadingConst.isActive = true
        trailingConst.isActive = false
        
        profileImageView.layer.cornerRadius = 35/2
        profileImageView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
