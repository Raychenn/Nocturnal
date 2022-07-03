//
//  Buzzable+Protocol.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/7/1.
//

import Foundation
import UIKit

protocol Buzzable {
    func buzz()
}

extension Buzzable where Self: UIView {
    func buzz() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 5.0, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 5.0, y: self.center.y))
        layer.add(animation, forKey: "position")
    }
}

class BuzzableButton: UIButton, Buzzable {}
class BuzzableTextfield: UITextView, Buzzable {}
