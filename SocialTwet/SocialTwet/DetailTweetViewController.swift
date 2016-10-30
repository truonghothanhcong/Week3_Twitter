//
//  DetailTweetViewController.swift
//  SocialTwet
//
//  Created by CongTruong on 10/28/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import UIKit
import AFNetworking

class DetailTweetViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var asdLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var retweetImageView: UIImageView!
    
    var tweet: Tweet!

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"", style: .plain, target:nil, action: nil)
        
        initView()
    }
    
    func initView() {
        // user content
        avatarImageView.setImageWith(tweet.userProfilePicture!)
        nameLabel.text = tweet.userName
        screenNameLabel.text = "@" + tweet.screenName!
        
        // tweet text
        asdLabel.text = tweet.tweetText
        // time tweet
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .short
        dateformatter.timeStyle = .short
        let time = tweet.timetamp!
        timeLabel.text = time
        
        // tweet count
        retweetCountLabel.text = "\(tweet.retweetCount!) Retweet"
        favoriteCountLabel.text = "\(tweet.favoriteCount!) Love"
        
        // set image
        favoriteImageView.image = tweet.favorited! ? UIImage(named: "like_on") : UIImage(named: "like_off")
        retweetImageView.image = tweet.retweeted! ? UIImage(named: "retweet_on") : UIImage(named: "retweet_off")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: action for tweet
    
    @IBAction func favoriteTweet(_ sender: UIButton) {
        if tweet.favorited! {
            // change state: image to unfavorite and variable
            favoriteImageView.image = UIImage(named: "like_off")
            tweet.favorited = false
            tweet.favoriteCount! -= 1
            
            // send to server
            ClientApi.shareInstance.unFavoriteTweet(idTweet: tweet.id, handleSuccess: {
                print("i unfavorite tweet")
            })
        } else {
            // change state: image to favorite and variable
            favoriteImageView.image = UIImage(named: "like_on")
            tweet.favorited = true
            tweet.favoriteCount! += 1
            
            // send to server
            ClientApi.shareInstance.favoriteTweet(idTweet: tweet.id, handleSuccess: { 
                print("i favorite tweet")
            })
        }
        
        favoriteCountLabel.text = "\(tweet.favoriteCount!) Love"
    }

    @IBAction func retweet(_ sender: UIButton) {
        if tweet.retweeted! {
            // change state: iamge to unRetweet and variable
            retweetImageView.image = UIImage(named: "retweet_off")
            tweet.retweeted = false
            tweet.retweetCount! -= 1
            
            // send to server
            ClientApi.shareInstance.unretweet(idTweet: tweet.id!, handleSuccess: {
                print("unretweet")
            })
        } else {
            // change state: image to retweet and variable
            retweetImageView.image = UIImage(named: "retweet_on")
            tweet.retweeted = true
            tweet.retweetCount! += 1
            
            // send to server
            ClientApi.shareInstance.retweet(idTweet: tweet.id!, handleSuccess: { 
                print("retweet")
            })
        }
        
        retweetCountLabel.text = "\(tweet.retweetCount!) Retweet"
    }
    
    @IBAction func reply(_ sender: UIButton) {
        let storyboart = UIStoryboard(name: "Main", bundle: nil)
        let replyVC = storyboart.instantiateViewController(withIdentifier: "typeTweetViewController") as! TypeTweetViewController
        
        // set data for view
        replyVC.isReply = true
        replyVC.screenNameToReply = tweet.screenName
        replyVC.idTweetReply = tweet.id
        replyVC.avatarUrl = User.currentUser?.profileImageUrl
        
        // open view
        replyVC.modalPresentationStyle = .overFullScreen;
        replyVC.view.backgroundColor = UIColor.clear
        self.present(replyVC, animated: true, completion: nil)
    }
}
