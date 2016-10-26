//
//  TwitterClient.swift
//  Twitter
//
//  Created by CongTruong on 10/25/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let consumerKey = "cKJE1qndqaoqlOJIwBeolH0mG"
let consumerSecret = "xv4ydfxDcWLJnlhpFX2dHjcijYaPyjSll6hXKzjsRON2PjG9hU"
let baseUrl = URL(string: "https://api.twitter.com/")!

class TwitterClient: BDBOAuth1SessionManager {
    var loginCallback: ((_ user: User?, _ error: NSError?) -> Void)?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: baseUrl, consumerKey: consumerKey, consumerSecret: consumerSecret)
        }
        
        return Static.instance!
    }
    
    func login(blockCallback: @escaping (_ user: User?, _ error: NSError?) -> Void) {
        self.loginCallback = blockCallback
        TwitterClient.sharedInstance.deauthorize()
        
        TwitterClient.sharedInstance.fetchRequestToken(withPath: "oauth/request_token", method: "POST", callbackURL: URL(string: "mytwitter://auth"), scope: nil, success: { (response: BDBOAuth1Credential?) in
            print("get the request token \(response?.token)")
            
            if let response = response {
                let authURL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(response.token!)")
                
                // open browser to authorize
                UIApplication.shared.open(authURL!, options: [:], completionHandler: nil)
            }
            }, failure: { (error: Error?) in
                print("\(error?.localizedDescription)")
        })
    }
    
    func handleTwitterCallBack(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        print(requestToken?.token)
        // save token to across restarts
        TwitterClient.sharedInstance.requestSerializer.saveAccessToken(requestToken)
        
        TwitterClient.sharedInstance.fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken!, success: { (response: BDBOAuth1Credential?) in
            
            TwitterClient.sharedInstance.get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask?, response: Any?) in
                //get user
                let user = response as! NSDictionary
                // save user
                User.saveCurrentUser(user: user)
                print(user["name"] as! String)
                
                // perform to timeline
                if let user = User.currentUser {
                    print("I got user logined by name: \(user.name)")
                    self.loginCallback!(user, nil)
                }
                }, failure: { (task: URLSessionDataTask?, error: Error) in
                    print("\(error.localizedDescription)")
            })
            
            
            }, failure: { (error: Error?) in
                print("\(error?.localizedDescription)")
        })
    }
    
    func getListTweet(count: Int?) -> [Tweet] {
        var tweetArray = [Tweet]()
        
        TwitterClient.sharedInstance.get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask?, response: Any?) in
            let listTweet = response as! [NSDictionary]
            
            // append all tweet to array
            for tweet in listTweet {
                tweetArray.append(Tweet(tweetDictionary: tweet))
            }
            
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                print("\(error.localizedDescription)")
        })
        
        return tweetArray
    }
}
