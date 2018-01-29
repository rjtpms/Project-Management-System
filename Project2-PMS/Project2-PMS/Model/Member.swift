//
//  Member.swift
//  Project2-PMS
//
//  Created by LinChico on 1/24/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import Foundation
import UIKit

class Member: NSObject {
    let id : String
    var name: String?
    var email: String?
    var profileImage: UIImage?
	var profileImageURL: URL?
	
    init(id: String) {
        self.id = id
    }
	
	init(id: String, name: String?, email: String?, imageURL: URL?) {
		self.id = id
		self.name = name
		self.email = email
		self.profileImageURL = imageURL
	}
}
