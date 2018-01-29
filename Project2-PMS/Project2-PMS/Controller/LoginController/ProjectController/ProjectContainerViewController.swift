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
	var addTaskButton: UIBarButtonItem!
	
	var project: Project!
	
	private let addTaskVCId = "AddTaskViewController"
	
	private var menuView: BTNavigationDropdownMenu!
	private var currentVCIndex = 0
	private var titles = ["Task List", "Members","About Project"]
	private lazy var childrenVCs: [UIViewController] = {
		// Instantiate View Controller
		var taskVC = storyboard?.instantiateViewController(withIdentifier: "TaskVC") as! TasksViewController
		taskVC.title = "Task List"
		
		var aboutVC = storyboard?.instantiateViewController(withIdentifier: "AboutVC") as! AboutProjectViewController
		aboutVC.title = "About Project"
		
		var membersVC = storyboard?.instantiateViewController(withIdentifier: "MembersVC") as! MembersViewController
		membersVC.title = "Members"
		
		return [taskVC, membersVC, aboutVC]
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		menuView.hide()
	}
	
	private func setupUI() {
		addTaskButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
		navigationItem.rightBarButtonItem = addTaskButton
		
		setupDropdownMenu()
		updateChildVC(with: currentVCIndex)
	}
	
	@objc func addTask() {
		if let targetVC = storyboard?.instantiateViewController(withIdentifier: addTaskVCId) as? AddTaskViewController {
			targetVC.projectID = project.id
			navigationController?.pushViewController(targetVC, animated: true)
		}
	}
	
	private func setupDropdownMenu() {
		menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: BTTitle.title(titles.first!), items: titles)
		
		// customize menu
		menuView.cellHeight = 40
		menuView.cellBackgroundColor = self.navigationController?.navigationBar.barTintColor
		menuView.shouldKeepSelectedCellColor = true
		menuView.cellTextLabelFont = mFont
		menuView.cellSelectionColor = UIColor.clear
		menuView.cellTextLabelAlignment = .center
		menuView.arrowPadding = 15
		menuView.animationDuration = 0.4
		menuView.cellSeparatorColor = UIColor.clear
		menuView.checkMarkImage = #imageLiteral(resourceName: "check_green_small")
		menuView.didSelectItemAtIndexHandler = updateChildVC
		menuView.menuTitleColor = UIColor.black
		menuView.arrowTintColor = UIColor.black
		
		self.navigationItem.titleView = menuView
	}
	
	private func updateChildVC(with selectionIndex: Int) {
		let currentChildVC = childrenVCs[currentVCIndex]
		let selectedVC = childrenVCs[selectionIndex]
		
		// configure selectedVC
		if selectedVC is TasksViewController {
			(selectedVC as! TasksViewController).taskIds = project.tasks.map { $0.id }
			print("Selected TaskVC")
			// show navigationbar item to add task
			if self.navigationItem.rightBarButtonItem == nil {
				self.navigationItem.rightBarButtonItem = addTaskButton
			}
		} else if selectedVC is AboutProjectViewController {
			(selectedVC as! AboutProjectViewController).project = project
			print("selected AboutVC")
			// hide navigationbar item
			self.navigationItem.rightBarButtonItem = nil
		} else if selectedVC is MembersViewController {
			(selectedVC as! MembersViewController).project = project
			print("selected membersVC")
			// hide navigationbar item
			self.navigationItem.rightBarButtonItem = nil
		}
		
		remove(asChildViewController: currentChildVC)
		add(asChildViewController: selectedVC)
		
		// keep track of childVC index
		currentVCIndex = selectionIndex
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

