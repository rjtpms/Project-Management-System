//
//  ManageMemberVC+SearchDelegate.swift
//  Project2-PMS
//
//  Created by Mark on 1/27/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import Foundation
import UIKit

extension ManageMemembersViewController: UISearchBarDelegate, UISearchResultsUpdating {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		dismissKB()
	}
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		view.addGestureRecognizer(tapRecognizer)
	}
	
	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		view.removeGestureRecognizer(tapRecognizer)
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		searchBar.setShowsCancelButton(true, animated: true)
		guard let queryText = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
			!queryText.isEmpty else {
				self.searchResultMembers.removeAll()
				return
		}
		print(queryText)
		
		showNetworkIndicators()
		
		// search Firebase for members with certain email or name
		FIRService.shareInstance.searchMembers(using: queryText, withinProject: projectId) { (members, error) in
			// nide networkIndicators
			DispatchQueue.main.async {
				self.finishGettingSearchResults(members: members, error: error)
			}
		}
		
	}
	
	func finishGettingSearchResults(members: [Member]?, error: Error?) {
		hideNetworkIndicatros()
		
		guard error == nil else { return }
		
		guard let resultMembers = members else { return }
		
		self.searchResultMembers = resultMembers
	}
}
