//
//  ChannelsViewController.swift
//  poli
//
//  Created by Vo, Van-Quan N on 3/10/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class ChannelsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var channelsTableView: UITableView!
    var user = PFUser()
    var userId = String()
    var network = String()
    var userChannels = [String]()
    var channels = [PFObject]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.title = "Channels"
        
        channelsTableView.dataSource = self
        channelsTableView.delegate = self
        
        user = PFUser.currentUser()!
        userId = user.objectId!
        network = user["network"] as! String
    }
    
    override func viewDidAppear(animated: Bool) {
        
        getUserChannels()
        getChannels()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getUserChannels() {
        
        var newUserChannels = [String]()
        
        let query = PFQuery(className: "UserChannel")
        query.whereKey("user", equalTo: userId)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            for object in objects! {
                newUserChannels.append(object["name"] as! (String))
            }
            
            self.userChannels = newUserChannels
        }
    }
    
    func getChannels() {
        
        let query = PFQuery(className: "Channel")
        query.whereKey("network", equalTo: network)
        query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            self.channels = objects!
            self.channelsTableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Channel Cell", forIndexPath: indexPath) as! ChannelsTableViewCell
        let channel = self.channels[indexPath.row]
        let channelName = channel["name"] as? String
        
        cell.channelNameLabel.text = channelName
        
        if userChannels.contains(channelName!) {
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let channel = self.channels[indexPath.row]
        let channelName = channel["name"] as? String
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            
            if cell.accessoryType == .None {
                
                let newUserChannel = PFObject(className: "UserChannel")
                newUserChannel["user"] = self.userId
                newUserChannel["name"] = channelName
                
                do {
                    try newUserChannel.save()
                }
                catch {
                    print(error)
                }
                
                cell.accessoryType = .Checkmark
                
            } else {
                
                let userChannelQuery = PFQuery(className: "UserChannel")
                userChannelQuery.whereKey("user", equalTo: self.userId)
                userChannelQuery.whereKey("name", equalTo: channelName!)
                userChannelQuery.getFirstObjectInBackgroundWithBlock {
                    (object: PFObject?, error: NSError?) -> Void in
                    
                    do {
                        try object?.delete()
                    }
                    catch {
                        print(error)
                    }
                    
                    cell.accessoryType = .None
                }
            }
        }
    }
    
    
    @IBAction func tapSelectAll(sender: AnyObject) {
        
        for i in 0...channelsTableView.numberOfSections - 1 {
            
            for j in 0...channelsTableView.numberOfRowsInSection(i) - 1 {
                
                if let cell = channelsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: j, inSection: i)) {
                    
                    if cell.accessoryType == .None {
                        
                        let channel = self.channels[j]
                        let channelName = channel["name"] as! String
                        
                        let newUserChannel = PFObject(className: "UserChannel")
                        newUserChannel["user"] = self.userId
                        newUserChannel["name"] = channelName
                        
                        do {
                            try newUserChannel.save()
                        }
                        catch {
                            print(error)
                        }
                        
                        cell.accessoryType = .Checkmark
                    }
                }
            }
        }
    }
    
    @IBAction func tapUnselectAll(sender: AnyObject) {
        
        for i in 0...channelsTableView.numberOfSections - 1 {
            
            for j in 0...channelsTableView.numberOfRowsInSection(i) - 1 {
                
                if let cell = channelsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: j, inSection: i)) {
                    
                    if cell.accessoryType == .Checkmark {
                        
                        let channel = self.channels[j]
                        let channelName = channel["name"] as! String
                        
                        let userChannelQuery = PFQuery(className: "UserChannel")
                        userChannelQuery.whereKey("user", equalTo: self.userId)
                        userChannelQuery.whereKey("name", equalTo: channelName)
                        userChannelQuery.getFirstObjectInBackgroundWithBlock {
                            (object: PFObject?, error: NSError?) -> Void in
                            
                            do {
                                try object?.delete()
                            }
                            catch {
                                print(error)
                            }
                            
                            cell.accessoryType = .None
                        }
                    }
                }
            }
        }
    }
}