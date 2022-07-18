//
//  MediaPlayerController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/17.
//
import UIKit

class MusicPlayerController: UIViewController {

    // MARK: - Properties
    
    var event: Event
    
    private lazy var mediaPlayerView: MediaPlayerView = {
        let view = MediaPlayerView(event: event)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did loadd")

        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mediaPlayerView.play()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mediaPlayerView.stop()
        // this prevet system from going to sleep mode, which dims the screen after a short time
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    init(event: Event) {
        self.event = event
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func addBlurView() {
        self.view.backgroundColor = UIColor.clear
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurView)
    }

    private func setupUI() {
        addBlurView()
        view.addSubview(mediaPlayerView)
        
        NSLayoutConstraint.activate([
            mediaPlayerView.topAnchor.constraint(equalTo: view.topAnchor),
            mediaPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mediaPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mediaPlayerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
