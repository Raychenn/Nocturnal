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
    
    private var user: User
        
    // MARK: - Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    init(user: User) {
        self.user = user
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .init(top: 16, left: 0, bottom: 16, right: 0)
        super.init(collectionViewLayout: layout)
        addMessagesListener()
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
        MessegeService.shared.addMessagesListener(forUser: user) { result in
            switch result {
            case .success(let message):
                self.messages.append(message)
                self.collectionView.reloadData()
                self.collectionView.scrollToItem(at: [0, self.messages.count - 1], at: .bottom, animated: true)
            case .failure(let error):
                print("Fail to fetch messages \(error)")
            }
        }
    }
    // MARK: - Helpers
    
    private func setupUI() {
        IQKeyboardManager.shared.enable = false
        navigationItem.title = user.name
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: MessageCell.identifier)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
    }
//    func numberOfSections(in tableView: UITableView) -> Int {
//        textMessages.count
//    }

    // MARK: - CollectionView DataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("messages.count \(messages.count)")
       return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messageCell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageCell.identifier, for: indexPath) as? MessageCell else { return UICollectionViewCell() }
      
        let message = messages[indexPath.item]
        
        messageCell.message = message
        
        if message.fromId == uid {
            messageCell.configureToCell()
        } else {
            messageCell.configureFromCell()
        }
        return messageCell
    }
}

// MARK: - CollectionView UICollectionViewDelegateFlowLayout

extension ChatController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let estimatedSizeCell = MessageCell(frame: frame)
        estimatedSizeCell.message = messages[indexPath.row]
        estimatedSizeCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(targetSize)
        
        return .init(width: view.frame.width, height: estimatedSize.height)
    }
}

// MARK: - MessageInputAccessoryViewDelegate
extension ChatController: MessageInputAccessoryViewDelegate {
    
    func messageInputView(_ inputView: MessageInputAccessoryView, wantsToSend message: String) {
        messageInputView.clearCommentTextView()
        
        let isFromCurrentUser = user.id ?? "" == uid
        // send message to firestore
        let message = Message(toId: user.id ?? "", fromId: uid, text: message, user: user, sentTime: Timestamp(date: Date()), isFromCurrenUser: isFromCurrentUser)
        
        MessegeService.shared.uploadMessage(message, to: user) { error in
            if let error = error {
                print("Fail to send message \(error)")
                return
            }
            print("Successfully sending message")
        }
    }
}