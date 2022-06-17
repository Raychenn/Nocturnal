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
    
    func fetchAllEvents(completion: @escaping (Result<[Event], Error>) -> Void) {
        collection_event.getDocuments { snapshot, error in
            
            guard let snapshot = snapshot, error == nil else {
                completion(.failure(error!))
                return
            }
            
            var events: [Event] = []
            
            snapshot.documents.forEach { document in
                do {
                    let event = try document.data(as: Event.self, with: .none, decoder: .init())
                    events.append(event)
                } catch {
                    completion(.failure(error))
                }
            }
            
            completion(.success(events))
        }
    }
    
}
