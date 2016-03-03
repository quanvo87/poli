//
//  LogInViewController.swift
//  poli
//
//  Created by Vo, Van-Quan N on 2/29/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    
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
    
    @IBAction func tapLogIn(sender: AnyObject) {
        
        self.messageLabel.text = ""
        
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if email == "" || password == "" {
            self.messageLabel.text = "Please enter a valid username and password"
            return
        }
        
        PFUser.logInWithUsernameInBackground(email!, password:password!) {
            (user: PFUser?, error: NSError?) -> Void in
            
            if error != nil {
                self.messageLabel.text = "Log in failed. Please try again."
                
            } else if user!["emailVerified"] as! Bool == true {
                
                self.messageLabel.text = ""
                
                let alert: UIAlertController = UIAlertController(title: "Logged In", message: "Welcome!", preferredStyle: .Alert)
                let okButton: UIAlertAction = UIAlertAction(title: "OK!", style: .Default) { action -> Void in
                }
                alert.addAction(okButton)
                self.presentViewController(alert, animated: true, completion: nil)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = storyboard.instantiateViewControllerWithIdentifier("Tab Bar") as! UITabBarController
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.window?.rootViewController = tabBarController
                
            } else {
                PFUser.logOut()
                self.messageLabel.text = "Please verify e-mail to log in."
            }
        }
    }
    
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}
