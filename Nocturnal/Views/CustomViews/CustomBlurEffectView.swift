//
//  CustomBlurEffectView.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/7/14.
//

import Foundation
import UIKit

class CustomBlurEffectView: UIVisualEffectView {
    
    var animator = UIViewPropertyAnimator(duration: 1, curve: .linear)
    
    override func didMoveToSuperview() {
        guard let superview = superview else { return }
        backgroundColor = .clear
        frame = superview.bounds
        setupBlur()
    }
    
    private func setupBlur() {
        animator.stopAnimation(true)
        effect = nil
        
        animator.addAnimations { [weak self] in
            self?.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        }
        animator.fractionComplete = 0.3
    }
    
    deinit {
        animator.stopAnimation(true)
    }
}
