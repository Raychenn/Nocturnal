//
//  UIViewController+Ext.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit

extension UIViewController {
    
    var isModal: Bool {

        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController

        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
    
    func configureChatNavBar(withTitle: String, backgroundColor: UIColor? = UIColor.black, preferLargeTitles: Bool) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = backgroundColor
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        navigationController?.navigationBar.prefersLargeTitles = preferLargeTitles
        navigationItem.title = withTitle
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = true
        
        navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
    }
    
    func configureGradientLayer() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.darkGray.cgColor, UIColor.black.cgColor]
        gradient.locations = [0, 1]
        view.layer.addSublayer(gradient)
        gradient.frame = view.frame
    }
    
    func setNavigationBarColor(bgColor: UIColor, textColor: UIColor, tintColor: UIColor, titleTextSize size: CGFloat = 22) {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = bgColor
        appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.medium(size: size) as Any, NSAttributedString.Key.foregroundColor: textColor]
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationController?.navigationBar.shadowImage = UIImage()
        appearance.shadowColor = .clear
        appearance.configureWithDefaultBackground()
        navigationController?.navigationBar.tintColor = tintColor
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func presentDeleteAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
        
        present(alert, animated: true)
    }

    func presentLoadingView(shouldPresent: Bool, message: String? = nil) {
        let loadingView = UIView()
        let indicator = UIActivityIndicatorView()
        let messageLabel = UILabel()

        if shouldPresent {
            view.addSubview(loadingView)
            loadingView.backgroundColor = .black
            loadingView.frame = view.bounds
            loadingView.alpha = 0
            loadingView.tag = 1
            
            UIView.animate(withDuration: 0.3) {
                loadingView.alpha = 0.7
            }
            
            loadingView.addSubview(indicator)
            indicator.style = .large
            indicator.center = view.center
            indicator.startAnimating()
            
            loadingView.addSubview(messageLabel)
            messageLabel.text = message
            messageLabel.textColor = .white
            messageLabel.alpha = 0.87
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont.systemFont(ofSize: 25)
            messageLabel.centerX(inView: view, topAnchor: indicator.bottomAnchor, paddingTop: 25)

        } else {
            // dismiss and remove loading view
            UIView.animate(withDuration: 0.3) {
                loadingView.alpha = 0
            }
            
            view.subviews.forEach { subview in
                if subview.tag == 1 {
                    subview.removeFromSuperview()
                }
            }
            
        }
    }
    
}
