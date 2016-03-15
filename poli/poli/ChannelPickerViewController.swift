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
        
        channelsTableView.dataSource = self
        channelsTableView.delegate = self
        automaticallyAdjustsScrollViewInsets = false
        
        getChannels()
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
        return channels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Channel Picker Cell", forIndexPath: indexPath) as! ChannelPickerTableViewCell
        cell.channelNameLabel.text = channels[indexPath.row]["name"] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        delegate.getChannel(channels[indexPath.row]["name"] as! String)
        navigationController?.popViewControllerAnimated(true)
    }
}