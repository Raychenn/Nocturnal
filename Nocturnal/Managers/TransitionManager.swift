//
//  TransitionManager.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/7/7.
//

import UIKit

final class TransitionManager: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration: TimeInterval
    private var operation = UINavigationController.Operation.push
    
    init(duration: TimeInterval) {
        self.duration = duration
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        animateTransition(from: fromViewController, to: toViewController, with: transitionContext)
    }
}

// MARK: - UINavigationControllerDelegate

extension TransitionManager: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        self.operation = operation
        
        if operation == .push {
            return self
        }
        
        return nil
    }
}

// MARK: - Animations

private extension TransitionManager {
    func animateTransition(from fromViewController: UIViewController, to toViewController: UIViewController, with context: UIViewControllerContextTransitioning) {
        switch operation {
        case .push:
            guard
                let homeViewController = fromViewController as? HomeController,
                let detailsViewController = toViewController as? EventDetailController
            else { return }
            
            presentViewController(detailsViewController, from: homeViewController, with: context)
            
        case .pop:
            guard
                let detailsViewController = fromViewController as? EventDetailController,
                let homeViewController = toViewController as? HomeController
            else { return }
            
            dismissViewController(detailsViewController, to: homeViewController)
            
        default:
            break
        }
    }
    
    func presentViewController(_ toViewController: EventDetailController, from fromViewController: HomeController, with context: UIViewControllerContextTransitioning) {
        
        guard
            let homeCell = fromViewController.currentCell,
            let eventImageView = fromViewController.currentCell?.eventImageView,
            let detailHeaderView = toViewController.headerView
        else { return}
        
        toViewController.view.layoutIfNeeded()
        
        let containerView = context.containerView
        
        let snapshotContentView = UIView()
        snapshotContentView.backgroundColor = .black
        snapshotContentView.frame = containerView.convert(homeCell.contentView.frame, from: homeCell)
        snapshotContentView.layer.cornerRadius = homeCell.contentView.layer.cornerRadius
        
        let snapshotEventImageView = UIImageView()
        snapshotEventImageView.clipsToBounds = true
        snapshotEventImageView.contentMode = eventImageView.contentMode
        snapshotEventImageView.image = eventImageView.image
        snapshotEventImageView.layer.cornerRadius = eventImageView.layer.cornerRadius
        snapshotEventImageView.frame = containerView.convert(eventImageView.frame, from: homeCell)
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(snapshotContentView)
        containerView.addSubview(snapshotEventImageView)
        
//        toViewController.view.isHidden = true
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
            snapshotContentView.frame = containerView.convert(toViewController.view.frame, from: toViewController.view)
            snapshotEventImageView.frame = containerView.convert(detailHeaderView.imageView.frame, from: detailHeaderView)
        }

        animator.addCompletion { position in
            toViewController.view.isHidden = false
            snapshotEventImageView.removeFromSuperview()
            snapshotContentView.removeFromSuperview()
            context.completeTransition(position == .end)
        }

        animator.startAnimation()
    }
    
    func dismissViewController(_ fromViewController: EventDetailController, to toViewController: HomeController) {
        
    }
}
