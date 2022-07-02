//
//  MessageCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/20.
//

import UIKit
import Kingfisher

protocol MessageCellDelegate: AnyObject {
    func performZoomInForStartingImageMessage(startingImageView: UIImageView)
}

class MessageCell: UICollectionViewCell {
    
    weak var delegate: MessageCellDelegate?
    
    var message: Message? {
        didSet {
            guard let message = message else { return  }
            textView.text = message.text
            
            if let messageUrlString = message.imageUrl, let messageUrl = URL(string: messageUrlString) {
                messageImageView.isHidden = false
                messageImageView.kf.setImage(with: messageUrl)
                bubbleContainer.backgroundColor = .clear
            } else {
                messageImageView.isHidden = true
            }
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
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
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleZoomin))
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    
    let bubbleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .purple
        
        return view
    }()
    
    var bubbleLeftAnchor: NSLayoutConstraint!
    var bubbleRightAnchor: NSLayoutConstraint!
    var bubbleContainerWidthConst = NSLayoutConstraint()
    
    // MARK: - Selector
    
    @objc func handleZoomin(tapGesture: UITapGestureRecognizer) {
        if let imageView = tapGesture.view as? UIImageView {
            delegate?.performZoomInForStartingImageMessage(startingImageView: imageView)
        } else {
            print("Can not get image view from gesture")
        }
    }
    
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
        //        bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        bubbleContainerWidthConst = bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250)
        bubbleContainerWidthConst.isActive = true
        
        bubbleLeftAnchor = bubbleContainer.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12)
        bubbleLeftAnchor.isActive = false
        
        bubbleRightAnchor = bubbleContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -12)
        bubbleRightAnchor.isActive = false
        
        bubbleContainer.addSubview(textView)
        textView.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)
        
        bubbleContainer.addSubview(messageImageView)
        messageImageView.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureFromCell(user: User) {
        guard let profileUrl = URL(string: user.profileImageURL) else { return }
        
        bubbleContainer.backgroundColor = .purple
        bubbleLeftAnchor.isActive = true
        bubbleRightAnchor.isActive = false
        profileImageView.isHidden = false
        profileImageView.kf.setImage(with: profileUrl)
    }
    
    func configureToCell() {
        //        guard let message = message else { return }
        bubbleContainer.backgroundColor = .lightGray
        bubbleLeftAnchor.isActive = false
        bubbleRightAnchor.isActive = true
        profileImageView.isHidden = true
    }
}
