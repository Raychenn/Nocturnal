//
//  HomeViewModel.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/7/18.
//

import Foundation
import FirebaseAuth

class HomeViewModel {
    
    var shouldPresentRefreshControl: ObservableObject<Bool> = ObservableObject(value: false)
    
    var shouldPresentLoadingView: ObservableObject<Bool> = ObservableObject(value: false)
    
    var shouldEndRefreshing: ObservableObject<Bool> = ObservableObject(value: false)
    
    var shouldPresentEmptyView: ObservableObject<Bool> = ObservableObject(value: false)
    
    var firestoreError: ObservableObject<Error?> = ObservableObject(value: nil)
    
    var currentUser: ObservableObject<User> = ObservableObject(value: User())
    
    var events: [Event] = []
    
    var eventHosts: [String: User]?
    
    var hostsId: [String] = []
    
    let userProvider: UserProvider
    let eventProvider: EventProvider
    
    init(userProvider: UserProvider, eventProvider: EventProvider) {
        self.userProvider = userProvider
        self.eventProvider = eventProvider
    }
    
    var homeEventCellViewModels: [HomeEventCellViewModel] = []
    
    // MARK: - Helpers
    
    func fetchCurrentUser(completion: @escaping () -> Void) {
        if Auth.auth().currentUser != nil {
            shouldPresentLoadingView.value = true
            if let userId = Auth.auth().currentUser?.uid {
                userProvider.fetchUser(uid: userId) { result in
                    completion()
                    switch result {
                    case .success(let user):
                        self.currentUser.value = user
                    case .failure(let error):
                        self.firestoreError.value = error
                        self.shouldPresentLoadingView.value = false
                        print("Fail to fetch user in home \(error)")
                    }
                }
            }
        } else {
            completion()
        }
    }
    
    func fetchAllEvents() {
        shouldPresentRefreshControl.value = true
        //        refreshControl.beginRefreshing()
        eventProvider.fetchAllEvents { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let events):
                self.events = self.getUnblockedEvents(from: events)
                self.fetchLoggedinHosts()
            case .failure(let error):
                self.firestoreError.value = error
                self.shouldPresentLoadingView.value = false
                //                self.presentErrorAlert(message: "\(error.localizedDescription)")
                //                self.presentLoadingView(shouldPresent: false)
                print("error fetching all events \(error)")
            }
        }
    }
    
    private func fetchLoggedinHosts() {
        if Auth.auth().currentUser != nil {
            // logged in, start fetching user data
            events.forEach({hostsId.append($0.hostID)})
            userProvider.fetchUsers(uids: hostsId) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let hosts):
                    let activeHosts = self.getActiveHosts(hosts: hosts)
                    self.eventHosts = activeHosts.reduce(into: [String: User](), { dict, host in
                        dict[host.id ?? ""] = host
                    })
                    self.shouldPresentEmptyView.value = self.eventHosts?.count == 0 ? true: false
                    
                    self.events = self.getActiveEvents(from: activeHosts)
                    self.shouldEndRefreshing.value = true
                case .failure(let error):
                    self.firestoreError.value = error
                    self.shouldEndRefreshing.value = true
                }
            }
        } else {
            self.shouldEndRefreshing.value = true
        }
    }
    
    private func getUnblockedEvents(from events: [Event]) -> [Event] {
        var result: [Event] = []
        
        if self.currentUser.value.blockedUsersId.count == 0 {
            return events
        } else {
            result = events.filter({ !currentUser.value.blockedUsersId.contains($0.hostID) })
            return result
        }
    }
    
    private func getActiveHosts(hosts: [User]) -> [User] {
        var undeletedHosts: [User] = []
        undeletedHosts = hosts.filter({ $0.name != "Unknown User" })
        return undeletedHosts
    }
    
    private func getActiveEvents(from hosts: [User]) -> [Event] {
        var undeletedHostsId: Set<String> = []
        var filteredEvents: [Event] = []
        hosts.forEach { host in
            if host.name != "Unknown User" {
                undeletedHostsId.insert(host.id ?? "")
            }
        }
        filteredEvents = events.filter({ undeletedHostsId.contains($0.hostID) })
        return filteredEvents
    }
}
