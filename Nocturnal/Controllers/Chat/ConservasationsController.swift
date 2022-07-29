//
//  ConservasationsController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/21.
//

import UIKit

class ConversationsController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var tableView: UITableView = {
       let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 80
        table.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.identifier)
        return table
    }()
    
    private var conversations: [Conversation] = []
    
    private var currentUser: User?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchCurrentUser { [weak self] user in
            guard let self = self else { return }
            self.currentUser = user
            self.fetchConversations()
        }
    }
    
    // MARK: - API
    
    private func fetchConversations() {
        presentLoadingView(shouldPresent: true)
        MessegeService.shared.fetchConversations { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let conversations):
                self.conversations = self.filterConversationsFromBlockedUser(conversations: conversations)
                self.tableView.reloadData()
                self.presentLoadingView(shouldPresent: false)
            case .failure(let error):
                self.presentLoadingView(shouldPresent: false)
                self.presentErrorAlert(title: "Error", message: "\(error.localizedDescription)", completion: nil)
            }
        }
    }
    
    private func fetchCurrentUser(completion: @escaping (User) -> Void) {
        UserService.shared.fetchUser(uid: uid) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                completion(user)
            case .failure(let error):
                self.presentLoadingView(shouldPresent: false)
                self.presentErrorAlert(title: "Error", message: "\(error.localizedDescription)", completion: nil)
            }
        }
    }
    
    private func filterConversationsFromBlockedUser(conversations: [Conversation]) -> [Conversation] {
        guard let currentUser = currentUser else {
            presentErrorAlert(title: "Error", message: "Current user is not existed", completion: nil)
            print("current user nil in conversation VC")
            return []
        }
        
        if currentUser.blockedUsersId.count == 0 {
            return conversations
        }

        var result: [Conversation] = []
        result = conversations.filter({ !currentUser.blockedUsersId.contains($0.user.id ?? "") })
        return result
    }
    
    // MARK: - Selector
    @objc private func handleDismissal() {
        self.dismiss(animated: true)
    }
    
    // MARK: - Helpers
    private func setupUI() {
        configureChatNavBar(withTitle: "Conversations", preferLargeTitles: true)
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "x.circle.fill"), style: .plain, target: self, action: #selector(handleDismissal))
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
    
    private func showChatController(for user: User) {
        let chatVC = ChatController(user: user)
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

extension ConversationsController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let convoell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.identifier, for: indexPath) as? ConversationCell else { return UITableViewCell() }
        
        let conversation = conversations[indexPath.row]
        convoell.configureCell(conversation: conversation)
        return convoell
    }
}

extension ConversationsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedConversation = conversations[indexPath.row]
        showChatController(for: selectedConversation.user)
    }
}
