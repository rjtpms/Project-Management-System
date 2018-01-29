//
//  EditTaskViewController.swift
//  Project2-PMS
//
//  Created by LinChico on 1/26/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit
import Eureka

protocol EditTaskViewControllerDelegate {
    func didUpdateTask(task: Task)
}

class EditTaskViewController: FormViewController, UIGestureRecognizerDelegate {

    var task: Task!
    var delegate: EditTaskViewControllerDelegate?
    var refreshControl: UIRefreshControl!
    var members: [Member] = []
    
    var memberCollection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRefreshControl()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPage()
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.isEnabled = true
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(refreshAction(_:)) , for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc func refreshAction(_ sender: Any) {
        loadPage()
    }
    
    func setupView() {
        self.tableView.register(UINib(nibName: "MembersCell", bundle: nil), forCellReuseIdentifier: "membersFormCell")
        
        form +++ Section("Edit Task")
                <<< TextRow(){ row in
                    row.tag = "titleRow"
                    row.title = "Title"
                    row.placeholder = "Task title"
                    row.value = task.title
                }
                <<< TextRow(){
                    $0.tag = "descriptionRow"
                    $0.title = "Description"
                    $0.placeholder = "Task Description"
                    $0.value = task.description
                }
            
                +++ Section("Dates")
                <<< DateRow(){
                    $0.tag = "startDateRow"
                    $0.title = "Start Date"
                    $0.value = task.startDate
                }
                <<< DateRow(){
                    $0.tag = "endDateRow"
                    $0.title = "Due Date"
                    $0.value = task.dueDate
                }
            
            +++ Section("Members") { section in
                var header = HeaderFooterView<MembersTableViewCell>(.nibFile(name: "MembersCell", bundle: nil))
                
                // Will be called every time the header appears on screen
                header.onSetupView = { view, _ in
                    // Commonly used to setup texts inside the view
                    // Don't change the view hierarchy or size here!
                    
                    self.setupCollectionLayout(collectionView: view.membersCollection)
                    
                    view.membersCollection.delegate = self
                    view.membersCollection.dataSource = self
                    self.memberCollection = view.membersCollection
                    view.membersCollection.register(UINib(nibName: "AvatarCellNib", bundle: nil), forCellWithReuseIdentifier: "avatarCell")
                    
                    // add target to view
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.gotoMembersPage(_:)))
                    tap.delegate = self
                    view.addGestureRecognizer(tap)
                    
                    func handleTap(sender: UITapGestureRecognizer? = nil) {
                        // handling code
                    }
                }
                section.header = header
            }
        
            
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(updateTaskAction))
        navigationItem.rightBarButtonItem = doneButton
        
        navigationItem.title = "Edit Task"
    }
    
    @objc func gotoMembersPage(_ sender: Any) {
        let navc = storyboard?.instantiateViewController(withIdentifier: "namageMembersNavC")
        let controller = navc?.contents as! ManageMemembersViewController
        controller.delegate = self
        controller.selectedMembers = members
        present(navc!, animated: true)
    }
    
    func loadPage() {
        // load members
        var tempMembers : [Member] = []
        var count = 0
        for memberId in task.members! {
            FIRService.shareInstance.getUserInfo(ofUser: memberId, completion: { (member, err) in
                if err != nil {
                    print(err!.localizedDescription)
                } else {
                    tempMembers.append(member!)
                    count += 1
                    if count == self.task.members?.count {
                        DispatchQueue.main.async {
                            self.members = tempMembers
                            self.memberCollection.reloadData()
                        }
                    }
                }
            })
        }
    }
    
    @objc func updateTaskAction(_ sender: Any) {
        // Validation
        guard let title = (form.rowBy(tag: "titleRow") as? TextRow)?.value
            else {
                alert("Error", "Title cannot be empty")
                return
        }
        guard let description = (form.rowBy(tag: "descriptionRow") as? TextRow)?.value
            else {
                alert("Error", "Description cannot be empty")
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
        
        task.title = title
        task.description = description
        task.startDate = startDate
        task.dueDate = endDate
        
        FIRService.shareInstance.updateTask(task: task)
        
        delegate?.didUpdateTask(task: task)
        navigationController?.popViewController(animated: true)
    }
    
    func setupCollectionLayout(collectionView: UICollectionView) {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor.clear
    }
    
    // TODO: - implement delegate method to remove/add member from/to task
}

extension EditTaskViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "avatarCell", for: indexPath) as! AvatarCell
        cell.avatarImageView.image = members[indexPath.item].profileImage
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.width / 2
        cell.avatarImageView.clipsToBounds = true
        cell.avatarImageView.contentMode = .scaleAspectFill
        return cell
    }
}

extension EditTaskViewController: EditTaskViewControllerDelegate {
    func didUpdateTask(task: Task) {
        self.task = task
    }
}

extension EditTaskViewController: ManageMemembersVCDelegate {
    func didAddMember(_ member: Member) {
        FIRService.shareInstance.assignTaskToUser(taskId: task.id, userId: member.id) { (err) in
            if (err != nil) {
                print(err!.localizedDescription)
            }
        }
    }
    
    func didRemoveMember(_ member: Member) {
        FIRService.shareInstance.UnassignTaskFromUser(taskId: task.id, userId: member.id) { (err) in
            if err != nil {
                print(err!.localizedDescription)
            }
        }
    }
}
