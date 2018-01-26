//
//  LoginVC+Helper.swift
//  Project2-PMS
//
//  Created by Mark on 1/24/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import TWMessageBarManager
import SVProgressHUD

// MARK: - Helper Methods
extension LoginViewController {
	func setupUI() {
		loginButton.layer.cornerRadius = 5
		loginButton.layer.borderWidth = 1
		loginButton.layer.borderColor = UIColor.gray.cgColor
		loginButton.clipsToBounds = true
		
		// view move up as keyboard shows
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	@objc func keyboardWillShow(_ notification: Notification) {
		if let userinfo = notification.userInfo {
			if let keyboardSize = (userinfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
				bottomViewContraint.constant = keyboardSize.height
			}
			UIView.animate(withDuration: 0.1, animations: {
				self.view.layoutIfNeeded()
			})
		}
	}
	
	@objc func keyboardWillHide(_ notification: Notification) {
		bottomViewContraint.constant = 0
		UIView.animate(withDuration: 0.1, animations: {
			self.view.layoutIfNeeded()
		})
	}
	
	func validateInputs() -> Bool {
		// validate
		guard let email = emailTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines),
			!email.isEmpty else {
				TWMessageBarManager().showMessage(withTitle: "Error", description: "Email can not be empty", type: .error)
				return false
		}
		
		guard let password = passwordTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines),
			!password.isEmpty else {
				TWMessageBarManager().showMessage(withTitle: "Error", description: "Password can not be empty", type: .error)
				return false
		}
		
		userEmail = email
		userPassword = password
		
		// Clear inputs once validated
		emailTextfield.text = ""
		passwordTextfield.text = ""
		
		return true
	}
	
	func loginUser(_ credential: AuthCredential? = nil) {
		// handle oAuth signin
		if let cred = credential {
			SVProgressHUD.show(withStatus: "logging in...")
			FIRService.shareInstance.loginUser(with: cred) { [weak self ] (user, error) in
				self?.proceedLogin(for: user, with: error)
			}
		} else {
			// Handle Email/Password login
			if validateInputs() {
				// Call FIRService to login user with email and password
				SVProgressHUD.show(withStatus: "logging in...")
				FIRService.shareInstance.loginUser(with: userEmail, and: userPassword) { [weak self] (user, error) in
					self?.proceedLogin(for: user, with: error)
				}
			}
		}
	}
	
	func proceedLogin(for user: User?, with error: Error?) {
		guard error == nil, let user = user else {
			SVProgressHUD.dismiss()
			TWMessageBarManager().showMessage(withTitle: "Error", description: error!.localizedDescription, type: .error)
			return
		}
		
		// Save user info in firebase, and in sinleton
		FIRService.shareInstance.saveLoggedInUser(user) {
			SVProgressHUD.dismiss()
			
			let currentUser = CurrentUser.sharedInstance
			// navigate to new page to select role if current user role is none
			if currentUser.role == .none {
				self.performSegue(withIdentifier: "LoginToExtraInfoSegue", sender: nil)
			} else {
				TWMessageBarManager().showMessage(withTitle: "Success", description: "Welcome, \(currentUser.fullname)", type: .success)
				// TODO: Navigate to homeVC
				self.performSegue(withIdentifier: "loginToTabSegue", sender: nil)
			}
		}
	}
}
