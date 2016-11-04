//
//  TimelineViewController.swift
//  SocialTwet
//
//  Created by CongTruong on 10/28/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import UIKit
import MBProgressHUD


class TimelineViewController: UIViewController, TypeTweetViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tweetCount = 20
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    
    var tweetArray = [Tweet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add icon twitter
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "twitter")
        self.navigationItem.titleView = imageView
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        // show progress hub
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)

        // get data
        ClientApi.shareInstance.homeTimeline(tweetCount: tweetCount, success: { (tweets: [Tweet]) in
            self.tweetArray = tweets
            self.tableView.reloadData()
            
            MBProgressHUD.hide(for: self.view, animated: true)
        }) { (error: Error) in
            print(error.localizedDescription)
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        tweetCount = 20
        ClientApi.shareInstance.homeTimeline(tweetCount: tweetCount, success: { (tweets: [Tweet]) in
            self.tweetArray = tweets
            self.tableView.reloadData()
            
            refreshControl.endRefreshing()
        }) { (error: Error) in
            print(error.localizedDescription)
            refreshControl.endRefreshing()
        }
    }

    @IBAction func writeTweet(_ sender: UIBarButtonItem) {
        let storyboart = UIStoryboard(name: "Main", bundle: nil)
        let replyVC = storyboart.instantiateViewController(withIdentifier: "typeTweetViewController") as! TypeTweetViewController
        
        // set data for view
        replyVC.isReply = false
        replyVC.avatarUrl = User.currentUser?.profileImageUrl
        replyVC.delegate = self
        
        // open view
        replyVC.modalPresentationStyle = .overFullScreen;
        replyVC.view.backgroundColor = UIColor.clear
        self.present(replyVC, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation
    */
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tweetSegue" {
            let detailTweetVC = segue.destination as! DetailTweetViewController
            
            let indexPath = tableView.indexPathForSelectedRow
            detailTweetVC.tweet = tweetArray[indexPath!.row]
        }
    }
    
    @IBAction func doubleTapToFavorite(_ sender: UITapGestureRecognizer) {
        let p = sender.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: p)
        let cell = tableView.cellForRow(at: indexPath!)
        
        onFavoriteClick(tweetCell: cell as! TweetCell)
    }
    
    
    func addNewTweet(typeTweetViewController: TypeTweetViewController, tweetText: String) {
        let newTweet = createNewTweet(textTweet: tweetText)
        tweetArray.insert(newTweet, at: 0)
        tableView.reloadData()
    }
    
    func createNewTweet(textTweet: String) -> Tweet {
        let date = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        let dateStr = formatter.string(from: date as Date)
        let tweetDic: [String: Any?] = ["created_at" : dateStr,
                                        "favorite_count" : 0,
                                        "favorited" : false,
                                        "id" : 0,
                                        "retweet_count" : 0,
                                        "retweeted" : false,
                                        "text" : textTweet,
                                        "user" : [
                                            "name" : User.currentUser?.name,
                                            "profile_banner_url" : User.currentUser?.profileImageUrl?.path,
                                            "profile_image_url_https" : User.currentUser?.profileBackgroundImageUrl?.path,
                                            "screen_name" : User.currentUser?.screenName,
            ]
        ]
        
        let newTweet = Tweet(tweetDictionary: tweetDic as NSDictionary)
        return newTweet
    }
}

extension TimelineViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TweetCell
        
        cell.tweet = tweetArray[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.none;
        cell.delegate = self
        
        return cell
    }
}

extension TimelineViewController: TweetCellDelegate {
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
    
    func showProfileUser(tweetCell: TweetCell) {
        let storyboart = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboart.instantiateViewController(withIdentifier: "profileUserViewController") as! ProfileViewController
        
        // set data for view
        profileVC.userId = tweetCell._tweet?.userId
        
        // open view
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}

extension TimelineViewController: UIScrollViewDelegate {
    
    func loadMoreData() {
        tweetCount += 20
        ClientApi.shareInstance.homeTimeline(tweetCount: tweetCount, success: { (tweets: [Tweet]) in
            self.tweetArray = tweets
            self.tableView.reloadData()
            
            self.isMoreDataLoading = false
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
        }) { (error: Error) in
            print(error.localizedDescription)
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                loadMoreData()
            }
        }
    }
}
