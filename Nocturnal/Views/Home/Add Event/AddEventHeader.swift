//
//  AddEventHeader.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/30.
//

import UIKit
import AVKit

protocol AddEventHeaderDelegate: AnyObject {
    func uploadNewEventImageView(header: AddEventHeader)
    func uploadNewEventVideoView(header: AddEventHeader)
}

class AddEventHeader: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    
    static let identifier = "AddEventHeader"
    
    weak var delegate: AddEventHeaderDelegate?
    
    private let uploadImageLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        label.text = "Upload New Event Image"
        return label
    }()
    
     lazy var newEventImageView: UIImageView = {
        let imageView = UIImageView()
         imageView.contentMode = .scaleAspectFill
         imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapEventImageView))
        imageView.addGestureRecognizer(tap)
         imageView.layer.borderWidth = 1
         imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
     lazy var newPhotoButton: UIButton = {
       let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        button.setImage(UIImage(systemName: "photo", withConfiguration: config), for: .normal)
        button.contentMode = .scaleAspectFill
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapNewPhotoButton), for: .touchUpInside)
        return button
    }()
    
    private let uploadVideoLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        label.text = "Upload New Event Video (Optional)"
        return label
    }()
    
    lazy var videoPlayerView: UIView = {
        let videoView = UIView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapVideoPlayerView))
        videoView.addGestureRecognizer(tap)
        videoView.isUserInteractionEnabled = true
        videoView.layer.borderWidth = 1
        videoView.layer.borderColor = UIColor.white.cgColor
        return videoView
    }()
    
     lazy var newVideoButton: UIButton = {
       let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        button.setImage(UIImage(systemName: "video", withConfiguration: config), for: .normal)
        button.contentMode = .scaleAspectFill
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapNewVideoButton), for: .touchUpInside)
        return button
    }()
    
    var looper: AVPlayerLooper?
        
    // MARK: - Life Cycle
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(uploadImageLabel)
        uploadImageLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor)
        uploadImageLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        contentView.addSubview(newEventImageView)
        newEventImageView.anchor(top: uploadImageLabel.bottomAnchor,
                                 left: contentView.leftAnchor,
                                 right: contentView.rightAnchor,
                                 paddingTop: 10, paddingLeft: 20,
                                 paddingRight: 20, height: 150)
        
        contentView.addSubview(newPhotoButton)
        newPhotoButton.centerX(inView: newEventImageView)
        newPhotoButton.centerY(inView: newEventImageView)
        newPhotoButton.setDimensions(height: 50, width: 50)
        
        contentView.addSubview(uploadVideoLabel)
        uploadVideoLabel.anchor(top: newEventImageView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10)
        uploadVideoLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        contentView.addSubview(videoPlayerView)
        videoPlayerView.anchor(top: uploadVideoLabel.bottomAnchor,
                                 left: contentView.leftAnchor,
                                 bottom: contentView.bottomAnchor,
                                 right: contentView.rightAnchor,
                                 paddingTop: 20,
                                 paddingLeft: 20,
                                 paddingBottom: 20, paddingRight: 10, height: 150)
        
        contentView.addSubview(newVideoButton)
        newVideoButton.centerX(inView: videoPlayerView)
        newVideoButton.centerY(inView: videoPlayerView)
        newVideoButton.setDimensions(height: 50, width: 50)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoPlayerView.layer.cornerRadius = 8
        newEventImageView.layer.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
     func setupVideoPlayerView(videoURL: URL) {
         let playerItem = AVPlayerItem(url: videoURL)
         let player = AVQueuePlayer()
         looper = AVPlayerLooper(player: player, templateItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.videoPlayerView.bounds
         playerLayer.contentsGravity = .resizeAspectFill
        self.videoPlayerView.layer.addSublayer(playerLayer)
        player.play()
    }
    
    // MARK: - Selector
    
    @objc func didTapEventImageView() {
        delegate?.uploadNewEventImageView(header: self)
    }
    
    @objc func didTapNewPhotoButton() {
        delegate?.uploadNewEventImageView(header: self)
    }
    
    @objc func didTapVideoPlayerView() {
        delegate?.uploadNewEventVideoView(header: self)
    }
    
    @objc func didTapNewVideoButton() {
        delegate?.uploadNewEventVideoView(header: self)
    }
    
}
