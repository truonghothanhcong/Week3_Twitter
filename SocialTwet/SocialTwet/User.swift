//
//  User.swift
//  SocialTwet
//
//  Created by CongTruong on 10/28/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import UIKit

let currentUserKey = "current_user_json"

class User: NSObject {
    var name: String?
    var favouritesCount: Int?
    var followersCount: Int?
    var following: Int?
    var friendsCount: Int?
    var idStr: String?
    var profileBackgroundImageUrl: URL?
    var profileImageUrl: URL?
    var screenName: String?
    var userID: NSNumber?
    
    var userDictionary: NSDictionary?
    
    init(userDictionary: NSDictionary) {
        self.userDictionary = userDictionary
        
        userID = userDictionary["id"] as? NSNumber ?? 0
        
        if let name = userDictionary["name"] as? String {
            self.name = name
        }
        if let favouritesCount = userDictionary["favourites_count"] as? Int {
            self.favouritesCount = favouritesCount
        }
        if let followersCount = userDictionary["followers_count"] as? Int {
            self.followersCount = followersCount
        }
        if let following = userDictionary["following"] as? Int {
            self.following = following
        }
        if let friendsCount = userDictionary["friends_count"] as? Int {
            self.friendsCount = friendsCount
        }
        if let idStr = userDictionary["id_str"] as? String {
            self.idStr = idStr
        }
        if let profileBackgroundImageUrl = userDictionary["profile_background_image_url_https"] as? String {
            self.profileBackgroundImageUrl = URL(string: profileBackgroundImageUrl)
        }
        if let profileImageUrl = userDictionary["profile_image_url_https"] as? String {
            self.profileImageUrl = URL(string: profileImageUrl)
        }
        if let screenName = userDictionary["screen_name"] as? String {
            self.screenName = screenName
        }
    }
    
    static var _currentUser: User?
    static let userLogoutEvent = "user_logout_event"
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                
                let userData = defaults.object(forKey: currentUserKey) as? NSData
                
                if let userData = userData {
                    let dictionary = try! JSONSerialization.jsonObject(with: userData as Data, options: []) as! NSDictionary
                    _currentUser = User(userDictionary: dictionary)
                    print(_currentUser?.name)
                }
            }
            
            return _currentUser
        }
        set(user) {
            self._currentUser = user
            
            let defaults = UserDefaults.standard
            
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.userDictionary!, options: [])
                
                defaults.set(data, forKey: currentUserKey)
            } else {
                defaults.removeObject(forKey: currentUserKey)
            }
            
            defaults.synchronize()
        }
    }
}
