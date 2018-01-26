//
//  ProjectViewController.swift
//  Project2-PMS
//
//  Created by Mark on 1/24/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit

class ProjectViewController: UIViewController {

	
	var projects: [Project] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()

    }
	
	func setupUI() {
		
	}
}

extension ProjectViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return projects.count + 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "BasicProjectCell", for: indexPath)
		
		if indexPath.row == 0 {
			cell.imageView?.image = #imageLiteral(resourceName: "add_project_icon")
			cell.textLabel?.text = "Create New"
		} else {
			let currentProject = projects[indexPath.row]
			cell.textLabel?.text = currentProject.name
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.row {
		case 0:
			// when selecting create-new-project row
			performSegue(withIdentifier: "AddProjectSegue", sender: nil)
		default:
			// when selecing project row
			break
		}
	}
}
