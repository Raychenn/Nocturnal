//
//  Firebase+Ext.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/18.
//

import FirebaseAuth

var uid: String {
    return Auth.auth().currentUser?.uid ?? "No User Found"
}
