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
    var networkChannels = [PFObject]()
    var userChannels = [String: Int]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.title = "Channels"
        channelsTableView.dataSource = self
        channelsTableView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        
        getNetworkChannels()
        getUserChannels()
    }
    
    override func viewWillDisappear(animated: Bool) {
        saveChannels()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getNetworkChannels() {
        
        let query = PFQuery(className:"Channel")
        query.whereKey("network", equalTo:PFUser.currentUser()!["network"])
        query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            self.networkChannels = objects!
            self.channelsTableView.reloadData()
        }
    }
    
    func getUserChannels() {
        if let user = PFUser.currentUser() {
            userChannels = user["channels"] as! [String: Int]
        }
    }
    
    func saveChannels() {
        if let user = PFUser.currentUser() {
            user["channels"] = userChannels
            user.saveInBackground()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networkChannels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Channel Cell", forIndexPath: indexPath) as! ChannelsTableViewCell
        cell.channelNameLabel.text = networkChannels[indexPath.row]["name"] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
        //            if cell.accessoryType == .Checkmark
        //            {
        //                cell.accessoryType = .None
        //                checked[indexPath.row] = false
        //            }
        //            else
        //            {
        //                cell.accessoryType = .Checkmark
        //                checked[indexPath.row] = true
        //            }
        //        }
    }
    
    @IBAction func tapSelectAll(sender: AnyObject) {
    }
    
    @IBAction func tapUnselectAll(sender: AnyObject) {
    }
}