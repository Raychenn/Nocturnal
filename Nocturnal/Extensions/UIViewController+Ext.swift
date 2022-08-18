//
//  UIViewController+Ext.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit

extension UIViewController {
    
     func showReportAlert() {
        let reportAlert = UIAlertController(title: "Please select a problem", message: "If someone is in immediate problem danger, get help before reporting to NocturnalHuman", preferredStyle: .alert)
        
        let responseAlert = UIAlertController(title: "Thanks for reporting this event", message: "We will review this event and remove anything that does not follow our standards as quickly as possible", preferredStyle: .alert)
        responseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        reportAlert.addAction(UIAlertAction(title: "Nudity", style: .default, handler: { _ in
            self.present(responseAlert, animated: true)
        }))
        
        reportAlert.addAction(UIAlertAction(title: "Violence", style: .default, handler: { _ in
            self.present(responseAlert, animated: true)
        }))
        
        reportAlert.addAction(UIAlertAction(title: "Harassment", style: .default, handler: { _ in
            self.present(responseAlert, animated: true)
        }))
        
        reportAlert.addAction(UIAlertAction(title: "Suicide or self-injury", style: .default, handler: { _ in
            self.present(responseAlert, animated: true)
        }))
        
        reportAlert.addAction(UIAlertAction(title: "False information", style: .default, handler: { _ in
            self.present(responseAlert, animated: true)
        }))
        
        reportAlert.addAction(UIAlertAction(title: "Spam", style: .default, handler: { _ in
            self.present(responseAlert, animated: true)
        }))
        
        reportAlert.addAction(UIAlertAction(title: "Hate speech", style: .default, handler: { _ in
            self.present(responseAlert, animated: true)
        }))
        
        reportAlert.addAction(UIAlertAction(title: "Terrorism", style: .default, handler: { _ in
            self.present(responseAlert, animated: true)
        }))
        
        reportAlert.addAction(UIAlertAction(title: "Something else", style: .default, handler: { _ in
            self.present(responseAlert, animated: true)
        }))
        
        reportAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(reportAlert, animated: true)
    }
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
    func presentAlert(title: String?, message: String?, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let completion = completion else { return }
            completion()
        }

        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func presentErrorAlert(title: String? = "Something went wrong", message: String?, completion: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let completion = completion else { return }
            completion()
        }

        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
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
            indicator.style = UIActivityIndicatorView.Style.large
            indicator.color = .white
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
