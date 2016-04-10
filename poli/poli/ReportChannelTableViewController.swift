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
    
    //# MARK: - Get Channels
    func getChannels() {
        let flagQuery = PFQuery(className: "Flag")
        flagQuery.whereKey("type", containedIn: ["user", "channel"])
        flagQuery.whereKey("user", equalTo: userId)
        
        let channelQuery = PFQuery(className: "Content")
        channelQuery.whereKey("type", equalTo: "custom channel")
        channelQuery.whereKey("network", equalTo: network)
        channelQuery.whereKey("flags", lessThan: 3)
        channelQuery.whereKey("creator", doesNotMatchKey: "content", inQuery: flagQuery)
        channelQuery.whereKey("objectId", doesNotMatchKey: "content", inQuery: flagQuery)
        channelQuery.orderByAscending("createdAt")
        channelQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.channels = objects!
                self.reportChannelTableView.reloadData()
            }
        }
    }
    
    //# MARK: - Report
    func showReportMenu(content: PFObject) {
        let alert = UIAlertController(title: "Inappropriate content?", message: nil, preferredStyle: .Alert)
        let reportContentButton = UIAlertAction(title: "Report Channel", style: .Default, handler: { (action) -> Void in
            self.confirmReportContent(content)
        })
        let reportUserButton = UIAlertAction(title: "Report User", style: .Default, handler: { (action) -> Void in
            self.confirmReportUser(content)
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
        }
        alert.addAction(reportContentButton)
        alert.addAction(reportUserButton)
        alert.addAction(cancelButton)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //# MARK: - Report Channel
    func confirmReportContent(content: PFObject) {
        let alert = UIAlertController(title: "", message: "Really report?", preferredStyle: .Alert)
        let cancelButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        let yesButton: UIAlertAction = UIAlertAction(title: "Yes", style: .Default) { action -> Void in
            self.reportContent(content)
        }
        alert.addAction(cancelButton)
        alert.addAction(yesButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func reportContent(content: PFObject) {
        getFlaggedContent(content)
    }
    
    func getFlaggedContent(content: PFObject) {
        let query = PFQuery(className: "FlaggedContent")
        query.whereKey("creator", equalTo: content["creator"])
        query.whereKey("content", equalTo: content.objectId!)
        query.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) in
            if object == nil {
                self.createFlaggedContent(content)
            } else {
                self.createFlag(content)
            }
        }
    }
    
    func createFlaggedContent(content: PFObject) {
        let flaggedContent = PFObject(className: "FlaggedContent")
        flaggedContent["creator"] = content["creator"]
        flaggedContent["content"] = content.objectId
        flaggedContent.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) in
            if error == nil {
                self.createFlag(content)
            }
        }
    }
    
    func createFlag(content: PFObject) {
        let flag = PFObject(className: "Flag")
        flag["type"] = "channel"
        flag["user"] = userId
        flag["content"] = content.objectId
        flag["contentCreator"] = content["creator"]
        flag.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) in
            if error == nil {
                self.incrementFlags(content)
            }
        }
    }
    
    func incrementFlags(content: PFObject) {
        content.incrementKey("flags")
        content.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) in
            if error == nil {
                self.showReportSuccessful()
            }
        }
    }
    
    func showReportSuccessful() {
        let alert = UIAlertController(title: "", message: "Channel successfully reported and will no longer be shown to you.", preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "Ok", style: .Default, handler: {(action) in
            self.navigationController?.popViewControllerAnimated(true)
        })
        alert.addAction(okButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //# MARK: - Report User
    func confirmReportUser(content: PFObject) {
        let alert = UIAlertController(title: "", message: "Really report?", preferredStyle: .Alert)
        let cancelButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
        }
        let yesButton: UIAlertAction = UIAlertAction(title: "Yes", style: .Default) { action in
            self.reportUser(content)
        }
        alert.addAction(cancelButton)
        alert.addAction(yesButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func reportUser(content: PFObject) {
        let flag = PFObject(className: "Flag")
        flag["type"] = "user"
        flag["user"] = userId
        flag["content"] = content["creator"]
        flag.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) in
            if error == nil {
                self.showReportUserSuccessful()
            }
        }
    }
    
    func showReportUserSuccessful() {
        let alert = UIAlertController(title: "", message: "User successfully reported. You will no longer see their content.", preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "Ok", style: .Default, handler: {(action) in
            self.navigationController?.popViewControllerAnimated(true)
        })
        alert.addAction(okButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //# MARK: - Table View
    func setUpTableView() {
        reportChannelTableView.dataSource = self
        reportChannelTableView.delegate = self
        automaticallyAdjustsScrollViewInsets = false
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
        showReportMenu(channel)
    }
}