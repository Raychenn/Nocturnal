//
//  UserService.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/18.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct UserService {
    
    static let shared = UserService()
    
    // MARK: - Blocking Service
    func addUserToBlockedList(blockedUid: String, completion: FirestoreCompletion) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        collection_users.document(currentUserId).updateData(["blockedUsersId": FieldValue.arrayUnion([blockedUid])], completion: completion)
    }
    
    func removeUserFromblockedList(blockedUid: String, completion: FirestoreCompletion) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        collection_users.document(currentUserId).updateData(["blockedUsersId": FieldValue.arrayRemove([blockedUid])], completion: completion)
    }
    
    // MARK: - Deletion
    func checkIfUserExist(uid: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        collection_users.document(uid).getDocument { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(.failure(error!))
                return
            }

            if snapshot.exists {
                completion(.success(true))
            } else {
                completion(.success(false))
            }
        }
    }
    
    func deleteJoinedEvent(eventId: String, completion: FirestoreCompletion) {
        collection_users.whereField("joinedEventsId", arrayContains: eventId).getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Fail to delet joined event \(error!)")
                return
            }

            if snapshot.documents.count == 0 {
                completion?(nil)
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
            
            if snapshot.documents.count == 0 {
                completion?(nil)
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
    
    func updateUserProfileForDeletion(deledtedUserId: String, emptyUser: User, completion: FirestoreCompletion) {
        
        do {
            try collection_users.document(deledtedUserId).setData(from: emptyUser, encoder: .init(), completion: completion)
        } catch {
            print("Fail to encoder deleted user data: \(error)")
        }
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
        var users: [User] = []
        let group = DispatchGroup()
        DispatchQueue.global(qos: .userInitiated).async {
            uids.forEach { uid in
                group.enter()
                fetchUser(uid: uid) { result in
                    switch result {
                    case .success(let user):
                        users.append(user)
                        group.leave()
                    case .failure(let error):
                        print("error fetching user \(error)")
                        completion(.failure(error))
                    }
                }
            }
            
            group.notify(queue: .main) {
                completion(.success(users))
            }
        }
    }
}
