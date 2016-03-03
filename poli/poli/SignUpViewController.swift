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
            return
        }
        
        if password == "" {
            self.messageLabel.text = "Please enter a password"
            return
        }
        
        let user = PFUser()
        user.username = emailTextField.text
        user.email = emailTextField.text
        user.password = passwordTextField.text
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            
            self.logOut()
            
            if error == nil {
                
                self.messageLabel.text = ""
                
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
    
    func logOut() {
        PFUser.logOut()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}