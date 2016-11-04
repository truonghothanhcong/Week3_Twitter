//
//  ClientApi.swift
//  SocialTwet
//
//  Created by CongTruong on 10/28/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import UIKit
import BDBOAuth1Manager


class ClientApi: BDBOAuth1SessionManager {
    static let accessTokenKey = "access_token"
    
    static let shareInstance = ClientApi(baseURL: URL(string: "https://api.twitter.com"), consumerKey: "FbgSlkl2wGkARJW83BfGNRtdr", consumerSecret: "kFhfwaMO509c9HzOvERGkjwwzZvySMud11r1h3KpgCG966NWdh")!
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    func login(success: @escaping () -> (), failure: @escaping (_ error: Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        ClientApi.shareInstance.deauthorize()
        ClientApi.shareInstance.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "socialtwet://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential?) in
            print("i got a token")
            
            let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken!.token!)")!
            UIApplication.shared.open(url, options: [ : ], completionHandler: nil)
            }, failure: { (error: Error?) in
                print("error \(error?.localizedDescription)")
                self.loginFailure?(error!)
        })
    }
    
    func handleOpenUrl(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) in
            print("i got a access token: \(accessToken)")
            // save access token
            let saveData = NSKeyedArchiver.archivedData(withRootObject: accessToken!)
            UserDefaults.standard.set(saveData, forKey: ClientApi.accessTokenKey)
            UserDefaults.standard.synchronize()
            
            self.currentAccount(success: { (user: User) in
                User.currentUser = user
                self.loginSuccess?()
            }, failure: { (error: Error) in
                self.loginFailure?(error)
            })
            
            }, failure: { (error: Error?) in
                self.loginFailure?(error!)
        })
    }
    
    func homeTimeline(tweetCount: Int?, success: @escaping (_ tweetArray: [Tweet]) -> (), failure: @escaping (_ error: Error) -> ()) {
        var params = [String: Any]()
        params["count"] = tweetCount! as Any
        
        get("1.1/statuses/home_timeline.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let tweets = response as! [NSDictionary]
            
            let tweetArray = Tweet.tweetWithArray(tweetDictionary: tweets)
            success(tweetArray)
        }) { (task: URLSessionDataTask?, error: Error) in
                failure(error)
        }
    }
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let userDictionary = response as! NSDictionary
            let user = User(userDictionary: userDictionary)
            
            success(user)
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error)
        })
    }
    
    func userInfomationWith(userId: Int, handleSuccess: @escaping (_ user: User) -> Void) {
        var params = [String: Any]()
        params["user_id"] = userId
        
        get("/1.1/users/lookup.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let userDic = response as! [NSDictionary]
            
            print(userDic)
            let user = User(userDictionary: userDic[0])
            handleSuccess(user)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print(error.localizedDescription)
        })
    }
    
    func userTimeline(userId: Int, success: @escaping (_ tweetArray: [Tweet]) -> (), failure: @escaping (_ error: Error) -> ()) {
        var params = [String: Any]()
        params["user_id"] = userId
        
        get("/1.1/statuses/user_timeline.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let tweets = response as! [NSDictionary]
            
            let tweetArray = Tweet.tweetWithArray(tweetDictionary: tweets)
            success(tweetArray)
        }) { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        }
    }
    func compose(text: String, idTweetToReply: Int?, handleSuccess: @escaping () -> ()) {
        var params = [String: Any]()
        params["status"] = text as Any?
        if let idTweet = idTweetToReply {
            params["in_reply_to_status_id"] = idTweet
        }
        
        post("1.1/statuses/update.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            print("compose success")
            
            handleSuccess()
        }) { (task: URLSessionDataTask?, error: Error) in
            print(error.localizedDescription)
        }
    }
    
    func retweet(idTweet: Int, handleSuccess: @escaping () -> ()) {
        post("1.1/statuses/retweet/\(idTweet).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            handleSuccess()
        }) { (task: URLSessionDataTask?, error: Error) in
                print(error.localizedDescription)
        }
    }
    
    func unretweet(idTweet: Int, handleSuccess: @escaping () -> ()) {
        post("1.1/statuses/unretweet/\(idTweet).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            handleSuccess()
        }) { (task: URLSessionDataTask?, error: Error) in
                print(error.localizedDescription)
        }
    }
    
    func favoriteTweet(idTweet: Int?, handleSuccess: @escaping () -> ()) {
        var params = [String: Any]()
        params["id"] = idTweet
        
        post("1.1/favorites/create.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            handleSuccess()
        }) { (task: URLSessionDataTask?, error: Error) in
            print(error.localizedDescription)
        }
    }
    
    func unFavoriteTweet(idTweet: Int?, handleSuccess: @escaping () -> ()) {
        var params = [String: Any]()
        params["id"] = idTweet
        
        post("1.1/favorites/destroy.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            handleSuccess()
        }) { (task: URLSessionDataTask?, error: Error) in
                print(error.localizedDescription)
        }
    }
    
    func logout() {
        User.currentUser = nil
        UserDefaults.standard.removeObject(forKey: ClientApi.accessTokenKey)
        deauthorize()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userLogoutEvent), object: nil)
    }
}
