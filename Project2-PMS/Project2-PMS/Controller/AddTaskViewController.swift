//
//  AddTaskViewController.swift
//  Project2-PMS
//
//  Created by LinChico on 1/24/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit
import Eureka

class AddTaskViewController: FormViewController {

    var projectID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }
    
    func setupView() {
        form +++ Section("New Task")
            <<< TextRow(){ row in
                row.tag = "titleRow"
                row.title = "Title"
                row.placeholder = "Task title"
            }
            <<< TextRow(){
                $0.tag = "descriptionRow"
                $0.title = "Description"
                $0.placeholder = "Task Description"
            }
            +++ Section("Dates")
            <<< DateRow(){
                $0.tag = "startDateRow"
                $0.title = "Start Date"
                $0.value = Date()
            }
            <<< DateRow(){
                $0.tag = "endDateRow"
                $0.title = "Due Date"
                $0.value = Date()
            }
    }
    
    @IBAction func createTaskAction(_ sender: Any) {
        // Validation
        guard let title = (form.rowBy(tag: "titleRow") as? TextRow)?.value
            else {
            alert("Error", "Please add a title")
            return
        }
        guard let description = (form.rowBy(tag: "descriptionRow") as? TextRow)?.value
            else {
                alert("Error", "Please add a description")
                return
        }
        
        guard let startDate = (form.rowBy(tag: "startDateRow") as? DateRow)?.value else {
            alert("Error", "Please choose a start date")
            return
        }
        
        guard let endDate = (form.rowBy(tag: "endDateRow") as? DateRow)?.value else {
            alert("Error", "Please choose an end date")
            return
        }
        
        let task = Task(id: "")
        task.projectId = projectID
        task.title = title
        task.description = description
        task.startDate = startDate
        task.dueDate = endDate
        task.members = []
        
        FIRService.shareInstance.createOrDeleteTask(task: task, toCreate: true) { (err) in
            if err != nil {
                print(err!)
                self.alert("Error", err!.localizedDescription)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    
}
