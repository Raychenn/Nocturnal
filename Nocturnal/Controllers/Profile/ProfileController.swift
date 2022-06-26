//
//  ProfileController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit

class ProfileController: UIViewController {

    // MARK: - Properties
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.allowsSelection = false
        table.backgroundColor = .black
        table.contentInsetAdjustmentBehavior = .never
        table.register(ProfileCell.self, forCellReuseIdentifier: ProfileCell.identifier)
        table.register(ProfileHeader.self, forHeaderFooterViewReuseIdentifier: ProfileHeader.identifier)
        let footerView = UIView()
        footerView.backgroundColor = .white
        table.tableFooterView = footerView
        return table
    }()
    
    private let currentUser: User
        
    private var joinedEventURLs: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Life Cycle
    
    init(user: User) {
        self.currentUser = user
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchJoinEvents()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - API

    private func fetchJoinEvents() {
        EventService.shared.fetchEvents(fromEventIds: currentUser.joinedEventsId) { result in
            switch result {
            case .success(let events):
                events.forEach({ self.joinedEventURLs.append($0.eventImageURL) })
            case .failure(let error):
                print("Fail to fetch events \(error)")
            }
        }
    }
    
    // MARK: - Helpers
    func setupUI() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
}

// MARK: - UITableViewDataSource
extension ProfileController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let profileCell = tableView.dequeueReusableCell(withIdentifier: ProfileCell.identifier, for: indexPath) as? ProfileCell else { return UITableViewCell() }
        profileCell.delegate = self
        profileCell.user = self.currentUser
        profileCell.configureCell(with: currentUser, joinedEventsURL: joinedEventURLs)
        return profileCell
    }
}

// MARK: - UITableViewDelegate
extension ProfileController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let profileHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: ProfileHeader.identifier) as? ProfileHeader else { return UIView() }
        
        let gradientView = UIView(frame: profileHeader.profileImageView.frame)
        let gradient = CAGradientLayer()
        gradient.frame = gradientView.frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0, 1.0]
        gradientView.layer.insertSublayer(gradient, at: 0)
        profileHeader.profileImageView.addSubview(gradientView)
        profileHeader.bringSubviewToFront(gradientView)

        profileHeader.user = currentUser
        profileHeader.configureHeader(user: currentUser)
        return profileHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        400
    }
}

// MARK: - ProfileCellDelegate
extension ProfileController: ProfileCellDelegate {

    func didTapEditProfile(cell: ProfileCell) {
        let editProfileVC = EditProfileController(user: currentUser)
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    func didTapOpenConversation(cell: ProfileCell) {
        let conversationVC = ConversationsController()
        let nav = UINavigationController(rootViewController: conversationVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    func didTapSelectedEvent(cell: ProfileCell, event: Event) {
        let detailController = EventDetailController(event: event)
        navigationController?.pushViewController(detailController, animated: true)
    }
}
