//
//  AboutProjectViewController.swift
//  Project2-PMS
//
//  Created by Mark on 1/26/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit

class AboutProjectViewController: UIViewController {
	@IBOutlet weak var commentView: UIView!
	@IBOutlet weak var commentInput: UITextField!
	@IBOutlet weak var commentShadow: UIView!
	@IBOutlet weak var projectName: UILabel!
	@IBOutlet weak var projectNameShadow: UIView!
	@IBOutlet weak var startDate: UILabel!
	@IBOutlet weak var startDateShadow: UIView!
	@IBOutlet weak var dueDate: UILabel!
	@IBOutlet weak var dueDateShadow: UIView!
	@IBOutlet weak var desShadow: UIView!
	@IBOutlet weak var desLabel: UILabel!
	@IBOutlet weak var EditButton: UIButton!
	@IBOutlet weak var EditButtonShadow: UIView!
	
	private let shadowColor = UIColor.gray.cgColor
	private let normalRadius: CGFloat = 10.0
	private let updateProjectSegue = "updateProjectSegue"
	
	var project: Project! {
		didSet {
			if view.window != nil {
				updateUI()
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		updateUI()
    }
	
	@IBAction func commentSend(_ sender: UIButton) {
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == updateProjectSegue, let targetVC = segue.destination.contents as? AddProjectViewController {
			targetVC.project = project
			targetVC.delegate = self
		}
	}
}

// MARK: -Helper
private extension AboutProjectViewController {
	func setupUI() {
		projectName.font = lFont
		startDate.font = mFont
		dueDate.font = mFont
		desLabel.font = mFont
		EditButton.titleLabel?.font = mFont
		
		makeRoundCorner(for: commentView, with: commentView.roundRadius)
		makeRoundCorner(for: desLabel, with: normalRadius)
		makeRoundCorner(for: projectName, with: normalRadius)
		makeRoundCorner(for: startDate, with: normalRadius)
		makeRoundCorner(for: dueDate, with: normalRadius)
		makeRoundCorner(for: EditButton, with: EditButton.roundRadius)
		
		setUpShawdow(for: commentShadow, withRadius: commentShadow.roundRadius, andColor: shadowColor)
		setUpShawdow(for: desShadow, withRadius: normalRadius, andColor: shadowColor)
		setUpShawdow(for: projectNameShadow, withRadius: normalRadius, andColor: shadowColor)
		setUpShawdow(for: startDateShadow, withRadius: normalRadius, andColor: shadowColor)
		setUpShawdow(for: dueDateShadow, withRadius: normalRadius, andColor: shadowColor)
		setUpShawdow(for: EditButtonShadow, withRadius: EditButtonShadow.roundRadius, andColor: shadowColor)
		
		// hide edit button if current user is member
		if CurrentUser.sharedInstance.role == .member {
			EditButtonShadow.isHidden = true
		}
	}
	
	func updateUI() {
		if project != nil {
			projectName.text = project.name
			startDate.text = project.startDate.dateString
			dueDate.text = project.endDate.dateString
			desLabel.text = project.description
		}
	}
	
	func makeRoundCorner(for view: UIView, with radius: CGFloat) {
		view.layer.cornerRadius = radius
		view.clipsToBounds = true
		view.layer.masksToBounds = true
	}
	
	func setUpShawdow(for view: UIView, withRadius radius: CGFloat, andColor color: CGColor) {
		// configure shadowView
		view.layer.cornerRadius = radius
		view.layer.shadowColor = color
		view.layer.shadowOffset = CGSize(width: 0.1, height: 0.1)
		view.layer.shadowRadius = radius
		view.layer.shadowOpacity = 0.2
	}
}

extension AboutProjectViewController: AddProjectVCDelegate {
	func didAddProject(_ newProject: Project) {
		// ignore here, should be optional
	}
	func didUpdateProject(_ updatedProject: Project) {
		project = updatedProject
	}
}
