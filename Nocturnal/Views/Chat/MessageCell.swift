//
//  MessageCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/20.
//

import UIKit
import Kingfisher

class MessageCell: UICollectionViewCell {
    
    var message: Message? {
        didSet {
            guard let message = message else { return  }
            textView.text = message.text
        }
    }
    
     let profileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private let textView: UITextView = {
       let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 20)
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.textColor = .white
        textView.text = "Loading text...."
        return textView
    }()
    
     let bubbleContainer: UIView = {
       let view = UIView()
        view.backgroundColor = .purple
        
        return view
    }()
    
    var bubbleLeftAnchor: NSLayoutConstraint!
    var bubbleRightAnchor: NSLayoutConstraint!
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor, bottom: bottomAnchor, paddingLeft: 8, paddingBottom: -4)
        profileImageView.setDimensions(height: 36, width: 36)
        profileImageView.layer.cornerRadius = 36/2
        
        addSubview(bubbleContainer)
        bubbleContainer.layer.cornerRadius = 12
        bubbleContainer.anchor(top: topAnchor, bottom: bottomAnchor)
        bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true

        bubbleLeftAnchor = bubbleContainer.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12)
        bubbleLeftAnchor.isActive = false
        
        bubbleRightAnchor = bubbleContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -12)
        bubbleRightAnchor.isActive = false
        
        bubbleContainer.addSubview(textView)
        textView.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureFromCell(user: User) {
        guard let profileUrl = URL(string: user.profileImageURL) else { return }
        
        guard let message = message else { return }
        bubbleLeftAnchor.isActive = true
        bubbleRightAnchor.isActive = false
        bubbleContainer.backgroundColor = .purple
        profileImageView.isHidden = false
        profileImageView.kf.setImage(with: profileUrl)
        textView.text = message.text
    }
    
    func configureToCell() {
        guard let message = message else { return }
        bubbleLeftAnchor.isActive = false
        bubbleRightAnchor.isActive = true
        bubbleContainer.backgroundColor = .lightGray
        profileImageView.isHidden = true
        textView.text = message.text
    }
}
