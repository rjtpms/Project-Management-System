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

protocol AddProjectVCDelegate: class {
	func didAddProject(_ newProject: Project)
	func didUpdateProject(_ updatedProject: Project)
}

// NOTE: only manager can see this VC
class AddProjectViewController: FormViewController {
	@IBOutlet weak var createProjectButton: UIBarButtonItem!
	
	var project: Project!
	
	weak var delegate: AddProjectVCDelegate?
	
	private var des: String!
	private var projectName: String!
	private var startDate: Date!
	private var endDate: Date!
	
	private lazy var projectId = Database.database().reference().childByAutoId().key
	
	private static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMM d yyyy"
		return formatter
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		setupForm()
    }
	
	private func setupUI() {
		// change create button and title when updating
		if project != nil {
			navigationItem.title = "Update Project"
			createProjectButton.title = "Update"
		}
	}
	
	private func setupForm() {
		form
			+++ Section()
			<<< TextRow() {
					$0.title = "Name"
					$0.value = project != nil ? project.name : ""
					$0.placeholder = "New Project"
					$0.onChange { [unowned self] row in
						self.projectName = row.value
						if self.project != nil {
							self.project.name = row.value!
						}
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
					$0.value = project != nil ? project.startDate : nil
					$0.title = "Start date"
					$0.add(rule: RuleRequired())
					$0.minimumDate = Date()
					$0.onChange { [unowned self] row in
						if let date = row.value {
							self.startDate = date
							if self.project != nil {
								self.project.startDate = date
							}
						}
					}
				}
			<<< DateTimeRow() {
					$0.dateFormatter = type(of: self).dateFormatter
					$0.value = project != nil ? project.endDate : nil
					$0.title = "Due date"
					$0.add(rule: RuleRequired())
					$0.minimumDate = Date()
					$0.onChange { [unowned self] row in
						if let date = row.value {
							self.endDate = date
							if self.project != nil {
								self.project.endDate = date
							}
						}
					}
				}
			<<< TextAreaRow() {
					$0.placeholder = "Description"
					$0.value = project != nil ? project.description : ""
					$0.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 40)
					$0.add(rule: RuleRequired())
					$0.validationOptions = .validatesOnChange
					$0.onChange { [unowned self] row in
						self.des = row.value
						if self.project != nil {
							self.project.description = row.value!
						}
					}
				}
		
			+++ Section()
		
			<<< ButtonRow() {
					// show delete button if updating
					if project == nil {
						$0.hidden = true
						$0.evaluateHidden()
					}
					$0.title = "DELETE"
				}.onCellSelection { [weak self] (cell, row) in
					self?.deleteProject()
				}.cellUpdate { (cell, row) in
					 cell.textLabel?.textColor = UIColor.red
				}
	}
	
	private func deleteProject() {
		print("Need to delete current project")
	}
	
	@IBAction func dismissVC(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: "Warning", message: "Unsaved changes, sure want to exit ?", preferredStyle: .alert)
		let actionYes = UIAlertAction(title: "YES", style: .default) { action in
			self.dismiss(animated: true, completion: nil)
		}
		let actionNo = UIAlertAction(title: "NO", style: .default, handler: nil)
		alert.addAction(actionYes)
		alert.addAction(actionNo)
		present(alert, animated: true, completion: nil)
	}
	
	@IBAction func createProject(_ sender: UIBarButtonItem) {
		// update project if it exist
		if project != nil {
			FIRService.shareInstance.updateProject(for: project) {
				print("Successfully updated project")
				DispatchQueue.main.async {
					self.delegate?.didUpdateProject(self.project)
					self.dismiss(animated: true, completion: nil)
				}
			}
		} else {
			// create one if not
			project = Project(id: projectId,
									 description: des,
									 startDate: startDate,
									 endDate: endDate,
									 name: projectName,
									 tasks: [],
									 members: [],
									 managerId: CurrentUser.sharedInstance.userId)
			
			FIRService.shareInstance.updateProject(for: project) {
				print("Successfully create project")
				DispatchQueue.main.async {
					self.delegate?.didAddProject(self.project)
					self.dismiss(animated: true, completion: nil)
				}
			}
		}
	}
}
