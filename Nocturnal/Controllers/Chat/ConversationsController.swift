//
//  ConversationsController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/19.
//

import UIKit
import SwiftUI

class ConversationsController: UIViewController {
    
    // MARK: - Properties

    private lazy var tableView: UITableView = {
       let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 80
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.tableFooterView = UIView()
        return table
    }()
    
    private lazy var newMessageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .systemPurple
        button.tintColor = .white
        button.setDimensions(height: 56, width: 56)
        button.addTarget(self, action: #selector(showNewMessage), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life cycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Selectors
    
    @objc func handleDismiss() {
        self.dismiss(animated: true)
    }
    
    @objc func showNewMessage() {
        let newMessageVC = NewMessageController()
        let nav = UINavigationController(rootViewController: newMessageVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    // MARK: - Helpers
    
    func setupUI() {
        configureChatNavBar(withTitle: "Messages", preferLargeTitles: true)
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.fillSuperview()
        
        view.addSubview(newMessageButton)
        newMessageButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                right: view.rightAnchor,
                                paddingBottom: 16,
                                paddingRight: 24)
        
        newMessageButton.layer.cornerRadius = 56/2
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "x.circle.fill"), style: .plain, target: self, action: #selector(handleDismiss))
    }
}

// MARK: - UITableViewDataSource
extension ConversationsController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = "Text cell"
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension ConversationsController: UITableViewDelegate {
    
}
