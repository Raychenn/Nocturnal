//
//  NotificationController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit
import FirebaseFirestore

class NotificationController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Properties
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.identifier)
        return table
    }()
    
    var hosts: [User] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var applicants: [User] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var notifications: [Notification] = []

    // MARK: - Life Cyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("uid \(uid)")
        fetchNotifications()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - API
    
    private func fetchHosts(uids: [String]) {
        UserService.shared.fetchUsers(uids: uids) { result in
            switch result {
            case .success(let users):
                self.hosts = users
            case .failure(let error):
                print("Fail to fetch hosts \(error)")
            }
        }
    }
    
    private func fetchApplicants(uids: [String]) {
        UserService.shared.fetchUsers(uids: uids) { result in
            switch result {
            case .success(let users):
                self.applicants = users
            case .failure(let error):
                print("Fail to fetch applicants \(error)")
            }
        }
    }
    
    private func fetchNotifications() {
        NotificationService.shared.fetchNotifications(uid: uid) { result in
            switch result {
            case .success(let notifications):                
                self.notifications = self.getFilteredNotifications(notifications: notifications)
                self.fetchHostsAndApplicants()
                print("Host \(self.hosts), applicant \(self.applicants)")
            case .failure(let error):
                print("Fail to get notification \(error)")
            }
        }
    }
    
    private func fetchHostsAndApplicants() {
        var applicantsId: [String] = []
        notifications.forEach({ applicantsId.append($0.applicantId) })
        var hostsId: [String] = []
        notifications.forEach({ hostsId.append($0.hostId) })
        
        self.notifications.forEach { notification in
            let type = NotificationType(rawValue: notification.type)
            if type == .joinEventRequest {
                fetchApplicants(uids: applicantsId)
            } else {
                // fetch hosts
                fetchHosts(uids: hostsId)
            }
        }
    }
    
   // MARK: - Helpers
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
    
    private func getFilteredNotifications(notifications: [Notification]) -> [Notification] {
      let result = notifications.filter { notification in
            let type = NotificationType(rawValue: notification.type)
            
          return notification.applicantId != uid || type == .successJoinedEventResponse || type == .failureJoinedEventResponse
        }
        return result
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let notificationCell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.identifier, for: indexPath) as? NotificationCell else { return UITableViewCell() }
        
        let notification = notifications[indexPath.row]
        
        if applicants.count == 0 {
            let host = hosts[indexPath.row]

            notificationCell.configueCell(with: notification, user: host)
        } else if hosts.count == 0 {
            let applicant = applicants[indexPath.row]
            notificationCell.configueCell(with: notification, user: applicant)
            notificationCell.delegate = self
        }
        
        return notificationCell
    }
}

// MARK: - NotificationCellDelegate

extension NotificationController: NotificationCellDelegate {
    
    func cell(_ cell: NotificationCell, wantsToAccept uid: String) {
        print("wantsToAccept called")
        let selectedIndexPath = tableView.indexPath(for: cell) ?? IndexPath()
        let selectedNotification = notifications[selectedIndexPath.row]
        let type = NotificationType.successJoinedEventResponse.rawValue
        
        let notification = Notification(applicantId: uid ,
                                        eventId: selectedNotification.eventId,
                                        hostId: selectedNotification.hostId,
                                        sentTime: Timestamp(date: Date()),
                                        type: type, isRequestPermitted: true)
        
        NotificationService.shared.postAceeptedNotification(to: selectedNotification.applicantId ,
                                                          notification: notification) { error in
            guard error == nil else {
                print("Fail to postAcceptNotification \(String(describing: error))")
                return
            }
            
            print("Succesfully postAcceptNotification")
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToDeny uid: String) {
        print("wantsToDeny called")
        let selectedIndexPath = tableView.indexPath(for: cell) ?? IndexPath()
        let selectedNotification = notifications[selectedIndexPath.row]
        let type = NotificationType.failureJoinedEventResponse.rawValue

        let notification = Notification(applicantId: uid ,
                                        eventId: selectedNotification.eventId,
                                        hostId: selectedNotification.hostId,
                                        sentTime: Timestamp(date: Date()),
                                        type: type, isRequestPermitted: false)

        NotificationService.shared.postDeniedNotification(to: selectedNotification.applicantId, notification: notification) { error in
            guard error == nil else {
                print("Fail to postDeyNotification \(String(describing: error))")
                return
            }
            
            print("Succesfully postDeyNotification")
        }
    }
}
