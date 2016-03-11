//
//  CreateAccountViewController.swift
//  poli
//
//  Created by Vo, Van-Quan N on 2/24/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageLabel.text = ""
        self.emailTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tapSignUp(sender: AnyObject) {
        
        let network = "utexas.edu"
        self.messageLabel.text = ""
        
        let email = emailTextField.text?.lowercaseString
        let password = passwordTextField.text
        
        if email?.hasSuffix(network) == false {
            self.messageLabel.text = "Please enter an e-mail associated with a supported organization."
            
        } else if password == "" {
            self.messageLabel.text = "Please enter a password."
            
        } else {
            
            let user = PFUser()
            user.username = emailTextField.text
            user.email = emailTextField.text
            user.password = passwordTextField.text
            user["network"] = network
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                
                self.getNetworkChannels(network)
                
                self.logOut()
                
                if error == nil {
                    
                    self.messageLabel.text = ""
                    
                    self.createNetwork(network)
                    
                    let alert: UIAlertController = UIAlertController(title: nil, message: "Verification e-mail sent. Please verify to log in!", preferredStyle: .Alert)
                    let okButton: UIAlertAction = UIAlertAction(title: "OK!", style: .Default) { action -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    alert.addAction(okButton)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                } else {
                    let alert: UIAlertController = UIAlertController(title: nil, message: "Unable to sign up. Please try again.", preferredStyle: .Alert)
                    let okButton: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    alert.addAction(okButton)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func logOut() {
        PFUser.logOut()
    }
    
    func createNetwork(network: String) {
        
        let query = PFQuery(className:"Network")
        query.whereKey("name", equalTo:network)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                if objects?.count == 0 {
                    
                    let newNetwork = PFObject(className: "Network")
                    
                    newNetwork["name"] = network
                    
                    let general = PFObject(className: "Channel")
                    let funny = PFObject(className: "Channel")
                    let events = PFObject(className: "Channel")
                    let buySellTrade = PFObject(className: "Channel")
                    
                    general["name"] = "General"
                    funny["name"] = "Funny"
                    events["name"] = "Events"
                    buySellTrade["name"] = "Buy/Sell/Trade"
                    
                    let channels = [general, funny, events, buySellTrade]
                    
                    for channel in channels {
                        channel["network"] = network
                        channel.saveInBackground()
                    }
                    
                    newNetwork.saveInBackground()
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func getNetworkChannels(network: String) {
        
        if let user = PFUser.currentUser() {
            
            let query = PFQuery(className:"Channel")
            query.whereKey("network", equalTo:network)
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    var channels = [String: Int]()
                    channels.updateValue(1, forKey: "f")
                    if let objects = objects {
                        for object in objects {
                            channels.updateValue(1, forKey: object["name"] as! String)
                        }
                    }
                    user["channels"] = channels
                    user.saveInBackground()
                    
                } else {
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
    }
    
    @IBAction func tapCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}