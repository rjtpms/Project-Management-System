//
//  AddProjectViewController.swift
//  Project2-PMS
//
//  Created by Mark on 1/25/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit
import Eureka

class AddProjectViewController: FormViewController {
	@IBOutlet weak var createProjectButton: UIBarButtonItem!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupForm()
    }
	
	private func setupForm() {
		Form
			+++ Section()
			<<< TextRow() {
				$0.title = "Name"
				$0.placeholder = "New Project"
			}
	}
	
	@IBAction func dismissVC(_ sender: UIBarButtonItem) {
		
	}
	
	@IBAction func createProject(_ sender: UIBarButtonItem) {
		
	}
}
