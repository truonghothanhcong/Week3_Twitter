//
//  ProfileViewController.swift
//  SocialTwet
//
//  Created by CongTruong on 11/4/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var bannerScrollView: UIScrollView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var tweetsCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var tweetArray = [Tweet]()
    var userId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        MBProgressHUD.showAdded(to: self.view, animated: true)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        if userId == nil {  // current user
            filUserInfomation(userInfo: User.currentUser!)
            ClientApi.shareInstance.userTimeline(userId: User.currentUser?.userID as! Int, success: { (tweetArray) in
                self.tweetArray = tweetArray
                self.tableView.reloadData()
                
                MBProgressHUD.hide(for: self.view, animated: true)
            }, failure: { (error) in
                print(error.localizedDescription)
            })
        } else {
            ClientApi.shareInstance.userInfomationWith(userId: userId!, handleSuccess: { (user) in
                self.filUserInfomation(userInfo: user)
            })
            ClientApi.shareInstance.userTimeline(userId: userId!, success: { (tweetArray) in
                self.tweetArray = tweetArray
                self.tableView.reloadData()
                
                MBProgressHUD.hide(for: self.view, animated: true)
            }, failure: { (error) in
                print(error.localizedDescription)
            })
        }
    }
    
    func filUserInfomation(userInfo: User) {
//        let bannerImageView = UIImageView()
//        bannerImageView.contentMode = .scaleAspectFill
//        bannerImageView.setImageWith(userInfo.profileBackgroundImageUrl!)
//        bannerImageView.bounds.size = bannerScrollView.contentSize
//        bannerScrollView.addSubview(bannerImageView)
        avatarImageView.setImageWith(userInfo.profileImageUrl!)
        nameLabel.text = userInfo.name!
        screenNameLabel.text = "@\(userInfo.screenName!)"
        tweetsCountLabel.text = "\(userInfo.statusesCount!)"
        followingCountLabel.text = "\(userInfo.followingCount!)"
        followerCountLabel.text = "\(userInfo.followersCount!)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tweetArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userTimelineCell", for: indexPath) as! TweetCell
        
        cell.tweet = tweetArray[indexPath.section]
        cell.selectionStyle = UITableViewCellSelectionStyle.none;
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2
    }
}

extension ProfileViewController: TweetCellDelegate {
    func onFavoriteClick(tweetCell: TweetCell) {
        if (tweetCell._tweet?.favorited!)! {
            // change state: image to unfavorite and variable
            tweetCell.favoriteImageView.image = UIImage(named: "like_off")
            tweetCell._tweet?.favorited = false
            tweetCell._tweet?.favoriteCount! -= 1
            
            // send to server
            ClientApi.shareInstance.unFavoriteTweet(idTweet: tweetCell._tweet?.id, handleSuccess: {
                print("i unfavorite tweet")
            })
        } else {
            // change state: image to favorite and variable
            tweetCell.favoriteImageView.image = UIImage(named: "like_on")
            tweetCell._tweet?.favorited = true
            tweetCell._tweet?.favoriteCount! += 1
            
            // send to server
            ClientApi.shareInstance.favoriteTweet(idTweet: tweetCell._tweet?.id, handleSuccess: {
                print("i favorite tweet")
            })
        }
        
        tweetCell.favoriteCountLabel.text = "\((tweetCell._tweet?.favoriteCount!)!)"
    }
    
    func onRetweetClick(tweetCell: TweetCell) {
        if (tweetCell._tweet?.retweeted!)! {
            // change state: iamge to unRetweet and variable
            tweetCell.retweetImageView.image = UIImage(named: "retweet_off")
            tweetCell._tweet?.retweeted = false
            tweetCell._tweet?.retweetCount! -= 1
            
            // send to server
            ClientApi.shareInstance.unretweet(idTweet: (tweetCell._tweet?.id!)!, handleSuccess: {
                print("unretweet")
            })
        } else {
            // change state: image to retweet and variable
            tweetCell.retweetImageView.image = UIImage(named: "retweet_on")
            tweetCell._tweet?.retweeted = true
            tweetCell._tweet?.retweetCount! += 1
            
            // send to server
            ClientApi.shareInstance.retweet(idTweet: (tweetCell._tweet?.id!)!, handleSuccess: {
                print("retweet")
            })
        }
        
        tweetCell.retweetCountLabel.text = "\((tweetCell._tweet?.retweetCount!)!)"
    }
    
    func onReplyClick(tweetCell: TweetCell) {
        let storyboart = UIStoryboard(name: "Main", bundle: nil)
        let replyVC = storyboart.instantiateViewController(withIdentifier: "typeTweetViewController") as! TypeTweetViewController
        
        // set data for view
        replyVC.isReply = true
        replyVC.screenNameToReply = tweetCell._tweet?.screenName
        replyVC.idTweetReply = tweetCell._tweet?.id
        replyVC.avatarUrl = User.currentUser?.profileImageUrl
        
        // open view
        replyVC.modalPresentationStyle = .overFullScreen;
        replyVC.view.backgroundColor = UIColor.clear
        self.present(replyVC, animated: true, completion: nil)
    }
}
