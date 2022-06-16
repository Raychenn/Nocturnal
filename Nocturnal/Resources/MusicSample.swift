//
//  MusicSample.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/15.
//

import Foundation

enum MusicSample: String {
    case allthat
    case betterdays
    case creativeminds
    case dreams
    case relaxing
    case slowmotion
    
    var description: String {
        switch self {
        case .allthat:
            return "All Hat"
        case .betterdays:
            return "Better Days"
        case .creativeminds:
            return "Creative Minds"
        case .dreams:
            return "Dreams"
        case .relaxing:
            return "Relaxing"
        case .slowmotion:
            return "Slow Motion"
        }
    }
    
//    var url: String {
//        switch self {
//        case .allthat:
//            guard let url = Bundle.main.url(forResource: MusicSample.allthat.rawValue, withExtension: "mp3") else { return }
//            return url
//        case .betterdays:
//            guard let url = Bundle.main.url(forResource: MusicSample.betterdays.rawValue, withExtension: "mp3") else { return }
//            return url
//        case .creativeminds:
//            guard let url = Bundle.main.url(forResource: MusicSample.creativeminds.rawValue, withExtension: "mp3") else { return }
//            return url
//        case .dreams:
//            guard let url = Bundle.main.url(forResource: MusicSample.creativeminds.rawValue, withExtension: "mp3") else { return }
//            return url
//        case .relaxing:
//            guard let url = Bundle.main.url(forResource: MusicSample.relaxing.rawValue, withExtension: "mp3") else { return }
//            return url
//        case .slowmotion:
//            guard let url = Bundle.main.url(forResource: MusicSample.slowmotion.rawValue, withExtension: "mp3") else { return }
//            return url
//        }
//    }
}
