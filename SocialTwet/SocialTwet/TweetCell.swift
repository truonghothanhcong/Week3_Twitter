//
//  TweetCell.swift
//  SocialTwet
//
//  Created by CongTruong on 10/29/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import UIKit

@objc protocol TweetCellDelegate {
    @objc optional func onFavoriteClick(tweetCell: TweetCell)
    @objc optional func onRetweetClick(tweetCell: TweetCell)
    @objc optional func onReplyClick(tweetCell: TweetCell)
    @objc optional func showProfileUser(tweetCell: TweetCell)
}

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!

    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var retweetImageView: UIImageView!
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    weak var delegate: TweetCellDelegate?
    
    var _tweet: Tweet?
    var tweet : Tweet! {
        didSet {
            if let avatar = tweet.userProfilePicture {
                avatarImageView.setImageWith(avatar)
            }
            nameLabel.text = tweet.userName
            screenNameLabel.text = "@\(tweet.screenName!)"
            timeLabel.text = tweet.timetamp!
            tweetTextLabel.text = tweet.tweetText
            favoriteImageView.image = tweet.favorited! ? UIImage(named: "like_on") : UIImage(named: "like_off")
            favoriteCountLabel.text = "\(tweet.favoriteCount!)"
            retweetImageView.image = tweet.retweeted! ? UIImage(named: "retweet_on") : UIImage(named: "retweet_off")
            retweetCountLabel.text = "\(tweet.retweetCount!)"
            
            _tweet = tweet
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func showUserProfile(_ sender: UIButton) {
        delegate?.showProfileUser!(tweetCell: self)
    }

    @IBAction func onFavoriteClick(_ sender: AnyObject) {
        delegate?.onFavoriteClick!(tweetCell: self)
    }
    
    @IBAction func onRetweetClick(_ sender: AnyObject) {
        delegate?.onRetweetClick!(tweetCell: self)
    }
    
    @IBAction func onReplyClick(_ sender: AnyObject) {
        delegate?.onReplyClick!(tweetCell: self)
    }
}
