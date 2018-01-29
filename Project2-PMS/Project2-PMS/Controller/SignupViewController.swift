//
//  SignupViewController.swift
//  Project2-PMS
//
//  Created by LinChico on 1/23/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit
import FirebaseAuth
import TWMessageBarManager

class SignupViewController: UIViewController {
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var roleField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    let roles = [Role.member.rawValue, Role.manager.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }
    
    func setupView() {
        hideKeyboardWhenTappedAround()
        signupButton.layer.cornerRadius = 5
        
        navigationItem.title = "Sign Up"
        
        // add bottom borders for text fields
        nameField.layer.addBorder(edge: .bottom, color: .darkGray, thickness: 0.5)
        emailField.layer.addBorder(edge: .bottom, color: .darkGray, thickness: 0.5)
        
        // add top border for bottom view
        bottomView.layer.addBorder(edge: .top, color: .darkGray, thickness: 0.5)
        
        // view move up as keyboard shows
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // pickerview
        let pickerView = UIPickerView()
        pickerView.delegate = self
        roleField.inputView = pickerView
        pickerView.dataSource = self
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userinfo = notification.userInfo {
            if let keyboardSize = (userinfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                bottomConstraint.constant = keyboardSize.height
            }
            UIView.animate(withDuration: 0.1, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func signupAction(_ sender: Any) {
        signup()
    }
    
    func signup() {
        let name = nameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if name.count == 0 {
            let alert = UIAlertController(title: "Invalid Name", message: "Full name must not be empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let role = roleField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if role != Role.manager.rawValue && role != Role.member.rawValue {
            let alert = UIAlertController(title: "Invalid Role", message: "Please select one of the roles in the options", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let pwd = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        /* sign up */
        Auth.auth().createUser(withEmail: email, password: pwd) { (firebaseUser, error) in
            if error == nil {
                if let user = firebaseUser {
                    print(user.description)
                    FIRService.shareInstance.createUserProfile(ofUser: user.uid, name: name, email: user.email, role: role)
                    TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "You have successfully signed up!", type: .success, duration: 3.0)
                    
                    let currUser = CurrentUser.sharedInstance
                    currUser.email = email
                    currUser.fullname = name
					currUser.role = Role(rawValue: role)!
                    currUser.userId = user.uid
					
					// save user data
					currUser.save()
					CurrentUser.sharedInstance.email = email
                    CurrentUser.sharedInstance.fullname = name
                    
                    
                    // TODO: - Go to home page
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "tabVC")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = controller
                }
            } else {
                let alert = UIAlertController(title: "Sign Up Failed", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

}

extension SignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            if (passwordField.text?.isEmpty)! {
                return false
            } else {
                signup()
            }
        }
        return true
    }
}

extension SignupViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return roles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return roles[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        roleField.text = roles[row]
    }
}
