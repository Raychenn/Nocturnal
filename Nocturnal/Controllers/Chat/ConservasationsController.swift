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
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
//        fetchConversations()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchConversations()
        configureChatNavBar(withTitle: "Conversations", preferLargeTitles: true)
    }
    
    // MARK: - API
    
    private func fetchConversations() {
        MessegeService.shared.fetchConversations { result in
            switch result {
            case .success(let conversations):
                self.conversations = conversations
                self.tableView.reloadData()
            case .failure(let error):
                print("Fail to fetch conversations \(error)")
            }
        }
    }
    
    // MARK: - Selector
    @objc private func handleDismissal() {
        self.dismiss(animated: true)
    }
    
    // MARK: - Helpers
    private func setupUI() {
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
