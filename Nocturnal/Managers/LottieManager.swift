//
//  LottieManager.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/7/18.
//

import Lottie

class LottieManager {
    
    static let shared = LottieManager()
    
    func createLottieView(name: String, mode: LottieLoopMode) -> AnimationView {
        let view = AnimationView(name: name)
         view.loopMode = mode
         view.contentMode = .scaleAspectFill
         view.animationSpeed = 1
         view.backgroundColor = .clear
         view.play()
         return view
    }
}
