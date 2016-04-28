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
        navigationItem.title = "Report A Channel"
        setUpUI()
        getUserData()
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
    
    //# MARK: - Get User Data
    func getUserData() {
        let user = PFUser.currentUser()
        userId = (user?.objectId)!
        network = user!["network"] as! String
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
            (objects: [PFObject]?, error: NSError?) in
            if error == nil {
                self.channels = objects!
                self.reportChannelTableView.reloadData()
            }
        }
    }
    
    //# MARK: - Report
    func showReportMenu(content: PFObject) {
        let alert = UIAlertController(title: "Inappropriate content?", message: nil, preferredStyle: .Alert)
        let reportContentButton = UIAlertAction(title: "Report Channel", style: .Default, handler: { action in
            self.confirmReportContent(content)
        })
        let reportUserButton = UIAlertAction(title: "Report User", style: .Default, handler: { action in
            self.confirmReportUser(content)
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        }
        alert.addAction(reportContentButton)
        alert.addAction(reportUserButton)
        alert.addAction(cancelButton)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //# MARK: - Report Channel
    func confirmReportContent(content: PFObject) {
        let alert = UIAlertController(title: "", message: "Really report?", preferredStyle: .Alert)
        let cancelButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
        }
        let yesButton: UIAlertAction = UIAlertAction(title: "Yes", style: .Default) { action in
            self.reportContent(content)
        }
        alert.addAction(cancelButton)
        alert.addAction(yesButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func reportContent(content: PFObject) {
        createFlag(content)
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
        let alert = UIAlertController(title: "", message: "Channel successfully reported.", preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "Ok", style: .Default, handler: { action in
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
        let alert = UIAlertController(title: "", message: "User successfully reported.", preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "Ok", style: .Default, handler: { action in
            self.navigationController?.popViewControllerAnimated(true)
        })
        alert.addAction(okButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //# MARK: - Table View
    func setUpTableView() {
        reportChannelTableView.dataSource = self
        reportChannelTableView.delegate = self
        reportChannelTableView.backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 241/255, alpha: 1)
        reportChannelTableView.separatorStyle = .None
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ReportChannelTableViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        reportChannelTableView.addSubview(refreshControl)
        
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Report Channel Cell", forIndexPath: indexPath) as! ReportChannelTableViewCell
        cell.channelNameLabel.text = channels[indexPath.section]["name"] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let channel = channels[indexPath.section]
        showReportMenu(channel)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        getChannels()
        refreshControl.endRefreshing()
    }
}