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
        self.emailTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tapLogIn(sender: AnyObject) {
        
        self.messageLabel.text = ""
        
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if email == "" || password == "" {
            self.messageLabel.text = "Please enter a valid username and password."
            
        } else {
            
            PFUser.logInWithUsernameInBackground(email!, password:password!) {
                (user: PFUser?, error: NSError?) -> Void in
                
                if error != nil {
                    print(error)
                } else if user!["emailVerified"] as! Bool == true {
                    
                    self.messageLabel.text = ""
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let tabBarController = storyboard.instantiateViewControllerWithIdentifier("Tab Bar") as! UITabBarController
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.window?.rootViewController = tabBarController
                    
                } else {
                    PFUser.logOut()
                    self.messageLabel.text = "Please verify e-mail to log in"
                }
            }
        }
    }
    
    @IBAction func tapSignUp(sender: AnyObject) {
        if let signUpViewController = storyboard?.instantiateViewControllerWithIdentifier("Sign Up") as! SignUpViewController? {
            self.presentViewController(signUpViewController, animated: true, completion: nil)
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