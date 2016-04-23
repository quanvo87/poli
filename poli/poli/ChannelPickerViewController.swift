//
//  ChannelPickerViewController.swift
//  poli
//
//  Created by Vo, Van-Quan N on 3/7/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class ChannelPickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var channelsTableView: UITableView!
    var delegate: ChannelPickerViewControllerDelegate!
    var channels = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Select A Channel"
        setUpUI()
        setUpTableView()
        getChannels()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //# MARK: - Set Up UI
    func setUpUI() {
        self.view.backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 241/255, alpha: 1)
    }
    
    //# MARK: - Get Channels
    func getChannels() {
        let user = PFUser.currentUser()
        let userId = user?.objectId
        let network = user!["network"]
        
        let flagQuery = PFQuery(className: "Flag")
        flagQuery.whereKey("type", containedIn: ["user", "channel"])
        flagQuery.whereKey("user", equalTo: userId!)
        
        let channelQuery = PFQuery(className: "Content")
        channelQuery.whereKey("type", containedIn: ["default channel", "custom channel"])
        channelQuery.whereKey("network", equalTo: network)
        channelQuery.whereKey("flags", lessThan: 3)
        channelQuery.whereKey("creator", doesNotMatchKey: "content", inQuery: flagQuery)
        channelQuery.whereKey("objectId", doesNotMatchKey: "content", inQuery: flagQuery)
        channelQuery.orderByAscending("createdAt")
        channelQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) in
            if error == nil {
                self.channels = objects!
                self.channelsTableView.reloadData()
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
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        channelsTableView.addSubview(refreshControl)
        
        automaticallyAdjustsScrollViewInsets = false
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Channel Picker Cell", forIndexPath: indexPath) as! ChannelPickerTableViewCell
        cell.channelNameLabel.text = channels[indexPath.section]["name"] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate.setChannel(channels[indexPath.section]["name"] as! String)
        navigationController?.popViewControllerAnimated(true)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        getChannels()
        refreshControl.endRefreshing()
    }
}