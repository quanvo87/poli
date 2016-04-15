//
//  Extensions.swift
//  poli
//
//  Created by locuyen on 4/2/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import Foundation

extension NSDate {
    func toString() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        return  dateFormatter.stringFromDate(self)
    }
}

extension NSString {
    func stringByTrimmingCharacters(trimTo: Int) -> String {
        var result = String()
        if self.length > trimTo {
            result = "\(self.substringToIndex(trimTo))..."
        } else {
            result = self as String
        }
        return result
    }
}

extension Int {
    func stringNumberOfContents(content: String) -> String {
        var text = String(self)
        if text == "1" {
            text += " " + content
        } else {
            text += " " + content + "s"
        }
        return text
    }
}

extension UIViewController {
    func showAlert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let alertButton: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action in
        }
        alert.addAction(alertButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //# MARK: - Check if user is banned
    func checkIfUserIsBanned() {
        let user = PFUser.currentUser()
        let userId = (user?.objectId)! as String
        checkUserFlags(user!, userId: userId)
    }
    
    func checkUserFlags(user: PFUser, userId: String) {
        let query = PFQuery(className: "Flag")
        query.whereKey("content", equalTo: userId)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) in
            if error == nil {
                if objects?.count > 2 {
                    self.kickUser(user)
                } else {
                    self.checkFlaggedContent(user, userId: userId)
                }
            }
        }
    }
    
    func checkFlaggedContent(user: PFUser, userId: String) {
        let query = PFQuery(className: "Content")
        query.whereKey("creator", equalTo: userId)
        query.whereKey("flags", greaterThan: 2)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) in
            if error == nil {
                if objects?.count > 2 {
                    self.kickUser(user)
                }
            }
        }
    }
    
    func kickUser(user: PFUser) {
        let alert = UIAlertController(title: "", message: "This accound has been reported too many times for posting inappropriate content and is now banned.", preferredStyle: .Alert)
        let alertButton: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action in
            self.logOut()
        }
        alert.addAction(alertButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //# MARK: - Log out
    func logOut() {
        PFUser.logOut()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let logInViewController  = storyboard.instantiateViewControllerWithIdentifier("Log In") as! LogInViewController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = logInViewController
    }
}