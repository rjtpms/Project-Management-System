//
//  LoginViewController.swift
//  Project2-PMS
//
//  Created by Mark on 1/23/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit
import TWMessageBarManager
import GoogleSignIn
import FirebaseAuth
import SVProgressHUD

class LoginViewController: UIViewController {
	@IBOutlet weak var loginButton: UIButton!
	@IBOutlet weak var emailTextfield: UITextField!
	@IBOutlet weak var passwordTextfield: UITextField!
	@IBOutlet weak var bottomViewContraint: NSLayoutConstraint!
	
	lazy var tapRecognizer: UITapGestureRecognizer = {
		var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
		return recognizer
	}()
	
	private var userEmail: String!
	private var userPassword: String!
	
	// MARK: - Viewcontroller Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		view.addGestureRecognizer(tapRecognizer)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		dismissKeyboard()
		view.removeGestureRecognizer(tapRecognizer)
	}
	
	// MARK: - IBActions
	@IBAction func forgotPassword(_ sender: UIButton) {
		// TODO: Reset password Page
	}
	
	@IBAction func login(_ sender: UIButton) {
		loginUser()
	}
	
	@IBAction func googleLogin(_ sender: UIButton) {
		GIDSignIn.sharedInstance().uiDelegate = self
		GIDSignIn.sharedInstance().delegate = self
		GIDSignIn.sharedInstance().signIn()
	}
}

// MARK: - Helper Methods
private extension LoginViewController {
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
		
		print(user.displayName ?? "")
		print(user.uid)
		print(user.email ?? "")
		print(user.photoURL?.absoluteString ?? "")
		
		// Save user info in firebase, and in sinleton
		FIRService.shareInstance.saveLoggedInUser(user) {
			SVProgressHUD.dismiss()
			TWMessageBarManager().showMessage(withTitle: "Success", description: "Welcome back \(CurrentUser.sharedInstance.fullname ?? "")", type: .success)
			// TODO: Navigate to homeVC and we are on main queue
		}
	}
}

extension LoginViewController: GIDSignInUIDelegate, GIDSignInDelegate {
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
		
		if let error = error {
			TWMessageBarManager().showMessage(withTitle: "Error", description: error.localizedDescription, type: .error)
			return
		}
		
		guard let authentication = user.authentication else  {
			return
		}
		
		let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
		
		print("Got credential, ready to login")
		loginUser(credential)
	}
}

extension LoginViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		switch textField {
		case emailTextfield:
			passwordTextfield.becomeFirstResponder()
		case passwordTextfield:
			passwordTextfield.resignFirstResponder()
			
			// Login user when press "GO"
			loginUser()
		default:
			break
		}
		
		return true
	}
}
