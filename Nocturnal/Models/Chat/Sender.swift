//
//  Sender.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/20.
//

import Foundation
import MessageKit

struct Sender: SenderType, Codable {
    
    var senderId: String
    
    var displayName: String
    
}
