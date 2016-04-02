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
    
    //# MARK: - Select Channel
    @IBAction func tapSelectChannel(sender: UIButton) {
        if let channelPickerViewController = storyboard?.instantiateViewControllerWithIdentifier("Channel Picker") as! ChannelPickerViewController? {
            channelPickerViewController.delegate = self
            self.navigationController?.pushViewController(channelPickerViewController, animated: true)
        }
    }
    
    func setChannel(channel: String) {
        self.selectedChannelLabel.text = channel
    }
    
    
    //# MARK: - New Channel
    @IBAction func tapNewChannel(sender: AnyObject) {
        var inputTextField: UITextField?
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: "Create a new channel:", preferredStyle: .Alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelAction)
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
            self.selectedChannelLabel.text = inputTextField?.text
        }
        actionSheetController.addAction(okAction)
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            inputTextField = textField
        }
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    //# MARK: - Create New Post
    @IBAction func tapPost(sender: AnyObject) {
        let postText = postTextView.text
        let channelName = selectedChannelLabel.text?.capitalizedString
        
        if postText == "" {
            self.showAlert("Posts cannot be blank.")
            
        } else if channelName == "" {
            self.showAlert("Please select a chanel for your post.")
            
        } else {
            postTextView.text = ""
            selectedChannelLabel.text = ""
            
            let user = PFUser.currentUser()
            let userId = user?.objectId as String?
            let network = user!["network"] as! String
            
            let post = PFObject(className: "Post")
            post["type"] = "post"
            post["creator"] = userId
            post["channel"] = channelName
            post["flags"] = 0
            post["text"] = postText
            post.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                
                if success {
                    let channelQuery = PFQuery(className: "Channel")
                    channelQuery.whereKey("network", equalTo: network)
                    channelQuery.whereKey("name", equalTo: channelName!)
                    channelQuery.getFirstObjectInBackgroundWithBlock {
                        (object: PFObject?, error: NSError?) -> Void in
                        
                        if object == nil {
                            let newChannel = PFObject(className: "Channel")
                            newChannel["network"] = network
                            newChannel["type"] = "custom"
                            newChannel["name"] = channelName
                            newChannel["flags"] = 0
                            newChannel.saveInBackground()
                        }
                    }
                    let userChannelQuerry = PFQuery(className: "UserChannel")
                    userChannelQuerry.whereKey("user", equalTo: userId!)
                    userChannelQuerry.whereKey("name", equalTo: channelName!)
                    userChannelQuerry.getFirstObjectInBackgroundWithBlock {
                        (object: PFObject?, error: NSError?) -> Void in
                        
                        if object == nil {
                            let newUserChannel = PFObject(className: "UserChannel")
                            newUserChannel["user"] = userId
                            newUserChannel["name"] = channelName
                            newUserChannel.saveInBackgroundWithBlock {
                                (success: Bool, error: NSError?) -> Void in
                                if success {
                                    self.tabBarController?.selectedIndex = 0
                                }
                            }
                        } else {
                            self.tabBarController?.selectedIndex = 0
                        }
                    }
                }
            }
        }
    }
    
    //# MARK: - Keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}