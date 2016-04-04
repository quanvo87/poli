//
//  PostDetailViewController.swift
//  poli
//
//  Created by Vo, Van-Quan N on 3/3/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var newCommentTextField: UITextField!
    @IBOutlet weak var commentsTableView: UITableView!
    var userId = String()
    var post = PFObject(className: "Post")
    var postId = String()
    var comments = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = PFUser.currentUser()
        userId = (user?.objectId)!
        postId = post.objectId!
        
        setPostValues()
        setUpTableView()
        getComments()
        
        newCommentTextField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //# MARK: - Set Post Values
    func setPostValues() {
        let date = post.createdAt! as NSDate
        timeStampLabel.text = date.toString()
        
        channelLabel.text = post["channel"] as? String
        
        let text = post["text"] as! NSString
        postTextLabel.text = text.stringByTrimmingCharacters(200)
    }
    
    //# MARK: - Report Post
    func reportPost(post: PFObject) {
        let postId = post.objectId
        let query = PFQuery(className: "Flag")
        query.whereKey("user", equalTo: userId)
        query.whereKey("content", equalTo: postId!)
        query.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if object == nil {
                self.confirmReportPost(post)
            } else {
                self.showAlert("You have already reported this. With enough flags, it will be removed.")
            }
        }
    }
    
    func confirmReportPost(post: PFObject) {
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: "Report for inappropriate content?", preferredStyle: .Alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelAction)
        let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .Default) { action -> Void in
            self.proceedReportPost(post)
        }
        actionSheetController.addAction(yesAction)
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func proceedReportPost(post: PFObject) {
        let postId = post.objectId
        let flag = PFObject(className: "Flag")
        flag["user"] = userId
        flag["content"] = postId
        flag.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if error == nil {
                self.incrementFlags(post)
            }
        }
    }
    
    func incrementFlags(post: PFObject) {
        post.incrementKey("flags")
        post.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if error == nil {
                self.showReportPostSuccessful(post)
            }
        }
    }
    
    func showReportPostSuccessful(post: PFObject) {
        let type = (post["type"] as! String).capitalizedString
        self.showAlert("Content has been reported. With enough flags, it will be removed.")
        if type == "Comment" {
            self.commentsTableView.reloadData()
        }
    }
    
    @IBAction func tapReportPost(sender: AnyObject) {
        reportPost(post)
    }
    
    //# MARK: - Create A Comment
    func createComment() {
        let flags = post["flags"] as! Int
        if flags > 2 {
            self.showAlert("This post has been flagged as inappropriate and commenting has been disabled.")
            
        } else {
            let newCommentText = self.newCommentTextField.text
            if newCommentText == "" {
                self.showAlert("Comments cannot be blank")
                
            } else {
                newCommentTextField.text = ""
                let comment = PFObject(className: "Post")
                comment["type"] = "comment"
                comment["post"] = postId
                comment["creator"] = userId
                comment["flags"] = 0
                comment["text"] = newCommentText
                comment.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if success {
                        self.getComments()
                        self.view.endEditing(true)
                    }
                }
            }
        }
    }
    
    @IBAction func tapComment(sender: AnyObject) {
        createComment()
    }
    
    //# MARK: - Table View
    func setUpTableView() {
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        commentsTableView.rowHeight = UITableViewAutomaticDimension
        commentsTableView.estimatedRowHeight = 80
    }
    
    func getComments() {
        let query = PFQuery(className: "Post")
        query.whereKey("type", equalTo: "comment")
        query.whereKey("post", equalTo:postId)
        query.whereKey("flags", lessThan: 3)
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
        
        let date = comment.createdAt! as NSDate
        cell.timeStampLabel.text = date.toString()
        
        let text = comment["text"] as! NSString
        cell.commentsTextLabel.text = text.stringByTrimmingCharacters(144)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let comment = comments[indexPath.row]
        reportPost(comment)
    }
    
    //# MARK: - Keyboard
    func keyboardWillShow(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        if keyboardSize.height == offset.height {
            if self.view.frame.origin.y == 0 {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.view.frame.origin.y -= keyboardSize.height
                })
            }
        } else {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height - offset.height
            })
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        self.view.frame.origin.y += keyboardSize.height
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.newCommentTextField.resignFirstResponder()
        createComment()
        return true
    }
}