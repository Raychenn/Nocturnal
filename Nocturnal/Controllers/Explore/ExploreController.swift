//
//  ExploreController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit
import CHTCollectionViewWaterfallLayout
import FirebaseAuth

class ExploreController: UIViewController, CHTCollectionViewDelegateWaterfallLayout {
    
    // MARK: - Properties
    
    let refreshControl = UIRefreshControl()
    
    private lazy var collectionView: UICollectionView = {
        
        let layout = CHTCollectionViewWaterfallLayout()
        layout.itemRenderDirection = .leftToRight
        layout.columnCount = 2
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.refreshControl = refreshControl
        collectionView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.register(ExploreCell.self, forCellWithReuseIdentifier: ExploreCell.identifier)
        return collectionView
    }()
    
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
    
    private lazy var searchController: UISearchController = {
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
        
        if Auth.auth().currentUser == nil {
            self.fetchEvents()
        } else {
            fetchCurrentUser { [weak self] user in
                guard let self = self else { return }
                
                self.currentUser = user
                self.fetchEvents()
            }
        }
    }
    
    // MARK: - API
    private func fetchEvents() {
        refreshControl.beginRefreshing()
        presentLoadingView(shouldPresent: true)
        EventService.shared.fetchAllEvents { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let events):
                if Auth.auth().currentUser == nil {
                    self.events = events
                    self.originalAllEvents = events
                    self.generateRandomHeight(eventCount: events.count)
                    self.refreshControl.endRefreshing()
                    self.collectionView.reloadData()
                    self.presentLoadingView(shouldPresent: false)
                } else {
                    self.filterEventsFromBlockedUsers(events: events) { [weak self] filteredEvents in
                        guard let self = self else { return }
                        print("filter events count in explore VC \(filteredEvents.count)")
                        self.events = filteredEvents
                        self.originalAllEvents = filteredEvents
                        self.generateRandomHeight(eventCount: filteredEvents.count)
                        self.refreshControl.endRefreshing()
                        self.collectionView.reloadData()
                        self.presentLoadingView(shouldPresent: false)
                }
            }
            case .failure(let error):
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
    
    private func fetchCurrentUser(completion: @escaping (User) -> Void) {
        UserService.shared.fetchUser(uid: uid) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                completion(user)
            case .failure(let error):
                self.presentErrorAlert(title: "Error", message: "\(error.localizedDescription)", completion: nil)
            }
        }
    }
    
    // MARK: - Selectors
    
    @objc func refreshData() {
        fetchEvents()
    }
    
    @objc func dateSegmentValueChange(sender: NTSegmentedControl) {
        
        switch sender.selectedButtonIndex {
            
        case 0:
            print("get all events")
            resetEvents()
            collectionView.reloadData()
        case 1:
            resetEvents()
            let calendar = Calendar.current
            
            let filteredEvents = events.filter { event in
                return calendar.isDateInToday(event.startingDate.dateValue())
            }
            
            self.events = filteredEvents
            collectionView.reloadData()
        case 2:
            resetEvents()
            let tomorrow = Calendar(identifier: .gregorian).date(byAdding: .day, value: 1, to: Date()) ?? Date()
            
            let filteredEvents = events.filter({ event in
                 if event.startingDate.dateValue() >= Date() && event.startingDate.dateValue() <= tomorrow {
                     return true
                 } else {
                     return false
                 }
             })
            self.events = filteredEvents
            collectionView.reloadData()
        case 3:
            resetEvents()
            let today = Date()
            let dateAfterSevenDays = Calendar(identifier: .gregorian).date(byAdding: .day, value: 7, to: Date()) ?? Date()
            
           let filteredEvents = events.filter({ event in
                if event.startingDate.dateValue() >= today && event.startingDate.dateValue() <= dateAfterSevenDays {
                    return true
                } else {
                    return false
                }
            })
            
            self.events = filteredEvents
            collectionView.reloadData()
        default:
            break
        }
    }
    
    // MARK: - Helpers
    
    func generateRandomHeight(eventCount: Int) {
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
                              bottom: view.safeAreaLayoutGuide.bottomAnchor,
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
        
        if isFiltering {
            event = filtedEvents[indexPath.row]
        } else {
            event = events[indexPath.row]
        }
              
        exploreCell.configureCell(with: event)
        
        return exploreCell
    }
    
}

// MARK: - UICollectionViewDelegate
extension ExploreController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginController = LoginController()
                let nav = UINavigationController(rootViewController: loginController)
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            let event: Event
            
            if isFiltering {
                event = filtedEvents[indexPath.item]
            } else {
                event = events[indexPath.item]
            }
            
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
