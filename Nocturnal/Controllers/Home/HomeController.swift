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
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .black
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
        
    var events: [Event] = [] {
        didSet {
            var hostsId: [String] = []
            events.forEach({hostsId.append($0.hostID)})
            fetchHosts(hostsId: hostsId)
        }
    }
    
    var evnetHosts: [User] = []
    
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
            guard let self = self else { return }
            switch result {
            case .success(let events):
                self.events = events
            case .failure(let error):
                print("error fetching all events \(error)")
            }
        }
    }
    
    private func fetchHosts(hostsId: [String]) {
        UserService.shared.fetchUsers(uids: hostsId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let hosts):
                self.evnetHosts = hosts
                self.collectionView.reloadData()
            case .failure(let error):
                print("error fetching event hosts \(error)")
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("events.count \(events.count)")
        return events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let eventCell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeEventCell.identifier, for: indexPath) as? HomeEventCell else { return UICollectionViewCell() }
        
        // should have 2 types of config | loggedin user vs no user
        let event = events[indexPath.item]
        let host = evnetHosts[indexPath.item]

        eventCell.configureCell(event: event, host: host)
        
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
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.size.width - 40, height: 350)
    }
}
