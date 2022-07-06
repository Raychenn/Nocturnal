//
//  PulsingButton.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/7/5.
//
import UIKit

class PulsingLayer: CALayer {
    
    var animationGroup = CAAnimationGroup()
    var initialPulsingScale: CGFloat = 0
    var animationDuration: TimeInterval = 2
    var radius: CGFloat = 50
    var numberOfPulses: Float = .infinity
    
    override init(layer: Any) {
        super.init(layer: layer)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(numberOfPulses: Float = .infinity, radius: CGFloat, view: UIView) {
        super.init()
        
        self.autoreverses = true
        self.backgroundColor = UIColor.primaryBlue.cgColor
        self.contentsScale = UIScreen.main.scale
        self.opacity = 0
        self.radius = radius
        self.numberOfPulses = numberOfPulses
        self.bounds = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        self.cornerRadius = radius
        self.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        
        DispatchQueue.global().async {
            self.setupAnimationGroup()
            
            DispatchQueue.main.async {
                self.add(self.animationGroup, forKey: "pulse")
            }
        }
    }
    
    func createScaleAnimation() -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = NSNumber(value: initialPulsingScale)
        scaleAnimation.toValue = NSNumber(value: 1)
        scaleAnimation.duration = animationDuration
        return scaleAnimation
    }
    
    func createOpacityAnimation() -> CAKeyframeAnimation {
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = animationDuration
        opacityAnimation.values = [0.4, 0.8, 0]
        opacityAnimation.keyTimes = [0, 0.3, 1]
        return opacityAnimation
    }
    
    func setupAnimationGroup() {
        self.animationGroup = CAAnimationGroup()
        self.animationGroup.duration = animationDuration
        self.animationGroup.repeatCount = numberOfPulses
        
        let defaultCurve = CAMediaTimingFunction(name: .easeInEaseOut)
        self.animationGroup.timingFunction = defaultCurve
        self.animationGroup.animations = [createScaleAnimation(), createOpacityAnimation()]
    }
    
}
