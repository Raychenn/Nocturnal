//
//  MainBarController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - API
    
    func authenticateUserAndConfigureUI() {
//        try? Auth.auth().signOut()
        
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
                print("user logged in current user name is \(self.currentUser?.name)")
                self.configureViewControllers(with: user)
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
                print("Fail to fetch user \(error)")
            }
        }
    }
    
    // MARK: - helpers
    
    func configureTabBarStyle() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemThickMaterialDark)
        tabBar.scrollEdgeAppearance = appearance
        tabBar.standardAppearance = appearance
    }
    
    func configureViewControllers(with user: User) {
        tabBar.tintColor = .black
        tabBar.isTranslucent = false
        self.delegate = self
        
        view.backgroundColor = .white
        let home = templateNavigationViewController(unselectedImage: UIImage(systemName: "house")!, selectedImage: UIImage(systemName: "house.fill")!, rootViewController: HomeController(currentUser: user))
        
        let explore = templateNavigationViewController(unselectedImage: UIImage(systemName: "magnifyingglass")!, selectedImage: UIImage(systemName: "magnifyingglass")!, rootViewController: ExploreController())
        
        let stats = templateNavigationViewController(unselectedImage: UIImage(systemName: "clock")!, selectedImage: UIImage(systemName: "clock.fill")!, rootViewController: StatsController(user: user))
        
        let notification = templateNavigationViewController(unselectedImage: UIImage(systemName: "heart")!, selectedImage: UIImage(systemName: "heart.fill")!, rootViewController: NotificationController(user: user))
         
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
