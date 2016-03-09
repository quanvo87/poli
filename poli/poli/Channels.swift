//
//  Channels.swift
//  poli
//
//  Created by Vo, Van-Quan N on 3/9/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import Foundation

class Channels {
    
    var channels:[PFObject] = []
    
    init() {
        let query = PFQuery(className:"Channel")
        query.whereKey("network", equalTo:PFUser.currentUser()!["network"])
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.channels = objects!
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
}