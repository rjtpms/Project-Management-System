//
//  FIRService.swift
//  Project2-PMS
//
//  Created by Mark on 1/23/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import UIKit

enum Result<T> {
	case Success(T)
	case Error(String)
}

class FIRService: NSObject {
	static let shareInstance = FIRService()
    
    var databaseRef : DatabaseReference!
    var storageRef: StorageReference!
    
    private override init () {
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
    }
	
    func createUserProfile(ofUser uid: String, name: String?, email: String?) {
        let userDict = ["name": name, "email": email]
        databaseRef.child("Users").child(uid).updateChildValues(userDict)
    }
}
