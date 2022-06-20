//
//  ChatService.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/20.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct ChatService {
    static let shared = ChatService()
    
    func addMessagesListener(chatRoomId: String, completion: @escaping (Result<Message, Error>) -> Void) {
        collection_chatrooms.document(chatRoomId).collection("messages").addSnapshotListener { snapshot, error in
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
    
    func fetchAllMessages(chatRoomId: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        collection_chatrooms.document(chatRoomId).collection("messages").order(by: "sentTime", descending: true).getDocuments { snapshot, error in
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
                    completion(.failure(error))
                }
            }
            
            completion(.success(messages))
        }
    }
    
    func sendMessage(message: Message, chatRoomId: String, completion: FirestoreCompletion) {
        do {
            let newMessageDoc = collection_chatrooms.document(chatRoomId).collection("messages").document()
            try newMessageDoc.setData(from: message, encoder: .init(), completion: completion)
        } catch {
            print("Fail to encode message: \(error)")
        }
    }
    
    func uploadNewChatroom(chatRoom: ChatRoom, completion: FirestoreCompletion) {
        let newChatDocument = collection_chatrooms.document(chatRoom.id ?? "")
    
        do {
            try newChatDocument.setData(from: chatRoom, encoder: .init(), completion: completion)
        } catch {
            print("Fail to encode Chat room \(error)")
        }
    }
    
    func checkIfChatRoomExist(chatRoomId: String, completion: @escaping(Bool) -> Void) {
        collection_chatrooms.getDocuments { snapshot, error in
            
            guard let snapshot = snapshot, error == nil else {
                return
            }
            if snapshot.isEmpty {
                completion(false)
            }
            snapshot.documents.forEach { document in
                if document.documentID == chatRoomId {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
