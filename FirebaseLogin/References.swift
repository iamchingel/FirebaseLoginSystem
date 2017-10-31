//
//  References.swift
//  FirebaseLogin
//
//  Created by Sanket Ray on 31/10/17.
//  Copyright © 2017 Sanket Ray. All rights reserved.
//

import Foundation
import Firebase

let storageRef = Storage.storage().reference(forURL: "gs://fir-lo-726b1.appspot.com")
let databaseRef = Database.database().reference(fromURL: "https://fir-lo-726b1.firebaseio.com/")
let uid = Auth.auth().currentUser?.uid

