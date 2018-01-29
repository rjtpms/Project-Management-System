//
//  ViewControllerExtension.swift
//  Project2-PMS
//
//  Created by LinChico on 1/23/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit

// hide keyboard when tapped around
extension UIViewController {
	var mFont: UIFont? {
		let font = UIFont(name: "Avenir-Heavy", size: 14)
		return font
	}
	
	var sFont: UIFont? {
		let font = UIFont(name: "Avenir", size: 12)
		return font
	}
	
	var lFont: UIFont? {
		let font = UIFont(name: "Avenir-Medium", size: 18)
		return font
	}
	
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
	
	func showNetworkIndicators() {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
	}
	
	func hideNetworkIndicatros() {
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
	}
	
	// get the first contentVC
	var contents: UIViewController {
		if let navCon = self as? UINavigationController {
			return navCon.visibleViewController ?? self
		} else {
			return self
		}
	}
	
	func daysLeft(to dueDate: Date) -> Int {
		let elapseSeconds = dueDate.timeIntervalSince(Date())
		let hr = elapseSeconds / 3600
		let days = hr / 24
		
		return Int(days)
	}
}

extension UIViewController {
    func alert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

// add border to one side
extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect.init(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect.init(x: 0, y: 0, width: thickness, height: frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect.init(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
}

extension Date {
	var dateString: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM d, yyyy"
		return dateFormatter.string(from: self)
	}
}

extension UIView {
	var roundRadius: CGFloat {
		return self.frame.height / 2
	}
}

