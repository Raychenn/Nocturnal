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
    case cancelEvent
    
    var description: String {
        switch self {
        case .joinEventRequest:
            return "sent you a request"
        case .successJoinedEventResponse:
            return "has accepted your request"
        case .failureJoinedEventResponse:
            return "has denied your request"
        case .cancelEvent:
            return "has been unfortunately canceled"
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

struct Applicant {
    let id: String
    let data: User
}

struct Host {
    let id: String
    let data: User
}
