//
//  HomeController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit
import FirebaseAuth
import AVKit

class HomeController: UIViewController {
    
    // MARK: - Properties
    
    let refreshControl = UIRefreshControl()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .black
        collectionView.refreshControl = refreshControl
        collectionView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.register(HomeEventCell.self, forCellWithReuseIdentifier: HomeEventCell.identifier)
        return collectionView
    }()
    
    private let addEventButtonBackgroundView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.primaryBlue
        view.setDimensions(height: 60, width: 60)
        return view
    }()
    
    private lazy var addEventButton: UIButton = {
        let button = UIButton()
        button.setDimensions(height: 60, width: 60)
        button.setImage(UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.primaryBlue
        button.addTarget(self, action: #selector(didTapShowEventButton), for: .touchUpInside)
        return button
    }()

    var currentUser: User
        
    var events: [Event] = []
    
    var evnetHosts: [User] = []
    
    var currentCell: HomeEventCell?
        
    // MARK: - Life Cycle
    
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
//        navigationController?.delegate = self
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let pulseLayer = PulsingLayer(numberOfPulses: .infinity, radius: 50, view: addEventButtonBackgroundView)
        self.addEventButtonBackgroundView.layer.addSublayer(pulseLayer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // fetch all events from firestore
        presentLoadingView(shouldPresent: true)
        fetchCurrentUser { [weak self] in
            guard let self = self else {return}
            self.fetchAllEvents()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removePulsingLayer()
        releaseVideoPlayer()
    }

    // MARK: - API
    
    private func fetchCurrentUser(completion: @escaping () -> Void) {
        if Auth.auth().currentUser == nil {
            completion()
        } else {
            if let userId = Auth.auth().currentUser?.uid {
                UserService.shared.fetchUser(uid: userId) { result in
                    switch result {
                    case .success(let user):
                        self.currentUser = user
                        completion()
                    case .failure(let error):
                        self.presentErrorAlert(message: "\(error.localizedDescription)")
                        self.presentLoadingView(shouldPresent: false)
                        print("Fail to fetch user in home \(error)")
                    }
                }
            }
        }
    }
    
    private func fetchAllEvents() {
        refreshControl.beginRefreshing()
        
        EventService.shared.fetchAllEvents { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let events):
                
                if self.currentUser.blockedUsersId.count == 0 {
                    self.events = events
                    self.fetchHostsWhenLoggedin()
                } else {
                    self.filterEventsFromBlockedUsers(events: events) { filteredEvents in
                        self.events = filteredEvents
                        self.fetchHostsWhenLoggedin()
                    }
                }
            case .failure(let error):
                self.presentErrorAlert(message: "\(error.localizedDescription)")
                self.presentLoadingView(shouldPresent: false)
                print("error fetching all events \(error)")
            }
        }
    }
        
    private func fetchHostsWhenLoggedin() {
        if Auth.auth().currentUser != nil {
            // logged in, start fetching user data
            var hostsId: [String] = []
            let sortedEvents = events.sorted(by: { $0.createTime.dateValue().compare($1.createTime.dateValue()) == .orderedDescending })
            sortedEvents.forEach({hostsId.append($0.hostID)})
            
            fetchHosts(hostsId: hostsId) { [weak self] in
                guard let self = self else { return }
                self.filterEventsForDeletedUser(hosts: self.evnetHosts)
                self.endRefreshing()
            }
        } else {
            // not logged in
            self.endRefreshing()
        }
    }
    
    private func fetchHosts(hostsId: [String], completion: @escaping () -> Void) {
        UserService.shared.fetchUsers(uids: hostsId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let hosts):
                // filter deleted hosts here
                self.filterDeletedHosts(hosts: hosts)
                completion()
            case .failure(let error):
                self.presentErrorAlert(message: "\(error.localizedDescription)")
                self.presentLoadingView(shouldPresent: false)
                print("error fetching event hosts \(error)")
            }
        }
    }
    
    // MARK: - Selectors
    @objc func refreshData() {
        self.fetchAllEvents()
    }
    
    @objc func didTapShowEventButton() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginController = LoginController()
                let nav = UINavigationController(rootViewController: loginController)
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            let addEventVC = AddEventController()
            navigationController?.pushViewController(addEventVC, animated: true)
        }
    }
    
    // MARK: - Helpers
    
    private func endRefreshing() {
        refreshControl.endRefreshing()
        collectionView.reloadData()
        presentLoadingView(shouldPresent: false)
    }
    
    private func filterDeletedHosts(hosts: [User]) {
        var undeletedHosts: [User] = []
        
        hosts.forEach { host in
            if host.name != "Unknown User" {
                undeletedHosts.append(host)
            }
        }
        self.evnetHosts = undeletedHosts
    }
    
    private func filterEventsForDeletedUser(hosts: [User]) {
        var undeletedHostsId: Set<String> = []
        var filteredEvents: [Event] = []
        hosts.forEach { host in
            if host.name != "Unknown User" {
                undeletedHostsId.insert(host.id ?? "")
            }
        }
                
        events.forEach { event in
            undeletedHostsId.forEach { undeletedHostId in
                if undeletedHostId == event.hostID {
                    filteredEvents.append(event)
                }
            }
        }
        
        self.events = filteredEvents
    }
    
    private func removePulsingLayer() {
        self.addEventButtonBackgroundView.layer.sublayers?.forEach({ layer in
            if layer is PulsingLayer {
                layer.removeFromSuperlayer()
            }
        })
    }
    
    func releaseVideoPlayer() {
        collectionView.visibleCells.forEach { cell in
            if let homeCell = cell as? HomeEventCell {
                homeCell.player?.removeAllItems()
                homeCell.player = nil
            }
        }
    }
    
    func setupUI() {
        configureChatNavBar(withTitle: "Home", backgroundColor: UIColor.hexStringToUIColor(hex: "#1C242F"), preferLargeTitles: true)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Home"
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(addEventButtonBackgroundView)
        addEventButtonBackgroundView.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                            right: view.rightAnchor,
                                            paddingBottom: 10,
                                            paddingRight: 8)
        addEventButtonBackgroundView.layer.cornerRadius = 60/2
        
        view.addSubview(addEventButton)
        addEventButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                              right: view.rightAnchor,
                              paddingBottom: 10,
                              paddingRight: 8)
        addEventButton.layer.cornerRadius = 60/2
    }
    
    func filterEventsFromBlockedUsers(events: [Event], completion: @escaping ([Event]) -> Void) {
        var result: [Event] = []
        
        currentUser.blockedUsersId.forEach { blockedId in
            events.forEach { event in
                if blockedId != event.hostID {
                    result.append(event)
                }
            }
        }
        completion(result)
    }
}

// MARK: - UICollectionViewDataSource

extension HomeController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let eventCell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeEventCell.identifier, for: indexPath) as? HomeEventCell else { return UICollectionViewCell() }
                
        // should have 2 types of config | loggedin user vs no user
        if Auth.auth().currentUser == nil {
            let event = events[indexPath.item]

            eventCell.configureCell(event: event)
        } else {
            let event = events[indexPath.item]
            let host = evnetHosts[indexPath.item]

            eventCell.configureCellForLoggedInUser(event: event, host: host)
        }
        
        return eventCell
    }
}

// MARK: - UICollectionViewDelegate

extension HomeController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginController = LoginController()
                let nav = UINavigationController(rootViewController: loginController)
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            let selectedEvent = events[indexPath.item]
            let detailVC = EventDetailController(event: selectedEvent)
            if let selectedCell = collectionView.cellForItem(at: indexPath) as? HomeEventCell {
                self.currentCell = selectedCell
            }
            
            detailVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.size.width - 40, height: 350)
    }
}

// MARK: - UINavigationControllerDelegate

//extension HomeController: UINavigationControllerDelegate {
//    func navigationController(
//        _ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation,
//        from fromVC: UIViewController,
//        to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//
//        return TransitionManager(duration: 0.5)
//    }
//}
