//
//  PostDetailViewController.swift
//  poli
//
//  Created by Vo, Van-Quan N on 3/3/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var newCommentTextField: UITextField!
    @IBOutlet weak var commentsTableView: UITableView!
    
    var post = PFObject(className: "Post")
    var postId = String()
    var userId = String()
    var comments = [PFObject]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        postId = post.objectId!
        
        let user = PFUser.currentUser()
        userId = (user?.objectId)!
        
        channelLabel.text = post["channel"] as? String
        
        let createdAt = post.createdAt as NSDate?
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        let createdAtString = dateFormatter.stringFromDate(createdAt!)
        timeStampLabel.text = createdAtString
        
        let text = post["text"] as? NSString
        if text!.length > 200 {
            postTextLabel.text = "\(text!.substringToIndex(200))..."
        } else {
            postTextLabel.text = text as? String
        }
        
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        commentsTableView.rowHeight = UITableViewAutomaticDimension
        commentsTableView.estimatedRowHeight = 80
        
        getComments()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //# MARK: - Report Post
    
    @IBAction func tapReportPost(sender: AnyObject) {
        
        let query = PFQuery(className: "Flag")
        query.whereKey("user", equalTo: userId)
        query.whereKey("content", equalTo: postId)
        query.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            
            if object == nil {
                self.showReportPostConfirm()
            } else {
                self.showReportPostFail()
            }
        }
    }
    
    func showReportPostConfirm() {
        
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: "Report post for inappropriate content?", preferredStyle: .Alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelAction)
        let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .Default) { action -> Void in
            self.reportPost()
        }
        actionSheetController.addAction(yesAction)
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func showReportPostFail() {
        
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: "You have already reported this post.", preferredStyle: .Alert)
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
        }
        actionSheetController.addAction(okAction)
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func reportPost() {
        
        let flag = PFObject(className: "Flag")
        flag["user"] = userId
        flag["content"] = postId
        flag.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if error == nil {
                self.incrementFlags()
            }
        }
    }
    
    func incrementFlags() {
        
        post.incrementKey("flags")
        post.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if error == nil {
                self.showReportPostSuccessful()
            }
        }
    }
    
    func showReportPostSuccessful() {
        
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: "Post has been reported. With enough flags, posts will be deleted.", preferredStyle: .Alert)
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
        }
        actionSheetController.addAction(okAction)
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    //# MARK: - Create A Comment
    
    @IBAction func tapComment(sender: AnyObject) {
        
        let flags = post["flags"] as! Int
        if flags > 2 {
            showPostClosed()
            
        } else {
            
            let newCommentText = self.newCommentTextField.text
            if newCommentText == "" {
                let alert: UIAlertController = UIAlertController(title: "", message: "Comments cannot be blank.", preferredStyle: .Alert)
                let alertButton: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
                }
                alert.addAction(alertButton)
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                
                let comment = PFObject(className: "Post")
                comment["type"] = "comment"
                comment["post"] = self.postId
                comment["creator"] = self.userId
                comment["flags"] = 0
                comment["text"] = newCommentText
                comment.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    
                    if success {
                        self.newCommentTextField.text = ""
                        self.getComments()
                        self.view.endEditing(true)
                    }
                }
            }
        }
    }
    
    func showPostClosed() {
        
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: "This post has been flagged as inappropriate and commenting has been disabled.", preferredStyle: .Alert)
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
        }
        actionSheetController.addAction(okAction)
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    //# MARK: - Table View
    
    func getComments() {
        
        let query = PFQuery(className: "Post")
        query.whereKey("type", equalTo: "comment")
        query.whereKey("post", equalTo:postId)
        query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                self.comments = objects!
                self.commentsTableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Comment", forIndexPath: indexPath) as! CommentsTableViewCell
        let comment = comments[indexPath.row]
        
        let text = comment["text"] as? NSString
        if text!.length > 144 {
            cell.commentsTextLabel.text = "\(text!.substringToIndex(144))..."
            
        } else {
            cell.commentsTextLabel.text = text as? String
        }
        
        let createdAt = comment.createdAt as NSDate?
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateStyle = .ShortStyle
        let createdAtString = dateFormatter.stringFromDate(createdAt!)
        cell.timeStampLabel.text = createdAtString
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    //# MARK: - Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}