//
//  AppDelegate.swift
//  Project2-PMS
//
//  Created by LinChico on 1/22/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleSignIn
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		FirebaseApp.configure()
		GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
		IQKeyboardManager.sharedManager().enable = true
		
		findEntryPoint()
		
        return true
    }
	
	private func findEntryPoint() {
		let mainStoryBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
		if let _ = Auth.auth().currentUser {
			// restore current user from userdefaults
			CurrentUser.sharedInstance.restore()
			window?.rootViewController = mainStoryBoard.instantiateViewController(withIdentifier: "tabVC")
		}
	}

	@available(iOS 9.0, *)
	func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
		-> Bool {
			
		return GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
	}

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataManager.shareInstance.saveContext()
    }
}

