//
//  ManageMemberVC+CollectionDelegates.swift
//  Project2-PMS
//
//  Created by Mark on 1/27/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import Foundation
import UIKit

extension ManageMemembersViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDragDelegate {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return selectedMembers.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cvCell = collectionView.dequeueReusableCell(withReuseIdentifier: memberPhotoCellID, for: indexPath) as! MemberPhotoCell
		
		let currentSelectedMember = selectedMembers[indexPath.row]
		cvCell.photoUrl = currentSelectedMember.profileImageURL
		cvCell.name = currentSelectedMember.name
		
		return cvCell
	}
	
	func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		// only manager can drag the memeber to delete it
		if let currentCell = collectionView.cellForItem(at: indexPath) as? MemberPhotoCell, CurrentUser.sharedInstance.role == .manager {
			let draggedImage = currentCell.memberPhoto.image!
			let itemProvider = NSItemProvider(object: draggedImage)
			let dragItem  = UIDragItem(itemProvider: itemProvider)
			print("items for begining dragging")
			// track the dragged itemIndex
			draggedMemberIndexpath = indexPath
			return [dragItem]
		}
		return []
	}
	
	func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
		
		let memberToBeRemoved = selectedMembers[draggedMemberIndexpath.row]
		// remove the item from collectionView
		selectedMembers.remove(at: draggedMemberIndexpath.row)
		
		// call delegte with removed member, if we
		delegate?.didRemoveMember(memberToBeRemoved)
	}
}
