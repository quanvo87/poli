//
//  CreateAccountViewController.swift
//  poli
//
//  Created by Vo, Van-Quan N on 2/24/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //# MARK: - Set Up UI
    func setUpUI() {
        self.view.addLogInScreenBackground()
        messageLabel.text = ""
        passwordTextField.delegate = self
    }
    
    //# MARK: - Sign Up
    func signUp() {
        self.messageLabel.text = ""
        let email = emailTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString
        let password = passwordTextField.text
        let network = email!.componentsSeparatedByString("@")[1]
        
        if isValidEmail(email!) == false {
            self.messageLabel.text = "Please enter a valid e-mail."
            
        } else if password == "" {
            self.messageLabel.text = "Please enter a password."
            
        } else {
            createUser(email!, password: password!, network: network)
        }
    }
    
    func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(testStr)
        return result
    }
    
    func createUser(email: String, password: String, network: String) {
        let user = PFUser()
        user.username = email
        user.email = email
        user.password = password
        user["network"] = network
        user.signUpInBackgroundWithBlock {
            (success: Bool, error: NSError?) in
            if success {
                self.setUpUser(network)
            } else {
                self.showAlert("Unable to sign up. Please try again.")
            }
        }
    }
    
    func setUpUser(network: String) {
        let userId = (PFUser.currentUser()?.objectId)!
        PFUser.logOut()
        self.joinNetworks(network, userId: userId)
        self.showSignUpSuccess()
    }
    
    func joinNetworks(network: String, userId: String) {
        let query = PFQuery(className: "Network")
        query.whereKey("name", equalTo: network)
        query.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) in
            if object == nil {
                self.createNetwork(network)
                self.createChannel("General", network: network)
                self.createChannel("Funny", network: network)
                self.createChannel("Events", network: network)
                self.createChannel("Buy/Sell/Trade", network: network)
            }
            self.createUserChannel("General", user: userId)
            self.createUserChannel("Funny", user: userId)
            self.createUserChannel("Events", user: userId)
            self.createUserChannel("Buy/Sell/Trade", user: userId)
        }
    }
    
    func createNetwork(network: String) {
        let newNetwork = PFObject(className: "Network")
        newNetwork["name"] = network
        newNetwork.saveInBackground()
    }
    
    func createChannel(channelName: String, network: String) {
        let newChannel = PFObject(className: "Content")
        newChannel["type"] = "default channel"
        newChannel["network"] = network
        newChannel["name"] = channelName
        newChannel["creator"] = "default"
        newChannel["posts"] = 0
        newChannel["flags"] = 0
        newChannel.saveInBackground()
    }
    
    func createUserChannel(userChannelName: String, user: String) {
        let newUserChannel = PFObject(className: "UserChannel")
        newUserChannel["name"] = userChannelName
        newUserChannel["user"] = user
        newUserChannel.saveInBackground()
    }
    
    func showSignUpSuccess() {
        let alert: UIAlertController = UIAlertController(title: "Success!", message: "Verification e-mail sent. Please verify to log in!", preferredStyle: .Alert)
        let okButton: UIAlertAction = UIAlertAction(title: "Ok!", style: .Default) { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(okButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func tapSignUp(sender: AnyObject) {
        signUp()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.passwordTextField.resignFirstResponder()
        signUp()
        return true
    }
    
    //# MARK: - Cancel
    @IBAction func tapCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //# MARK: - Keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}