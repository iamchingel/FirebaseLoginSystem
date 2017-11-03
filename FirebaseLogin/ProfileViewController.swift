//
//  ProfileViewController.swift
//  FirebaseLogin
//
//  Created by Sanket Ray on 30/10/17.
//  Copyright © 2017 Sanket Ray. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userDetails: UITextView!
    var uid : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let value = UserDefaults.standard.object(forKey: "uid")   {
            print("🥩🥩🥩🥩",value,"🥩🥩🥩🥩🥩")
            uid = value as? String
        }
        setupProfile()

    }

    @IBAction func uploadImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    @IBAction func saveImage(_ sender: Any) {
        if profileImage.image != nil {
            let imageName = NSUUID().uuidString
            let storedImage = storageRef.child("profileImage").child(imageName)
            if let uploadData = UIImagePNGRepresentation(profileImage.image!) {
                storedImage.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        //handle error
                        print("🥒","\(String(describing: error?.localizedDescription))")
                        return
                    }
                    storedImage.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print("🥕","\(String(describing: error?.localizedDescription))")
                            return
                        }
                        if let urlText = url?.absoluteString {
                            databaseRef.child("users").child(self.uid!).updateChildValues(["pic": urlText], withCompletionBlock: { (error, ref) in
                                if error != nil {
                                    print("🌽","\(String(describing: error?.localizedDescription))")
                                    return
                                }
                                print("🥖Successfully added image to database🥖")
                            })
                        }
                    })
                })
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImage.image = editedImage
        }else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            profileImage.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logout(_ sender: Any) {
        try! Auth.auth().signOut()
        UserDefaults.standard.set(nil, forKey: "uid")
        logout()
    }
    func setupProfile() {
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        databaseRef.child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String:AnyObject] {
                self.userDetails.text = "Name: \(dict["username"] as! String), Email ID: \(dict["email"] as! String), Location: \(dict["location"] as! String)"
                
                guard let url = URL(string: (dict["pic"] as? String)!) else {
                    print("Image URL not found")
                    return
                }
                let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    if error == nil {
                        DispatchQueue.main.async {
                            self.profileImage.image = UIImage(data: data!)
                        }
                    }
                })
                task.resume()
            }
        }

    }
    
    func logout() {
        print("🍇🍇🍇Need to logout🍇🍇🍇🍇")
        let controller = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        present(controller, animated: true, completion: nil)
    }

}
