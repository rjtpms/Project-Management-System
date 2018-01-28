//
//  ProjectTasksViewController.swift
//  Project2-PMS
//
//  Created by Mark on 1/26/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu

class ProjectContainerViewController: UIViewController {
	
	var project: Project!
	
	private var menuView: BTNavigationDropdownMenu!
	private var currentVCIndex = 0
	private var titles = ["Task List", "Members","About Project"]
	private lazy var childrenVCs: [UIViewController] = {
		// Load Storyboard
		let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
		
		// Instantiate View Controller
		var taskVC = storyboard.instantiateViewController(withIdentifier: "TaskVC") as! TasksViewController
		taskVC.title = "Task List"
		
		var aboutVC = storyboard.instantiateViewController(withIdentifier: "AboutVC") as! AboutProjectViewController
		aboutVC.title = "About Project"
		
		var membersVC = storyboard.instantiateViewController(withIdentifier: "MembersVC") as! MembersViewController
		membersVC.title = "Members"
		
		// Add View Controller as Child View Controller
		self.add(asChildViewController: taskVC)
		self.add(asChildViewController: aboutVC)
		self.add(asChildViewController: membersVC)
		
		return [taskVC, membersVC, aboutVC]
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
    }
	
	private func setupUI() {
		setupDropdownMenu()
		updateChildVC(with: currentVCIndex)
	}
	
	private func setupDropdownMenu() {
		menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: BTTitle.title(titles.first!), items: titles)
		// customized menu
		menuView.cellHeight = 40
		menuView.cellBackgroundColor = self.navigationController?.navigationBar.barTintColor
		menuView.shouldKeepSelectedCellColor = true
		menuView.cellTextLabelFont = UIFont(name: "Avenir-Heavy", size: 14)
		menuView.cellTextLabelAlignment = .center
		menuView.arrowPadding = 15
		menuView.animationDuration = 0.5
		menuView.cellSeparatorColor = UIColor.clear
		menuView.checkMarkImage = nil
		menuView.didSelectItemAtIndexHandler = updateChildVC
		menuView.menuTitleColor = UIColor.black
		menuView.arrowTintColor = UIColor.cyan
		
		self.navigationItem.titleView = menuView
	}
	
	private func updateChildVC(with selectionIndex: Int) {
		if selectionIndex != currentVCIndex {
			let currentChildVC = childrenVCs[currentVCIndex]
			let selectedVC = childrenVCs[selectionIndex]
			
			// configure selectedVC
			if selectedVC is TasksViewController {
				//			(selectedVC as! TasksViewController).taskIds = project.tasks?.map { $0.id }
				print("Selected TaskVC")
			} else if selectedVC is AboutProjectViewController {
				//			(selectedVC as! AboutProjectViewController).project = project
				print("selected AboutVC")
			} else if selectedVC is MembersViewController {
				(selectedVC as! MembersViewController).project = project
				print("selected membersVC")
			}
			
			remove(asChildViewController: currentChildVC)
			add(asChildViewController: selectedVC)
			
			// keep track of childVC index
			currentVCIndex = selectionIndex
		}
	}
	
	private func add(asChildViewController viewController: UIViewController) {
		// Add Child View Controller
		addChildViewController(viewController)
		
		// Add Child View as Subview
		view.addSubview(viewController.view)
		
		// Configure Child View
		viewController.view.frame = view.bounds
		viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		// Notify Child View Controller
		viewController.didMove(toParentViewController: self)
	}
	
	private func remove(asChildViewController viewController: UIViewController) {
		// Notify Child View Controller
		viewController.willMove(toParentViewController: nil)
		
		// Remove Child View From Superview
		viewController.view.removeFromSuperview()
		
		// Notify Child View Controller
		viewController.removeFromParentViewController()
	}
}

