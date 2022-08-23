//
//  HomeEventCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/25.
//

import UIKit
import Kingfisher
import FirebaseFirestore
import AVKit

protocol HomeEventCellDelegate: AnyObject {
    func didTapReportButton(cell: HomeEventCell)
}

class HomeEventCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    weak var delegate: HomeEventCellDelegate?
    
    let eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray
        
        return imageView
    }()
    
    private let eventNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .bold)
        
        return label
    }()
    
    private let dateImageview: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "calendar")
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading date"
        label.textColor = .lightGray
        return label
    }()
    
    private let feeImageview: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "ticket")
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let feeLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading fee"
        label.textColor = .lightGray
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .lightGray
        imageView.image = UIImage(systemName: "person")
        return imageView
    }()
    
    private let hostNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading host"
        label.textColor = .white
        return label
    }()
    
    private let bottomBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "#1C242F")
        return view
    }()
    
    let videoPlayerView = UIView()
    
     lazy var muteButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        button.setImage(UIImage(systemName: "speaker.slash", withConfiguration: config), for: .normal)
         button.tintColor = .deepBlue
        button.isHidden = true
        button.addTarget(self, action: #selector(muteVideo), for: .touchUpInside)
        return button
    }()
    
    private lazy var reportButton: UIButton = {
       let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        button.setImage(UIImage(systemName: "exclamationmark.circle", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapReportButton), for: .touchUpInside)
        return button
    }()
    
    private let blurEffectView: UIVisualEffectView = {
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blureEffectView = UIVisualEffectView(effect: blurEffect)
        return blureEffectView
    }()
    
    var player: AVQueuePlayer?
    
    var looper: AVPlayerLooper?
    
    var isMuted = true
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImageView.layer.cornerRadius = 25/2
        profileImageView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        player?.removeAllItems()
        player = nil
    }
    
    // MARK: - Selector
    
    @objc func muteVideo() {
        isMuted = !isMuted
        muteSound(shouldMute: isMuted)
    }
    
    @objc func didTapReportButton() {
        delegate?.didTapReportButton(cell: self)
    }
    
    // MARK: - Heleprs
    
    func setupVideoPlayerView(videoURLString: String) {
        player = AVQueuePlayer()
        layoutIfNeeded()
        guard let player = player else {
            print("player nil in home cell")
            return
        }
        player.isMuted = isMuted
        
        // caching video url
        CacheManager.shared.getFileWith(urlString: videoURLString) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let url):
                let playerItem = AVPlayerItem(url: url)
                self.looper = AVPlayerLooper(player: player, templateItem: playerItem)
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = self.videoPlayerView.bounds
                playerLayer.contentsGravity = .resizeAspectFill
                self.videoPlayerView.layer.addSublayer(playerLayer)
                self.videoPlayerView.bringSubviewToFront(self.muteButton)
                player.play()
            case .failure(let error):
                print("Failt to cachce url \(error)")
            }
        }
    }
    
    func updateCellForDisplayMode(shouldShowVideo: Bool) {
        videoPlayerView.bringSubviewToFront(muteButton)
        if shouldShowVideo {
            videoPlayerView.isHidden = false
            muteButton.isHidden = false
            eventImageView.isHidden = true
        } else {
            videoPlayerView.isHidden = true
            muteButton.isHidden = true
            eventImageView.isHidden = false
        }
    }
    
    func muteSound(shouldMute: Bool) {
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        if shouldMute {
            player?.isMuted = true
            muteButton.setImage(UIImage(systemName: "speaker.slash", withConfiguration: config), for: .normal)
        } else {
            player?.isMuted = false
            muteButton.setImage(UIImage(systemName: "speaker", withConfiguration: config), for: .normal)
        }
    }
    
    func bindCell(with viewModel: HomeEventCellViewModel) {
        viewModel.shouldShowVideo.bind { [weak self] shouldShow in
            guard let self = self else { return }
            
            self.updateCellForDisplayMode(shouldShowVideo: shouldShow)
        }
    }
    
    func configureCell(with viewModel: HomeEventCellViewModel) {
        
        if let viedoURLString = viewModel.eventVideoURLString {
            setupVideoPlayerView(videoURLString: viedoURLString)
        } else {
            eventImageView.kf.setImage(with: viewModel.eventImageViewURL)
        }
        
        if let profileUrl = viewModel.hostProfileURL {
            profileImageView.kf.setImage(with: profileUrl)
        } else {
            profileImageView.image = UIImage(systemName: "person")
        }
        
        dateLabel.text = viewModel.eventDate
        eventNameLabel.text = viewModel.eventName
        feeLabel.text = viewModel.eventFee
        hostNameLabel.text = viewModel.hostName
    }
    
    func setupCellUI() {
        layer.cornerRadius = 20
        layer.masksToBounds = true
        backgroundColor = .black
        contentView.addSubview(eventImageView)
        eventImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, height: 210)
        
        contentView.addSubview(videoPlayerView)
        videoPlayerView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, height: 210)
        
        videoPlayerView.addSubview(muteButton)
        muteButton.anchor(bottom: videoPlayerView.bottomAnchor,
                          right: videoPlayerView.rightAnchor,
                          paddingBottom: 8,
                          paddingRight: 8)
        
        contentView.addSubview(bottomBackgroundView)
        bottomBackgroundView.anchor(top: eventImageView.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor)
        
        bottomBackgroundView.addSubview(blurEffectView)
        blurEffectView.fillSuperview()
        
        bottomBackgroundView.addSubview(eventNameLabel)
        eventNameLabel.anchor(top: bottomBackgroundView.topAnchor,
                              left: bottomBackgroundView.leftAnchor,
                              right: bottomBackgroundView.rightAnchor,
                              paddingTop: 12, paddingLeft: 12, paddingRight: 12)
        
        bottomBackgroundView.addSubview(dateImageview)
        dateImageview.setDimensions(height: 15, width: 15)
        dateImageview.anchor(top: eventNameLabel.bottomAnchor,
                             left: eventNameLabel.leftAnchor,
                             paddingTop: 8)
        
        bottomBackgroundView.addSubview(dateLabel)
        dateLabel.centerY(inView: dateImageview)
        dateLabel.anchor(left: dateImageview.rightAnchor, paddingLeft: 6)
        
        bottomBackgroundView.addSubview(feeImageview)
        feeImageview.centerY(inView: dateImageview)
        feeImageview.setDimensions(height: 15, width: 15)
        feeImageview.anchor(left: dateLabel.rightAnchor, paddingLeft: 15)
        
        bottomBackgroundView.addSubview(feeLabel)
        feeLabel.centerY(inView: dateImageview)
        feeLabel.anchor(left: feeImageview.rightAnchor, paddingLeft: 6)
        
        bottomBackgroundView.addSubview(profileImageView)
        profileImageView.setDimensions(height: 25, width: 25)
        profileImageView.anchor(top: dateImageview.bottomAnchor,
                                left: dateImageview.leftAnchor,
                                paddingTop: 12)
        
        bottomBackgroundView.addSubview(hostNameLabel)
        hostNameLabel.centerY(inView: profileImageView)
        hostNameLabel.anchor(left: profileImageView.rightAnchor, paddingLeft: 8)
        
        contentView.addSubview(reportButton)
        reportButton.centerY(inView: eventNameLabel, constant: -5)
        reportButton.anchor(right: contentView.rightAnchor, paddingRight: 15)
        reportButton.setDimensions(height: 25, width: 25)
    }
}
