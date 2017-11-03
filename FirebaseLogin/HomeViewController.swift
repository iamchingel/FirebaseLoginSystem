//
//  HomeViewController.swift
//  FirebaseLogin
//
//  Created by Sanket  Ray on 03/11/17.
//  Copyright © 2017 Sanket Ray. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var open: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        open.target = self.revealViewController()
        open.action = #selector(SWRevealViewController.revealToggle(_:))
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
    }


}
