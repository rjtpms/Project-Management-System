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
	
	private let cellIdentifier = "BasicProjectCell"
	private let addProjectSegue = "AddProjectSegue"
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
		fetchProjects()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == showContainerSegue,
			let targetVC = segue.destination as? ProjectContainerViewController,
			let indexPath = tableview.indexPathForSelectedRow {
			
			let trueIndex = currentUser.role == .manager ? indexPath.row - 1 : indexPath.row
			targetVC.project = projects[trueIndex]
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
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
		
		// enable add row if current is manager
		if indexPath.row == 0, currentUser.role == .manager {
			cell.imageView?.image = #imageLiteral(resourceName: "add_project_icon")
			cell.textLabel?.text = "Create New"
		} else {
			let rowIndex = currentUser.role == .manager ? indexPath.row - 1 : indexPath.row
			let currentProject = projects[rowIndex]
			cell.textLabel?.text = currentProject.name
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.row {
		case 0:
			// nav to addproject VC if current user is manager
			if currentUser.role == .manager {
				performSegue(withIdentifier: addProjectSegue, sender: nil)
			} else {
				// when selecing project row
				performSegue(withIdentifier: showContainerSegue, sender: nil)
			}
		default:
			// when selecing project row
			performSegue(withIdentifier: showContainerSegue, sender: nil)
			break
		}
	}
}
