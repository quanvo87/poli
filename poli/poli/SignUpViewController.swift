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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tapSignUp(sender: AnyObject) {
        
        self.messageLabel.text = ""
        
        let email = emailTextField.text?.lowercaseString
        let password = passwordTextField.text
        
        if email?.hasSuffix("utexas.edu") == false {
            self.messageLabel.text = "Please enter an e-mail associated with a supported organization"
            
        } else if password == "" {
            self.messageLabel.text = "Please enter a password"
            
        } else {
            
            let user = PFUser()
            user.username = emailTextField.text
            user.email = emailTextField.text
            user.password = passwordTextField.text
            user["network"] = "utexas.edu"
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                
                self.logOut()
                
                if error == nil {
                    
                    self.messageLabel.text = ""
                    
                    self.createNetwork("utexas.edu")
                    
                    let alert: UIAlertController = UIAlertController(title: "Sign up successful!", message: "A verification e-mail has been sent to the provided address. Please confirm to log in!", preferredStyle: .Alert)
                    let okButton: UIAlertAction = UIAlertAction(title: "OK!", style: .Default) { action -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    alert.addAction(okButton)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                } else {
                    self.messageLabel.text = "Sign up failed. Please try again."
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
                    
                    general["channelType"] = "default"
                    funny["channelType"] = "default"
                    events["channelType"] = "default"
                    buySellTrade["channelType"] = "default"
                    
                    newNetwork["defaultChannels"] = [general, funny, events, buySellTrade]
                    
                    newNetwork.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                        } else {
                            print("Error creating new network")
                        }
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
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