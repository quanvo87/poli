//
//  PostDetailViewController.swift
//  poli
//
//  Created by Vo, Van-Quan N on 3/3/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController {
    
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var newCommentTextField: UITextField!
    
    var objectId = ""
    var posts:[PFObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postTextLabel.text = ""
        timeStampLabel.text = ""
        getPost()
    }
    
    func getPost() {
        let query = PFQuery(className:"Post")
        query.whereKey("objectId", equalTo:objectId)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                
                self.posts = objects!

                self.postTextLabel.text = self.posts[0]["text"] as? String
                
                let createdAt = self.posts[0].createdAt as NSDate?
                let dateFormatter = NSDateFormatter()
                dateFormatter.timeStyle = .ShortStyle
                let createdAtString = dateFormatter.stringFromDate(createdAt!)
                self.timeStampLabel.text = createdAtString
                
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tapComment(sender: AnyObject) {
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}
