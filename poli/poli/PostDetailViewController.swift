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
    var flaggedContent = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = PFUser.currentUser()
        userId = (user?.objectId)!
        postId = post.objectId!
        
        setPostValues()
        setUpTableView()
        getComments()
        
        newCommentTextField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostDetailViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostDetailViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: self.view.window)
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
    
    //# MARK: - Report
    func showReportMenu(content: PFObject) {
        let contentType = content["type"] as! String
        let alert = UIAlertController(title: "Report", message: nil, preferredStyle: .Alert)
        let reportPostButton = UIAlertAction(title: "Report \(contentType)", style: .Default, handler: { (action) -> Void in
            self.reportContentConfirm(content)
        })
        let reportUserButton = UIAlertAction(title: "Report User", style: .Default, handler: { (action) -> Void in
            // implement
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
        }
        alert.addAction(reportPostButton)
        alert.addAction(reportUserButton)
        alert.addAction(cancelButton)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func reportContentConfirm(content: PFObject) {
        let alert: UIAlertController = UIAlertController(title: "", message: "Really report?", preferredStyle: .Alert)
        let cancelButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        let yesButton: UIAlertAction = UIAlertAction(title: "Yes", style: .Default) { action -> Void in
            self.reportContent(content)
        }
        alert.addAction(cancelButton)
        alert.addAction(yesButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func reportContent(content: PFObject) {
        let contentId = content.objectId
        let flag = PFObject(className: "Flag")
        flag["type"] = "comment"
        flag["user"] = userId
        flag["content"] = contentId
        flag.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if error == nil {
                self.incrementFlags(content)
            }
        }
    }
    
    func incrementFlags(content: PFObject) {
        content.incrementKey("flags")
        content.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if error == nil {
                self.showReportSuccessful(content)
            }
        }
    }
    
    func showReportSuccessful(content: PFObject) {
        let type = (content["type"] as! String).capitalizedString
        self.showAlert("Content reported.")
        if type == "Post" {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            getComments()
        }
    }
    
    @IBAction func tapReport(sender: AnyObject) {
        showReportMenu(post)
    }
    
    //# MARK: - Create A Comment
    func startCreateComment() {
        let flags = post["flags"] as! Int
        if flags > 2 {
            showPostDisabled()
            
        } else {
            let newCommentText = self.newCommentTextField.text
            if newCommentText == "" {
                self.showAlert("Comments cannot be blank")
                
            } else {
                newCommentTextField.text = ""
                createComment(newCommentText!)
            }
        }
    }
    
    func showPostDisabled() {
        let alert = UIAlertController(title: nil, message: "This post has been flagged as inappropriate and commenting has been disabled.", preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        alert.addAction(okButton)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func createComment(newCommentText: String) {
        let comment = PFObject(className: "Content")
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
    
    @IBAction func tapComment(sender: AnyObject) {
        startCreateComment()
    }
    
    //# MARK: - Table View
    func setUpTableView() {
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        commentsTableView.rowHeight = UITableViewAutomaticDimension
        commentsTableView.estimatedRowHeight = 80
    }
    
    func getComments() {
        getFlags()
        
//        let query = PFQuery(className: "Content")
//        query.whereKey("type", equalTo: "comment")
//        query.whereKey("post", equalTo:postId)
//        query.whereKey("flags", lessThan: 3)
//        query.orderByAscending("createdAt")
//        query.findObjectsInBackgroundWithBlock {
//            (objects: [PFObject]?, error: NSError?) -> Void in
//            if error == nil {
//                self.comments = objects!
//                self.commentsTableView.reloadData()
//            }
//        }
    }
    
    func getFlags() {
        let query = PFQuery(className: "Flag")
        query.whereKey("user", equalTo: userId)
        query.whereKey("type", containedIn: ["user", "comment"])
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for object in objects! {
                    let flaggedContent = object["content"] as! String
                    self.flaggedContent.append(flaggedContent)
                }
                self.getFilteredComments()
            }
        }
    }
    
    func getFilteredComments() {
        let query = PFQuery(className: "Content")
        query.whereKey("post", equalTo:postId)
        query.whereKey("flags", lessThan: 3)
        query.whereKey("creator", notContainedIn: flaggedContent)
        query.whereKey("objectId", notContainedIn: flaggedContent)
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
        showReportMenu(comment)
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
        startCreateComment()
        return true
    }
}