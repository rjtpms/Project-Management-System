//
//  MemersCollectionCell.swift
//  Project2-PMS
//
//  Created by Mark on 1/27/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit

typealias CVDelegates = UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDragDelegate

class CollectionContainerCell: UITableViewCell {
	@IBOutlet private weak var membersCollectionView: UICollectionView! {
		didSet {
			membersCollectionView.dragInteractionEnabled = true
		}
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	// this incomding delegate we are about to assign to collectionview has to conform both
	// collectionDatasouce and delegate
	func setCollectionViewDelegates
		<D: CVDelegates> (dataSourceDelegate: D) {
		
		membersCollectionView.delegate = dataSourceDelegate
		membersCollectionView.dragDelegate = dataSourceDelegate
		membersCollectionView.dataSource = dataSourceDelegate
		membersCollectionView.reloadData()
	}
	
	func reloadSelectedMemberData() {
		membersCollectionView.reloadData()
	}
}
