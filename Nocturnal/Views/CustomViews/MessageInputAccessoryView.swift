//
//  MessageInputView.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/20.
//

import UIKit

protocol MessageInputAccessoryViewDelegate: AnyObject {
    func messageInputView(_ inputView: MessageInputAccessoryView, wantsToSend message: String)
}

class MessageInputAccessoryView: UIView {
    
    // MARK: - properties
    weak var delegate: MessageInputAccessoryViewDelegate?
    
    private var messageTextView: InputTextView = {
       let textView = InputTextView()
        textView.placeholderText = "enter text ..."
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.placeholderShouldCenter = true
        return textView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle( "Send", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleSendButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.shadowOpacity = 0.25
        layer.shadowOffset = .init(width: 0, height: -8)
        layer.shadowColor = UIColor.lightGray.cgColor
        
        backgroundColor = .white
        autoresizingMask = .flexibleHeight
        
        addSubview(sendButton)
        sendButton.anchor(top: topAnchor, right: rightAnchor, paddingTop: 4, paddingRight: 8)
        sendButton.setDimensions(height: 40, width: 50)
        
        addSubview(messageTextView)
        messageTextView.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 12, paddingLeft: 4, paddingBottom: 8, paddingRight: 8)
        
        let divider = UIView()
        addSubview(divider)
        divider.backgroundColor = .lightGray
        divider.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Action
    
    @objc func handleSendButtonTapped() {
        guard let messageTexts = messageTextView.text, messageTexts != "" else { return }
        
        delegate?.messageInputView(self, wantsToSend: messageTexts)
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    func clearCommentTextView() {
        messageTextView.text = nil
        messageTextView.placeholderLabel.isHidden = false
    }
}
