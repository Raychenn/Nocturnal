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
import FirebaseAuth
import Lottie

class EventDetailController: UIViewController {
    
    // MARK: - Properties
    enum JoinState: String {
        case join
        case joined
        case pending
        case denied
        
        var joinButtonTitle: String {
            switch self {
            case .join:
                return "Join Now"
            case .joined:
                return "Joined"
            case .pending:
                return "Cancel"
            case .denied:
                return "Denied"
            }
        }
    }
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.showsVerticalScrollIndicator = false
        table.contentInsetAdjustmentBehavior = .never
        table.sectionHeaderTopPadding = 0
        table.dataSource = self
        table.delegate = self
        table.allowsSelection = false
        table.register(DetailInfoCell.self, forCellReuseIdentifier: DetailInfoCell.identifier)
        table.register(PreviewMapCell.self, forCellReuseIdentifier: PreviewMapCell.identifier)
        table.register(DetailDescriptionCell.self, forCellReuseIdentifier: DetailDescriptionCell.identifier)
        let header = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width))
        header.backgroundColor = UIColor.hexStringToUIColor(hex: "#161616")
        header.layer.cornerRadius = 15
        header.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        header.configureHeader(with: URL(string: event.eventImageURL)!)
        table.tableHeaderView = header
        table.tableFooterView = UIView()
        return table
    }()
    
    private lazy var joinButton: UIButton = {
        let button = UIButton()
        button.setTitle("Join", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setHeight(50)
        button.backgroundColor = .primaryBlue
        button.addTarget(self, action: #selector(didTapJoinButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage( UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    private let event: Event
    
    private var currentUser: User? {
        didSet {
            // host can not join his own event
            tableView.reloadData()
        }
    }
    
    private var host: User? {
        didSet {
            tableView.reloadData()
        }
    }
        
    var buttonStack = UIStackView()
            
    var isJoined: Bool {
        if event.participants.contains(uid) {
            return true
        } else {
            return false
        }
    }
    
    var isDenied: Bool {
        if event.deniedUsersId.contains(uid) {
            return true
        } else {
            return false
        }
    }
    
    var isPending: Bool {
        if event.pendingUsersId.contains(uid) {
            return true
        } else {
            return false
        }
    }
    
    var joinState: JoinState = .join
    
    private let loadingAnimationView: AnimationView = {
       let view = AnimationView(name: "cheers")
        view.loopMode = .loop
        view.contentMode = .scaleAspectFill
        view.animationSpeed = 1
        view.backgroundColor = .clear
        view.play()
        return view
    }()
    
    public var headerView: DetailHeader?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchHost()
        fetchCurrentUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
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
            case .failure(let error):
                print("Fail to get user \(error)")
            }
        }
    }
    
    private func fetchHost() {
        UserService.shared.fetchUser(uid: event.hostID) { result in
            switch result {
            case .success(let host):
                self.host = host
            case .failure(let error):
                print("Fail to get user \(error)")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func configureAnimationView() {
        view.addSubview(loadingAnimationView)
        loadingAnimationView.centerY(inView: view)
        loadingAnimationView.centerX(inView: view)
        loadingAnimationView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        loadingAnimationView.heightAnchor.constraint(equalTo: loadingAnimationView.widthAnchor).isActive = true
    }
    
    private func stopAnimationView() {
        loadingAnimationView.stop()
        loadingAnimationView.alpha = 0
        loadingAnimationView.removeFromSuperview()
    }
    
    private func setupUI() {
        overrideUserInterfaceStyle = .dark
        guard let uid = Auth.auth().currentUser?.uid else { return }
        setupJoinButtonState()
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
        view.backgroundColor = .black
        view.addSubview(tableView)
        view.addSubview(buttonStack)
        joinButton.layer.cornerRadius = 20
        buttonStack.addArrangedSubview(joinButton)
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
        buttonStack.anchor(top: tableView.bottomAnchor,
                          left: view.leftAnchor,
                          bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          right: view.rightAnchor,
                          paddingLeft: 16,
                          paddingBottom: 8,
                          paddingRight: 16)
        
        if event.hostID == uid {
            buttonStack.removeArrangedSubview(joinButton)
            joinButton.removeFromSuperview()
        } else {
            buttonStack.addArrangedSubview(joinButton)
            
            setJoinButton(forState: joinState)
        }
        
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 8, paddingLeft: 16)
    }
    
    private func setupJoinButtonState() {
        if isJoined {
            joinState = .joined
        } else if isPending {
            joinState = .pending
        } else if isDenied {
            joinState = .denied
        } else {
            joinState = .join
        }
    }
    
    private func setJoinButton(forState state: JoinState) {
        switch joinState {
        case .join:
            joinButton.isEnabled = true
            joinButton.backgroundColor = .primaryBlue
            joinButton.setTitle(JoinState.join.joinButtonTitle, for: .normal)
        case .joined:
            joinButton.isEnabled = false
            joinButton.backgroundColor = .darkGray
            joinButton.setTitle(JoinState.joined.joinButtonTitle, for: .disabled)
        case .pending:
            joinButton.isEnabled = true
            joinButton.backgroundColor = .red
            joinButton.setTitle(JoinState.pending.joinButtonTitle, for: .normal)
        case .denied:
            joinButton.isEnabled = false
            joinButton.backgroundColor = .darkGray
            joinButton.setTitle(JoinState.denied.joinButtonTitle, for: .disabled)
        }
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
        
        if joinState == .pending {
            let cancelAlert = UIAlertController(title: "Are you are you want to cancel this application?", message: "", preferredStyle: .alert)
            cancelAlert.addAction(UIAlertAction(title: "NO", style: .default, handler: nil))
            cancelAlert.addAction(UIAlertAction(title: "YES", style: .destructive, handler: { _ in
                print("canceling request...")
                UserService.shared.deleteRequestedEvent(eventId: eventId) { error in
                    if let error = error {
                        print("Error deleting RequestedEvent \(error)")
                        return
                    }
                    
                    EventService.shared.removeEventPendingUsers(eventId: eventId, applicantId: applicantId) { error in
                        if let error = error {
                            print("Error deleting EventPendingUsers \(error)")
                            return
                        }
                        
                        NotificationService.shared.deleteNotifications(eventId: eventId) { [weak self] error in
                            guard let self = self else { return }
                            if let error = error {
                                print("Error deleting notification \(error)")
                                return
                            }
                            
                            self.joinState = .join
                            self.setJoinButton(forState: self.joinState)
                            print("Successfully canceling event application, pop up alert")
                        }
                    }
                }
            }))
            self.present(cancelAlert, animated: true)
        } else {
            print("start joining event")
            NotificationService.shared.postNotification(to: event.hostID, notification: notification) { [weak self] error in
                
                guard let self = self else { return }
                
                if let error = error {
                    print("Error sending notification \(error)")
                    return
                }
                // update user requestedEventsId
                UserService.shared.updateUserEventRequest(eventId: self.event.id ?? "") { error in
                    if let error = error {
                        print("Fail to updateUserEventRequest \(error)")
                        return
                    }
                    
                    EventService.shared.updateEventPendingUsers(eventId: self.event.id ?? "", applicantId: uid) { error in
                        if let error = error {
                            print("Fail to updateEventPendingUsers \(error)")
                            return
                        }
                        
                        self.joinState = .pending
                        self.setJoinButton(forState: self.joinState)
                        print("Successfully sending notification, pop up alert")
                    }
                }
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
        
        guard let host = host else { return UITableViewCell() }
        
        switch indexPath.row {
        case 0:
            infoCell.configureCell(with: event, host: host)
            infoCell.delegate = self
            return infoCell
        case 1:
            mapCell.delegate = self
            mapCell.event = event
            mapCell.backgroundColor = UIColor.hexStringToUIColor(hex: "#161616")
            mapCell.configureCell(with: event)
            return mapCell
        case 2:
            descriptionCell.configureCell(with: event)
            descriptionCell.delegate = self
            descriptionCell.backgroundColor = UIColor.hexStringToUIColor(hex: "#161616")
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
        
        if indexPath.row == 0 {
            return 310
        } else if indexPath.row == 1 {
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
    func deleteEvent(cell: DetailInfoCell) {
        let alert = UIAlertController(title: "Are you sure you want to delete this event?", message: "", preferredStyle: .actionSheet)
        let yesAction = UIAlertAction(title: "YES", style: .destructive) { [weak self] _ in
            guard let self = self else {
                return
            }
            print("start deleting ...")
            let eventId = self.event.id ?? ""
            print("eventId \(eventId)")
            self.configureAnimationView()
            print("start deleteJoinedEvent")
            UserService.shared.deleteJoinedEvent(eventId: eventId) { error in
                if let error = error {
                    print("Fail to delete JoinedEvent for user \(error)")
                    return
                }
                print("deleteJoinedEvent done")
                UserService.shared.deleteRequestedEvent(eventId: eventId) { error in
                    if let error = error {
                        print("Fail to delete RequestedEvent for user \(error)")
                        return
                    }
                    print("deleteRequestedEvent done")
                    NotificationService.shared.deleteNotifications(eventId: eventId) { error in
                        if let error = error {
                            print("Fail to delete Notifications3 \(error)")
                            return
                        }
                        print("delet notfications done")
                        EventService.shared.deleteEvent(eventId: eventId) { error in
                            if let error = error {
                                print("Fail to delete event \(error)")
                                return
                            }
                            self.stopAnimationView()
                            print("Successfully delete event")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
        let noAction = UIAlertAction(title: "NO", style: .default, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        self.present(alert, animated: true)
    }
    
    func tappedHostProfile(cell: DetailInfoCell) {
        guard let host = host else {
            print("NO host")
            return
        }
        let profileVC = ProfileController(user: host)
        let nav = UINavigationController(rootViewController: profileVC)
        present(nav, animated: true)
    }
    
    func openChatRoom(cell: DetailInfoCell) {
        UserService.shared.fetchUser(uid: self.event.hostID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let host):
                let chatVC = ChatController(user: host)
                self.navigationController?.pushViewController(chatVC, animated: true)
            case .failure(let error):
                self.presentLoadingView(shouldPresent: false)
                self.presentErrorAlert(title: "Error", message: "\(error.localizedDescription)", completion: nil)
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

// MARK: - DetailDescriptionCellDelegate
extension EventDetailController: DetailDescriptionCellDelegate {
    
    func animateDescriptionLabel(cell: DetailDescriptionCell) {

        tableView.beginUpdates()
        cell.decriptionContentLabel.numberOfLines = 0
        tableView.endUpdates()
    }
}
