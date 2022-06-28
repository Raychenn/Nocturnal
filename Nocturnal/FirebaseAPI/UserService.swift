//
//  UserService.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/18.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserService {
    
    static let shared = UserService()
    
    // MARK: - Deletion
    func deleteJoinedEvent(eventId: String, completion: FirestoreCompletion) {
        collection_users.whereField("joinedEventsId", arrayContains: eventId).getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Fail to delet joined event \(error!)")
                return
            }

            snapshot.documents.forEach { document in
                document.reference.updateData(["joinedEventsId": FieldValue.arrayRemove([eventId])], completion: completion)
            }
        }
    }
    
    func deleteRequestedEvent(eventId: String, completion: FirestoreCompletion) {
        print("eventId in deleteRequestedEvent \(eventId)")
        collection_users.whereField("requestedEventsId", arrayContains: eventId).getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Fail to delet joined event \(error!)")
                return
            }

            snapshot.documents.forEach { document in
                document.reference.updateData(["requestedEventsId": FieldValue.arrayRemove([eventId])], completion: completion)
            }
        }
//        collection_users.document(uid).updateData(["requestedEventsId": FieldValue.arrayRemove([eventId])], completion: completion)
    }
    
    func removeUserFromEvent(uid: String, joinedEventId: String, completion: FirestoreCompletion) {
        collection_users.document(uid).updateData(["joinedEventsId": FieldValue.arrayRemove([joinedEventId])], completion: completion)
    }
    
    // MARK: - Update
    func updateUserEventRequest(eventId: String, completion: FirestoreCompletion) {
        collection_users.document(uid).updateData(["requestedEventsId": FieldValue.arrayUnion([eventId])], completion: completion)
    }
    
    /// testing
    func updateUserProfile(newUserData: User, completion: FirestoreCompletion) {
        do {
            try collection_users.document(uid).setData(from: newUserData, encoder: .init(), completion: completion)
        } catch {
            print("Fail to encode user \(error)")
        }
    }
    
    func updateUserToJoinEvent(uid: String, joinedEventId: String, completion: FirestoreCompletion) {
        
        collection_users.document(uid).updateData(["joinedEventsId": FieldValue.arrayUnion([joinedEventId])], completion: completion)
    }
    
    // MARK: - Get

    func fetchUser(uid: String, completion: @escaping (Result<User, Error>) -> Void) {
        collection_users.document(uid).getDocument { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(.failure(error!))
                return
            }
            
            do {
                let user = try snapshot.data(as: User.self)
                completion(.success(user))
            } catch {
                completion(.failure(error))
                print("Fail to decode user \(error)")
            }
        }
    }
    
    // 要抓每個notification的hosts看他們有沒有給通過
    // 也要抓每個notification的applicants看host要不要給過
    func fetchUsers(uids: [String], completion: @escaping (Result<[User], Error>) -> Void) {
        let group = DispatchGroup()
        
        var users: [User] = []
        
        uids.forEach { uid in
            group.enter()
            fetchUser(uid: uid) { result in
                group.leave()
                switch result {
                case .success(let user):
                    users.append(user)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(users))
        }
    }
}
