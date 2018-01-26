//
//  CurrentUser.swift
//  Project2-PMS
//
//  Created by Mark on 1/23/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import Foundation
import UIKit

class CurrentUser: NSObject {
	private let userDataKey = "userData"
	var userId: String!
	var email: String!
	var fullname: String!
	var profileImageUrl: URL?
	var role: Role = .none
	
	struct Static {
		static var instance: CurrentUser?
	}
	
	class var sharedInstance: CurrentUser {
		if Static.instance == nil {
			Static.instance = CurrentUser()
		}
		
		return Static.instance!
	}
	
	private override init() {}
	
	func dispose() {
		CurrentUser.Static.instance = nil
		UserDefaults.standard.removeObject(forKey: userDataKey)
	}
	
	func update(id: String, email: String, name: String, photoUrl: URL?, role: Role) {
		self.userId = id
		self.email = email
		self.fullname = name
		self.profileImageUrl = photoUrl
		self.role = role
	}
	
	func save() {
		var dictionary = [String: Any]()
		dictionary["userId"] = userId
		dictionary["email"] = email
		dictionary["fullname"] = fullname
		dictionary["profileImageUrl"] = profileImageUrl?.absoluteString
		dictionary["role"] = role.rawValue
		
		UserDefaults.standard.set(dictionary, forKey: userDataKey)
	}
	
	func restore() {
		if let dictionary = UserDefaults.standard.dictionary(forKey: userDataKey) {
			userId = dictionary["userId"] as! String
			email = dictionary["email"] as! String
			fullname = dictionary["fullname"] as! String
            if let profileImageUrlStr = dictionary["profileImageUrl"] as? String {
                profileImageUrl = URL(string: profileImageUrlStr)
            }
            
			role = Role(rawValue: (dictionary["role"] as! String))!
		}
	}
}
