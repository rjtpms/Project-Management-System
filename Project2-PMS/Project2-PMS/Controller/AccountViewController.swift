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
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPage()
    }
    
    func setupPage() {
        hideKeyboardWhenTappedAround()
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.clipsToBounds = true
        if let imgUrl = CurrentUser.sharedInstance.profileImageUrl {
            avatarImageView.image = FIRService.shareInstance.downloadImageWithURL(url: imgUrl)
        } else {
            avatarImageView.image = #imageLiteral(resourceName: "user")
        }
        
        nameField.isEnabled = false
        nameField.text = CurrentUser.sharedInstance.fullname
        emailLabel.text = CurrentUser.sharedInstance.email
        
        nameField.delegate = self
		
		let bar = self.navigationController?.navigationBar
		bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
		bar?.shadowImage = UIImage()
		bar?.backgroundColor = UIColor.clear
        
    }
    
    @IBAction func editImageAction(_ sender: Any) {
        // Show options for the source picker only if the camera is available.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            self.presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take a photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)//important step for source type
        }
        let choosePhoto = UIAlertAction(title: "Choose from gallery", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)//important step for source type
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(photoSourcePicker, animated: true)
        
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()//init
        picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate//confirm to delegate that this class will implement delegate methods
        picker.sourceType = sourceType//important to tell UIImagePickerController, what source type camera or photo
        present(picker, animated: true)//not significant
    }
    
    func uploadImage() {
        if let img = avatarImageView.image,
            let uid = CurrentUser.sharedInstance.userId {
            FIRService.shareInstance.uploadImage(ofId: uid, with: img, completion: { (data, err) in
                if (err != nil) {
                    print(err!.localizedDescription)
                } else { // update CurrentUser
                    FIRService.shareInstance.getProfileImageUrl(ofUser: uid, completion: { (url, err) in
                        if err != nil {
                            print (err!.localizedDescription)
                        } else {
                            if let url = url {
                                CurrentUser.sharedInstance.profileImageUrl = url
                            } else {
                                print ("url is not found")
                            }
                        }
                    })
                }
            })
        }
    }
    
    @IBAction func editNameAction(_ sender: Any) {
        nameField.isEnabled = true
        nameField.becomeFirstResponder()
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

extension AccountViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isEnabled = false
        if textField.text!.isEmpty {
            textField.text = CurrentUser.sharedInstance.fullname
            alert("Error", "Name cannot be empty!")
        } else {
            CurrentUser.sharedInstance.fullname = textField.text
            FIRService.shareInstance.updateUserName(ofUser: CurrentUser.sharedInstance.userId, name: textField.text!)
        }
    }
    
    func textfieldret(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //imagePickerController delegate methods
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)
        
        // We always expect `imagePickerController(:didFinishPickingMediaWithInfo:)` to supply the original image.
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        avatarImageView.image = image
        uploadImage()
    }
    
    //imagePickerController delegate methods
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        print("cancel")
    }
}



