//
//  AccountViewController.swift
//  Project2-PMS
//
//  Created by Mark on 1/24/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class AccountViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

	@IBAction func logOut(_ sender: UIButton) {
		do {
			// logout user
			try Auth.auth().signOut()
			GIDSignIn.sharedInstance().signOut()
			
			// reset current user
			CurrentUser.sharedInstance.dispose()
			
			destroyToLogin()
		} catch let error {
			print(error)
		}
	}
	
	private func destroyToLogin() {
		guard let window = UIApplication.shared.keyWindow else {
			return
		}
		
		guard let rootViewController = window.rootViewController else {
			return
		}
		
		// unsubscribe user from push notification
//		Messaging.messaging().unsubscribe(fromTopic: CurrentUser.sharedInstance.userId)
		
		let vc = storyboard?.instantiateViewController(withIdentifier: "mainNav") as! UINavigationController
		
		vc.view.frame = rootViewController.view.frame
		vc.view.layoutIfNeeded()
		
		UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
			window.rootViewController = vc
		}, completion: { completed in
			rootViewController.dismiss(animated: true, completion: nil)
		})
	}
}
