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
    
    func setChannel(channel: String) {
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
        let channelName = selectedChannelLabel.text?.capitalizedString
        
        if postText == "" {
            
            let alert: UIAlertController = UIAlertController(title: "", message: "Posts cannot be blank.", preferredStyle: .Alert)
            let alertButton: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
            }
            alert.addAction(alertButton)
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else if channelName == "" {
            
            let alert: UIAlertController = UIAlertController(title: "", message: "Please select a channel for your post.", preferredStyle: .Alert)
            let alertButton: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
            }
            alert.addAction(alertButton)
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            
            postTextView.text = ""
            selectedChannelLabel.text = ""
            
            let user = PFUser.currentUser()
            let userId = user?.objectId
            let network = user!["network"] as! String
            
            let post = PFObject(className: "Post")
            post["class"] = "post"
            post["creator"] = userId
            post["channel"] = channelName
            post["text"] = postText
            
            do {
                try post.save()
            }
            catch {
                print(error)
            }
            
            let channelQuery = PFQuery(className: "Channel")
            channelQuery.whereKey("network", equalTo: network)
            channelQuery.whereKey("name", equalTo: channelName!)
            channelQuery.getFirstObjectInBackgroundWithBlock {
                (object: PFObject?, error: NSError?) -> Void in
                
                if object == nil {
                    
                    let newChannel = PFObject(className: "Channel")
                    newChannel["name"] = channelName
                    newChannel["network"] = network
                    
                    do {
                        try newChannel.save()
                    }
                    catch {
                        print(error)
                    }
                }
            }
            
            let userChannelQuerry = PFQuery(className: "UserChannel")
            userChannelQuerry.whereKey("user", equalTo: userId!)
            userChannelQuerry.whereKey("name", equalTo: channelName!)
            userChannelQuerry.getFirstObjectInBackgroundWithBlock {
                (object: PFObject?, error: NSError?) -> Void in
                
                if object == nil {
                    
                    let newUserChannel = PFObject(className: "UserChanel")
                    newUserChannel["user"] = userId
                    newUserChannel["name"] = channelName
                    
                    do {
                        try newUserChannel.save()
                    }
                    catch {
                        print(error)
                    }
                }
            }
            
            self.tabBarController?.selectedIndex = 0
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