//
//  AddProjectViewController.swift
//  Project2-PMS
//
//  Created by Mark on 1/25/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit
import Eureka
import FirebaseDatabase

class AddProjectViewController: FormViewController {
	@IBOutlet weak var createProjectButton: UIBarButtonItem!
	
	var des: String!
	var projectName: String!
	var startDate: Date! {
		didSet {
			print(startDate)
		}
	}
	var endDate: Date! {
		didSet {
			print(endDate)
		}
	}
	
	static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMM d yyyy"
		return formatter
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupForm()
    }
	
	private func setupForm() {
		form
			+++ Section()
			<<< TextRow() {
				$0.title = "Name"
				$0.placeholder = "New Project"
				$0.onChange { [unowned self] row in
					self.projectName = row.value
				}
				$0.add(rule: RuleRequired())
				$0.validationOptions = .validatesOnChange
				$0.cellUpdate { (cell, row) in
					if !row.isValid {
						cell.titleLabel?.textColor = .red
					}
				}
			}
		
			+++ Section()
			<<< DateTimeRow() {
				$0.dateFormatter = type(of: self).dateFormatter
				$0.title = "Start date"
				$0.add(rule: RuleRequired())
				$0.minimumDate = Date()
				$0.onChange { [unowned self] row in
					if let date = row.value {
						self.startDate = date
					}
				}
			}
			<<< DateTimeRow() {
				$0.dateFormatter = type(of: self).dateFormatter
				$0.title = "Due date"
				$0.add(rule: RuleRequired())
				$0.minimumDate = Date()
				$0.onChange { [unowned self] row in
					if let date = row.value {
						self.endDate = date
					}
				}
			}
			<<< TextAreaRow() {
				$0.placeholder = "Description"
				$0.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 40)
				$0.add(rule: RuleRequired())
				$0.validationOptions = .validatesOnChange
				$0.onChange { [unowned self] row in
					self.des = row.value
				}
			}
	}

	
	@IBAction func dismissVC(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: "Warning", message: "Unsaved changed, sure want to exit ?", preferredStyle: .alert)
		let actionYes = UIAlertAction(title: "YES", style: .default) { action in
			self.dismiss(animated: true, completion: nil)
		}
		let actionNo = UIAlertAction(title: "NO", style: .default, handler: nil)
		alert.addAction(actionYes)
		alert.addAction(actionNo)
		present(alert, animated: true, completion: nil)
	}
	
	@IBAction func createProject(_ sender: UIBarButtonItem) {
		print(projectName)
		print(startDate.timeIntervalSince1970)
		print(endDate.timeIntervalSince1970)
		print(des)
		
		let projectId = Database.database().reference().childByAutoId().key
		let newProject = Project(id: projectId,
								 description: des,
								 startDate: startDate,
								 endDate: endDate,
								 name: projectName,
								 tasks: nil,
								 members: nil,
								 managerId: CurrentUser.sharedInstance.userId)
		
		FIRService.shareInstance.createProject(for: newProject) {
			print("Successfully create project")
		}
	}
}
