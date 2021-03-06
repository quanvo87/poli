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
    var network = String()
    var channels = [PFObject]()
    var userChannels = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        getUserData()
        setUpTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationItem.title = "Channels - " + network
    }
    
    override func viewDidAppear(animated: Bool) {
        getChannels()
    }
    
    override func viewWillDisappear(animated: Bool) {
        navigationItem.title = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //# MARK: - Set Up UI
    func setUpUI() {
        self.view.backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 241/255, alpha: 1)
    }
    
    //# MARK: - Get User Data
    func getUserData() {
        let user = PFUser.currentUser()
        userId = (user!.objectId as String?)!
        network = user!["network"] as! String
    }
    
    //# MARK: - Get Channels
    func getChannels() {
        let flagQuery = PFQuery(className: "Flag")
        flagQuery.whereKey("type", containedIn: ["user", "channel"])
        flagQuery.whereKey("user", equalTo: userId)
        
        let channelQuery = PFQuery(className: "Content")
        channelQuery.whereKey("type", containedIn: ["default channel", "custom channel"])
        channelQuery.whereKey("network", equalTo: network)
        channelQuery.whereKey("flags", lessThan: 3)
        channelQuery.whereKey("creator", doesNotMatchKey: "content", inQuery: flagQuery)
        channelQuery.whereKey("objectId", doesNotMatchKey: "content", inQuery: flagQuery)
        channelQuery.orderByDescending("posts")
        channelQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) in
            if error == nil {
                self.channels = objects!
                self.getUserChannels()
            }
        }
    }
    
    //# MARK: - Table View
    func setUpTableView() {
        channelsTableView.dataSource = self
        channelsTableView.delegate = self
        channelsTableView.backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 241/255, alpha: 1)
        channelsTableView.separatorStyle = .None
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ChannelsViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        channelsTableView.addSubview(refreshControl)
    }
    
    func getUserChannels() {
        var newUserChannels = [String]()
        let query = PFQuery(className: "UserChannel")
        query.whereKey("user", equalTo: userId)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) in
            if error == nil {
                for object in objects! {
                    newUserChannels.append(object["name"] as! String)
                }
                self.userChannels = newUserChannels
                self.channelsTableView.reloadData()
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return channels.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as! UITableViewHeaderFooterView
        footer.contentView.backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 241/255, alpha: 1)
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Channel Cell", forIndexPath: indexPath) as! ChannelsTableViewCell
        let channel = self.channels[indexPath.section]
        let channelName = channel["name"] as? String
        cell.channelNameLabel.text = channelName
        cell.postsCountLabel.text = "(" + String((channel["posts"] as! Int)) + ")"
        
        if userChannels.contains(channelName!) {
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let channel = self.channels[indexPath.section]
        let channelName = channel["name"] as? String
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .None {
                let newUserChannel = PFObject(className: "UserChannel")
                newUserChannel["user"] = self.userId
                newUserChannel["name"] = channelName
                newUserChannel.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) in
                    if success {
                        cell.accessoryType = .Checkmark
                    }
                }
            } else {
                let userChannelQuery = PFQuery(className: "UserChannel")
                userChannelQuery.whereKey("user", equalTo: self.userId)
                userChannelQuery.whereKey("name", equalTo: channelName!)
                userChannelQuery.getFirstObjectInBackgroundWithBlock {
                    (object: PFObject?, error: NSError?) in
                    object!.deleteInBackgroundWithBlock {
                        (success: Bool, error: NSError?) in
                        if success {
                            cell.accessoryType = .None
                        }
                    }
                }
            }
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        getChannels()
        refreshControl.endRefreshing()
    }
    
    //# MARK: - Buttons
    @IBAction func tapSelectAll(sender: AnyObject) {
        for i in 0...channelsTableView.numberOfSections - 1 {
            if let cell = channelsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: i)) {
                if cell.accessoryType == .None {
                    let channel = self.channels[i]
                    let channelName = channel["name"] as! String
                    let newUserChannel = PFObject(className: "UserChannel")
                    newUserChannel["user"] = self.userId
                    newUserChannel["name"] = channelName
                    newUserChannel.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) in
                        if success {
                            cell.accessoryType = .Checkmark
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func tapUnselectAll(sender: AnyObject) {
        for i in 0...channelsTableView.numberOfSections - 1 {
            if let cell = channelsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: i)) {
                if cell.accessoryType == .Checkmark {
                    let channel = self.channels[i]
                    let channelName = channel["name"] as! String
                    let userChannelQuery = PFQuery(className: "UserChannel")
                    userChannelQuery.whereKey("user", equalTo: self.userId)
                    userChannelQuery.whereKey("name", equalTo: channelName)
                    userChannelQuery.getFirstObjectInBackgroundWithBlock {
                        (object: PFObject?, error: NSError?) in
                        object!.deleteInBackgroundWithBlock {
                            (success: Bool, error: NSError?) in
                            if success {
                                cell.accessoryType = .None
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func tapReportChannel(sender: AnyObject) {
        if let reportChannelViewController = storyboard?.instantiateViewControllerWithIdentifier("Report Channel") as! ReportChannelTableViewController? {
            navigationController?.pushViewController(reportChannelViewController, animated: true)
        }
    }
}