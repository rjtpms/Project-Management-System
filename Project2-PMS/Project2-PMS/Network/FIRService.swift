//
//  FIRService.swift
//  Project2-PMS
//
//  Created by Mark on 1/23/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import Foundation

enum Result<T> {
	case Success(T)
	case Error(String)
}

class FIRService: NSObject {
	static let shareInstance = FIRService()
	private override init() {}
	
	
}
