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
        header.delegate = self
        header.backgroundColor = .deepGray
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
    
    private let event: Event
    
    private var host: User?
        
    var buttonStack = UIStackView()
            
    var isJoined: Bool {
        return event.participants.contains(uid) ? true: false
    }
    
    var isDenied: Bool {
        return event.deniedUsersId.contains(uid) ? true: false
    }
    
    var isPending: Bool {
        return event.pendingUsersId.contains(uid) ? true: false
    }
    
    var joinState: JoinState = .join
    
    private let loadingAnimationView = LottieManager.shared.createLottieView(name: "cheers", mode: .loop)
    
    private var joinedMembers: [User] = []
        
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchJoinedMemebers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
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
    
    private func fetchJoinedMemebers() {
        self.presentLoadingView(shouldPresent: true)
        UserService.shared.fetchUsers(uids: event.participants) { result in
            switch result {
            case .success(let joinedMembers):
                self.joinedMembers = joinedMembers
                self.fetchHost()
            case .failure(let error):
                self.presentLoadingView(shouldPresent: false)
                self.presentErrorAlert(message: "\(error.localizedDescription)")
                print("Fail to get joined members \(error)")
            }
        }
    }
    
    private func fetchHost() {
        self.presentLoadingView(shouldPresent: true)
        UserService.shared.fetchUser(uid: event.hostID) { result in
            switch result {
            case .success(let host):
                self.presentLoadingView(shouldPresent: false)
                self.host = host
                self.tableView.reloadData()
            case .failure(let error):
                self.presentLoadingView(shouldPresent: false)
                self.presentErrorAlert(message: "\(error.localizedDescription)")
                print("Fail to get user \(error)")
            }
        }
    }
    
    private func cancelEvent(eventId: String, applicantId: String) {
        self.presentLoadingView(shouldPresent: true)
        UserService.shared.deleteRequestedEvent(eventId: eventId) { error in
            if let error = error {
                self.presentLoadingView(shouldPresent: false)
                self.presentErrorAlert(message: "\(error.localizedDescription)")
                print("Error deleting RequestedEvent \(error)")
                return
            }
            
            EventService.shared.removeEventPendingUsers(eventId: eventId, applicantId: applicantId) { error in
                if let error = error {
                    self.presentLoadingView(shouldPresent: false)
                    self.presentErrorAlert(message: "\(error.localizedDescription)")
                    print("Error deleting EventPendingUsers \(error)")
                    return
                }
                
                NotificationService.shared.deleteNotifications(eventId: eventId) { [weak self] error in
                    guard let self = self else { return }
                    if let error = error {
                        self.presentLoadingView(shouldPresent: false)
                        self.presentErrorAlert(message: "\(error.localizedDescription)")
                        print("Error deleting notification \(error)")
                        return
                    }
                    self.presentLoadingView(shouldPresent: false)
                    self.joinState = .join
                    self.setJoinButton(forState: self.joinState)
                    print("Successfully canceling event application, pop up alert")
                }
            }
        }
    }
    
    private func joinedEvent(hostId: String, eventId: String, applicantId: String, notification: Notification) {
        self.presentLoadingView(shouldPresent: true)
        NotificationService.shared.postNotification(to: hostId, notification: notification) { [weak self] error in
            
            guard let self = self else { return }
            
            if let error = error {
                self.presentLoadingView(shouldPresent: false)
                self.presentErrorAlert(message: "\(error.localizedDescription)")
                print("Error sending notification \(error)")
                return
            }
            // update user requestedEventsId
            UserService.shared.updateUserEventRequest(eventId: eventId) { error in
                if let error = error {
                    self.presentLoadingView(shouldPresent: false)
                    self.presentErrorAlert(message: "\(error.localizedDescription)")
                    print("Fail to updateUserEventRequest \(error)")
                    return
                }
                
                EventService.shared.updateEventPendingUsers(eventId: eventId, applicantId: applicantId) { error in
                    if let error = error {
                        self.presentLoadingView(shouldPresent: false)
                        self.presentErrorAlert(message: "\(error.localizedDescription)")
                        print("Fail to updateEventPendingUsers \(error)")
                        return
                    }
                    self.presentLoadingView(shouldPresent: false)
                    self.joinState = .pending
                    self.setJoinButton(forState: self.joinState)
                    print("Successfully sending notification, pop up alert")
                }
            }
        }
    }
    
    private func deleteEvent(eventId: String) {
        self.configureAnimationView()
        print("start deleteJoinedEvent")
        UserService.shared.deleteJoinedEvent(eventId: eventId) { error in
            if let error = error {
                self.stopAnimationView()
                self.presentErrorAlert(message: "\(error.localizedDescription)")
                print("Fail to delete JoinedEvent for user \(error)")
                return
            }
            print("deleteJoinedEvent done")
            UserService.shared.deleteRequestedEvent(eventId: eventId) { error in
                if let error = error {
                    self.stopAnimationView()
                    self.presentErrorAlert(message: "\(error.localizedDescription)")
                    print("Fail to delete RequestedEvent for user \(error)")
                    return
                }
                print("deleteRequestedEvent done")
                NotificationService.shared.deleteNotifications(eventId: eventId) { error in
                    if let error = error {
                        self.stopAnimationView()
                        self.presentErrorAlert(message: "\(error.localizedDescription)")
                        print("Fail to delete Notifications3 \(error)")
                        return
                    }
                    print("delet notfications done")
                    EventService.shared.deleteEvent(eventId: eventId) { error in
                        if let error = error {
                            self.stopAnimationView()
                            self.presentErrorAlert(message: "\(error.localizedDescription)")
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
        
        setupJoinedButton(shouldShow: event.hostID == uid)
    }
    
    private func setupJoinedButton(shouldShow: Bool) {
        if shouldShow {
            buttonStack.removeArrangedSubview(joinButton)
            joinButton.removeFromSuperview()
        } else {
            buttonStack.addArrangedSubview(joinButton)
            setJoinButton(forState: joinState)
        }
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
        let applicantId = uid
        let eventId = self.event.id ?? ""

        if joinState == .pending {
            let cancelAlert = UIAlertController(title: "Are you are you want to cancel this application?", message: "", preferredStyle: .alert)
            cancelAlert.addAction(UIAlertAction(title: "NO", style: .default, handler: nil))
            cancelAlert.addAction(UIAlertAction(title: "YES", style: .destructive, handler: { _ in
                print("canceling request...")
                self.cancelEvent(eventId: eventId, applicantId: applicantId)
            }))
            self.present(cancelAlert, animated: true)
        } else {
            print("start joining event")
            let notificationType = NotificationType.joinEventRequest.rawValue
            let notification = Notification(applicantId: applicantId,
                                            eventId: eventId,
                                            hostId: event.hostID,
                                            sentTime: Timestamp(date: Date()),
                                            type: notificationType, isRequestPermitted: false)
            
            self.joinedEvent(hostId: self.event.hostID, eventId: eventId, applicantId: applicantId, notification: notification)
        }
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
    
        let joinedMemberProfileURLs = joinedMembers.map({ $0.profileImageURL })
        
        switch indexPath.row {
        case 0:
            infoCell.configureCell(with: event, host: host, joinedMemberProfileURLs: joinedMemberProfileURLs)
            infoCell.joinedMemberProfileURLs = joinedMemberProfileURLs
            infoCell.delegate = self
            return infoCell
        case 1:
            mapCell.delegate = self
            mapCell.backgroundColor = .deepGray
            mapCell.configureCell(with: event)
            return mapCell
        case 2:
            descriptionCell.configureCell(with: event)
            descriptionCell.delegate = self
            descriptionCell.backgroundColor = .deepGray
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
            return 370
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
        let noAction = UIAlertAction(title: "NO", style: .default, handler: nil)
        let yesAction = UIAlertAction(title: "YES", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            print("start deleting ...")
            let eventId = self.event.id ?? ""
            self.deleteEvent(eventId: eventId)
        }
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
        self.presentLoadingView(shouldPresent: true)
        UserService.shared.fetchUser(uid: self.event.hostID) { [weak self] result in
            guard let self = self else { return }
            self.presentLoadingView(shouldPresent: false)
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
}

// MARK: - DetailDescriptionCellDelegate
extension EventDetailController: DetailDescriptionCellDelegate {
    
    func animateDescriptionLabel(cell: DetailDescriptionCell) {

        tableView.beginUpdates()
        cell.decriptionContentLabel.numberOfLines = 0
        tableView.endUpdates()
    }
}

// MARK: - StretchyTableHeaderViewDelegate
extension EventDetailController: StretchyTableHeaderViewDelegate {
    
    func didTapBackButton(header: StretchyTableHeaderView) {
        navigationController?.popViewController(animated: true)
    }
}
