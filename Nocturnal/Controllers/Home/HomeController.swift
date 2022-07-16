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
        button.setDimensions(height: 60, width: 60)
        button.setImage(UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.primaryBlue
        button.addTarget(self, action: #selector(didTapShowEventButton), for: .touchUpInside)
        return button
    }()
    
    private let emptyAnimationView: AnimationView = {
       let view = AnimationView(name: "empty-box")
        view.loopMode = .loop
        view.contentMode = .scaleAspectFill
        view.animationSpeed = 1
        view.backgroundColor = .clear
        view.play()
        return view
    }()
    
    private let emptyWarningLabel: UILabel = {
       let label = UILabel()
        label.text = "No Events yet, click the + button to add new event"
        label.font = .satisfyRegular(size: 25)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private let currentUserNameLabel: UILabel = {
       let label = UILabel()
        label.text = "Loading Name"
        label.textColor = .white
        label.font = .satisfyRegular(size: 18)
        return label
    }()
    
    private let currentUserProfileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lightGray
        imageView.tintColor = .black
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let profileView: UIView = {
       let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
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
    
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        currentUserProfileImageView.layer.cornerRadius = 35/2
        
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
            self.currentUserNameLabel.text = self.currentUser.name
            if let profileURL = URL(string: self.currentUser.profileImageURL) {
                self.currentUserProfileImageView.kf.setImage(with: profileURL)
            } else {
                self.currentUserProfileImageView.image = UIImage(systemName: "person")
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removePulsingLayer()
        releaseVideoPlayer()
        emptyAnimationView.stop()
        emptyWarningLabel.removeFromSuperview()
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
            events.forEach({hostsId.append($0.hostID)})
            
            fetchHosts(hostsId: hostsId) { [weak self] in
                guard let self = self else { return }
                self.filterEventsForDeletedUser(hosts: self.evnetHosts)
                self.presentEmptyViewIfNecessary()
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
    
    private func showReportAlert() {
        let reportAlert = UIAlertController(title: "Please select a problem", message: "If someone is in immediate problem danger, get help before reporting to NocturnalHuman", preferredStyle: .alert)
        
        let responseAlert = UIAlertController(title: "Thanks for reporting this event", message: "We will review this event and remove anything that does not follow our standards as quickly as possible", preferredStyle: .alert)
        responseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        reportAlert.addAction(UIAlertAction(title: "Nudity", style: .default, handler: { _ in
            self.present(responseAlert, animated: true)
        }))
        
        reportAlert.addAction(UIAlertAction(title: "Violence", style: .default, handler: { _ in
            self.present(responseAlert, animated: true)
        }))
        
        reportAlert.addAction(UIAlertAction(title: "Harassment", style: .default, handler: { _ in
            self.present(responseAlert, animated: true)
        }))
        
        reportAlert.addAction(UIAlertAction(title: "Suicide or self-injury", style: .default, handler: { _ in
            self.present(responseAlert, animated: true)
        }))
        
        reportAlert.addAction(UIAlertAction(title: "False information", style: .default, handler: { _ in
            self.present(responseAlert, animated: true)
        }))
        
        reportAlert.addAction(UIAlertAction(title: "Spam", style: .default, handler: { _ in
            self.present(responseAlert, animated: true)
        }))
        
        reportAlert.addAction(UIAlertAction(title: "Hate speech", style: .default, handler: { _ in
            self.present(responseAlert, animated: true)
        }))
        
        reportAlert.addAction(UIAlertAction(title: "Terrorism", style: .default, handler: { _ in
            self.present(responseAlert, animated: true)
        }))
        
        reportAlert.addAction(UIAlertAction(title: "Something else", style: .default, handler: { _ in
            self.present(responseAlert, animated: true)
        }))
        
        reportAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(reportAlert, animated: true)
    }
    
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
        navigationController?.navigationBar.isHidden = true
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
        if scrollView.contentOffset.y >= 110 && profileView.alpha != 1 {
            profileView.isHidden = false
            profileView.alpha = 0
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, animations: {
                self.profileView.alpha = 1
            })
        } else if scrollView.contentOffset.y < 110 && profileView.alpha == 1 {
            profileView.alpha = 1
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, animations: {
                self.profileView.alpha = 0
            })
        }
    }
}

// MARK: - HomeEventCellDelegate
extension HomeController: HomeEventCellDelegate {
    
    func didTapReportButton(cell: HomeEventCell) {
        showReportAlert()
    }
}
