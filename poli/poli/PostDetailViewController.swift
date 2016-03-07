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
    @IBOutlet weak var newCommentTextField: UITextField!
    @IBOutlet weak var commentsTableView: UITableView!
    
    var postObjectId = ""
    var post:[PFObject] = []
    var comments:[PFObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTextLabel.text = ""
        timeStampLabel.text = ""
        
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        
        getPost()
        getComments()
    }
    
    func getPost() {
        let query = PFQuery(className:"Post")
        query.whereKey("objectId", equalTo:postObjectId)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                
                self.post = objects!
                
                self.postTextLabel.text = self.post[0]["text"] as? String
                
                let createdAt = self.post[0].createdAt as NSDate?
                let dateFormatter = NSDateFormatter()
                dateFormatter.timeStyle = .ShortStyle
                let createdAtString = dateFormatter.stringFromDate(createdAt!)
                self.timeStampLabel.text = createdAtString
                
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func getComments() {
        let query = PFQuery(className:"Comment")
        query.whereKey("post", equalTo:postObjectId)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                
                self.comments = objects!
                self.commentsTableView.reloadData()
                
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tapComment(sender: AnyObject) {
        
        let newCommentText = newCommentTextField.text
        let user = PFUser.currentUser()
        let userObjectId = user?.objectId
        
        if newCommentText == "" {
            let alert: UIAlertController = UIAlertController(title: "", message: "Comments cannot be blank", preferredStyle: .Alert)
            let okButton: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
            }
            alert.addAction(okButton)
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            
            let comment = PFObject(className:"Comment")
            comment["creator"] = userObjectId
            comment["text"] = newCommentText
            comment["post"] = self.postObjectId
            
            comment.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    
                    self.newCommentTextField.text = ""
                    self.getComments()
                
                    
                } else {
                    let alert: UIAlertController = UIAlertController(title: "Comment failed", message: "Unable to post comment. Please try again.", preferredStyle: .Alert)
                    let okButton: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
                    }
                    alert.addAction(okButton)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CommentsTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CommentsTableViewCell
        let comment = comments[indexPath.row]
        
        let createdAt = comment.createdAt as NSDate?
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        let createdAtString = dateFormatter.stringFromDate(createdAt!)
        
        cell.commentsTextLabel.text = comment["text"] as? String
        cell.timeStampLabel.text = createdAtString
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}
