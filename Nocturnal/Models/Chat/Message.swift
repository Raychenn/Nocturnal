//
//  Message.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/20.
//

import Foundation
import MessageKit
import FirebaseFirestoreSwift
import FirebaseFirestore

struct Message: Codable {
    @DocumentID var id: String?
    let senderId: String
    let content: String
    let sentTime: Timestamp
}

