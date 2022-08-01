//
//  ExploreController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit
import CHTCollectionViewWaterfallLayout
import FirebaseAuth
import Lottie

class ExploreController: UIViewController, CHTCollectionViewDelegateWaterfallLayout {
    
    // MARK: - Properties
        
    private lazy var collectionView: UICollectionView = {
        let layout = CHTCollectionViewWaterfallLayout()
        layout.itemRenderDirection = .leftToRight
        layout.columnCount = 2
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ExploreCell.self, forCellWithReuseIdentifier: ExploreCell.identifier)
        return collectionView
    }()
    
    private let emptyAnimationView: AnimationView = LottieManager.shared.createLottieView(name: "empty-box", mode: .loop)
        
    private let emptyWarningLabel: UILabel = UILabel().makeBasicSemiboldLabel(fontSize: 20,
                                                                              text: "No Events yet, click the + button to add new event", textAlighment: .center)
    
    private lazy var dateSegmentControl: NTSegmentedControl = {
        let seg = NTSegmentedControl()
        seg.translatesAutoresizingMaskIntoConstraints = false
        seg.borderWidth = 0
        seg.commaSeparatedButtonTitles = "All, Today, Tomorrow, This week"
        seg.textColor = .white
        seg.selectorColor = .primaryBlue
        seg.addTarget(self, action: #selector(dateSegmentValueChange), for: .valueChanged)
        return seg
    }()
    
     lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Events"
        definesPresentationContext = true
        return searchController
    }()
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }
    
    var events: [Event] = []
    
    var filtedEvents: [Event] = []
    
    var randomHeights: [CGFloat] = []
    
    var originalAllEvents: [Event] = []
    
    private var currentUser: User
    
    // MARK: - Life Cycle
    
    init(user: User) {
        self.currentUser = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Auth.auth().currentUser == nil ? self.fetchEvents(): self.fetchCurrentUser()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        emptyAnimationView.stop()
        emptyWarningLabel.removeFromSuperview()
    }
    
    // MARK: - API
    private func fetchEvents() {
        presentLoadingView(shouldPresent: true)
        EventService.shared.fetchAllEvents { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let events):
                if Auth.auth().currentUser == nil {
                    self.events = events
                    self.fetchHosts { hosts in
                        self.processAPICallback(hosts: hosts, events: events)
                    }
                } else {
                    self.filterEventsFromBlockedUsers(events: events) { filteredEvents in
                        // filter blocked users' posts first
                        self.events = filteredEvents
                        self.fetchHosts { hosts in
                            self.processAPICallback(hosts: hosts, events: self.events)
                        }
                    }
                }
            case .failure(let error):
                print("Fail to fetch events in explore VC \(error)")
                self.presentLoadingView(shouldPresent: false)
                self.presentErrorAlert(title: "Error", message: "Fail to fetch events: \(error.localizedDescription)", completion: nil)
            }
        }
    }
    
    private func resetEvents() {
        self.events = originalAllEvents
    }
    
    func filterEventsFromBlockedUsers(events: [Event], completion: @escaping ([Event]) -> Void) {
        var result: [Event] = []
        
        if currentUser.blockedUsersId.count == 0 {
            completion(events)
        } else {
            result = events.filter({ !self.currentUser.blockedUsersId.contains( $0.hostID ) })
            completion(result)
        }
    }
    
    private func fetchCurrentUser() {
        UserService.shared.fetchUser(uid: uid) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.currentUser = user
                self.fetchEvents()
            case .failure(let error):
                self.presentLoadingView(shouldPresent: false)
                self.presentErrorAlert(title: "Error", message: "\(error.localizedDescription)", completion: nil)
            }
        }
    }
    
    private func fetchHosts(completion: @escaping ([User]) -> Void) {
        var hostsId: [String] = []
        let sortedEvents = events.sorted(by: { $0.createTime.dateValue().compare($1.createTime.dateValue()) == .orderedDescending })
        sortedEvents.forEach({hostsId.append($0.hostID)})
        
        UserService.shared.fetchUsers(uids: hostsId) { result in
            switch result {
            case .success(let hosts):
                completion(self.getUndeletedHosts(hosts: hosts))
            case .failure(let error):
                self.presentLoadingView(shouldPresent: false)
                self.presentErrorAlert(message: "\(error.localizedDescription)")
                print("error fetching event hosts \(error)")
            }
        }
    }
    
    // MARK: - Selectors
    
    @objc func dateSegmentValueChange(sender: NTSegmentedControl) {
        switch sender.selectedButtonIndex {
            
        case 0:
            resetEvents()
            collectionView.reloadData()
        case 1:
            resetEvents()
            filterTodaysEvents()
        case 2:
            resetEvents()
            let tomorrow = Calendar(identifier: .gregorian).date(byAdding: .day, value: 1, to: Date()) ?? Date()
            filterEvents(for: tomorrow)
        case 3:
            resetEvents()
            let dateAfterSevenDays = Calendar(identifier: .gregorian).date(byAdding: .day, value: 7, to: Date()) ?? Date()
            filterEvents(for: dateAfterSevenDays)
        default:
            break
        }
    }
    
    // MARK: - Helpers
    
    private func filterTodaysEvents() {
        let filteredEvents = events.filter { Calendar.current.isDateInToday($0.startingDate.dateValue()) }
        
        self.events = filteredEvents
        collectionView.reloadData()
    }
    
    func filterEvents(for date: Date) {
        let filteredEvents = events.filter({ event in
            return event.startingDate.dateValue() >= Date() && event.startingDate.dateValue() <= date
        })
        self.events = filteredEvents
        collectionView.reloadData()
    }
    
    private func processAPICallback(hosts: [User], events: [Event]) {
        self.events = getFilteredEventsFromActiveHosts(hosts: hosts)
        self.originalAllEvents = getFilteredEventsFromActiveHosts(hosts: hosts)
        self.generateRandomHeight(eventCount: events.count)
        self.presentEmptyViewIfNecessary()
        self.endRefreshing()
    }
    
    private func presentEmptyViewIfNecessary() {
        if events.count == 0 {
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
        emptyWarningLabel.anchor(top: emptyAnimationView.bottomAnchor,
                                 left: view.leftAnchor, right: view.rightAnchor,
                                 paddingTop: 15, paddingLeft: 5, paddingRight: 5)
    }
    
    private func endRefreshing() {
        collectionView.reloadData()
        presentLoadingView(shouldPresent: false)
    }
    
    private func getUndeletedHosts(hosts: [User]) -> [User] {
        return hosts.filter({ $0.name != "Unknown User" })
    }
    
    func getFilteredEventsFromActiveHosts(hosts: [User]) -> [Event] {
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
    
    private func generateRandomHeight(eventCount: Int) {
        if eventCount == 0 {
            return
        }
        
        for _ in 0...eventCount - 1 {
            self.randomHeights.append(CGFloat(Int.random(in: 150...400)))
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        collectionView.backgroundColor = .black
        configureChatNavBar(withTitle: "Explore", preferLargeTitles: true)
        view.addSubview(dateSegmentControl)
        NSLayoutConstraint.activate([
            dateSegmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dateSegmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            dateSegmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            dateSegmentControl.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        navigationItem.searchController = searchController
        
        view.addSubview(collectionView)
        collectionView.anchor(top: dateSegmentControl.bottomAnchor,
                              left: view.leftAnchor,
                              bottom: view.bottomAnchor,
                              right: view.rightAnchor,
                              paddingTop: 8
        )
    }
    
    func filterContentForSearchText(_ searchText: String) {
        
        filtedEvents = events.filter({ event in
            return event.title.lowercased().contains(searchText.lowercased())
        })
        
        collectionView.reloadData()
    }
    
    private func presentLoginVC() {
        let loginController = LoginController()
        let nav = UINavigationController(rootViewController: loginController)
        self.present(nav, animated: true, completion: nil)
    }
    
    // MARK: - CHTCollectionViewDelegateWaterfallLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.size.width/2, height: randomHeights[indexPath.row])
    }
}

// MARK: - UICollectionViewDataSource
extension ExploreController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        isFiltering ? filtedEvents.count: events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let exploreCell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreCell.identifier, for: indexPath) as? ExploreCell else { return UICollectionViewCell() }
        
        let event: Event
        event = isFiltering ? filtedEvents[indexPath.row]: events[indexPath.row]
        exploreCell.configureCell(with: event)
        
        return exploreCell
    }
    
}

// MARK: - UICollectionViewDelegate
extension ExploreController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if Auth.auth().currentUser == nil {
            presentLoginVC()
        } else {
            let event: Event
            event = isFiltering ? filtedEvents[indexPath.item]: events[indexPath.item]
            let detailedVC = EventDetailController(event: event)
            detailedVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(detailedVC, animated: true)
        }
    }
}

// MARK: - UISearchResultsUpdating
extension ExploreController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchingText = searchController.searchBar.text else { return }
        
        filterContentForSearchText(searchingText)
    }
}
