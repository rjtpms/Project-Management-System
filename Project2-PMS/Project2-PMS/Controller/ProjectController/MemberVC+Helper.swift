//
//  MemberVC+Helper.swift
//  Project2-PMS
//
//  Created by Mark on 1/27/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import Foundation
import UIKit

extension MembersViewController {
	func preConfigureProperties() {
		if currentUser.userId == project.managerId {
			manager = currentUser.convertToMember()
		}
		
		guard !project.members.isEmpty else { return }
		members = project.members
	}
	
	func setupUI() {
		refreshControl.isEnabled = true
		refreshControl.tintColor = UIColor.cyan
		refreshControl.addTarget(self, action: #selector(fetchTableData), for: .valueChanged)
		memberTableview.addSubview(refreshControl)
		memberTableview.rowHeight = UITableViewAutomaticDimension
		memberTableview.estimatedRowHeight = 55
	}
	
	@objc func needToFetch() {
		refreshControl.beginRefreshing()
		fetchTableData()
	}
	
	@objc func fetchTableData() {
		let fetchdataGroup = DispatchGroup()
		var tempMembers: [Member] = []
		
		// fetch manager if current user is not the manager of currenet project
		if manager == nil {
			fetchdataGroup.enter()
			FIRService.shareInstance.fetchUserInfo(with: project.managerId) { (manager, error) in
				fetchdataGroup.leave()
				guard error == nil else {
					print(error!.localizedDescription)
					return
				}
				
				guard let unwrappedManager = manager else { return }
				
				DispatchQueue.main.async {
					self.manager = unwrappedManager
				}
			}
		}
		
		// fetch members data
		if !members.isEmpty {
			for member in members {
				fetchdataGroup.enter()
				FIRService.shareInstance.fetchUserInfo(with: member.id) { (member, error) in
					fetchdataGroup.leave()
					
					guard error == nil else {
						print(error!.localizedDescription)
						return
					}
					
					guard let unwrappedMember = member else { return }
					
					tempMembers.append(unwrappedMember)
				}
			}
		}
		
		fetchdataGroup.notify(queue: .main) { [weak self] in
			// stop spinner,refresh controll
			self?.refreshControl.endRefreshing()
			self?.members = tempMembers
		}
	}
}
