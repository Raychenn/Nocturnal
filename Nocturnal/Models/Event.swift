//
//  Event.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/15.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct Event: Codable {
    @DocumentID var id: String?
    let title: String
    let hostID: String
    let description: String
    let startingDate: Timestamp
    let destinationLocation: GeoPoint
    let fee: Double
    let style: String
    let eventImageURL: String
    let eventMusicURL: String
    let participants: [String]
    let deniedUsersId: [String]
    let pendingUsersId: [String]
}

struct Location: Codable {
    let lat: Double
    let long: Double
}

enum EventStyle: String, CaseIterable {
    case kpop = "K-pop"
    case hippop = "Hip Pop"
    case rock = "Rock"
    case jazz = "Jazz"
    case disco = "Disco"
    case edm = "EDM"
    case metal = "Metal"
    case rapping = "Rapping"
}
