//
//  RegistrationViewController.swift
//  FirebaseLogin
//
//  Created by Sanket Ray on 30/10/17.
//  Copyright © 2017 Sanket Ray. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var emailID: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var location: UITextField!
    
    var userUniqueID : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fullName.delegate = self
        emailID.delegate = self
        password.delegate = self
        location.delegate = self
        
    }

    @IBAction func register(_ sender: Any) {
        guard let name = fullName.text else {
            return
        }
        guard let email = emailID.text else {
            return
        }
        guard let password = password.text else {
            return
        }
        guard let location = location.text else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                return
            }
            // registration successful
            guard let uid = user?.uid else {
                return
            }
            self.userUniqueID = uid
            UserDefaults.standard.set(uid, forKey: "uid")
            
            let userReference = databaseRef.child("users").child(uid)
            let values = ["username":name,"email":email,"pic":"","location":location]
            
            userReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
                if error != nil {
                    return
                }
                // successfully saved user details
                self.performSegue(withIdentifier: "RegistrationComplete", sender: self)
            })
        }
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationController = segue.destination as! HomeScreenViewController
        destinationController.uid = userUniqueID
    }
    
}
