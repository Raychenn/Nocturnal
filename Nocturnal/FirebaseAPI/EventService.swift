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
    
    /// Update accepted user id to event participant array
    func updateEvent(hostId: String, acceptedApplicantId: String, completion: FirestoreCompletion) {
        collection_event.whereField("hostID", isEqualTo: hostId).getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Fail to update event \(String(describing: error))")
                return
            }

            snapshot.documents.forEach { document in
                document.reference.updateData(["participants": FieldValue.arrayUnion([acceptedApplicantId])], completion: completion)
            }
        }
    }
    /// Remove denied user id from event participant array
    func updateEvent(hostId: String, deniedApplicantId: String, completion: FirestoreCompletion) {
        collection_event.whereField("hostID", isEqualTo: hostId).getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Fail to update event \(String(describing: error))")
                return
            }

            snapshot.documents.forEach { document in
                document.reference.updateData(["participants": FieldValue.arrayRemove([deniedApplicantId])], completion: completion)
            }
        }
    }
    
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
