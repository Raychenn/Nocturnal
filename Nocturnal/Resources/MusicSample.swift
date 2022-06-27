//
//  MusicSample.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/15.
//

import Foundation

enum MusicSample: String {
    case enigma
    case extreme
    case powerfultrap
    case summertime
    case urbanhiphop
    case yourstory
    
    var description: String {
        switch self {
        case .enigma:
            return "Enigma"
        case .extreme:
            return "Extreme"
        case .powerfultrap:
            return "Powerful Trap"
        case .summertime:
            return "Summer Time"
        case .urbanhiphop:
            return "Urban Hip Hop"
        case .yourstory:
            return "Your Story"
        }
    }
    
}
