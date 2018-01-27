//
//  ManageMemberVC+TabeDelegates.swift
//  Project2-PMS
//
//  Created by Mark on 1/27/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import Foundation
import UIKit

extension ManageMemembersViewController: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if section == 0 {
			return 1
		}
		
		return searchResultMembers.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell!
		
		if indexPath.section == 0 {
			cell = tableview.dequeueReusableCell(withIdentifier: containerCellID, for: indexPath) as! CollectionContainerCell
			collectionMemberCell = cell as! CollectionContainerCell!
		} else {
			cell = tableview.dequeueReusableCell(withIdentifier: showMemberCellID, for: indexPath)
			let currentMember = searchResultMembers[indexPath.row]
			(cell as! ShowMemeberCell).configureCell(imageURL: currentMember.profileImageURL, name: currentMember.name, email: currentMember.email)
			
			// check if currentMemeber is already in selected list
			if selectedMembers.contains(where: { $0.id == currentMember.id }) {
				cell.accessoryType = .checkmark
			} else {
				cell.accessoryType = .none
			}
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		// setup delegate for the first row which is the collectionContainer cell
		guard let containerCell = cell as? CollectionContainerCell else { return }
		
		// this will always set the #1 row unless we change the cell position in cellforrow at indexpath
		containerCell.setCollectionViewDelegates(dataSourceDelegate: self)
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let titleLabel = UILabel()
		titleLabel.frame = CGRect(x: 15, y: 8, width: 320, height: 20)
		titleLabel.font = mFont
		titleLabel.text = section == 0 ? "Selected Members" : "Available Members"
		
		let headerView = UIView()
		headerView.addSubview(titleLabel)
		
		return headerView
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let currentCell = tableView.cellForRow(at: indexPath),
			currentCell.accessoryType == .none {
			
			// if it not checked then check it
			currentCell.accessoryType = .checkmark
			
			// add it to collection view
			let currentMemeber = searchResultMembers[indexPath.row]
			selectedMembers.append(currentMemeber)
			
			// call delegate
			delegate?.didAddMember(currentMemeber)
		}
	}
	
}
