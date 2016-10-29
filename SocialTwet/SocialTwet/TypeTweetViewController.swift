//
//  TypeTweetViewController.swift
//  SocialTwet
//
//  Created by CongTruong on 10/29/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import UIKit

@objc protocol TypeTweetViewControllerDelegate {
    @objc optional func addNewTweet(typeTweetViewController: TypeTweetViewController, tweetText: String)
}

class TypeTweetViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var textCountLabel: UILabel!
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var viewToShow: UIView!
    @IBOutlet weak var buttomConstrant: NSLayoutConstraint!
    
    weak var delegate: TypeTweetViewControllerDelegate?
    
    var isReply: Bool!
    var screenNameToReply: String!
    var idTweetReply: Int!
    var avatarUrl: URL!
    var textCount = 140

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(TypeTweetViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        self.tweetTextView.delegate = self
        // show keyboard
        tweetTextView.becomeFirstResponder()
        
        if isReply == true {
            tweetTextView.text = "@\(screenNameToReply!) "
        }
        
        // set avatar
        avatarImageView.setImageWith(avatarUrl)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            buttomConstrant.constant += keyboardSize.size.height
        }
    }
    
    @IBAction func closeView(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func sendTweet(_ sender: UIButton) {
        if isReply == true {    // reply
            ClientApi.shareInstance.compose(text: tweetTextView.text, idTweetToReply: idTweetReply) {
                self.dismiss(animated: true, completion: nil)
            }
        } else {                // compose
            ClientApi.shareInstance.compose(text: tweetTextView.text, idTweetToReply: nil) {
                self.delegate?.addNewTweet!(typeTweetViewController: self, tweetText: self.tweetTextView.text)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension TypeTweetViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if isReply == false {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // calcula character
        textCount = 140 - tweetTextView.text.characters.count
        textCountLabel.text = "\(textCount)"
        
        if textCount < 0 {
            tweetButton.isEnabled = false
            tweetButton.backgroundColor = .gray
        } else {
            tweetButton.isEnabled = true
            tweetButton.backgroundColor = .blue
        }
    }
}
