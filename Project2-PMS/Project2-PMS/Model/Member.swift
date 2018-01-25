//
//  Member.swift
//  Project2-PMS
//
//  Created by LinChico on 1/24/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import Foundation
import UIKit

class Member {
    let id : String
    var name: String?
    var email: String?
    var profileImage: UIImage?
    
    init(id: String) {
        self.id = id
    }
}
