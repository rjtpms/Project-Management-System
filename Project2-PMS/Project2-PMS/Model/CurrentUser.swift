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
	struct Static {
		static var instance: CurrentUser?
	}
	
	class var sharedInstance: CurrentUser {
		if Static.instance == nil
		{
			Static.instance = CurrentUser()
		}
		
		return Static.instance!
	}
	
	func dispose() {
		CurrentUser.Static.instance = nil
		print("Disposed Singleton instance")
	}
	
	private override init() {}
	
	var userId: String!
	var email: String!
	var fullname: String?
	var profileImageUrl: URL?
    var role: Role!
}
