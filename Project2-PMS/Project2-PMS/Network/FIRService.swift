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

enum Result<T> {
	case Success(T)
	case Error(String)
}

typealias LoginResultHandler = (User?, Error?) -> ()

class FIRService: NSObject {
	static let shareInstance = FIRService()
	
	// Database refences
	private var userRef: DatabaseReference!
	private var databaseRef : DatabaseReference!
	private var storageRef: StorageReference!
	
	private override init() {
		userRef = Database.database().reference().child("Users")
		databaseRef = Database.database().reference()
		storageRef = Storage.storage().reference()
	}
	
	
	func createUserProfile(ofUser uid: String, name: String?, email: String?) {
		let userDict = ["name": name, "email": email]
		databaseRef.child("Users").child(uid).updateChildValues(userDict)
	}
	
	// Email,Password login
	func loginUser(with email: String, and password: String, completion: @escaping LoginResultHandler) {
		Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
			DispatchQueue.main.async {
				completion(user, error)
			}
		}
	}
	
	// OAuth Login
	func loginUser(with credential: AuthCredential, completion: @escaping LoginResultHandler) {
		Auth.auth().signIn(with: credential) { (user, error) in
			DispatchQueue.main.async {
				completion(user, error)
			}
		}
	}
	
	// Save loggedin user info in Firebase Users table and store into as CurrentUser singleton
	func saveLoggedInUser(_ user: User, completion: @escaping () -> ()) {
		let currentUser = CurrentUser.sharedInstance
		
		userRef.observeSingleEvent(of: .value) { [weak self] (snapshot) in
			if !snapshot.hasChild(user.uid) {
				// If record not exist, create one (only for OAuth)
				self?.userRef.child(user.uid).updateChildValues(
					["name": user.displayName ?? "",
					 "email": user.email!,
					 "profile photo": user.photoURL?.absoluteString ?? ""
					]
				)
				// save oAuth user info to current user
				currentUser.userId = user.uid
				currentUser.email = user.email
				currentUser.fullname = user.displayName
				currentUser.profileImageUrl = user.photoURL
				
				DispatchQueue.main.async {
					completion()
				}
			} else {
				// if record exist, fetch it
				self?.fetchCurrentUserInfo(with: user.uid) {
					DispatchQueue.main.async {
						completion()
					}
				}
			}
		}
	}
	
	// Fetch currentuser info from firebase and store in singleton
	func fetchCurrentUserInfo(with id: String, completion: @escaping () -> ()) {
		let currentUser = CurrentUser.sharedInstance
		
		userRef.child(id).observeSingleEvent(of: .value) { (snapshot) in
			if let userDict = snapshot.value as? [String: String] {
				let email = userDict["email"]!
				let name = userDict["name"]
				let profileUrlStr = userDict["profile photo"]
				
				if let profilestr = profileUrlStr {
					currentUser.profileImageUrl = URL(string: profilestr)
				}
				currentUser.email = email
				currentUser.fullname = name
				
				DispatchQueue.main.async {
					completion()
				}
			}
		}
	}
}
