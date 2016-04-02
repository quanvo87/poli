//
//  Extensions.swift
//  poli
//
//  Created by locuyen on 4/2/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import Foundation

extension NSDate {
    func dateToString() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        return  dateFormatter.stringFromDate(self)
    }
}

extension NSString {
    func stringByTrimmingCharacters(l: Int) -> String {
        var result = String()
        if self.length > l {
            result = "\(self.substringToIndex(l))..."
        } else {
            result = self as String
        }
        return result
    }
}

extension UIViewController {
    //MARK: - Show Alert
    func showAlert(message: String) {
        let alert: UIAlertController = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let alertButton: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
        }
        alert.addAction(alertButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}