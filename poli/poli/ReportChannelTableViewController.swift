//
//  ReportChannelTableViewController.swift
//  poli
//
//  Created by Vo, Van-Quan N on 3/30/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class ReportChannelTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var reportChannelTableView: UITableView!
    var channels = [PFObject]()
    var userId = String()
    var network = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = PFUser.currentUser()
        userId = (user?.objectId)!
        network = user!["network"] as! String
        
        setUpTableView()
        getChannels()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //# MARK: - Report Channel
    func reportPost(post: PFObject) {
        let postId = post.objectId
        let query = PFQuery(className: "Flag")
        query.whereKey("user", equalTo: userId)
        query.whereKey("content", equalTo: postId!)
        query.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if object == nil {
                self.confirmReportPost(post)
            } else {
                self.showAlert("You have already reported this channel. With enough flags, it will be removed.")
            }
        }
    }
    
    func confirmReportPost(post: PFObject) {
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: "Report channel for inappropriate title?", preferredStyle: .Alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelAction)
        let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .Default) { action -> Void in
            self.proceedReportPost(post)
        }
        actionSheetController.addAction(yesAction)
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func proceedReportPost(post: PFObject) {
        let postId = post.objectId
        let flag = PFObject(className: "Flag")
        flag["user"] = userId
        flag["content"] = postId
        flag.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if error == nil {
                self.incrementFlags(post)
            }
        }
    }
    
    func incrementFlags(post: PFObject) {
        post.incrementKey("flags")
        post.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if error == nil {
                self.showReportChannelSuccess()
            }
        }
    }
    
    func showReportChannelSuccess() {
        let alert: UIAlertController = UIAlertController(title: "", message: "Channel has been reported. With enough flags, it will be removed.", preferredStyle: .Alert)
        let alertButton: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        }
        alert.addAction(alertButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //# MARK: - Table View
    func setUpTableView() {
        reportChannelTableView.dataSource = self
        reportChannelTableView.delegate = self
        automaticallyAdjustsScrollViewInsets = false
    }
    
    func getChannels() {
        let query = PFQuery(className: "Channel")
        query.whereKey("network", equalTo: network)
        query.whereKey("type", equalTo: "custom")
        query.whereKey("flags", lessThan: 3)
        query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.channels = objects!
                self.reportChannelTableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Report Channel Cell", forIndexPath: indexPath) as! ReportChannelTableViewCell
        cell.channelNameLabel.text = channels[indexPath.row]["name"] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let channel = channels[indexPath.row]
        reportPost(channel)
    }
}