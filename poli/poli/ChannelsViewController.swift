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
    var userId = String()
    var channels = [PFObject]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.title = "Channels"
        
        channelsTableView.dataSource = self
        channelsTableView.delegate = self
        
        userId = (PFUser.currentUser()?.objectId as String?)!
    }
    
    override func viewDidAppear(animated: Bool) {
        getChannels()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getChannels() {
        
        let query = PFQuery(className:"Channel")
        query.whereKey("network", equalTo:PFUser.currentUser()!["network"])
        query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            self.channels = objects!
            self.channelsTableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Channel Cell", forIndexPath: indexPath) as! ChannelsTableViewCell
        let channel = self.channels[indexPath.row]
        
        cell.channelNameLabel.text = channel["name"] as? String
        
        let users = channel["users"] as! [String]

        if users.contains(self.userId) {
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    @IBAction func tapSelectAll(sender: AnyObject) {
    }
    
    @IBAction func tapUnselectAll(sender: AnyObject) {
    }
}