//
//  MessageService.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/20.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct MessegeService {
    
    static let shared = MessegeService()
    
    func uploadMessage(_ message: Message, to user: User, completion: FirestoreCompletion) {
        
        do {
            let newMessageDoc = collection_messages.document(uid).collection(user.id ?? "").document()
            
            try newMessageDoc.setData(from: message, encoder: .init(), completion: { error in
                guard error == nil else { return }
                
                do {
                    try collection_messages.document(user.id ?? "").collection(uid).document().setData(from: message, encoder: .init(), completion: { error in
                        
                        // update current collection_messages -> currentUser -> collection_recent_messages
                        do {
                            try collection_messages.document(uid).collection("recent_messages").document(user.id ?? "").setData(from: message)
                            
                            try collection_messages.document(user.id ?? "").collection("recent_messages").document(uid).setData(from: message, encoder: .init(), completion: completion)
                            
                        } catch {
                            print("Fail to encode \(error)")
                        }
                        
                    })
                } catch {
                    print("Fail to encode \(error)")
                }
            })
        } catch {
            print("Fail to encode \(error)")
        }
    }
    
    func addMessagesListener(forUser user: User, completion: @escaping (Result<Message, Error>) -> Void) {
        let query = collection_messages.document(uid).collection(user.id ?? "").order(by: "sentTime", descending: false)
        
        query.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { change in
                if change.type == .added {
                    do {
                        let newMessage = try change.document.data(as: Message.self)
                        completion(.success(newMessage))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    func fetchAllMessages(forUser user: User, completion: @escaping (Result<[Message], Error>) -> Void) {
        let query = collection_messages.document(uid).collection(user.id ?? "").order(by: "sentTime", descending: false)
        query.getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(.failure(error!))
                return
            }
            
            var messages: [Message] = []
            
            snapshot.documents.forEach { document in
                do {
                    let message = try document.data(as: Message.self)
                    messages.append(message)
                } catch {
                    print("Fail to decode message \(error)")
                }
            }
            
            completion(.success(messages))
        }
    }
    
    func fetchConversations(completion: @escaping (Result<[Conversation], Error>) -> Void) {
        var conversations: [Conversation] = []
        
        let query = collection_messages.document(uid).collection("recent_messages").order(by: "sentTime", descending: true)
        
        query.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(.failure(error!))
                return
            }
            let group = DispatchGroup()
            
            snapshot.documentChanges.forEach { change in
                if change.type == .added {
                    do {
                        let message = try change.document.data(as: Message.self)
                        group.enter()
                        UserService.shared.fetchUser(uid: message.chatPartnerId) { result in
                            group.leave()
                            switch result {
                            case .success(let user):
//                                print("chatPartner name in api \(user.name)")
                                let conversation = Conversation(user: user, message: message)
                                conversations.append(conversation)
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
            group.notify(queue: .main) {
                completion(.success(conversations))
            }
            
        }
    }
}
