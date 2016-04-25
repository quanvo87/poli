//
//  PostDetailViewController.swift
//  poli
//
//  Created by Vo, Van-Quan N on 3/3/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var newCommentTextField: UITextField!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var newCommentTextFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentButtonBottomContraint: NSLayoutConstraint!
    var userId = String()
    var post = PFObject(className: "Post")
    var postId = String()
    var comments = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        getUserData()
        setPostValues()
        addReportButton()
        setUpTableView()
        getComments()
        setUpComments()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    override func viewDidAppear(animated: Bool) {
        checkIfUserIsBanned()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //# MARK: - Set Up UI
    func setUpUI() {
        self.view.backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 241/255, alpha: 1)
    }
    
    //# MARK: - Get User Data
    func getUserData() {
        let user = PFUser.currentUser()
        userId = (user?.objectId)!
        postId = post.objectId!
    }
    
    //# MARK: - Set Post Values
    func setPostValues() {
        timeStampLabel.text = (post.createdAt! as NSDate).toString()
        channelLabel.text = post["channel"] as? String
        postTextLabel.text = (post["text"] as! NSString).stringByTrimmingCharacters(200)
//        commentsCountLabel.text = (post["comments"] as! Int).stringNumberOfContents("comment")
    }
    
    //# MARK: - Report
    func addReportButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Report", style: .Plain, target: self, action: Selector("tapReport:"))
    }
    
    @IBAction func tapReport(sender: AnyObject) {
        showReportMenu(post)
    }
    
    func showReportMenu(content: PFObject) {
        let contentType = (content["type"] as! String).capitalizedString
        let alert = UIAlertController(title: "Inappropriate content?", message: nil, preferredStyle: .Alert)
        let reportContentButton = UIAlertAction(title: "Report \(contentType)", style: .Default, handler: { action in
            self.confirmReportContent(content)
        })
        let reportUserButton = UIAlertAction(title: "Report User", style: .Default, handler: { action in
            self.confirmReportUser(content)
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel) { action in
        }
        alert.addAction(reportContentButton)
        alert.addAction(reportUserButton)
        alert.addAction(cancelButton)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //# MARK: - Report Post/Comment
    func confirmReportContent(content: PFObject) {
        let alert = UIAlertController(title: "", message: "Really report?", preferredStyle: .Alert)
        let cancelButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
        }
        let yesButton: UIAlertAction = UIAlertAction(title: "Yes", style: .Default) { action in
            self.reportContent(content)
        }
        alert.addAction(cancelButton)
        alert.addAction(yesButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func reportContent(content: PFObject) {
        createFlag(content)
    }
    
    func createFlag(content: PFObject) {
        let flag = PFObject(className: "Flag")
        flag["type"] = content["type"]
        flag["user"] = userId
        flag["content"] = content.objectId
        flag["contentCreator"] = content["creator"]
        flag.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) in
            if error == nil {
                self.incrementFlags(content)
            }
        }
    }
    
    func incrementFlags(content: PFObject) {
        content.incrementKey("flags")
        content.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) in
            if error == nil {
                self.showReportSuccessful(content)
            }
        }
    }
    
    func showReportSuccessful(content: PFObject) {
        if content["type"] as! String == "post" {
            showReportPostSuccessful()
        } else {
            showReportCommentSuccessful()
        }
    }
    
    func showReportPostSuccessful() {
        let alert = UIAlertController(title: "", message: "Post successfully reported.", preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "Ok", style: .Default, handler: { action in
            self.navigationController?.popViewControllerAnimated(true)
        })
        alert.addAction(okButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showReportCommentSuccessful() {
        self.showAlert("Comment successfully reported.")
        getComments()
    }
    
    //# MARK: - Report User
    func confirmReportUser(content: PFObject) {
        let alert = UIAlertController(title: "", message: "Really report?", preferredStyle: .Alert)
        let cancelButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
        }
        let yesButton: UIAlertAction = UIAlertAction(title: "Yes", style: .Default) { action in
            self.reportUser(content)
        }
        alert.addAction(cancelButton)
        alert.addAction(yesButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func reportUser(content: PFObject) {
        let flag = PFObject(className: "Flag")
        flag["type"] = "user"
        flag["user"] = userId
        flag["content"] = content["creator"]
        flag.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) in
            if error == nil {
                self.showReportUserSuccessful(content)
            }
        }
    }
    
    func showReportUserSuccessful(content: PFObject) {
        let type = content["type"] as! String
        if type == "post" {
            showReportPostCreatorSuccessful()
        } else {
            showReportCommentCreatorSuccessful()
        }
    }
    
    func showReportPostCreatorSuccessful() {
        let alert = UIAlertController(title: "", message: "User successfully reported.", preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "Ok", style: .Default, handler: { action in
            self.navigationController?.popViewControllerAnimated(true)
        })
        alert.addAction(okButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showReportCommentCreatorSuccessful() {
        showAlert("User successfully reported.")
        getComments()
    }
    
    //# MARK: - Get Comments
    func getComments() {
        let flagQuery = PFQuery(className: "Flag")
        flagQuery.whereKey("type", containedIn: ["user", "comment"])
        flagQuery.whereKey("user", equalTo: userId)
        
        let commentQuery = PFQuery(className: "Content")
        commentQuery.whereKey("post", equalTo:postId)
        commentQuery.whereKey("flags", lessThan: 3)
        commentQuery.whereKey("creator", doesNotMatchKey: "content", inQuery: flagQuery)
        commentQuery.whereKey("objectId", doesNotMatchKey: "content", inQuery: flagQuery)
        commentQuery.orderByAscending("createdAt")
        commentQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) in
            if error == nil {
                self.comments = objects!
                self.commentsTableView.reloadData()
            }
        }
    }
    
    //# MARK: - Table View
    func setUpTableView() {
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        commentsTableView.backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 241/255, alpha: 1)
        commentsTableView.rowHeight = UITableViewAutomaticDimension
        commentsTableView.estimatedRowHeight = 80
        commentsTableView.separatorStyle = .None
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        commentsTableView.addSubview(refreshControl)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return comments.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as! UITableViewHeaderFooterView
        footer.contentView.backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 241/255, alpha: 1)
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Comment", forIndexPath: indexPath) as! CommentsTableViewCell
        let comment = comments[indexPath.section]
        cell.timeStampLabel.text = (comment.createdAt! as NSDate).toString()
        cell.commentsTextLabel.text = (comment["text"] as! NSString).stringByTrimmingCharacters(200)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let comment = comments[indexPath.section]
        showReportMenu(comment)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        getComments()
        refreshControl.endRefreshing()
    }
    
    //# MARK: - Set Up Comments
    func setUpComments() {
        newCommentTextField.delegate = self
        disableCommentButton()
    }
    
    //# MARK: - Create A Comment
    func startCreateComment() {
        let flags = post["flags"] as! Int
        if flags > 2 {
            showPostDisabled()
        } else {
            createComment(self.newCommentTextField.text!)
            newCommentTextField.text = ""
        }
    }
    
    func showPostDisabled() {
        let alert = UIAlertController(title: nil, message: "This post has been flagged as inappropriate and commenting has been disabled.", preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "Ok", style: .Default, handler: { action in
            self.navigationController?.popViewControllerAnimated(true)
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
            (success: Bool, error: NSError?) in
            if success {
                self.disableCommentButton()
                self.getComments()
                self.incrementComments()
                self.commentsCountLabel.text = (self.post["comments"] as! Int).stringNumberOfContents("comment")
                self.view.endEditing(true)
            }
        }
    }
    
    func incrementComments() {
        post.incrementKey("comments")
        post.saveInBackground()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let oldString = newCommentTextField.text! as NSString
        let newString = oldString.stringByReplacingCharactersInRange(range, withString: string) as NSString
        if newString.length == 0 {
            disableCommentButton()
        } else {
            enableCommentButton()
        }
        return true
    }
    
    func enableCommentButton() {
        commentButton.userInteractionEnabled = true
        commentButton.alpha = 1
    }
    
    func disableCommentButton() {
        commentButton.userInteractionEnabled = false
        commentButton.alpha = 0.5
    }
    
    @IBAction func tapComment(sender: AnyObject) {
        startCreateComment()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.newCommentTextField.resignFirstResponder()
        startCreateComment()
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.commentButtonBottomContraint.constant = keyboardFrame.size.height
            self.newCommentTextFieldBottomConstraint.constant = keyboardFrame.size.height
        })
    }
    
    func keyboardWillHide(sender: NSNotification) {
        commentButtonBottomContraint.constant = 8
        newCommentTextFieldBottomConstraint.constant = 8
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}