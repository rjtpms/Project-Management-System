//
//  Project.swift
//  Project2-PMS
//
//  Created by Mark on 1/24/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import Foundation

struct Project {
	var id: String
	var description: String
	var startDate: Date
	var endDate: Date
	var name: String
	var tasks: [Task] = []
	var members: [Member] = []
	var managerId: String
}
