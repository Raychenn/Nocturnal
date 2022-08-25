//
//  NotificationController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Lottie

class NotificationController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Properties
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.rowHeight = UITableView.automaticDimension
        table.separatorColor = UIColor.clear
        table.tableFooterView = UIView()
        table.contentInset = .init(top: 20, left: 0, bottom: 20, right: 0)
        table.allowsSelection = false
        table.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.identifier)
        return table
    }()
    
    private let loadingAnimationView: AnimationView = LottieManager.shared.createLottieView(name: "empty-box", mode: .loop)
    
    private let emptyWarningLabel: UILabel = UILabel().makeBasicBoldLabel(fontSize: 30, text: "No Available Data yet")
    
    private var currentUser: User
    
    private var users: [User] = []
    
    var hosts: [String: User] = [:]

    var applicants: [String: User] = [:]
    
    var events: [String: Event] = [:]
    
    var notifications: [Notification] = [] {
        didSet {
            if notifications.count == 0 {
                configureAnimationView()
                configureEmptyWarningLabel()
                presentLoadingView(shouldPresent: false)
            } else {
                loadingAnimationView.stop()
                emptyWarningLabel.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Life Cyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    init(user: User) {
        self.currentUser = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCurrentUser { [weak self] user in
            guard let self = self else { return }
            self.currentUser = user
            self.fetchNotifications()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        loadingAnimationView.stop()
        emptyWarningLabel.removeFromSuperview()
    }
    
    // MARK: - API
    
    private func fetchNotifications() {
        presentLoadingView(shouldPresent: true)
        NotificationService.shared.fetchNotifications(uid: currentUser.id ?? "") { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let notifications):
                self.notifications = self.getFilteredNotifications(notifications: notifications)
                self.notifications = self.filterNotificationFromBlockedUsers(notifications: self.notifications)
                
                self.fetchEvents(from: self.notifications) { [weak self] events in
                    guard let self = self else { return }
                    
                    events.forEach { event in
                        if let id = event.id {
                            self.events[id] = event
                        }
                    }
                    
                    self.fetchHostsAndApplicants()
                }
            case .failure(let error):
                self.presentLoadingView(shouldPresent: false)
                self.presentErrorAlert(title: "Error", message: "Fail to get notification: \(error.localizedDescription)", completion: nil)
            }
        }
    }
    
    private func fetchCurrentUser(completion: @escaping (User) -> Void) {
        UserService.shared.fetchUser(uid: uid) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                completion(user)
            case .failure(let error):
                self.presentLoadingView(shouldPresent: false)
                self.presentErrorAlert(title: "Error", message: "\(error.localizedDescription)", completion: nil)
            }
        }
    }
    
    private func fetchEvents(from notifications: [Notification], completion: @escaping ([Event]) -> Void) {
        var eventsId: [String] = []
        notifications.forEach({ eventsId.append($0.eventId) })
        EventService.shared.fetchEvents(fromEventIds: eventsId) { result in
            switch result {
            case .success(let events):
                completion(events)
            case .failure(let error):
                self.presentLoadingView(shouldPresent: false)
                self.presentErrorAlert(title: "Error", message: "Fail to fetch event: \(error.localizedDescription)", completion: nil)
            }
        }
    }
    
    private func fetchHosts(uids: [String], completion: @escaping ([User]) -> Void) {
        UserService.shared.fetchUsers(uids: uids) { result in
            switch result {
            case .success(let users):
                completion(users)
            case .failure(let error):
                self.presentLoadingView(shouldPresent: false)
                self.presentErrorAlert(title: "Error", message: "Fail to fetch hosts: \(error.localizedDescription)", completion: nil)
            }
        }
    }
    
    private func fetchApplicants(uids: [String], completion: @escaping ([User]) -> Void) {
        UserService.shared.fetchUsers(uids: uids) { result in
            switch result {
            case .success(let users):
                completion(users)
            case .failure(let error):
                self.presentLoadingView(shouldPresent: false)
                self.presentErrorAlert(title: "Error", message: "Fail to fetch applicants: \(error.localizedDescription)", completion: nil)
            }
        }
    }
    
    private func fetchHostsAndApplicants() {
        
        var applicantsId: [String] = []
        notifications.forEach({ applicantsId.append($0.applicantId) })
        var hostsId: [String] = []
        notifications.forEach({ hostsId.append($0.hostId) })
        
        let group = DispatchGroup()
    
        group.enter()
        fetchApplicants(uids: applicantsId) { [weak self] applicants in
            guard let self = self else { return }
            applicants.forEach({
                if let id = $0.id {
                    self.applicants[id] = $0
                }
            })
            group.leave()
        }
        
        group.enter()
        fetchHosts(uids: hostsId) { [weak self] hosts in
            guard let self = self else { return }
            
            hosts.forEach({
                if let id = $0.id {
                    self.hosts[id] = $0
                }
            })
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.presentLoadingView(shouldPresent: false)
            self.tableView.reloadData()
        }
    }
    
   // MARK: - Helpers
    
    private func setupUI() {
        navigationController?.navigationBar.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
    
    private func configureAnimationView() {
        view.addSubview(loadingAnimationView)
        loadingAnimationView.centerY(inView: view)
        loadingAnimationView.centerX(inView: view)
        loadingAnimationView.widthAnchor.constraint(equalToConstant: view.frame.size.width - 20).isActive = true
        loadingAnimationView.heightAnchor.constraint(equalTo: loadingAnimationView.widthAnchor).isActive = true
        loadingAnimationView.play()
    }
    
    private func configureEmptyWarningLabel() {
        view.addSubview(emptyWarningLabel)
        emptyWarningLabel.centerX(inView: loadingAnimationView)
        emptyWarningLabel.anchor(top: loadingAnimationView.bottomAnchor, paddingTop: 15)
    }
    
    private func stopAnimationView() {
        loadingAnimationView.stop()
        loadingAnimationView.alpha = 0
        loadingAnimationView.removeFromSuperview()
    }
    
    private func getFilteredNotifications(notifications: [Notification]) -> [Notification] {
        
        guard let currentUid = Auth.auth().currentUser?.uid else {
            print("current uid nil in explore VC")
            return []
        }
        
      let result = notifications.filter { notification in
          
            let type = NotificationType(rawValue: notification.type)
          
          return notification.applicantId != currentUid || type == .successJoinedEventResponse || type == .failureJoinedEventResponse || type == .cancelEvent
        }
        return result
    }
    
    func filterNotificationFromBlockedUsers(notifications: [Notification]) -> [Notification] {
        if currentUser.blockedUsersId.count == 0 {
            return notifications
        }
    
        var result: [Notification] = []
        
        currentUser.blockedUsersId.forEach { blockedId in
            notifications.forEach { notification in
                if notification.hostId != blockedId && notification.applicantId != blockedId {
                    result.append(notification)
                }
            }
        }
        return result
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        events.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let notificationCell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.identifier, for: indexPath) as? NotificationCell else { return UITableViewCell() }
        
        notificationCell.delegate = self
        
        let notification = notifications[indexPath.section]
        let event = events[notification.eventId]
        
        let type = NotificationType(rawValue: notification.type) ?? .none
        let applicant = applicants[notification.applicantId]
        let host = hosts[notification.hostId]
        
        if type == .joinEventRequest {
            notificationCell.configueCell(with: notification, user: applicant ?? User(), event: event ?? Event())
        } else {
            notificationCell.configueCell(with: notification, user: host ?? User(), event: event ?? Event())
        }
        
        return notificationCell
    }
    
    // MARK: - UITablViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layer.masksToBounds = true
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    
}

// MARK: - NotificationCellDelegate

extension NotificationController: NotificationCellDelegate {
    
    func cell(_ cell: NotificationCell, wantsToAccept uid: String) {
        print("wantsToAccept called")
        let selectedIndexPath = tableView.indexPath(for: cell) ?? IndexPath()
        let selectedNotification = notifications[selectedIndexPath.section]
        let type = NotificationType.successJoinedEventResponse.rawValue

        let notification = Notification(applicantId: uid ,
                                        eventId: selectedNotification.eventId,
                                        hostId: selectedNotification.hostId,
                                        sentTime: Timestamp(date: Date()),
                                        type: type, isRequestPermitted: true)

        presentLoadingView(shouldPresent: true)

        NotificationService.shared.postAceeptedNotification(to: selectedNotification.applicantId ,
                                                          notification: notification) { [weak self] error in
            guard let self = self else { return }
            guard error == nil else {
                self.presentLoadingView(shouldPresent: false)
                print("Fail to postAcceptNotification \(String(describing: error))")
                self.presentErrorAlert(title: "Error", message: "Fail to post accept notification: \(error!.localizedDescription)", completion: nil)
                return
            }
            self.presentLoadingView(shouldPresent: false)
            print("Succesfully postAcceptNotification")
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToDeny uid: String) {
        print("wantsToDeny called")
        let selectedIndexPath = tableView.indexPath(for: cell) ?? IndexPath()
        let selectedNotification = notifications[selectedIndexPath.section]
        let type = NotificationType.failureJoinedEventResponse.rawValue

        let notification = Notification(applicantId: uid ,
                                        eventId: selectedNotification.eventId,
                                        hostId: selectedNotification.hostId,
                                        sentTime: Timestamp(date: Date()),
                                        type: type, isRequestPermitted: false)
        
        presentLoadingView(shouldPresent: true)
        
        NotificationService.shared.postDeniedNotification(to: selectedNotification.applicantId, notification: notification) { [weak self] error in
            guard let self = self else { return }
            guard error == nil else {
                self.presentLoadingView(shouldPresent: false)
                self.presentErrorAlert(title: "Error", message: "Fail to post deny notification: \(error!.localizedDescription)", completion: nil)
                print("Fail to post Deny Notification \(String(describing: error))")
                return
            }
            self.presentLoadingView(shouldPresent: false)
            print("Succesfully postDeyNotification")
        }
    }
}
