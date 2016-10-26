//
//  Tweet.swift
//  Twitter
//
//  Created by CongTruong on 10/26/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import Foundation

class Tweet {
    var userProfilePicture: URL?
    var userName: String?
    var tweetText: String?
    var timestamp: String?
    
    init(tweetDictionary: NSDictionary) {
        if let userProfilePicture = tweetDictionary[""] as? String {
            self.userProfilePicture = URL(string: userProfilePicture)
        }
        if let userName = tweetDictionary[""] as? String {
            self.userName = userName
        }
        if let tweetText = tweetDictionary[""] as? String {
            self.tweetText = tweetText
        }
        if let timestamp = tweetDictionary[""] as? String {
            self.timestamp = timestamp
        }
    }
}
