//
//  ManageMemembersViewController.swift
//  Project2-PMS
//
//  Created by Mark on 1/26/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit

protocol ManageMemembersVCDelegate: class {
	func didAddMember(_ member: Member)
	func didRemoveMember(_ member: Member)
}

class ManageMemembersViewController: UIViewController {
	@IBOutlet weak var tableview: UITableView!
	var collectionMemberCell: CollectionContainerCell!
	var draggedMemberIndexpath:IndexPath!
	
	let containerCellID = "ContainerCell"
	let showMemberCellID = "ShowMemberCell"
	let memberPhotoCellID = "MemberPhotoCell"
	
	// if delegate is set then, we allow remove members as well
	// otherwise, we can only add members
	weak var delegate: ManageMemembersVCDelegate?
	
	// this is for collectionview that is in #1 row always
	var selectedMembers: [Member] = [] {
		didSet {
			if collectionMemberCell != nil {
				collectionMemberCell.reloadSelectedMemberData()
			}
		}
	}
	
	// this is the model for available memebers when searching
	var searchResultMembers: [Member] = [] {
		didSet {
			tableview.reloadData()
		}
	}
	
	lazy var tapRecognizer: UITapGestureRecognizer = {
		var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKB))
		return recognizer
	}()
	
	var searchBar: UISearchBar!
	private var searchController = UISearchController(searchResultsController: nil)
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		setupSearching()
    }
}

// MARK: - Helper Methods
extension ManageMemembersViewController {
	
	@objc func dismissKB() {
		searchBar.resignFirstResponder()
		searchBar.setShowsCancelButton(false, animated: true)
	}
	
	@IBAction func dismiss(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}
	
	private func setupUI() {
		tableview.rowHeight = UITableViewAutomaticDimension
		tableview.estimatedRowHeight = 70
		tableview.tableFooterView = UIView()
	}
	
	private func setupSearching() {
		// setup search
		searchController = UISearchController(searchResultsController: nil)
		
		// configure searchController
		searchController.searchResultsUpdater = self
		searchController.dimsBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = false
		// Set this to false, sinceIr we want the search bar accessible at all times.
		
		// configure searchbar
		searchBar = searchController.searchBar
		searchBar.sizeToFit()
		searchBar.placeholder = "Search by email or name"
		searchBar.delegate = self
		searchBar.searchBarStyle = .minimal
		
		let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as! UITextField
		textFieldInsideSearchBar.adjustsFontSizeToFitWidth = true
		textFieldInsideSearchBar.adjustsFontForContentSizeCategory = true
		textFieldInsideSearchBar.font = UIFont(name: "Avenir-Heavy", size: 14)
		
		// Add searchbar to nav bar
		// Fallback on earlier versions
		navigationItem.titleView = searchController.searchBar
	}
}


