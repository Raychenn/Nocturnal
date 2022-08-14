//
//  HomeController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit
import FirebaseAuth
import Kingfisher
import AVKit
import Lottie

class HomeController: UIViewController {
    
    // MARK: - Properties
    
    let refreshControl = UIRefreshControl()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .black
        collectionView.refreshControl = refreshControl
        collectionView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.register(HomeEventCell.self, forCellWithReuseIdentifier: HomeEventCell.identifier)
        collectionView.register(HomeProfileCell.self, forCellWithReuseIdentifier: HomeProfileCell.identifier)
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
        button.accessibilityIdentifier = "add"
        button.setDimensions(height: 60, width: 60)
        button.setImage(UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.primaryBlue
        button.addTarget(self, action: #selector(didTapShowEventButton), for: .touchUpInside)
        return button
    }()
    
    private let emptyAnimationView = LottieManager.shared.createLottieView(name: "empty-box", mode: .loop)
    
    private let emptyWarningLabel = UILabel().makeSatisfyLabel(text: "No Events yet, click the + button to add new event",
                                                               size: 25,
                                                               textAlighment: .center)
    
    private let currentUserNameLabel = UILabel().makeSatisfyLabel(text: "Loading Name", size: 18)
    
    private let currentUserProfileImageView = UIImageView().createBasicImageView(backgroundColor: .lightGray, tintColor: .black)
    
    private let profileView: UIView = {
       let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    let userProvider: UserProvider
    
    let homeEventProvider: EventProvider

    var currentUser: User = User()
        
    var events: [Event] = []
    
    var evnetHosts: [String: User] = [:]
    
    var hostsId: [String] = []
    
    let viewModel: HomeViewModel = HomeViewModel()
    
    var homeEventCellViewModels: [HomeEventCellViewModel] = []
            
    // MARK: - Life Cycle
    
    init(userProvider: UserProvider, homeEventProvider: EventProvider) {
        self.userProvider = userProvider
        self.homeEventProvider = homeEventProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        currentUserProfileImageView.layer.cornerRadius = 35/2
        setupPulsingLayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        
        // fetch all events from firestore
        presentLoadingView(shouldPresent: true)
        fetchCurrentUser { [weak self] in
            guard let self = self else {return}
            self.fetchAllEvents()
            self.setupProfileView()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cleanupLayers()
        cleanupEmptyViews()
    }

    // MARK: - API
    
    private func fetchCurrentUser(completion: @escaping () -> Void) {
        if Auth.auth().currentUser == nil {
            completion()
        } else {
            if let userId = Auth.auth().currentUser?.uid {
                userProvider.fetchUser(uid: userId) { result in
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
        
        homeEventProvider.fetchAllEvents { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let events):
                self.filterBlockedEventsIfNecessary(from: events)
                self.fetchLoggedinHosts()
            case .failure(let error):
                self.presentErrorAlert(message: "\(error.localizedDescription)")
                self.presentLoadingView(shouldPresent: false)
                print("error fetching all events \(error)")
            }
        }
    }
        
    private func fetchLoggedinHosts() {
        if Auth.auth().currentUser != nil {
            // logged in, start fetching user data
            events.forEach({hostsId.append($0.hostID)})
            
            fetchHosts(hostsId: hostsId) { [weak self] hosts in
                guard let self = self else { return }
                let activeHosts = self.getActiveHosts(hosts: hosts)
                
                activeHosts.forEach { host in
                    if let id = host.id {
                        self.evnetHosts[id] = host
                    }
                }
                
                let hosts = self.evnetHosts.map({ $0.value })
                self.events = self.getActiveEvents(from: hosts)
                self.presentEmptyViewIfNecessary()
                self.endRefreshing()
            }
        } else {
            // not logged in
            self.endRefreshing()
        }
    }
    
    private func fetchHosts(hostsId: [String], completion: @escaping ([User]) -> Void) {
        userProvider.fetchUsers(uids: hostsId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let hosts):
                let sortedHosts = self.getSortedHosts(users: hosts)
                completion(sortedHosts)
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
            presentLoginVC()
        } else {
            let addEventVC = AddEventController()
            navigationController?.pushViewController(addEventVC, animated: true)
        }
    }
    
    // MARK: - Helpers
    
    private func bindingViewModel() {
        
    }
    
    private func getSortedHosts(users: [User]) -> [User] {
        var result: [User] = []
        hostsId.forEach { id in
            users.forEach { user in
                if id == user.id ?? "" {
                    result.append(user)
                }
            }
        }
        return result
    }
    
    private func filterBlockedEventsIfNecessary(from events: [Event]) {
        if self.currentUser.blockedUsersId.count == 0 {
            self.events = events
        } else {
            self.filterEventsFromBlockedUsers(events: events) { filteredEvents in
                self.events = filteredEvents
            }
        }
    }
    
    func filterEventsFromBlockedUsers(events: [Event], completion: @escaping ([Event]) -> Void) {
        var result: [Event] = []
        result = events.filter({ !currentUser.blockedUsersId.contains($0.hostID) })
        completion(result)
    }
    
    private func setupProfileView() {
        self.currentUserNameLabel.text = self.currentUser.name
        if let profileURL = URL(string: self.currentUser.profileImageURL) {
            self.currentUserProfileImageView.kf.setImage(with: profileURL)
        } else {
            self.currentUserProfileImageView.image = UIImage(systemName: "person")
        }
    }
    
    private func setupPulsingLayer() {
        let pulseLayer = PulsingLayer(numberOfPulses: .infinity, radius: 50, view: addEventButtonBackgroundView)
        self.addEventButtonBackgroundView.layer.addSublayer(pulseLayer)
    }
    
    private func presentEmptyViewIfNecessary() {
        if evnetHosts.count == 0 {
            configureEmptyAnimationView()
            configureEmptyWarningLabel()
            collectionView.isHidden = true
        } else {
            stopAnimationView()
            emptyWarningLabel.removeFromSuperview()
            collectionView.isHidden = false
        }
    }
    
    private func configureEmptyAnimationView() {
        view.addSubview(emptyAnimationView)
        emptyAnimationView.centerY(inView: view)
        emptyAnimationView.centerX(inView: view)
        emptyAnimationView.widthAnchor.constraint(equalToConstant: view.frame.size.width - 20).isActive = true
        emptyAnimationView.heightAnchor.constraint(equalTo: emptyAnimationView.widthAnchor).isActive = true
        emptyAnimationView.play()
    }
    
    private func stopAnimationView() {
        emptyAnimationView.stop()
        emptyAnimationView.alpha = 0
        emptyAnimationView.removeFromSuperview()
    }
    
    private func configureEmptyWarningLabel() {
        view.addSubview(emptyWarningLabel)
        emptyWarningLabel.centerX(inView: emptyAnimationView)
        emptyWarningLabel.anchor(top: emptyAnimationView.bottomAnchor, paddingTop: 15)
    }
    
    private func endRefreshing() {
        refreshControl.endRefreshing()
        collectionView.reloadData()
        presentLoadingView(shouldPresent: false)
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
    
    private func removePulsingLayer() {
        self.addEventButtonBackgroundView.layer.sublayers?.forEach({ layer in
            if layer is PulsingLayer {
                layer.removeFromSuperlayer()
            }
        })
    }
    
    private func releaseVideoPlayer() {
        collectionView.visibleCells.forEach { cell in
            if let homeCell = cell as? HomeEventCell {
                homeCell.player?.removeAllItems()
                homeCell.player = nil
            }
        }
    }
    
    private func presentLoginVC() {
        let loginController = LoginController()
        let nav = UINavigationController(rootViewController: loginController)
        self.present(nav, animated: true, completion: nil)
    }
    
    private func cleanupLayers() {
        removePulsingLayer()
        releaseVideoPlayer()
    }
    
    private func cleanupEmptyViews() {
        emptyAnimationView.stop()
        emptyWarningLabel.removeFromSuperview()
    }
    
    private func animateProfileView(scrollView: UIScrollView, yOffset: CGFloat, duration: TimeInterval) {
        if scrollView.contentOffset.y >= yOffset && profileView.alpha != 1 {
            profileView.isHidden = false
            profileView.alpha = 0
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, animations: {
                self.profileView.alpha = 1
            })
        } else if scrollView.contentOffset.y < yOffset && profileView.alpha == 1 {
            profileView.alpha = 1
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, animations: {
                self.profileView.alpha = 0
            })
        }
    }
    
    func setupUI() {
        view.addSubview(profileView)
        profileView.isHidden = true
        profileView.alpha = 0
        profileView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                           right: view.rightAnchor, height: 55)
        
        profileView.addSubview(currentUserProfileImageView)
        currentUserProfileImageView.centerY(inView: profileView)
        currentUserProfileImageView.anchor(left: profileView.leftAnchor, paddingLeft: 20)
        currentUserProfileImageView.setDimensions(height: 35, width: 35)
        
        profileView.addSubview(currentUserNameLabel)
        currentUserNameLabel.centerY(inView: currentUserProfileImageView)
        currentUserNameLabel.anchor(left: currentUserProfileImageView.rightAnchor, paddingLeft: 10)
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: profileView.bottomAnchor),
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
}

// MARK: - UICollectionViewDataSource

extension HomeController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1: events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            
            guard let profileCell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeProfileCell.identifier, for: indexPath) as? HomeProfileCell else { return UICollectionViewCell() }
            
            profileCell.configureCell(user: self.currentUser)
            
            return profileCell
            
        } else {
            guard let eventCell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeEventCell.identifier, for: indexPath) as? HomeEventCell else { return UICollectionViewCell() }
            
            eventCell.delegate = self
            let event = events[indexPath.item]
            
            // should have 2 types of config | loggedin user vs no user
            if Auth.auth().currentUser == nil {
                eventCell.configureCell(event: event)
            } else {
                let host = evnetHosts[event.hostID]
                eventCell.configureCellForLoggedInUser(event: event, host: host ?? User())
            }
            
            return eventCell
        }
    }
}

// MARK: - UICollectionViewDelegate

extension HomeController: UICollectionViewDelegate {
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if Auth.auth().currentUser == nil {
            presentLoginVC()
        } else {
            if indexPath.section == 1 {
                let selectedEvent = events[indexPath.item]
                let detailVC = EventDetailController(event: selectedEvent)
                detailVC.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        
        return section == 0 ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0): UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return indexPath.section == 0 ? CGSize(width: view.frame.width, height: 60) : CGSize(width: view.frame.size.width - 40, height: 350)
    }
}

// MARK: - UIScrollViewDelegate
extension HomeController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        animateProfileView(scrollView: scrollView, yOffset: 110, duration: 0.3)
    }
}

// MARK: - HomeEventCellDelegate
extension HomeController: HomeEventCellDelegate {
    
    func didTapReportButton(cell: HomeEventCell) {
        showReportAlert()
    }
}
