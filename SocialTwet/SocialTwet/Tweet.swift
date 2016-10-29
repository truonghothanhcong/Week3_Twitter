//
//  Tweet.swift
//  SocialTwet
//
//  Created by CongTruong on 10/28/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var userProfilePicture: URL?
    var userBannerPicture: URL?
    var userName: String?
    var screenName: String?
    var tweetText: String?
    var createAt: String?
    var favoriteCount: Int?
    var favorited: Bool?
    var retweetCount: Int?
    var retweeted: Bool?
    var id: Int?
    
    var timetamp: Date?
    
    init(tweetDictionary: NSDictionary) {
        // get info user
        if let user = tweetDictionary["user"] as? NSDictionary {
            // get avatar and banner
            if let userProfilePicture = user["profile_image_url_https"] as? String {
                self.userProfilePicture = URL(string: userProfilePicture)
            }
            if let userBannerPicture = user["profile_banner_url"] as? String {
                self.userBannerPicture = URL(string: userBannerPicture)
            }
            // get name and screen name
            if let userName = user["name"] as? String {
                self.userName = userName
            }
            if let screenName = user["screen_name"] as? String {
                self.screenName = screenName
            }
        }
        
        // get tweet text and time to create
        if let tweetText = tweetDictionary["text"] as? String {
            self.tweetText = tweetText
        }
        if let createAt = tweetDictionary["created_at"] as? String {
            self.createAt = createAt
            
            let formater = DateFormatter()
            formater.dateFormat = "EEE MMM d HH:mm:ss Z y"
            self.timetamp = formater.date(from: createAt)
        }
        
        // get info about reaction of tweet
        if let id = tweetDictionary["id"] as? Int {
            self.id = id
        }
        if let favoriteCount = tweetDictionary["favorite_count"] as? Int {
            self.favoriteCount = favoriteCount
        }
        if let favorited = tweetDictionary["favorited"] as? Bool {
            self.favorited = favorited
        }
        if let retweetCount = tweetDictionary["retweet_count"] as? Int {
            self.retweetCount = retweetCount
        }
        if let retweeted = tweetDictionary["retweeted"] as? Bool {
            self.retweeted = retweeted
        }
    }
    
    class func tweetWithArray(tweetDictionary: [NSDictionary]) -> [Tweet] {
        var tweetArray = [Tweet]()
        
        for tweet in tweetDictionary {
            tweetArray.append(Tweet(tweetDictionary: tweet))
        }
        
        return tweetArray
    }
}
