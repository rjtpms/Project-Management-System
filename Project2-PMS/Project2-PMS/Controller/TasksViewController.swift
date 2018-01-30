//
//  TasksViewController.swift
//  Project2-PMS
//
//  Created by LinChico on 1/24/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit

class TasksViewController: UIViewController {

	@IBOutlet weak var taskTable: UITableView! {
		didSet {
			print("tableview is set ")
		}
	}
    var refreshControl: UIRefreshControl!
    
    var tasks : [Task] = []
    var taskIds : [String]?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRefreshControl()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    func setupView() {
        taskTable.tableFooterView = UIView()
		let bar = self.navigationController?.navigationBar
		bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
		bar?.shadowImage = UIImage()
		bar?.backgroundColor = UIColor.clear
    }
    
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.isEnabled = true
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(refreshAction(_:)) , for: .valueChanged)
        taskTable.addSubview(refreshControl)
        taskTable.sectionHeaderHeight = 50
        taskTable.sectionFooterHeight = 50
    }
    
    @objc func refreshAction(_ sender: Any) {
        loadData()
    }
    
    func loadData() {
        if let taskids = taskIds {
            
            var tempTasks : [Task] = []
            for taskId in taskids {
                tempTasks.append(Task(id: taskId))
            }
            
            self.tasks = tempTasks
            self.taskTable.reloadData()
            self.refreshControl.endRefreshing()
            
            return
        }
        
        guard let uid = CurrentUser.sharedInstance.userId else {return}
        
        FIRService.shareInstance.getAllTaskIds(ofUser: uid) { (tasks, err) in
            if err != nil {
                print()
                print(err!)
                return
            }
            
            var tempTasks : [Task] = []
            for taskId in tasks! {
                tempTasks.append(Task(id: taskId))
            }
            
            DispatchQueue.main.async {
                self.tasks = tempTasks
                self.taskTable.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
}

extension TasksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = taskTable.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)  as! TaskCell
        let task = tasks[indexPath.row]
        if let title = task.title {
            cell.titleLabel.text = title
        } else {
            FIRService.shareInstance.getTaskInfo(ofTask: task.id, completion: { (taskObj, err) in
                if err != nil {
                    print()
                    print(err!.localizedDescription)
                }
                DispatchQueue.main.async {
                    self.tasks[indexPath.row] = taskObj!
                    self.taskTable.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                }
            })
        }
        
        if let dueDate = task.dueDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd"
            cell.dueDateLabel.text = formatter.string(from: dueDate)
        }
        
        if let isCompleted = task.isCompleted {
            cell.finishedImageView.image = isCompleted ? #imageLiteral(resourceName: "checked-green") : #imageLiteral(resourceName: "checked-grey")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "taskDetailVC") as! TaskDetailViewController
        let task = tasks[indexPath.row]
        if let _ = task.title {
            controller.task = tasks[indexPath.row]
            navigationController?.pushViewController(controller, animated: true)
        } else {
            FIRService.shareInstance.getTaskInfo(ofTask: task.id, completion: { (taskObj, err) in
                if err != nil {
                    print()
                    print(err!.localizedDescription)
                } else {
                    controller.task = taskObj
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            })
        }
    }
    
    
}
