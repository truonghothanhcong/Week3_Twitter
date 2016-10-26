//
//  LoginViewController.swift
//  Twitter
//
//  Created by CongTruong on 10/24/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func login(_ sender: AnyObject) {
        TwitterClient.sharedInstance.login() { (user, error) in
            if let u = user {
                print("Logged in user: \(u.name) (@\(u.screenName))")
                self.performSegue(withIdentifier: "tabberSegue", sender: self)
            } else {
                print("Error logging in: \(error)")
            }
        }
    }
}




























