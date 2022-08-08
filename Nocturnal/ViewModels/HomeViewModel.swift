//
//  HomeViewModel.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/7/18.
//

import Foundation
import FirebaseAuth

class HomeViewModel {
    
//    var currentUserDidUpdate: ((Result<User, Error>) -> Void)?
//    var onRefresh: (() -> Void)?
//    
//    var currentUser: User = User()
//    var events: [Event] = []
//    var eventHost: [String: User] = [:]
//
//    let userProvider: UserProvider
//    let eventProvider: EventProvider
//
//    init(userProvider: UserProvider, eventProvider: EventProvider) {
//        self.userProvider = userProvider
//        self.eventProvider = eventProvider
//    }
//
//    func fetchCurrentUser() {
//        if Auth.auth().currentUser == nil {
//            
//        } else {
//            if let userId = Auth.auth().currentUser?.uid {
//                userProvider.fetchUser(uid: userId) { result in
//                    switch result {
//                    case .success(let user):
//                        self.currentUser = user
//                        self.currentUserDidUpdate?(user)
//                        self.onRefresh?()
//                    case .failure(let error):
//                        self.fetchCurrentUserDidFail?(error)
////                        self.presentErrorAlert(message: "\(error.localizedDescription)")
////                        self.presentLoadingView(shouldPresent: false)
//                        print("Fail to fetch user in home \(error)")
//                    }
//                }
//            }
//        }
//    }
    
//    private func fetchAllEvents() {
//        refreshControl.beginRefreshing()
//
//        homeEventProvider.fetchAllEvents { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let events):
//                self.filterBlockedEventsIfNecessary(from: events)
//                self.fetchLoggedinHosts()
//            case .failure(let error):
//                self.presentErrorAlert(message: "\(error.localizedDescription)")
//                self.presentLoadingView(shouldPresent: false)
//                print("error fetching all events \(error)")
//            }
//        }
//    }
//
//    private func fetchLoggedinHosts() {
//        if Auth.auth().currentUser != nil {
//            // logged in, start fetching user data
//            events.forEach({hostsId.append($0.hostID)})
//
//            fetchHosts(hostsId: hostsId) { [weak self] hosts in
//                guard let self = self else { return }
//                let activeHosts = self.getActiveHosts(hosts: hosts)
//
//                activeHosts.forEach { host in
//                    if let id = host.id {
//                        self.evnetHosts[id] = host
//                    }
//                }
//
//                let hostValues = self.evnetHosts.map({ $0.value })
//                self.filterEventsFromDeletedHosts(hosts: hostValues)
//                self.presentEmptyViewIfNecessary()
//                self.endRefreshing()
//            }
//        } else {
//            // not logged in
//            self.endRefreshing()
//        }
//    }
//
//    private func fetchHosts(hostsId: [String], completion: @escaping ([User]) -> Void) {
//        userProvider.fetchUsers(uids: hostsId) { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let hosts):
//                let sortedHosts = self.getSortedHosts(users: hosts)
//                completion(sortedHosts)
//            case .failure(let error):
//                self.presentErrorAlert(message: "\(error.localizedDescription)")
//                self.presentLoadingView(shouldPresent: false)
//                print("error fetching event hosts \(error)")
//            }
//        }
//    }
}
