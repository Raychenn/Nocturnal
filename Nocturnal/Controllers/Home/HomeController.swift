//
//  HomeController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit
import FirebaseAuth

class HomeController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.hexStringToUIColor(hex: "#1C242F")
        collectionView.register(HomeEventCell.self, forCellWithReuseIdentifier: HomeEventCell.identifier)
        return collectionView
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
    
    let cellHeight: CGFloat = 100
    
    var events: [Event] = []
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // fetch all events from firestore
        fetchAllEvents()
    }
    
    // MARK: - API
    
    private func fetchAllEvents() {
        EventService.shared.fetchAllEvents { [weak self] result in
            switch result {
            case .success(let events):
                self?.events = events
                self?.collectionView.reloadData()
            case .failure(let error):
                print("error fetching all events \(error)")
            }
        }
    }
    
    // MARK: - Selectors
    
    @objc func didTapShowEventButton() {
        let addEventVC = AddEventController()
        navigationController?.pushViewController(addEventVC, animated: true)
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Fail to log out \(error)")
        }
       
       checkIfUserIsLoggedIn()
    }
    
    // MARK: - Helpers
    
    private func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { _, _ in
            // Item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // Group
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalWidth(0.9))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 120, leading: 2.5, bottom: 0, trailing: 2.5)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.visibleItemsInvalidationHandler = { (items, offset, environment) in
                items.forEach { item in
                    let distanceFromCenter = abs((item.frame.midX - offset.x) - environment.container.contentSize.width / 2.0)
                    let minScale: CGFloat = 0.7
                    let maxScale: CGFloat = 1.25
                    let scale = max(maxScale - (distanceFromCenter / environment.container.contentSize.width), minScale)
                    item.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }
            return section
        }
    }
    
    func setupUI() {
        configureChatNavBar(withTitle: "Home", backgroundColor: UIColor.hexStringToUIColor(hex: "#1C242F"), preferLargeTitles: true)
        navigationItem.title = "Home"
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        view.addSubview(addEventButton)
        
        addEventButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                              right: view.rightAnchor,
                              paddingBottom: 10,
                              paddingRight: 8)
        
        addEventButton.layer.cornerRadius = 60/2
        addEventButton.layer.masksToBounds = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(handleLogout))
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginController = LoginController()
                // after log in completes, we delegate the action of fetching/updating user function back to MainTabBarController so that all other controllers will also take effects
                let nav = UINavigationController(rootViewController: loginController)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension HomeController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let eventCell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeEventCell.identifier, for: indexPath) as? HomeEventCell else { return UICollectionViewCell() }
        
        let event = events[indexPath.item]
        eventCell.configureCell(event: event)
        
        return eventCell
    }
}

// MARK: - UICollectionViewDelegate

extension HomeController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedEvent = events[indexPath.item]
        let detailVC = EventDetailController(event: selectedEvent)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return UIMenu() }
            let selectedEvent = self.events[indexPath.item]
            let selecrtedEventId = selectedEvent.id ?? ""
            let currentUserId = uid
            let selectedEventHostId = selectedEvent.hostID
            let deleteAction = UIAction(title: "Delete",
                                            image: UIImage(systemName: "trash"),
                                            identifier: nil, discoverabilityTitle: nil,
                                            attributes: .destructive, state: .off) { _ in
                if selectedEventHostId != uid {
                    let alert = UIAlertController(title: "Oops!", message: "You are not the host of this event", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true)
                } else {
                    EventService.shared.deleteEvent(eventId: selecrtedEventId) { error in
                        if let error = error {
                            print("Fail to delete event \(error)")
                            return
                        }
                        UserService.shared.deleteJoinedEvent(eventId: selecrtedEventId) { error in
                            if let error = error {
                                print("Fail to delete JoinedEvent for user \(error)")
                                return
                            }
                            UserService.shared.deleteRequestedEvent(eventId: selecrtedEventId) { error in
                                if let error = error {
                                    print("Fail to delete RequestedEvent for user \(error)")
                                    return
                                }
                                NotificationService.shared.deleteNotifications(eventId: selecrtedEventId, forUserId: selectedEventHostId) { error in
                                    if let error = error {
                                        print("Fail to delete Notifications for host \(error)")
                                        return
                                    }
                                    NotificationService.shared.deleteNotifications(eventId: selecrtedEventId, forUserId: currentUserId) { error in
                                        if let error = error {
                                            print("Fail to delete Notifications for current user \(error)")
                                            return
                                        }
                                        self.events.remove(at: indexPath.item)
    //                                    collectionView.deleteItems(at: [indexPath])
                                        collectionView.reloadData()
                                        print("Successfully delete event")
                                    }
                                }
                            }
                        }
                    }
                }
            }
                return UIMenu(title: "", image: nil, identifier: nil, options: .destructive, children: [deleteAction])
        }
        return config
    }
}
