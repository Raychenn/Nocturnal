//
//  HapticsManager.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/7/14.
//

import UIKit

final class HapticsManager {
    
    static let shared = HapticsManager()
    
    private init() {}
    
    public func selectionVibrate() {
        DispatchQueue.main.async {
            let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
            selectionFeedbackGenerator.prepare()
            selectionFeedbackGenerator.selectionChanged()
        }
    }
    
    public func vibrate(for tpye: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            let notificationnGenerator = UINotificationFeedbackGenerator()
            notificationnGenerator.prepare()
            notificationnGenerator.notificationOccurred(tpye)
        }
    }
    
}
