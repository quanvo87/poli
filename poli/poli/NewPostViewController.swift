//
//  NewPostViewController.swift
//  poli
//
//  Created by Vo, Van-Quan N on 2/29/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class NewPostViewController: UIViewController, ChannelPickerViewControllerDelegate {
    
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var selectedChannelLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "New Post"
        selectedChannelLabel.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tapSelectChannel(sender: UIButton) {
        if let channelPickerViewController = storyboard?.instantiateViewControllerWithIdentifier("Channel Picker") as! ChannelPickerViewController? {
            channelPickerViewController.delegate = self
            self.navigationController?.pushViewController(channelPickerViewController, animated: true)
        }
    }
    
    func getChannel(channel: String) {
        self.selectedChannelLabel.text = channel
    }
    
    @IBAction func tapNewChannel(sender: AnyObject) {
        
        var inputTextField: UITextField?
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: "Create a new channel:", preferredStyle: .Alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelAction)
        let nextAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
            self.selectedChannelLabel.text = inputTextField?.text
        }
        actionSheetController.addAction(nextAction)
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            inputTextField = textField
        }
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func tapPost(sender: AnyObject) {
        
        let postText = postTextView.text
        let user = PFUser.currentUser()
        let userObjectId = user?.objectId
        let channel = selectedChannelLabel.text
        
        if postText == "" {
            
            let alert: UIAlertController = UIAlertController(title: "", message: "Posts cannot be blank.", preferredStyle: .Alert)
            let alertButton: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
            }
            alert.addAction(alertButton)
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else if channel == "" {
            
            let alert: UIAlertController = UIAlertController(title: "", message: "Please select a channel for your post.", preferredStyle: .Alert)
            let alertButton: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
            }
            alert.addAction(alertButton)
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            
            let post = PFObject(className:"Post")
            post["creator"] = userObjectId
            post["text"] = postText
            post["channel"] = channel
            
            post.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    self.postTextView.text = ""
                    self.selectedChannelLabel.text = ""
                    self.tabBarController?.selectedIndex = 0
                }
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