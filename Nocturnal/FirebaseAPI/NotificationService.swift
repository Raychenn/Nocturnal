//
//  NotificationService.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/18.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct NotificationService {
    
    static let shared = NotificationService()
    
    // MARK: - Deletion
    
    func deleteNotifications(eventId: String, forUserId: String, completion: FirestoreCompletion) {
        let query = collection_notification.document(forUserId).collection("user-notification").whereField("eventId", isEqualTo: eventId)
        
        query.getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                return
            }

            snapshot.documents.forEach { document in
                document.reference.delete(completion: completion)
            }
        }
    }
    
    // MARK: - Update
    
    func updatePermissionNotification(for uid: String, isPermitted: Bool, notification: Notification, completion: FirestoreCompletion) {
        let query = collection_notification.document(uid).collection("user-notification").whereField("applicantId", isEqualTo: notification.applicantId).whereField("eventId", isEqualTo: notification.eventId)
        
        query.getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Fail to update PermissionNotification for host \(error!)")
                return
            }

            snapshot.documents.forEach { document in
                document.reference.updateData(["isRequestPermitted": isPermitted], completion: completion)
            }
        }
    }

func postNotification(to uid: String, notification: Notification, completion: FirestoreCompletion) {
    
    let newNotificationDocument = collection_notification.document(uid).collection("user-notification").document()
    
    do {
        try newNotificationDocument.setData(from: notification, encoder: .init(), completion: completion)
    } catch {
        print("Fail to encode notification \(error)")
    }
}

func postAceeptedNotification(to applicantUid: String, notification: Notification, completion: FirestoreCompletion) {
    print("postAceeptedNotification called")
    updatePermissionNotification(for: uid, isPermitted: notification.isRequestPermitted, notification: notification) { error in
        guard error == nil else {
            print("Fail to update notification \(String(describing: error))")
            return
        }
        // send response notification to applicant
        postNotification(to: applicantUid, notification: notification) { error in
            guard error == nil else {
                print("Fail to post notification \(String(describing: error))")
                return
            }
           
            // also need to add nitification.applicantId to event.participants array
            EventService.shared.updateEventParticipants(notification: notification) { error in
                guard error == nil else {
                    print("Fail to update event \(String(describing: error))")
                    return
                }
                // add nitification.eventId to specified user's user.joinedEvents array
                UserService.shared.updateUserToJoinEvent(uid: applicantUid, joinedEventId: notification.eventId, completion: completion)
            }
        }
    }
}

func postDeniedNotification(to applicantUid: String, notification: Notification, completion: FirestoreCompletion) {
    // finish here tomorrow (opposite of postAceeptedNotification)
    updatePermissionNotification(for: uid, isPermitted: notification.isRequestPermitted, notification: notification) { error in
        guard error == nil else {
            print("Fail to update notification \(String(describing: error))")
            return
        }
        
        postNotification(to: applicantUid, notification: notification) { error in
            guard error == nil else {
                print("Fail to post notification \(String(describing: error))")
                return
            }
            
            EventService.shared.removeEventParticipants(notification: notification) { error in
                guard error == nil else {
                    print("Fail to remove applicant from participants \(String(describing: error))")
                    return
                }
                
                EventService.shared.updateEventDeniedUsers(eventId: notification.eventId, applicantId: applicantUid) { error in
                    
                    guard error == nil else {
                        print("Fail to update EventDeniedUsers \(String(describing: error))")
                        return
                    }
                    
                    UserService.shared.removeUserFromEvent(uid: applicantUid, joinedEventId: notification.eventId, completion: completion)
                }
            }
        }
    }
}
// MARK: - Get
func fetchNotifications(uid: String, completion: @escaping (Result<[Notification], Error>) -> Void) {
    
    let query = collection_notification.document(uid).collection("user-notification").order(by: "sentTime", descending: true)
    
    query.getDocuments { snapshot, error in
        guard let snapshot = snapshot, error == nil else {
            completion(.failure(error!))
            return
        }
        var notifications: [Notification] = []
        
        snapshot.documents.forEach { document in
            do {
                let notification = try document.data(as: Notification.self)
                notifications.append(notification)
            } catch {
                completion(.failure(error))
                print("Fail to decode user \(error)")
            }
        }
        
        completion(.success(notifications))
    }
}
}
