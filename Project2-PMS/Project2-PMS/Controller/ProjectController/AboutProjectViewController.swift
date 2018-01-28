//
//  AboutProjectViewController.swift
//  Project2-PMS
//
//  Created by Mark on 1/26/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit

class AboutProjectViewController: UIViewController {
	@IBOutlet weak var commentInput: UITextField!
	@IBOutlet weak var projectName: UILabel!
	@IBOutlet weak var projectNameShadow: UIView!
	@IBOutlet weak var startDate: UILabel!
	@IBOutlet weak var startDateShadow: UIView!
	@IBOutlet weak var dueDate: UILabel!
	@IBOutlet weak var dueDateShadow: UIView!
	@IBOutlet weak var des: UIView!
	
	var project: Project! 
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		updateUI()
    }
	
	private func setupUI() {
		if project != nil {
			// make round textfield wrapper
			commentInput.layer.cornerRadius = 15
			commentInput.layer.borderColor = UIColor.gray.cgColor
			commentInput.layer.borderWidth = 0.2
			
			makeRoundCorner(for: projectName)
			makeRoundCorner(for: startDate)
			makeRoundCorner(for: dueDate)
			
			setUpShawdow(for: projectName)
			setUpShawdow(for: startDate)
			setUpShawdow(for: dueDate)
		}
	}
	
	private func updateUI() {
		projectName.text = project.name
		startDate.text = project.startDate.dateString
		dueDate.text = project.endDate.dateString
	}
	
	private func makeRoundCorner(for view: UIView) {
		view.layer.cornerRadius = 8.0
		view.clipsToBounds = true
		view.layer.masksToBounds = true
	}
	
	private func setUpShawdow(for view: UIView) {
		// configure shadowView
		view.layer.cornerRadius = 8.0
		view.layer.shadowColor = UIColor.gray.cgColor
		view.layer.shadowOffset = CGSize(width: 0.2, height: 0.2)
		view.layer.shadowRadius = 10
		view.layer.shadowOpacity = 0.2
	}
	
	@IBAction func commentSend(_ sender: UIButton) {
		
	}
}
