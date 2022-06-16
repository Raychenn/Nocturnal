//
//  EventService.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/15.
//

import Foundation
import FirebaseFirestore

typealias FirestoreCompletion = ((Error?) -> Void)?

class EventService {
    
    static let shared = EventService()
    
    func postNewEvent(event: Event, completion: FirestoreCompletion) {
        let newEventDocument = collection_event.document()
        
        do {
            try newEventDocument.setData(from: event, encoder: .init(), completion: completion)
        } catch {
            print("Fail to set new event \(error)")
        }
    }
    
}
