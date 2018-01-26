//
//  Task.swift
//  Project2-PMS
//
//  Created by LinChico on 1/24/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import Foundation

class Task {
    let id: String
    var projectId: String?
    var title: String?
    var isCompleted: Bool?
    var description: String?
    var startDate: Date?
    var dueDate: Date?
    var members: [String]?
    
    init(id: String) {
        self.id = id
    }
}
