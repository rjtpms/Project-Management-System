//
//  MembersViewController.swift
//  Project2-PMS
//
//  Created by Mark on 1/26/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit

class MembersViewController: UIViewController {
	@IBOutlet weak var memberTableview: UITableView!
	var refreshControl = UIRefreshControl()
	
	private let memberCellIdentifier = "MemberCell"
	private let addMemberCellidentifier = "AddCell"
	private let showManageMemberSegue = "ShowManageMemberSegue"
	
	var project: Project! {
		didSet {
			
		}
	}
	
	var manager: Member! {
		didSet {
			let indexPath = IndexPath(row: 0, section: 0)
			memberTableview.reloadRows(at: [indexPath], with: .none)
		}
	}
	
	var members: [Member] = [] {
		didSet {
			memberTableview.reloadData() // need improve
		}
	}
	
	lazy var currentUser: CurrentUser = {
		CurrentUser.sharedInstance.restore()
		return CurrentUser.sharedInstance
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		preConfigureProperties()
		fetchTableData()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		print("memeber VC will appear")
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		print("member VC did appear")
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShowManageMemberSegue", let target = segue.destination.contents as? ManageMemembersViewController {
			target.selectedMembers = members
			target.delegate = self
		}
	}
}

extension MembersViewController: ManageMemembersVCDelegate {
	func didRemoveMember(_ member: Member) {
		print("\(member.name!) is about to be removed from current project")
		
		members = members.filter { $0.id != member.id }
		
		// remove from firebase
		FIRService.shareInstance.remove(member: member.id, fromProject: project.id)
	}
	
	func didAddMember(_ member: Member) {
		print("\(member.name!) is about to be added to current project")
		
		members.append(member)
		
		// add member to project: add project id to member, and add member to membes in project
		FIRService.shareInstance.add(member: member.id, toProject: project.id)
	}
}

extension MembersViewController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 1
		}
		
		switch currentUser.role {
		case .manager:
			return members.count + 1
		case .member:
			return members.count
		default:
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell!
		// section 0
		if indexPath.section == 0 {
			cell = tableView.dequeueReusableCell(withIdentifier: memberCellIdentifier, for: indexPath)
			if manager != nil {
				(cell as! MemberCell).configureCell(imageURL: manager.profileImageURL, name: manager.name, email: manager.email)
			}
			return cell
		}
		
		// section 1
		let isManager = currentUser.role == .manager
		if indexPath.row == 0, isManager {
			cell = tableView.dequeueReusableCell(withIdentifier: addMemberCellidentifier, for: indexPath)
		} else {
			cell = tableView.dequeueReusableCell(withIdentifier: memberCellIdentifier, for: indexPath)
			let rowIndex = isManager ? indexPath.row - 1 : indexPath.row
			let currentMember = members[rowIndex]
			(cell as! MemberCell).configureCell(imageURL: currentMember.profileImageURL, name: currentMember.name, email: currentMember.email)
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let titleLabel = UILabel()
		titleLabel.frame = CGRect(x: 15, y: 8, width: 320, height: 20)
		titleLabel.font = mFont
		titleLabel.text = section == 0 ? "Manager" : "Members"
		
		let headerView = UIView()
		headerView.addSubview(titleLabel)
		
		return headerView
	}
}
