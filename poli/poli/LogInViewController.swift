//
//  LogInViewController.swift
//  poli
//
//  Created by Vo, Van-Quan N on 2/29/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        messageLabel.text = ""
        passwordTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //# MARK: - Set Up UI
    func setUpUI() {
        self.view.addLogInScreenBackground()
    }
    
    //# MARK: - Log In
    func logIn() {
        self.messageLabel.text = ""
        let email = emailTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString
        let password = passwordTextField.text
        
        if email == "" || password == "" {
            self.messageLabel.text = "Please enter a valid username and password."
            
        } else {
            self.messageLabel.text = ""
            PFUser.logInWithUsernameInBackground(email!, password:password!) {
                (user: PFUser?, error: NSError?) in
                if error == nil {
                    if user!["emailVerified"] as! Bool == true {
                        self.logInSuccess()
                        
                    } else {
                        PFUser.logOut()
                        self.messageLabel.text = "Please verify e-mail to log in"
                    }
                }
                else {
                    self.messageLabel.text = "Log in failed. Please try again."
                }
            }
        }
    }
    
    func logInSuccess() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewControllerWithIdentifier("Tab Bar") as! UITabBarController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBarController
    }
    
    @IBAction func tapLogIn(sender: AnyObject) {
        logIn()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.passwordTextField.resignFirstResponder()
        logIn()
        return true
    }
    
    //# MARK: - Sign up
    @IBAction func tapSignUp(sender: AnyObject) {
        if let signUpViewController = storyboard?.instantiateViewControllerWithIdentifier("Sign Up") as! SignUpViewController? {
            self.presentViewController(signUpViewController, animated: true, completion: nil)
        }
    }
    
    //# MARK: - Keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}