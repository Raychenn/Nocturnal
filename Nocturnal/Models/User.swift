//
//  User.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/18.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

enum Gender: Int, Codable {
    case male = 0
    case female
    case unspecified
    
    var description: String {
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
    
    var age: Int {
        // should calculate this based on birthday
        return 99
    }
}
