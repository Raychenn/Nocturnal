//
//  ChatController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/20.
//

import UIKit
import FirebaseFirestore
import IQKeyboardManagerSwift

class ChatController: UICollectionViewController {

    // MARK: - Properties
    
    private lazy var messageInputView: MessageInputAccessoryView = {
        let view = MessageInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        view.delegate = self
        return view
    }()
    
    private lazy var messageInputContainerView: UIView = {
       let view = UIView()
        view.backgroundColor = .lightGray
        view.addSubview(inputTextField)
        inputTextField.fillSuperview()
        return view
    }()
    
    private let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter messages..."
        return textField
    }()
    
    private var chatMessages: [[Message]] = []
    
    private var messages: [Message] = []
    
    private var theOtherUserName: String
    
    private var chatRoom: ChatRoom
    
    private var theOtherUserId: String
    
    private var isFromCurrentUser = false
    
    private var theOtherUser: User?
        
    // MARK: - Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMessagesListener()
        setupUI()
    }
    
    init(theOtherUserName: String, chatRoom: ChatRoom, theOtherUserId: String) {
        self.theOtherUserName = theOtherUserName
        self.chatRoom = chatRoom
        self.theOtherUserId = theOtherUserId
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .init(top: 16, left: 0, bottom: 16, right: 0)
        super.init(collectionViewLayout: layout)
        fetchAllMessages()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var inputAccessoryView: UIView? {
        return messageInputView
    }
    
    override var canBecomeFirstResponder: Bool {
        true
    }
    
    // MARK: - API
    
    private func addMessagesListener() {
        ChatService.shared.addMessagesListener(chatRoomId: chatRoom.id ?? "") { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let messages):
                self.messages.append(messages)
                self.collectionView.insertItems(at: [IndexPath(item: self.messages.count - 1, section: 0)])
            case .failure(let error):
                print("Fail to fetch message \(error)")
            }
        }
    }
    
    private func fetchAllMessages() {
        ChatService.shared.fetchAllMessages(chatRoomId: chatRoom.id ?? "") { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let messages):
                print("Fetched messages \(messages)")
                self.messages = messages
                self.collectionView.reloadData()
            case .failure(let error):
                print("Fail to get messages \(error)")
            }
        }
    }
    
//    private func fetchSender() {
//        UserService.shared.fetchUser(uid: theOtherUserId) { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let theOtherUser):
//                print("theOtherUser \(theOtherUser)")
//                self.theOtherUser = theOtherUser
//                self.collectionView.reloadData()
//            case .failure(let error):
//                print("Fail to fetch user \(error)")
//            }
//        }
//    }
    
    // MARK: - Selectors
    
    @objc func handleDissmisal() {
        self.dismiss(animated: true)
    }
    
    // MARK: - Helpers
    
    private func setupUI() {
        IQKeyboardManager.shared.enable = false
        navigationItem.title = theOtherUserName
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: MessageCell.identifier)
        collectionView.alwaysBounceVertical = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "x.circle.fill"), style: .plain, target: self, action: #selector(handleDissmisal))
    }
//    func numberOfSections(in tableView: UITableView) -> Int {
//        textMessages.count
//    }

    // MARK: - CollectionView DataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messageCell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageCell.identifier, for: indexPath) as? MessageCell else { return UICollectionViewCell() }
        
//        guard let currentUser = currentUser, let theOtherUser = theOtherUser else {
//            return UICollectionViewCell()
//        }

        let message = messages[indexPath.item]
        
        if uid == message.senderId {
            // message right side (ourselves)
            messageCell.bubbleLeftAnchor.isActive = false
            messageCell.bubbleRightAnchor.isActive = true
            messageCell.bubbleContainer.backgroundColor = .lightGray
            messageCell.configureCell(message: message)
            messageCell.profileImageView.isHidden = true
            
        } else {
            // message left side
            messageCell.bubbleLeftAnchor.isActive = true
            messageCell.bubbleRightAnchor.isActive = false
            messageCell.bubbleContainer.backgroundColor = .purple
            messageCell.configureCell(message: message)
            messageCell.profileImageView.isHidden = false
        }
        
        return messageCell
    }
}

// MARK: - CollectionView UICollectionViewDelegateFlowLayout

extension ChatController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 50)
    }
}

// MARK: - MessageInputAccessoryViewDelegate
extension ChatController: MessageInputAccessoryViewDelegate {
    
    func messageInputView(_ inputView: MessageInputAccessoryView, wantsToSend message: String) {
        messageInputView.clearCommentTextView()
        
        // send message to firestore
        let message = Message(senderId: uid, content: message, sentTime: Timestamp(date: Date()))
        ChatService.shared.sendMessage(message: message, chatRoomId: chatRoom.id ?? "") { error in
            if let error = error {
                print("Fail to send message \(error)")
                return
            }
            
            print("Success sending message")
        }
    }
}
