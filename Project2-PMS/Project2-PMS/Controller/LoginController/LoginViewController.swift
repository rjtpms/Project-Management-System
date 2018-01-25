//
//  LoginViewController.swift
//  Project2-PMS
//
//  Created by Mark on 1/23/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit
import GoogleSignIn
import TWMessageBarManager
import FirebaseAuth

class LoginViewController: UIViewController {
	@IBOutlet weak var loginButton: UIButton!
	@IBOutlet weak var emailTextfield: UITextField!
	@IBOutlet weak var passwordTextfield: UITextField!
	@IBOutlet weak var bottomViewContraint: NSLayoutConstraint!
	
	lazy var tapRecognizer: UITapGestureRecognizer = {
		var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
		return recognizer
	}()
	
	var userEmail: String!
	var userPassword: String!
	
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
