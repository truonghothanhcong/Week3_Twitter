//
//  User.swift
//  Twitter
//
//  Created by CongTruong on 10/25/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import Foundation

var _currentUser: User?
let currentUserKey = "current_user_json"

class User {
    var name: String?
    var favouritesCount: Int?
    var followersCount: Int?
    var following: Int?
    var friendsCount: Int?
    var idStr: String?
    var profileBackgroundImageUrl: URL?
    var profileImageUrl: URL?
    var screenName: String?
    
    init(userDictionary: NSDictionary) {
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
    
    class func saveCurrentUser(user: NSDictionary) {
        do {
            let data  = try JSONSerialization.data(withJSONObject: user, options: .prettyPrinted)
            
            UserDefaults.standard.set(data, forKey: currentUserKey)
            UserDefaults.standard.synchronize()
        } catch {
            print("error when save user")
        }
    }
    
    class var currentUser: User? {
        if _currentUser == nil {
            if let dataUser = UserDefaults.standard.object(forKey: currentUserKey) as? Data {
                do {
                    let dict = try JSONSerialization.jsonObject(with: dataUser, options: .allowFragments) as! NSDictionary
                    
                    _currentUser = User(userDictionary: dict)
                } catch {
                    print("error when get user")
                }
            }
        }
        
        return _currentUser
    }
}



































