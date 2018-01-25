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
        projectID = "324324as9dsadsada"
        setupView()
    }
    
    func setupView() {
        form +++ Section("New Task")
            <<< TextRow(){ row in
                row.title = "Title"
                row.placeholder = "Task title"
            }
            <<< TextRow(){
                $0.title = "Description"
                $0.placeholder = "Task Description"
            }
            +++ Section("Dates")
            <<< DateRow(){
                $0.title = "Start Date"
                $0.value = Date()
            }
            <<< DateRow(){
                $0.title = "Due Date"
                $0.value = Date()
            }
    }
    
    @IBAction func createTaskAction(_ sender: Any) {
        
        let task = Task(id: "")
        
        FIRService.shareInstance.createOrDeleteTask(task: task, toCreate: true) { (err) in
            if err != nil {
                print(err!)
            }
        }
    }
    
}
