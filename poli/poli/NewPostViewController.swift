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
    }
    
    @IBAction func tapPost(sender: AnyObject) {
        
        let postText = postTextView.text
        let user = PFUser.currentUser()
        let userObjectId = user?.objectId
        
        if postText != "" {
            
            let post = PFObject(className:"Post")
            post["creator"] = userObjectId
            post["text"] = postText
            
            post.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
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