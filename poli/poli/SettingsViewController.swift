//
//  SettingsViewController.swift
//  poli
//
//  Created by Vo, Van-Quan N on 2/24/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tapLogOut(sender: AnyObject) {

        PFUser.logOut()
        
        let alert: UIAlertController = UIAlertController(title: "Logged Out", message: "Good bye!", preferredStyle: .Alert)
        let okButton: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let logInViewController  = storyboard.instantiateViewControllerWithIdentifier("Log In") as! LogInViewController
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.window?.rootViewController = logInViewController
        }
        alert.addAction(okButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}