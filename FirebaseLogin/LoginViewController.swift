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
            //success logging in
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "HomeScreen") as! HomeScreenViewController
            self.present(controller, animated: true, completion: nil)
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
            print("🥒",accessTokenString,"🥒")

            let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
            
            Auth.auth().signIn(with: credentials, completion: { (user, error) in
                if error != nil {
                    print("Something went wrong with FB user", error?.localizedDescription)
                    return
                }
                print("Successfully logged in with user")
            })
            
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"name,email,picture.type(large)"]).start { (connection, result, error) in
                if error == nil {
                    print(result)
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

}
