//
//  ViewController.swift
//  SocialTwet
//
//  Created by CongTruong on 10/28/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import PulsingHalo

class ViewController: UIViewController {

    @IBOutlet weak var facebookLoginLabel: UILabel!
    @IBOutlet weak var lolLabel: UILabel!
    @IBOutlet weak var LOLImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initHalo()
    }
    
    func initHalo() {
        let halo = PulsingHaloLayer()
        halo.haloLayerNumber = 2
        halo.radius = self.view.frame.width / 3
        halo.backgroundColor = UIColor.white.cgColor
        halo.position = view.center
        view.layer.addSublayer(halo)
        halo.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginFacebook(_ sender: AnyObject) {
        lolLabel.isHidden = false
        LOLImageView.isHidden = false
    }

    @IBAction func onLogin(_ sender: AnyObject) {
        let client = ClientApi.shareInstance
        
        client.login(success: { 
            print("i login now")
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }) { (error: Error) in
            print(error.localizedDescription)
        }
    }
}



