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
    
    func updateEventPendingUsers(eventId: String, applicantId: String, completion: FirestoreCompletion) {
        collection_event.document(eventId).updateData(["pendingUsersId": FieldValue.arrayUnion([applicantId])], completion: completion)
    }
    
    func updateEventDeniedUsers(eventId: String, applicantId: String, completion: FirestoreCompletion) {
        
        collection_event.document(eventId).updateData(["deniedUsersId": FieldValue.arrayUnion([applicantId])], completion: completion)
    }

/// Update accepted user id to event participant array
func updateEventParticipants(notification: Notification, completion: FirestoreCompletion) {
    //        print("event ID in updateEventParticipants \(notification.eventId)")
    collection_event.document(notification.eventId).updateData(["participants": FieldValue.arrayUnion([notification.applicantId])], completion: completion)
}
    
/// Remove denied user id from event participant array
func removeEventParticipants(notification: Notification, completion: FirestoreCompletion) {
    collection_event.document(notification.eventId).getDocument { snapshot, error in
        guard let snapshot = snapshot, error == nil else {
            print("Fail to update event \(String(describing: error))")
            return
        }
        
        snapshot.reference.updateData(["participants": FieldValue.arrayRemove([notification.applicantId])], completion: completion)
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

func fetchEvents(fromEventIds ids: [String], completion: @escaping (Result<[Event], Error>) -> Void) {
    var events: [Event] = []
    let group = DispatchGroup()
    
    ids.forEach { eventId in
        group.enter()
        collection_event.document(eventId).getDocument { snapshot, error in
            group.leave()
            guard let snapshot = snapshot, error == nil else {
                completion(.failure(error!))
                return
            }
            do {
                let event = try snapshot.data(as: Event.self)
                events.append(event)
            } catch {
                completion(.failure(error))
            }
        }
    }
    group.notify(queue: .main) {
        completion(.success(events))
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
