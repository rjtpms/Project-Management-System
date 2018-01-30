//
//  ProjectViewController.swift
//  Project2-PMS
//
//  Created by Mark on 1/24/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit

class ProjectViewController: UIViewController {
	@IBOutlet weak var tableview: UITableView!
	private var refreshControl = UIRefreshControl()
	
	private let createNewCellIdentifier = "CreateNewProjectCell"
	private let projectCellIdentifier = "ProjectCell"
	private let addProjectVCSegue = "addProjectVCSegue"
	private let showContainerSegue = "showContainerSegue"
	
	// PM can see all the projects, Member can only see projects that they are assigned task to
	var projects: [Project] = [] {
		didSet {
			tableview.reloadData()
		}
	}
	
	private lazy var currentUser: CurrentUser = {
		CurrentUser.sharedInstance.restore()
		return CurrentUser.sharedInstance
	}()
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		fetchProjects()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == showContainerSegue,
			let targetVC = segue.destination as? ProjectContainerViewController,
			let indexPath = tableview.indexPathForSelectedRow {
			
			let trueIndex = currentUser.role == .manager ? indexPath.row - 1 : indexPath.row
			targetVC.project = projects[trueIndex]
		} else if segue.identifier == addProjectVCSegue,
			let targetVC = segue.destination.contents as? AddProjectViewController {
			targetVC.delegate = self
		}
	}
}

// MARK: - Helper Methods
private extension ProjectViewController {
	
	func setupUI() {
		refreshControl.isEnabled = true
		refreshControl.tintColor = UIColor.cyan
		refreshControl.addTarget(self, action: #selector(fetchProjects), for: .valueChanged)
		tableview.addSubview(refreshControl)
		
		tableview.rowHeight = UITableViewAutomaticDimension
		tableview.estimatedRowHeight = 110
		
		let bar = self.navigationController?.navigationBar
		bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
		bar?.shadowImage = UIImage()
		bar?.backgroundColor = UIColor.clear
	}
	
	@objc func fetchProjects () {
		showNetworkIndicators()
		let firService = FIRService.shareInstance
		
		switch currentUser.role {
		case .member:
			// only fetch projects which has task that memeber is working on
			firService.getMemberProjects(with: currentUser.userId) { (newProjects, error) in
				DispatchQueue.main.async {
					self.finishFetching(newProjects: newProjects, err: error)
				}
			}
		case .manager:
			// fetch all projects with all tasks
			firService.getAllProjects(with: currentUser.userId) { (newProjects, error) in
				DispatchQueue.main.async {
					self.finishFetching(newProjects: newProjects, err: error)
				}
			}
		default:
			break
		}
	}
	
	func finishFetching(newProjects: [Project]?, err: Error?) {
		refreshControl.endRefreshing()
		hideNetworkIndicatros()
		guard err == nil else {
			print(err!.localizedDescription)
			return
		}
		
		guard let unwrappedProjects = newProjects else { return }
		
		projects = unwrappedProjects
	}
}

extension ProjectViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch currentUser.role {
		case .manager:
			return projects.count + 1
		case .member:
			return projects.count
		default:
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell!
		
		// enable add row if current is manager
		if indexPath.row == 0, currentUser.role == .manager {
			cell = tableView.dequeueReusableCell(withIdentifier: createNewCellIdentifier, for: indexPath)
			cell.imageView?.image = #imageLiteral(resourceName: "add_project_icon")
			cell.textLabel?.text = "Create New"
		} else {
			cell = tableview.dequeueReusableCell(withIdentifier: projectCellIdentifier, for: indexPath)
			let rowIndex = currentUser.role == .manager ? indexPath.row - 1 : indexPath.row
			let currentProject = projects[rowIndex]
			let countdownDays = daysLeft(to: currentProject.endDate)
			
			(cell as! ProjectCell).configureCell(with: currentProject, and: countdownDays)
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.row {
		case 0:
			// nav to addproject VC if current user is manager
			if currentUser.role == .manager {
				performSegue(withIdentifier: addProjectVCSegue, sender: nil)
			} else {
				// when selecing project row
				performSegue(withIdentifier: showContainerSegue, sender: nil)
			}
		default:
			// when selecing project row
			performSegue(withIdentifier: showContainerSegue, sender: nil)
			break
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		// enable add row if current is manager
		if indexPath.row == 0, currentUser.role == .manager {
			return 44
		} else {
			return 110
		}
	}
	
}

extension ProjectViewController: AddProjectVCDelegate {
	func didUpdateProject(_ updatedProject: Project) {
		// Ignore this, should be optional
	}
	
	func didAddProject(_ newProject: Project) {
		//
		projects.append(newProject)
	}
}
