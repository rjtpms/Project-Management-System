//
//  TasksViewController.swift
//  Project2-PMS
//
//  Created by LinChico on 1/24/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit

class TasksViewController: UIViewController {

    @IBOutlet weak var taskTable: UITableView!
    @IBOutlet weak var addTaskButton: UITableView!
    var refreshControl: UIRefreshControl!
    
    var tasks : [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRefreshControl()
        setupView()
        loadData()
    }
    
    func setupView() {
        let role = CurrentUser.sharedInstance.role
        switch role {
        case Role.manager:
            addTaskButton.isHidden = false
        case Role.member:
            addTaskButton.isHidden = true
		default:
			break
        }
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
        let cell = taskTable.dequeueReusableCell(withIdentifier: "taskCell")  as! TaskCell
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
        
        return cell
    }
    
    
}
