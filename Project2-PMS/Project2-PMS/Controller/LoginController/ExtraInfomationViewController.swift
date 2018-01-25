//
//  ExtraInfomationViewController.swift
//  Project2-PMS
//
//  Created by Mark on 1/24/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit
import Eureka
import FirebaseAuth
import FirebaseDatabase
import TWMessageBarManager

class ExtraInfomationViewController: FormViewController {

	private var selectedRole: Role!
	private lazy var userRef = Database.database().reference().child("Users")
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
    }
	
	private func setupUI() {
		navigationItem.hidesBackButton = true
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(preceedLogin))
		
		form
			+++ Section()
			<<< PickerInlineRow("Inline picker"){(row : PickerInlineRow<String>) -> Void in
				row.title = "Choose your role"
				row.options = ["Member", "Project Manager"]
				row.onChange{ [unowned self] row in
					self.selectedRole = Role(rawValue: row.value!)
				}
		}
	}
	
	@objc func preceedLogin() {
		print(selectedRole.rawValue)
		// save to firebase
		let currentUser = CurrentUser.sharedInstance
		let roleValue = ["role": selectedRole.rawValue]
		userRef.child(currentUser.userId).updateChildValues(roleValue) { (error, ref) in
			guard error == nil else {
				print(error!.localizedDescription)
				return
			}
			DispatchQueue.main.async {
				// update currentUser
				currentUser.role = self.selectedRole
				currentUser.save()
				
				// show welcome message
				TWMessageBarManager().showMessage(withTitle: "Success", description: "Welcome, \(currentUser.fullname)", type: .success)
				
				// navigate to homeVC
				self.performSegue(withIdentifier: "ExtraInfoToTabSegue", sender: nil)
			}
		}
	}
}
