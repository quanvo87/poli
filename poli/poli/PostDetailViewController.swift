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
    
    var post = PFObject(className: "Post")
    var comments:[PFObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTextLabel.text = post["text"] as? String
        
        let createdAt = post.createdAt as NSDate?
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        let createdAtString = dateFormatter.stringFromDate(createdAt!)
        timeStampLabel.text = createdAtString
        
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        
        getComments()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getComments() {
        let query = PFQuery(className:"Comment")
        query.whereKey("post", equalTo:post.objectId!)
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
    
    @IBAction func tapComment(sender: AnyObject) {
        
        let newCommentText = newCommentTextField.text
        
        if newCommentText == "" {
            
            let alert: UIAlertController = UIAlertController(title: "", message: "Comments cannot be blank.", preferredStyle: .Alert)
            let alertButton: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
            }
            alert.addAction(alertButton)
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            
            let comment = PFObject(className:"Comment")
            comment["creator"] = PFUser.currentUser()?.objectId
            comment["text"] = newCommentText
            comment["post"] = post.objectId
            
            comment.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    self.newCommentTextField.text = ""
                    self.getComments()
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Comment", forIndexPath: indexPath) as! CommentsTableViewCell
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
