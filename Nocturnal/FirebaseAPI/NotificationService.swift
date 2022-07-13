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
    
    func deleteNotifications(eventId: String, completion: FirestoreCompletion) {
        collection_notification.getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Snapshot nil")
                print("Fail to deleteNotifications1 \(error!)")
                return
            }
            snapshot.documents.forEach { document in
                print("document \(document.reference)")
                document.reference.collection("user-notification").whereField("eventId", isEqualTo: eventId).getDocuments { snapshot, error in

                    guard let snapshot = snapshot, error == nil else {
                        print("Fail to deleteNotifications1 \(error!)")
                        return
                    }
                    if snapshot.documents.count == 0 {
                        completion?(nil)
                    }
                    snapshot.documents.forEach { document in
                        document.reference.delete(completion: completion)
                    }
                }
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
    
    let notificationDoc = collection_notification.document(uid)
    let newNotificationDocument = collection_notification.document(uid).collection("user-notification").document()
    
    notificationDoc.setData(["id": uid])
    
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
        print("done updatePermissionNotification")
        // send response notification to applicant
        postNotification(to: applicantUid, notification: notification) { error in
            guard error == nil else {
                print("Fail to post notification \(String(describing: error))")
                return
            }
           
            print("done updateEventParticipants")
            // also need to add nitification.applicantId to event.participants array
            EventService.shared.updateEventParticipants(notification: notification) { error in
                guard error == nil else {
                    print("Fail to update event \(String(describing: error))")
                    return
                }
                print("done removeEventPendingUsers")
                EventService.shared.removeEventPendingUsers(eventId: notification.eventId, applicantId: notification.applicantId) { error in
                    guard error == nil else {
                        print("Fail to remove pending user \(String(describing: error))")
                        return
                    }
                    print("done updateUserToJoinEvent")
                    // add nitification.eventId to specified user's user.joinedEvents array
                    UserService.shared.updateUserToJoinEvent(uid: applicantUid, joinedEventId: notification.eventId, completion: completion)
                }
            }
        }
    }
}

func postDeniedNotification(to applicantUid: String, notification: Notification, completion: FirestoreCompletion) {
    // finish here tomorrow (opposite of postAceeptedNotification)
    print("postAceeptedNotification called")
    updatePermissionNotification(for: uid, isPermitted: notification.isRequestPermitted, notification: notification) { error in
        guard error == nil else {
            print("Fail to update notification \(String(describing: error))")
            return
        }
        print("done updatePermissionNotification")
        postNotification(to: applicantUid, notification: notification) { error in
            guard error == nil else {
                print("Fail to post notification \(String(describing: error))")
                return
            }
            print("done postNotification")
            EventService.shared.removeEventParticipants(notification: notification) { error in
                guard error == nil else {
                    print("Fail to remove applicant from participants \(String(describing: error))")
                    return
                }
                print("done removeEventParticipants")
                EventService.shared.updateEventDeniedUsers(eventId: notification.eventId, applicantId: applicantUid) { error in
                    
                    guard error == nil else {
                        print("Fail to update EventDeniedUsers \(String(describing: error))")
                        return
                    }
                    print("done updateEventDeniedUsers")
                    EventService.shared.removeEventPendingUsers(eventId: notification.eventId, applicantId: notification.applicantId) { error in
                        guard error == nil else {
                            print("Fail to remove pending user \(String(describing: error))")
                            return
                        }
                        print("done removeEventPendingUsers")
                        UserService.shared.removeUserFromEvent(uid: applicantUid, joinedEventId: notification.eventId, completion: completion)
                    }
                }
            }
        }
    }
}
    
    func updateCancelNotification(deletedUserId: String, completion: FirestoreCompletion) {
        collection_notification.getDocuments { snapshot, error in

            guard let snapshot = snapshot, error == nil else {
                print("snapshot in collection_notification.getDocuments nil")
                // completion send error back
                completion?(error)
                return
            }
            
            print("snapshot documets \(snapshot.documents)")
            
            snapshot.documents.forEach { document in
                let query = document.reference.collection("user-notification").whereField("hostId", isEqualTo: deletedUserId)

                query.getDocuments { snapshot, error in
                    
                    guard let snapshot = snapshot, error == nil else {
                        print("snapshot in query nil")
                        // completion send error back
                        completion?(error)
                        return
                    }
                    
                    if snapshot.documents.count == 0 {
                        print("no document")
                        completion?(nil)
                    }
                    
                    snapshot.documents.forEach { document in
                        if document.exists {
                            print("doc exist")
                            document.reference.updateData(["type": 3]) { error in
                                completion?(error)
                            }
                        } else {
                            print("doc does not exist")
                            completion?(nil)
                            return
                        }
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
