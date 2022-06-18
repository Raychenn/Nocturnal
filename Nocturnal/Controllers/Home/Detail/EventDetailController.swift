//
//  EventDetailController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/16.
//

import UIKit
import AVFoundation
import CoreLocation

var player: AVPlayer?

class EventDetailController: UIViewController {

    // MARK: - Properties
    
    private lazy var tableView: UITableView = {
       let table = UITableView()
        table.contentInsetAdjustmentBehavior = .never
        table.sectionHeaderTopPadding = 0
        table.dataSource = self
        table.delegate = self
        table.register(DetailInfoCell.self, forCellReuseIdentifier: DetailInfoCell.identifier)
        table.register(PreviewMapCell.self, forCellReuseIdentifier: PreviewMapCell.identifier)
        table.register(DetailDescriptionCell.self, forCellReuseIdentifier: DetailDescriptionCell.identifier)
        let header = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width))
        header.imageView.image = UIImage(named: "cat")
        table.tableHeaderView = header
        table.tableFooterView = UIView()
        return table
    }()
    
    private lazy var joinButton: UIButton = {
       let button = UIButton()
        button.setTitle("Join", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .primaryBlue
        button.addTarget(self, action: #selector(didTapJoinButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var backButton: UIButton = {
       let button = UIButton()
        button.setImage( UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    private let event: Event
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    init(event: Event) {
        self.event = event
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func setupUI() {
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
        view.addSubview(joinButton)
        joinButton.anchor(top: tableView.bottomAnchor,
                          left: view.leftAnchor,
                          bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          right: view.rightAnchor,
                          paddingLeft: 16,
                          paddingBottom: 8,
                          paddingRight: 16)
        
        joinButton.setHeight(50)
        joinButton.layer.cornerRadius = 20
        
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 8, paddingLeft: 8)
    }
    
    func playSound(url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            guard let player = player else { return }
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Selectors
    @objc func didTapJoinButton() {
        
        UserService.shared.fetchUser(uid: uid) { result in
            switch result {
            case .success(let user):
                print("Current User \(user)")
            case .failure(let error):
                print("Fail to get user \(error)")
            }
        }
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension EventDetailController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let infoCell = tableView.dequeueReusableCell(withIdentifier: DetailInfoCell.identifier) as? DetailInfoCell else { return UITableViewCell() }
        
        guard let mapCell = tableView.dequeueReusableCell(withIdentifier: PreviewMapCell.identifier) as? PreviewMapCell else { return UITableViewCell() }
        
        guard let descriptionCell = tableView.dequeueReusableCell(withIdentifier: DetailDescriptionCell.identifier) as? DetailDescriptionCell else { return UITableViewCell() }
        
        switch indexPath.row {
        case 0:
            infoCell.configureCell(with: event)
            infoCell.delegate = self
            return infoCell
        case 1:
            mapCell.delegate = self
            mapCell.event = event
            return mapCell
        case 2:
            descriptionCell.configureCell(with: event)
            return descriptionCell
        default:
            break
        }
        
        return infoCell
    }
}

// MARK: - UITableViewDelegate
extension EventDetailController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 1 {
            return 200
        }
        
        return UITableView.automaticDimension
    }
}

// MARK: - PreviewMapCellDelegate
extension EventDetailController: PreviewMapCellDelegate {
    
    func handleShowFullMap(cell: PreviewMapCell) {
        
        let coordinate = CLLocationCoordinate2D(latitude: event.destinationLocation.latitude,
                                                longitude: event.destinationLocation.longitude)
        let fullMapVC = FullMapController(coodinate: coordinate)
        
        navigationController?.pushViewController(fullMapVC, animated: true)
    }
}
// MARK: - UIScrollViewDelegate
extension EventDetailController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let header = tableView.tableHeaderView as? StretchyTableHeaderView else { return }
        
        header.scrollViewDidScroll(scrollView: scrollView)
    }
}
// MARK: -
extension EventDetailController: DetailInfoCellDelegate {
    
    func playMusic(cell: DetailInfoCell, musicURL: String) {
        let musicPlayerVC = MusicPlayerController(event: event)
        present(musicPlayerVC, animated: true)
    }
}
