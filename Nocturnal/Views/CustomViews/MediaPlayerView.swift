//
//  MediaPlayerView.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/17.
//

import UIKit
import AVKit
import Kingfisher

class MediaPlayerView: UIView {
    
    // MARK: - Properties
        
    private lazy var albumNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    private lazy var albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 100
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        return imageView
    }()
    
    private lazy var progressBarSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        let durationTime = self.player.currentItem?.asset.duration ?? CMTime()
        let duration = Float(CMTimeGetSeconds(durationTime))
        slider.minimumValue = 0
        slider.addTarget(self, action: #selector(progressScrubbed), for: .valueChanged)
        slider.minimumTrackTintColor = UIColor(named: "subtitleColor")
        return slider
    }()
    
    private lazy var elapsedTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.text = "00:00"
        return label
    }()
    
    private lazy var remaingTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.text = "00:00"
        return label
    }()
    
    private lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .light)
        return label
    }()
    
    private lazy var songNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 40)
        button.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: config), for: .normal)
        button.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    private lazy var fastForwadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 30)
        button.setImage(UIImage(systemName: "goforward.5", withConfiguration: config), for: .normal)
        button.addTarget(self, action: #selector(didTapForwardButton), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    private lazy var backForwadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 30)
        button.setImage(UIImage(systemName: "gobackward.5", withConfiguration: config), for: .normal)
        button.addTarget(self, action: #selector(didTapBackwardButton), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    private lazy var hstack: UIStackView = {
        let hstack = UIStackView(arrangedSubviews: [
                                                    backForwadButton,
                                                    playPauseButton,
                                                    fastForwadButton
                                                   ])
        hstack.translatesAutoresizingMaskIntoConstraints = false
        hstack.axis = .horizontal
        hstack.distribution = .fillEqually
        hstack.spacing = 10
        
        return hstack
    }()
    
    let event: Event
    private var player = AVPlayer()
    private var timer: Timer?
    private var playingIndex = 0
    private var isPlaying = false
    fileprivate let seekDuration: Float64 = 5
    var playerObserver: Any?
    
    // MARK: - Life Cycle
    
    init(event: Event) {
        self.event = event
        super.init(frame: .zero)
        timeObserverSetup()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func setupUI() {
        albumNameLabel.text = "Album name"
        guard let eventImageURL = URL(string: event.eventImageURL) else { return }
        albumCoverImageView.kf.setImage(with: eventImageURL)
        setupPlayer(event: event)
        [albumNameLabel, songNameLabel, artistLabel, elapsedTimeLabel, remaingTimeLabel].forEach({ $0.textColor = .white })
        
        [albumNameLabel,
         albumCoverImageView,
         songNameLabel,
         artistLabel,
         progressBarSlider,
         elapsedTimeLabel,
         remaingTimeLabel,
         hstack].forEach({ addSubview($0) })
        
        NSLayoutConstraint.activate([
            albumNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            albumNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            albumNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            albumCoverImageView.topAnchor.constraint(equalTo: albumNameLabel.bottomAnchor, constant: 32),
            albumCoverImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            albumCoverImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            albumCoverImageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.5),
            
            songNameLabel.topAnchor.constraint(equalTo: albumCoverImageView.bottomAnchor, constant: 16),
            songNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            songNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            artistLabel.topAnchor.constraint(equalTo: songNameLabel.bottomAnchor, constant: 8),
            artistLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            artistLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            progressBarSlider.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 8),
            progressBarSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            progressBarSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            elapsedTimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            elapsedTimeLabel.topAnchor.constraint(equalTo: progressBarSlider.bottomAnchor, constant: 8),
            
            remaingTimeLabel.topAnchor.constraint(equalTo: progressBarSlider.bottomAnchor, constant: 8),
            remaingTimeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            hstack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            hstack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            hstack.topAnchor.constraint(equalTo: remaingTimeLabel.bottomAnchor, constant: 8)
        ])
    }
    
    func play() {
        progressBarSlider.value = 0
        let duration = player.currentItem?.duration ?? CMTime()
        let totalSeconds = CMTimeGetSeconds(duration)
        progressBarSlider.maximumValue = Float(totalSeconds)
        player.play()
        isPlaying = !isPlaying
        setPlayPauseIcon(isPlaying: isPlaying)
    }
    
    func stop() {
        player.pause()
        timer?.invalidate()
        timer = nil
    }
    
    private func setPlayPauseIcon(isPlaying: Bool) {
        print("is playing \(isPlaying)")
        let config = UIImage.SymbolConfiguration(pointSize: 100)
        playPauseButton.setImage(UIImage(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill", withConfiguration: config), for: .normal)
    }
    
    private func setupPlayer(event: Event) {
        guard let url = URL(string: event.eventMusicURL ) else { return }
        
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        }
        
        songNameLabel.text = event.title
        artistLabel.text = "ramdon artist"
        
        do {
            let avPlayerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: avPlayerItem)
            player.rate = 1.0
            self.timeObserverSetup()
            
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print(error)
        }
    }
    
    private func getFormattedTime(timeInterval: TimeInterval) -> String {
        let mins = timeInterval / 60
        let secs = timeInterval.truncatingRemainder(dividingBy: 60)
        let timeFormatter = NumberFormatter()
        timeFormatter.minimumIntegerDigits = 2
        timeFormatter.minimumFractionDigits = 0
        timeFormatter.roundingMode = .down
        guard let minsString = timeFormatter.string(from: NSNumber(value: mins)),
              let secsString = timeFormatter.string(from: NSNumber(value: secs)) else { return "00:00" }
        
        return "\(minsString):\(secsString)"
    }
    
    func timeObserverSetup() {
        // Invoke callback every second
        let interval = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        // Queue on which to invoke the callback
        let mainQueue = DispatchQueue.main

        // Keep the reference to remove
        self.playerObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { [weak self] time in
            
            let seconds = CMTimeGetSeconds(time)
            let secondsString = String(format: "%02d", Int(Int(seconds)%60))
            self?.elapsedTimeLabel.text = "00:\(secondsString)"
            self?.updateSlider(elapsedTime: time)
        }
    }

    func removeTimerObserver() {
        if self.playerObserver != nil {
            if self.player.rate == 1.0 { // it is required as you have to check if player is playing
                self.player.removeTimeObserver(self.playerObserver as Any)
                self.playerObserver = nil
            }
        }
    }
    
    func updateSlider(elapsedTime: CMTime) {
//        let playerDuration = playerItemDuration()
        let durationTime = self.player.currentItem?.duration ?? CMTime()
        let duration = Float(CMTimeGetSeconds(durationTime))
        if duration.isFinite && duration > 0 {
            progressBarSlider.minimumValue = 0.0
            progressBarSlider.maximumValue = duration
            let time = Float(CMTimeGetSeconds(elapsedTime))
            print("time sections \(time)")
            progressBarSlider.setValue(time, animated: true)
        }
    }
    
    private func playerItemDuration() -> CMTime {
        let thePlayerItem = player.currentItem
        if thePlayerItem?.status == .readyToPlay {
            return thePlayerItem!.duration
        }
        return CMTime.invalid
    }
    
    // MARK: - Selectors
    @objc func updateProgress() {
        let currentTime = Float(CMTimeGetSeconds(player.currentTime()))
        let durationTime = self.player.currentItem?.asset.duration ?? CMTime()
        
        let duration = Float(CMTimeGetSeconds(durationTime))
        let remainingTime = duration - currentTime
        remaingTimeLabel.text = getFormattedTime(timeInterval: TimeInterval(remainingTime))
    }
    
    @objc func progressScrubbed(_ sender: UISlider, event: UIEvent) {
        
        if let duration = player.currentItem?.duration {
            print("duration \(duration)")

            let seekTime = CMTime(value: Int64(sender.value), timescale: 1)
            player.seek(to: seekTime)
        } else {
            print("no duration")
        }
        
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                self.removeTimerObserver()
                self.player.pause()
            case .moved:
                break
            case .ended:
                self.timeObserverSetup()
                self.player.play()
            default:
                break
            }
        }
    }

    @objc func didTapPlayPause(_ sender: UIButton) {
        if player.timeControlStatus == .playing {
            isPlaying = !isPlaying
            setPlayPauseIcon(isPlaying: isPlaying)
            // pause
            player.pause()
        } else {
            isPlaying = !isPlaying
            setPlayPauseIcon(isPlaying: isPlaying)
            player.play()
        }
    }
    
    @objc func didTapForwardButton() {
        guard let duration = player.currentItem?.duration else {
            return
        }
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = playerCurrentTime + seekDuration
        
        if newTime < CMTimeGetSeconds(duration) {
            
            let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            player.seek(to: time2)
        }
        updateProgress()
    }
    
    @objc func didTapBackwardButton() {
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = playerCurrentTime - seekDuration
        
        if newTime < 0 {
            newTime = 0
        }
        let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player.seek(to: time2)
        updateProgress()
    }
}
