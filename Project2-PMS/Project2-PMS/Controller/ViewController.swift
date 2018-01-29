//
//  ViewController.swift
//  Project2-PMS
//
//  Created by LinChico on 1/22/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet weak var signunButton: UIButton!
	@IBOutlet weak var signinButton: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
    }
	
	func setupUI() {
		let bar = self.navigationController?.navigationBar
		bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
		bar?.shadowImage = UIImage()
		bar?.backgroundColor = UIColor.clear
		
		signinButton.layer.cornerRadius = 10
		signinButton.clipsToBounds = true
		
		signunButton.layer.cornerRadius = 10
		signunButton.clipsToBounds = true
		
		signinButton.titleLabel?.font = mFont
		signunButton.titleLabel?.font = mFont
		
	}
}

