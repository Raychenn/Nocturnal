//
//  FirebaseReference.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/15.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

let collection_event = Firestore.firestore().collection("events")
let collection_users = Firestore.firestore().collection("users")
let collection_notification = Firestore.firestore().collection("notifications")
