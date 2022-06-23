//
//  MainBarController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit
import FirebaseAuth

class MainTabBarController: UITabBarController {

    // MARK: - Properties
    
    var currentUser: User?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCurrentUser { [weak self] user in
            guard let self = self else { return }
            self.currentUser = user
            self.configureViewControllers()
            self.configureTabBarStyle()
            self.configureNavigationBarUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.checkIfUserIsLoggedIn()
    }
    
    // MARK: - API
    
    func checkIfUserIsLoggedIn() {
//        try? Auth.auth().signOut()
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
    
    private func fetchCurrentUser(completion: @escaping (User) -> Void) {
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
    
    func configureViewControllers() {
        guard let currentUser = currentUser else {
            print("Current user nil")
            return
        }
        // conform to delegate
        self.delegate = self
        
        view.backgroundColor = .white
        let home = templateNavigationViewController(unselectedImage: UIImage(systemName: "house")!, selectedImage: UIImage(systemName: "house.fill")!, rootViewController: HomeController())
        
        let explore = templateNavigationViewController(unselectedImage: UIImage(systemName: "magnifyingglass")!, selectedImage: UIImage(systemName: "magnifyingglass")!, rootViewController: ExploreController())
        
        let stats = templateNavigationViewController(unselectedImage: UIImage(systemName: "clock")!, selectedImage: UIImage(systemName: "clock.fill")!, rootViewController: StatsController())
        
        let notification = templateNavigationViewController(unselectedImage: UIImage(systemName: "heart")!, selectedImage: UIImage(systemName: "heart.fill")!, rootViewController: NotificationController())
         
//        let profileController = ProfileContoller(user: user)
        let profile = templateNavigationViewController(unselectedImage: UIImage(systemName: "person")!, selectedImage: UIImage(systemName: "person.fill")!, rootViewController: ProfileController(user: currentUser))
        
        viewControllers = [home, explore, stats, notification, profile]
        tabBar.tintColor = .black
        tabBar.isTranslucent = false
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
        return true
    }
}
