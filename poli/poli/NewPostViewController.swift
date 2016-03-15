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
    
    override func viewDidAppear(animated: Bool) {
        self.postTextView.becomeFirstResponder()
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
        let nextAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
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
        let userObjectId = PFUser.currentUser()!.objectId
        let channel = selectedChannelLabel.text?.capitalizedString
        
        if postText == "" {
            
            let alert: UIAlertController = UIAlertController(title: "", message: "Posts cannot be blank.", preferredStyle: .Alert)
            let alertButton: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
            }
            alert.addAction(alertButton)
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else if channel == "" {
            
            let alert: UIAlertController = UIAlertController(title: "", message: "Please select a channel for your post.", preferredStyle: .Alert)
            let alertButton: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
            }
            alert.addAction(alertButton)
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            
            let post = PFObject(className: "Post")
            post["creator"] = userObjectId
            post["text"] = postText
            
            let network = PFUser.currentUser()!["network"] as! String
            let query = PFQuery(className: "Channel")
            query.whereKey("network", equalTo: network)
            query.whereKey("name", equalTo: channel!)
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                let userId = (PFUser.currentUser()?.objectId)!
                
                if objects?.count == 0 {
                    
                    let newChannel = PFObject(className: "Channel")
                    newChannel["name"] = channel
                    newChannel["network"] = network
                    newChannel["users"] = [userId]
                    
                    newChannel.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        
                        post["channel"] = newChannel.objectId
                        post.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            
                            self.postTextView.text = ""
                            self.selectedChannelLabel.text = ""
                            self.tabBarController?.selectedIndex = 0
                        }
                    }
                } else {
                    
                    let selectedChannel = objects?[0]
                    let selectedChannelUsers = selectedChannel!["users"] as! [String]
                    
                    if selectedChannelUsers.contains(userId) == false {
                        
                        selectedChannel?.addObject(userId, forKey: "users")
                        selectedChannel!.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            
                            post["channel"] = selectedChannel!.objectId
                            post.saveInBackgroundWithBlock {
                                (success: Bool, error: NSError?) -> Void in
                                
                                self.postTextView.text = ""
                                self.selectedChannelLabel.text = ""
                                self.tabBarController?.selectedIndex = 0
                            }
                        }
                    } else {
                        
                        post["channel"] = selectedChannel!.objectId
                        post.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            
                            self.postTextView.text = ""
                            self.selectedChannelLabel.text = ""
                            self.tabBarController?.selectedIndex = 0
                        }
                    }
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