//
//  Notification.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/18.
//

import FirebaseFirestoreSwift
import FirebaseFirestore

enum NotificationType: Int {
    case joinEventRequest
    case successJoinedEventResponse
    case failure
}

struct Notification: Codable {
    @DocumentID var id: String?
    let applicantId: String
    let eventId: String
    let hostId: String
    let sentTime: Timestamp
    let type: Int
}
