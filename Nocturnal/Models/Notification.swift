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
    case failureJoinedEventResponse
    
    var description: String {
        switch self {
        case .joinEventRequest:
            return "Sent you a request"
        case .successJoinedEventResponse:
            return "Has accepted your request"
        case .failureJoinedEventResponse:
            return "Has denied your request"
        }
    }
}

struct Notification: Codable {
    @DocumentID var id: String?
    let applicantId: String
    let eventId: String
    let hostId: String
    let sentTime: Timestamp
    let type: Int
    var isRequestPermitted: Bool
}
