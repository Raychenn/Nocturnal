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
}
