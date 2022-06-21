//
//  EventDetailController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/16.
//

import UIKit
import AVFoundation
import CoreLocation
import FirebaseFirestore

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
        header.configureHeader(with: URL(string: event.eventImageURL)!)
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
    
    private var currentUser: User? {
        didSet {
            // host can not join his own event
            guard let currentUserId = currentUser?.id else {
                print("currentUserId is nil")
                return
            }
            if event.hostID == currentUserId {
                joinButton.isHidden = true
            } else {
                joinButton.isHidden = false
            }
            
            print("joinButton hidden \(joinButton.isHidden)")
        }
    }
    
    private var host: User?
    
    private var shouldShowDescription = false
        
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrentUser()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
    }
    
    init(event: Event) {
        self.event = event
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - API
    
    private func fetchCurrentUser() {
        UserService.shared.fetchUser(uid: uid) { result in
            switch result {
            case .success(let user):
                self.currentUser = user
                self.tableView.reloadData()
            case .failure(let error):
                print("Fail to get user \(error)")
            }
        }
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
    
    // MARK: - Selectors
    @objc func didTapJoinButton() {
        let applicantId = currentUser?.id ?? ""
        let eventId = self.event.id ?? ""
        let notificationType = NotificationType.joinEventRequest.rawValue
        
        let notification = Notification(applicantId: applicantId,
                                        eventId: eventId,
                                        hostId: event.hostID,
                                        sentTime: Timestamp(date: Date()),
                                        type: notificationType, isRequestPermitted: false)
        
        NotificationService.shared.postNotification(to: event.hostID, notification: notification) { error in
            if let error = error {
                print("Error sending notification \(error)")
                return
            }
            
            print("Successfully sending notification")
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
        
//        let descriptionCell = tableView.cellForRow(at: indexPath) as? DetailDescriptionCell
//        shouldShowDescription = !shouldShowDescription
//        descriptionCell?.animateDescriptionLabel(shouldShow: shouldShowDescription)
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
// MARK: - DetailInfoCellDelegate
extension EventDetailController: DetailInfoCellDelegate {
    
    func openChatRoom(cell: DetailInfoCell) {
        UserService.shared.fetchUser(uid: self.event.hostID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let host):
                let chatVC = ChatController(user: host)
                self.navigationController?.pushViewController(chatVC, animated: true)
            case .failure(let error):
                print("Fail to fetch host \(error)")
            }
        }
    }
    
    func playMusic(cell: DetailInfoCell, musicURL: String) {
        let musicPlayerVC = MusicPlayerController(event: event)
        present(musicPlayerVC, animated: true)
    }
    
    func generateChatRoomId(otherUid: String) -> String {
        if uid > otherUid {
            return otherUid + uid
        } else {
            return uid + otherUid
        }
    }
}
