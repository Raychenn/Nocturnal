//
//  ProfileController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit

class ProfileController: UIViewController {

    // MARK: - Properties
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Selectors
    
    @objc func didTapConversationButton() {
        let conversationVC = ConversationsController()
        let nav = UINavigationController(rootViewController: conversationVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    // MARK: - Helpers
    func setupUI() {
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "message"), style: .plain, target: self, action: #selector(didTapConversationButton))
    }
    
}
