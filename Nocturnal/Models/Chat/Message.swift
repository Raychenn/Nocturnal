//
//  Message.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/20.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseAuth

struct Message: Codable {
    @DocumentID var id: String?
    let toId: String
    let fromId: String
    let text: String?
    let imageUrl: String?
    var imageHeight: CGFloat?
    var imageWidth: CGFloat?
    let user: User?
    let sentTime: Timestamp
    var isFromCurrenUser: Bool
    var chatPartnerId: String {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("current user nil")
            return ""
        }
        if uid == fromId {
            return toId
        } else {
            return fromId
        }
    }
}
