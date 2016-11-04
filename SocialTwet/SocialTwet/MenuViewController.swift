//
//  MenuViewController.swift
//  SocialTwet
//
//  Created by CongTruong on 11/4/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import UIKit
import AFNetworking

class MenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    private var timelineNavigationViewController: UIViewController!
    private var profileNavigationViewController: UIViewController!
    
    var viewController: [UIViewController] = []
    
    var hamburgerViewController: HamburgerViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        timelineNavigationViewController = storyboard.instantiateViewController(withIdentifier: "timelineNavigationController")
        profileNavigationViewController = storyboard.instantiateViewController(withIdentifier: "profileNavigationController")
        
        viewController.append(timelineNavigationViewController)
        viewController.append(profileNavigationViewController)
        
        hamburgerViewController.contentViewController = timelineNavigationViewController
        
        // load name and avatar
        avatarImageView.setImageWith((User.currentUser?.profileImageUrl)!)
        userNameLabel.text = User.currentUser?.name!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! menuCell
        
        let title = ["Timeline", "Profile", "Logout"]
        let image = ["home", "profile", "logout"]
        cell.cellNameLabel.text = title[indexPath.row]
        cell.iconMenuImageView.image = UIImage(named: image[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 2 {
            ClientApi.shareInstance.logout()
            return
        }
        
        hamburgerViewController.contentViewController = viewController[indexPath.row]
    }
}
