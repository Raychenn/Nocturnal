//
//  HudWrapper.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/7/4.
//

import JGProgressHUD

class HudManager {
    
    static let shared = HudManager()
    
     func showSuccess(on viewController: UIViewController, text: String? = nil) {
        let hud = JGProgressHUD()
        hud.textLabel.text = text
        hud.show(in: viewController.view, animated: true)
        hud.style = .dark
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.dismiss(afterDelay: 1.5)
    }
    
     func showError(on viewController: UIViewController, text: String) {
        let hud = JGProgressHUD()
        hud.textLabel.text = text
        hud.show(in: viewController.view, animated: true)
        hud.style = .dark
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.dismiss(afterDelay: 1.5)
    }
    
     func showWithoutAutoDismiss(on viewController: UIViewController, text: String) -> JGProgressHUD {
        let hud = JGProgressHUD()
        hud.textLabel.text = text
        hud.show(in: viewController.view, animated: true)
        hud.style = .dark
        return hud
    }

     func showNormal(on cell: UITableViewCell, text: String) -> JGProgressHUD {
        let hud = JGProgressHUD()
        hud.textLabel.text = text
        hud.show(in: cell.contentView, animated: true)
        hud.style = .dark
        return hud
    }
}
