//
//  BlockedUsersController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/30.
//

import UIKit
import FirebaseAuth

class BlockedUsersController: UIViewController {
    
    // MARK: - Propeties
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = UIColor.hexStringToUIColor(hex: "#3F4E4F")
        table.register(BlockListCell.self, forCellReuseIdentifier: BlockListCell.identifier)
        return table
    }()
    
    var blockedUsers: [User] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchBlockedUsers()
    }
    
    func setupUI() {
        navigationController?.navigationBar.isHidden = false
        
        configureChatNavBar(withTitle: "Blocked Users", backgroundColor: UIColor.hexStringToUIColor(hex: "#3F4E4F"), preferLargeTitles: true)
        
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
}

// MARK: - UITableViewDataSource
extension BlockedUsersController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        blockedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let blockUserCell = tableView.dequeueReusableCell(withIdentifier: BlockListCell.identifier, for: indexPath) as? BlockListCell else { return UITableViewCell() }
        
        let blockedUser = blockedUsers[indexPath.row]
        
        blockUserCell.configureCell(user: blockedUser)
        
        return blockUserCell
    }
    
    // MARK: - API
    private func fetchBlockedUsers() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("no current user in BlockedUsersController")
            return
        }
        
        UserService.shared.fetchUser(uid: currentUserId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                UserService.shared.fetchUsers(uids: user.blockedUsersId) {result in
                    switch result {
                    case .success(let blockedUsers):
                        self.blockedUsers = blockedUsers
                    case .failure(let error):
                        print("Fail to fetch blocked users \(error)")
                    }
                }
            case .failure(let error):
                print("Fail to fetch current users \(error)")
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension BlockedUsersController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedBlockedUser = blockedUsers[indexPath.row]
        let profileVC = ProfileController(user: selectedBlockedUser)
        // go to profileVC
        present(profileVC, animated: true)
    }
}
