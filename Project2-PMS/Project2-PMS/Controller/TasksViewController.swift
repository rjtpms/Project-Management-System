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
    var refreshControl: UIRefreshControl!
    
	var tasks : [Task] = []
    var taskIds : [String]?
	private var numberFetched = 0 {
		didSet {
			if numberFetched == tasks.count {
				tasks.sort { !$0.isCompleted! && $1.isCompleted!}
				taskTable.reloadData()
			}
		}
	}
	
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
        refreshControl.tintColor = .red
        refreshControl.addTarget(self, action: #selector(refreshAction(_:)) , for: .valueChanged)
        taskTable.addSubview(refreshControl)
        taskTable.sectionHeaderHeight = 50
        taskTable.sectionFooterHeight = 50
    }
    
    @objc func refreshAction(_ sender: Any) {
        loadData()
    }
    
    func loadData() {
		numberFetched = 0
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
        let t = Task(id: "123")
        t.title = "TT"
        t.isCompleted = true
        t.dueDate = Date()
        tasks=[t]
        taskTable.reloadData()
        
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
//                    self.taskTable.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
					self.numberFetched += 1
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
			cell.dueDateLabel.isEnabled = !isCompleted
			cell.titleLabel.isEnabled = !isCompleted
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
