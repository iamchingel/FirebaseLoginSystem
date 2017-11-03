//
//  LoginViewController.swift
//  FirebaseLogin
//
//  Created by Sanket Ray on 30/10/17.
//  Copyright © 2017 Sanket Ray. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var signInEmail: UITextField!
    @IBOutlet weak var signInPassword: UITextField!
    
    var uniqueID : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signInEmail.delegate = self
        signInPassword.delegate = self
    

    }
    
    @IBAction func login(_ sender: Any) {
        login()
    }
    @IBAction func loginWithFacebook(_ sender: Any) {
        facebookLogin()
    }
    
    
    func login(){
        guard let email = signInEmail.text else {
            return
        }
        guard let password = signInPassword.text else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
            //handle error
                return
            }
            self.uniqueID = user?.uid
            //success logging in
            UserDefaults.standard.set(user?.uid, forKey: "uid") // Saving the uid to Userdefaults
            
            self.performSegue(withIdentifier: "LoginWithEmail", sender: self)
            
        }
        
    }
    
    func facebookLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email","public_profile"], from: self) { (result, error) in
            if error != nil {
                print("FB login failed")
                return
            }// login Success
            
            let accessToken = FBSDKAccessToken.current()
            
            guard let accessTokenString = accessToken?.tokenString else {
                return
            }

            let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
            
            Auth.auth().signIn(with: credentials, completion: { (user, error) in
                if error != nil {
                    print("Something went wrong with FB user", error?.localizedDescription)
                    return
                }
                print("Successfully logged in with user",Auth.auth().currentUser?.uid,"🍇")
                
                self.uniqueID = (Auth.auth().currentUser?.uid)!
                UserDefaults.standard.set((Auth.auth().currentUser?.uid)!, forKey: "uid")
                
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"name,email,picture.type(large)"]).start { (connection, result, error) in
                    guard error == nil else {
                        print("Found an error: \(error?.localizedDescription)")
                        return
                    }
                    guard let result = result as? [String: Any] else {
                        print("Error getting detail results of User")
                        return
                    }
                    guard let email = result["email"] as? String else {
                        print("Could not get email id")
                        return
                    }
                    guard let username = result["name"] as? String else {
                        print("Could not get username")
                        return
                    }
                    guard let picture = result["picture"] as? [String:Any] else {
                        print("Getting picture details")
                        return
                    }
                    guard let pictureData = picture["data"] as? [String:Any] else {
                        print("Error getting picture data")
                        return
                    }
                    guard let pictureURL = pictureData["url"] as? String else {
                        print("Error getting the picture URL")
                        return
                    }
                    self.saveUserInfoToFirebase(name: username, url: pictureURL, email: email, uid : (Auth.auth().currentUser?.uid)!)
                }
            })
   
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func saveUserInfoToFirebase(name : String, url : String, email: String, uid: String) {
        
        let userReference = databaseRef.child("users").child(uid)
        let values = ["username":name,"email":email,"pic":url,"location":""]
        userReference.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
           self.performSegue(withIdentifier: "LoginWithFB", sender: self)
        }
    }

}
