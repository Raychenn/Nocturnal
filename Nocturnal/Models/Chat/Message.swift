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
    let toId: String
    let fromId: String
    let text: String
    let user: User?
    let sentTime: Timestamp
    // isFromCurrenUser = fromId == uid
    var isFromCurrenUser: Bool
    var chatPartnerId: String {
        if uid == fromId {
            return toId
        } else {
            return fromId
        }
    }
}
