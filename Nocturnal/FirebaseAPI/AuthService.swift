//
//  AuthService.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/18.
//
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit
import FirebaseCore

struct AuthCredentials {
    let email: String
    let password: String
    let fullName: String
    let profileImage: UIImage
}

struct AuthService {
    
    static let shared = AuthService()
    
     func logUserIn(with email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func registerUser(withUser user: User, password: String, completion: @escaping (Error?) -> Void ) {
                
             Auth.auth().createUser(withEmail: user.email, password: password) { [user] authResult, error in
                if let error = error {
                    print("failed to create user with error: \(error)")
                    return
                }
                
                guard let uid = authResult?.user.uid else { return }
                 
                let newUserDocument = collection_users.document(uid)
                 
                 do {
                     try newUserDocument.setData(from: user, encoder: .init(), completion: completion)
                 } catch {
                     print("Error Encoding user \(error)")
                 }
            }
    }
    
    func uploadNewUser(withId uid: String, name: String, email: String, completion: @escaping (Error?) -> Void) {
        let newUserDocument = collection_users.document(uid)
        let newUser = User(id: uid, name: name, email: email, country: "", profileImageURL: "", birthday: Timestamp(date: Date()), gender: 2, numberOfHostedEvents: 0, bio: "", joinedEventsId: [], blockedUsersId: [], requestedEventsId: [])
        
         do {
             try newUserDocument.setData(from: newUser, encoder: .init(), completion: completion)
         } catch {
             print("Error Encoding user \(error)")
         }
    }
    
//    static func resetPasswrod(withEamil email: String, completion: SendPasswordResetCallback?) {
//
//        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
//    }
}
