//
//  User.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/18.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct User: Codable {
    @DocumentID var id: String?
    let name: String
    let email: String
    let country: String        
    let profileImageURL: String
    let birthday: Timestamp
    let gender: Int
    let numberOfHostedEvents: Int
    let bio: String
    let joinedEventsId: [String]
    let blockedUsersId: [String]
    let requestedEventsId: [String]
    
    var age: Int {
        // should calculate this based on birthday
        return 99
    }
}

enum Gender: Int, Codable {
    case male = 0
    case female
    case unspecified
    
    var getDescription: String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        case .unspecified:
            return "Unspecified"
        }
    }
}

enum Country: String {
    case usa = "USA"
    case japan = "Japan"
    case australia = "Australia"
    case germany = "Germany"
    case spain = "Spain"
    case italy = "Italy"
    case india = "India"
    case china = "China"
    case france = "France"
    case korea = "Korea"
    case unspecified = "Unspecified"
    
    var countryCode: String {
        switch self {
        case .usa:
            return "US"
        case .japan:
            return "JP"
        case .australia:
            return "AU"
        case .germany:
            return "DE"
        case .spain:
            return "ES"
        case .italy:
            return "IT"
        case .india:
            return "IN"
        case .china:
            return "CN"
        case .france:
            return "FR"
        case .korea:
            return "KP"
        case .unspecified:
            return "Unspecified"
        }
    }
}
