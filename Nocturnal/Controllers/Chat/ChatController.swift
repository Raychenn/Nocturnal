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
    
    private var startingFrame: CGRect?
    
    private var blackBackgroundView: UIView?
    
    private var startingImageView: UIImageView?
    
    private var chatMessages: [[Message]] = []
    
    private var messages: [Message] = [] {
        didSet {
            if messages.count == 0 {
                return
            }
        }
    }
    
    private var user: User
    
    private var chatPartner: User?
        
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
        
        self.addMessagesListener()
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
        self.presentLoadingView(shouldPresent: true)
        MessegeService.shared.addMessagesListener(forUser: user) { result in
            switch result {
            case .success(let message):
                self.messages.append(message)
                self.collectionView.reloadData()
                self.collectionView.scrollToItem(at: [0, self.messages.count - 1], at: .bottom, animated: true)
            case .failure(let error):
                self.presentErrorAlert(message: "\(error.localizedDescription)")
                self.presentLoadingView(shouldPresent: false)
                print("Fail to fetch messages \(error)")
            }
        }
    }
    
    private func fetchAllMessages(completion: @escaping () -> Void) {
        MessegeService.shared.fetchAllMessages(forUser: user) { result in
            switch result {
            case .success(let messages):
                self.messages = messages
                self.groupMessagesBasedOnDates()
                self.collectionView.reloadData()
                completion()
            case .failure(let error):
                print("Fail to fetch messaes \(error)")
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
    
    private func groupMessagesBasedOnDates() {
        let groupMessages = Dictionary(grouping: messages, by: { element in
            return element.sentTime.dateValue()
        })
                
        let sortedKeys = groupMessages.keys.sorted()
        
        sortedKeys.forEach { key in
            let values = groupMessages[key]
            chatMessages.append(values ?? [])
        }
    }

    private func estimatedFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesLineFragmentOrigin
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)], context: nil)
    }
    
    // MARK: - Selectors
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        
        if let zoomOutImageView = tapGesture.view, let startingFrame = self.startingFrame {
            // prevent the abrupt corner radius chagnes when zooming back in
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
                zoomOutImageView.frame = startingFrame
                self.blackBackgroundView?.alpha = 0
                self.inputAccessoryView?.alpha = 1
            } completion: { _ in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            }
        }
    }

    // MARK: - CollectionView DataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messageCell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageCell.identifier, for: indexPath) as? MessageCell else { return UICollectionViewCell() }
        messageCell.delegate = self
        
        let message = messages[indexPath.item]
        
        if let text = message.text {
            messageCell.bubbleContainerWidthConst.constant = estimatedFrameForText(text: text).width + 40
        } else if message.imageUrl != nil {
            // fall in here if it is a image message
            messageCell.bubbleContainerWidthConst.constant = 200
        }
       
        if message.fromId == uid {
            messageCell.configureToCell()
        } else {
            messageCell.configureFromCell(user: user)
        }
        
        messageCell.message = message
        
        return messageCell
    }
}

// MARK: - CollectionView UICollectionViewDelegateFlowLayout

extension ChatController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let message = messages[indexPath.row]
        
        var estimatedHeight: CGFloat = 80
        
        if let text = message.text {
            estimatedHeight = estimatedFrameForText(text: text).height + 25
        } else if let imageWidth = message.imageWidth, let imageHeight = message.imageHeight {
            // determine estimated height for image message bubble container
            
            // h1 / w1 = h2 / w2
            // solve for h1
            // h1 = h2 / w2 * w1
            estimatedHeight = CGFloat(imageHeight / imageWidth * 200)
//            estimatedHeight = 120
        }
                
        return .init(width: view.frame.width, height: estimatedHeight)
    }
}

// MARK: - MessageInputAccessoryViewDelegate
extension ChatController: MessageInputAccessoryViewDelegate {
    
    func handleSentImage(_ inputView: MessageInputAccessoryView) {
        print("did tap handleSentImage")
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    func messageInputView(_ inputView: MessageInputAccessoryView, wantsToSend message: String) {
        messageInputView.clearCommentTextView()
        
        let isFromCurrentUser = user.id ?? "" == uid
        // send message to firestore
        let message = Message(toId: user.id ?? "", fromId: uid, text: message, imageUrl: nil, user: user, sentTime: Timestamp(date: Date()), isFromCurrenUser: isFromCurrentUser)
        presentLoadingView(shouldPresent: true)
        MessegeService.shared.uploadMessage(message, to: user) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.presentErrorAlert(message: "\(error.localizedDescription)")
                self.presentLoadingView(shouldPresent: false)
                print("Fail to send message \(error)")
                return
            }
            self.presentLoadingView(shouldPresent: false)
            print("Successfully sending message")
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ChatController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let selectedPhoto = info[.editedImage] as? UIImage else { return }
        
        // upload image to firebase
        presentLoadingView(shouldPresent: true)
        StorageUploader.shared.uploadMessageImage(with: selectedPhoto) { [weak self] downloadedImageUrl in
            guard let self = self else { return }
            
            let isFromCurrentUser = self.user.id ?? "" == uid
            // send message to firestore
            let message = Message(toId: self.user.id ?? "",
                                  fromId: uid, text: nil,
                                  imageUrl: downloadedImageUrl,
                                  imageHeight: selectedPhoto.size.height,
                                  imageWidth: selectedPhoto.size.width,
                                  user: self.user,
                                  sentTime: Timestamp(date: Date()),
                                  isFromCurrenUser: isFromCurrentUser)
            
            MessegeService.shared.uploadMessage(message, to: self.user) { error in
                if let error = error {
                    self.presentErrorAlert(message: "\(error.localizedDescription)")
                    self.presentLoadingView(shouldPresent: false)
                    print("Fail to send message \(error)")
                    return
                }
                self.presentLoadingView(shouldPresent: false)
                print("Successfully sending message")
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - MessageCellDelegate
extension ChatController: MessageCellDelegate {
    
    func performZoomInForStartingImageMessage(startingImageView: UIImageView) {
        // hold the reference to startingImageView so that when zooming in, we hide the imageView first and unhide it after removing the zoomingImageView completely
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        // get the frame for the entire cell
        guard let startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil) else {
            print("can not convert zooming frame")
            return
        }
        
        self.startingFrame = startingFrame
    
        guard let safeStartingFrame = self.startingFrame else {
            print("no starting frame ...")
            return
        }
        
        let zoomingImageView = UIImageView(frame: safeStartingFrame)
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        let zoomingImageViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleZoomOut))
        zoomingImageView.addGestureRecognizer(zoomingImageViewTapGesture)

        guard let keyWindow = self.keyWindow else {
            print("can not get keywindow")
            return
        }
        
        self.blackBackgroundView = UIView(frame: keyWindow.frame)
        guard let blackBackgroundView = blackBackgroundView else {
            print("blackBackgroundView nil")
            return
        }
        blackBackgroundView.backgroundColor = .black
        blackBackgroundView.alpha = 0
        keyWindow.addSubview(blackBackgroundView)
        
        keyWindow.addSubview(zoomingImageView)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            blackBackgroundView.alpha = 1
            self.inputAccessoryView?.alpha = 0
            // get the correct height
            // h2 / w2 = h1 / w1
            // h2 = h1 / w1 * w2
            let height = safeStartingFrame.height / safeStartingFrame.width * keyWindow.frame.width
            zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
            zoomingImageView.center = keyWindow.center
        } completion: { _ in
            // do nothing
        }
    }
    
}
