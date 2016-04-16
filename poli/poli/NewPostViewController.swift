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
        checkIfUserIsBanned()
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
        let alert = UIAlertController(title: "", message: "Create a new channel:", preferredStyle: .Alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel) { action in
        }
        let okButton = UIAlertAction(title: "Ok", style: .Default) { action in
            self.selectedChannelLabel.text = inputTextField?.text
        }
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        alert.addTextFieldWithConfigurationHandler { textField in
            inputTextField = textField
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //# MARK: - Create New Post
    @IBAction func tapPost(sender: AnyObject) {
        let postText = (postTextView.text as NSString).stringByTrimmingCharacters(200)
        let channelName = selectedChannelLabel.text?.capitalizedString
        if postText == "" {
            showAlert("Posts cannot be blank.")
        } else if channelName == "" {
            showAlert("Please select a channel for your post.")
        } else {
            postTextView.text = ""
            selectedChannelLabel.text = ""
            createPost(postText, channelName: channelName!)
        }
    }
    
    func createPost(postText: String, channelName: String) {
        let user = PFUser.currentUser()
        let userId = user!.objectId
        let network = user!["network"] as! String
        let post = PFObject(className: "Content")
        post["type"] = "post"
        post["creator"] = userId
        post["channel"] = channelName
        post["comments"] = 0
        post["text"] = postText
        post["flags"] = 0
        post.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) in
            if success {
                self.setUpChannelAndUserChannel(network, channelName: channelName, userId: userId!)
            }
        }
    }
    
    func setUpChannelAndUserChannel(network: String, channelName: String, userId: String) {
        getChannel(network, channelName: channelName, userId: userId)
    }
    
    func getChannel(network: String, channelName: String, userId: String) {
        let channelQuery = PFQuery(className: "Content")
        channelQuery.whereKey("type", containedIn: ["default channel", "custom channel"])
        channelQuery.whereKey("network", equalTo: network)
        channelQuery.whereKey("name", equalTo: channelName)
        channelQuery.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) in
            if object == nil {
                self.createNewChannel(network, channelName: channelName, userId: userId)
            } else {
                self.incrementPosts(object!, network: network, channelName: channelName, userId: userId)
            }
        }
    }
    
    func createNewChannel(network: String, channelName: String, userId: String) {
        let newChannel = PFObject(className: "Content")
        newChannel["type"] = "custom channel"
        newChannel["network"] = network
        newChannel["creator"] = userId
        newChannel["name"] = channelName
        newChannel["posts"] = 1
        newChannel["flags"] = 0
        newChannel.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) in
            if success {
                self.getUserChannel(network, channelName: channelName, userId: userId)
            }
        }
    }
    
    func incrementPosts(channel: PFObject, network: String, channelName: String, userId: String) {
        channel.incrementKey("posts")
        channel.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) in
            if success {
                self.getUserChannel(network, channelName: channelName, userId: userId)
            }
        }
    }
    
    func getUserChannel(network: String, channelName: String, userId: String) {
        let userChannelQuerry = PFQuery(className: "UserChannel")
        userChannelQuerry.whereKey("user", equalTo: userId)
        userChannelQuerry.whereKey("name", equalTo: channelName)
        userChannelQuerry.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) in
            if object == nil {
                self.createUserChannel(network, channelName: channelName, userId: userId)
            } else {
                self.tabBarController?.selectedIndex = 0
            }
        }
    }
    
    func createUserChannel(network: String, channelName: String, userId: String) {
        let newUserChannel = PFObject(className: "UserChannel")
        newUserChannel["user"] = userId
        newUserChannel["name"] = channelName
        newUserChannel.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) in
            if success {
                self.tabBarController?.selectedIndex = 0
            }
        }
    }
    
    //# MARK: - Keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}