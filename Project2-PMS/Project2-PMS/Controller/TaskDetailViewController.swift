//
//  TaskDetailViewController.swift
//  Project2-PMS
//
//  Created by LinChico on 1/24/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {
   
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var commentTable: UITableView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var myScrollView: UIScrollView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateImageView: UIImageView!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var membersCollection: UICollectionView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var task: Task!
    var comments: [Comment] = [Comment()]
    var members: [Member] = []
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupRefreshControl()
        setupView()
        loadPage()
    }
    
    
    @IBAction func refreshBtnAction(_ sender: Any) {
        refreshControl.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        super.viewWillDisappear(animated)
    }
    
    func setupView() {
        navigationItem.title = "Task"
        commentTable.tableFooterView = UIView()
        commentView.layer.cornerRadius = commentView.frame.height / 2
        
        if let isCompleted  = task.isCompleted {
            let image = isCompleted ? #imageLiteral(resourceName: "checked-green") : #imageLiteral(resourceName: "checked-grey")
            checkButton.setImage(image, for: .normal)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        startDateLabel.text = formatter.string(from: task.startDate!)
        endDateLabel.text = formatter.string(from: task.dueDate!)
        titleLabel.text = task.title
        descriptionLabel.text = task.description
        setupCollectionLayout(collectionView: membersCollection)
    }
    
    func loadPage() {
        // load members
        var tempMembers : [Member] = []
        for memberId in task.members! {
            FIRService.shareInstance.getUserInfo(ofUser: memberId, completion: { (member, err) in
                if err != nil {
                    print(err!.localizedDescription)
                } else {
                    tempMembers.append(member!)
                    DispatchQueue.main.async {
                        self.members = tempMembers
                        self.membersCollection.reloadData()
                    }
                }
            })
        }
        
        // load comments
        // ...
        
        refreshControl.endRefreshing()
    }
    @IBAction func checkButtonAction(_ sender: Any) {
        task.isCompleted = !task.isCompleted!
        let image = task.isCompleted! ? #imageLiteral(resourceName: "checked-green") : #imageLiteral(resourceName: "checked-grey")
        checkButton.setImage(image, for: .normal)
        FIRService.shareInstance.setCompletionStatus(ofTask: task.id, to: task.isCompleted!)
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.isEnabled = true
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(refreshAction(_:)) , for: .valueChanged)
        myScrollView.addSubview(refreshControl)
    }
    
    @objc func refreshAction(_ sender: Any) {
        loadPage()
    }
    
    func setupCollectionLayout(collectionView: UICollectionView) {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        
//        let indexPath = IndexPath(item: 0, section: 0)
//        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        collectionView.backgroundColor = UIColor.clear
    }
}

//extension TaskDetailViewController: UITableViewDataSource, UITableViewDelegate {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return comments.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = commentTable.dequeueReusableCell(withIdentifier: "commentCell") as! CommentCell
//        return cell
//    }
//    
//}

extension TaskDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "avatarCell", for: indexPath) as! AvatarCell
        cell.avatarImageView.image = members[indexPath.item].profileImage
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.width / 2
        cell.avatarImageView.clipsToBounds = true
        return cell
    }
}
