//
//  ChatRoom.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/20.
//

import FirebaseFirestoreSwift

struct ChatRoom: Codable {
    @DocumentID var id: String?
    let chatMembersId: [String]
}
