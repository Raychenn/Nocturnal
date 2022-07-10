//
//  MainBarController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class MainTabBarController: UITabBarController {

    // MARK: - Properties
    
    var currentUser: User?
    
    let defaultUser = User(id: "guest", name: "", email: "", country: "", profileImageURL: "", birthday: Timestamp(date: Date()), gender: 2, numberOfHostedEvents: 0, bio: "", joinedEventsId: [], blockedUsersId: [], requestedEventsId: [])
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureTabBarStyle()
        self.configureNavigationBarUI()
        self.authenticateUserAndConfigureUI()
    }
    
    // MARK: - API
    
    func authenticateUserAndConfigureUI() {
        
        if Auth.auth().currentUser == nil {
            self.configureViewControllers(with: defaultUser)
            DispatchQueue.main.async {
                let loginController = LoginController()
                let nav = UINavigationController(rootViewController: loginController)
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            // user is logged in
            fetchCurrentUser { [weak self] user in
                guard let self = self else { return }
                self.currentUser = user
                self.configureViewControllers(with: user)
                self.selectedIndex = 0
            }
        }
    }
    
    private func fetchCurrentUser(completion: @escaping (User) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.shared.fetchUser(uid: uid) { result in
            switch result {
            case .success(let user):
                completion(user)
            case .failure(let error):
                self.presentErrorAlert(message: "\(error.localizedDescription)")
                self.presentLoadingView(shouldPresent: false)
                print("Fail to fetch user \(error)")
            }
        }
    }
    
    // MARK: - helpers
    
    func configureTabBarStyle() {
        let appearance = UITabBarAppearance()
        tabBar.isTranslucent = true
        tabBar.clipsToBounds = true
        tabBar.backgroundColor = .clear
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterialDark)
        tabBar.scrollEdgeAppearance = appearance
        tabBar.standardAppearance = appearance
    }
    
    func configureViewControllers(with user: User) {
        self.delegate = self
        
        let home = templateNavigationViewController(unselectedImage: UIImage(systemName: "house")!, selectedImage: UIImage(systemName: "house.fill")!, rootViewController: HomeController(currentUser: user))
        
        let explore = templateNavigationViewController(unselectedImage: UIImage(systemName: "magnifyingglass")!, selectedImage: UIImage(systemName: "magnifyingglass")!, rootViewController: ExploreController(user: user))
        
        let stats = templateNavigationViewController(unselectedImage: UIImage(systemName: "clock")!, selectedImage: UIImage(systemName: "clock.fill")!, rootViewController: StatsController(user: user))
        
        let notification = templateNavigationViewController(unselectedImage: UIImage(systemName: "bell")!, selectedImage: UIImage(systemName: "bell.fill")!, rootViewController: NotificationController(user: user))
         
        let profile = templateNavigationViewController(unselectedImage: UIImage(systemName: "person")!, selectedImage: UIImage(systemName: "person.fill")!, rootViewController: ProfileController(user: user))
    
        viewControllers = [home, explore, stats, notification, profile]
    }
    
    func templateNavigationViewController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController) -> UINavigationController {
        
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = unselectedImage
        nav.tabBarItem.selectedImage = selectedImage
        nav.navigationBar.tintColor = .black
        return nav
    }
    
    func configureNavigationBarUI() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
    }
}

// MARK: - UITabBarControllerDelegate
extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.firstIndex(of: viewController)

        if Auth.auth().currentUser != nil || index == 0 || index == 1 {
            return true
        } else {
            authenticateUserAndConfigureUI()
            return false
        }
    }
}
