//
//  NewPostViewController.swift
//  poli
//
//  Created by Vo, Van-Quan N on 2/29/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class NewPostViewController: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tapSelectChannel(sender: AnyObject) {
    }
    
    @IBAction func tapNewChannel(sender: AnyObject) {
    }
    
    @IBAction func tapPost(sender: AnyObject) {
        
        let postText = postTextView.text
        let user = PFUser.currentUser()
        let userObjectId = user?.objectId
        
        if postText == "" {
            messageLabel.text = "Posts cannot be blank!"
            return
        }
        
        let post = PFObject(className:"Post")
        post["creator"] = userObjectId
        post["text"] = postText
        post.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                
                let alert: UIAlertController = UIAlertController(title: "Success", message: "Post successful!", preferredStyle: .Alert)
                let okButton: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
                    self.tabBarController?.selectedIndex = 0
                    self.postTextView.text = ""
                }
                alert.addAction(okButton)
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                self.messageLabel.text = "Post was unsuccessful. Please try again."
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}
