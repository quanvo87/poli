//
//  HomeViewController.swift
//  poli
//
//  Created by Vo, Van-Quan N on 2/24/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var homeTableView: UITableView!
    var posts = [PFObject]()
    var userId = String()
    var network = String()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let user = PFUser.currentUser()
        userId = (user!.objectId as String?)!
        network = user!["network"] as! String
        
        homeTableView.delegate = self
        homeTableView.dataSource = self
        homeTableView.rowHeight = UITableViewAutomaticDimension
        homeTableView.estimatedRowHeight = 80
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(animated: Bool) {
        
        navigationItem.title = "poli"
        getPosts()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        posts = []
        homeTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getPosts() {
        
        let userChannelQuery = PFQuery(className: "UserChannel")
        userChannelQuery.whereKey("user", equalTo: userId)
        
        let channelQuery = PFQuery(className: "Channel")
        channelQuery.whereKey("network", equalTo: network)
        channelQuery.whereKey("name", matchesKey: "name", inQuery: userChannelQuery)
        
        let postQuery = PFQuery(className: "Post")
        postQuery.whereKey("type", equalTo: "post")
        postQuery.whereKey("channel", matchesKey: "name", inQuery: channelQuery)
        postQuery.whereKey("flags", lessThan: 3)
        postQuery.orderByDescending("createdAt")
        postQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                self.posts = objects!
                self.homeTableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Post", forIndexPath: indexPath) as! HomeTableViewCell
        let post = posts[indexPath.row]
        
        cell.channelLabel.text = post["channel"] as? String
        
        let createdAt = post.createdAt as NSDate?
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        let createdAtString = dateFormatter.stringFromDate(createdAt!)
        cell.timeStampLabel.text = createdAtString
        
        let text = post["text"] as? NSString
        if text!.length > 144 {
            cell.postTextLabel.text = "\(text!.substringToIndex(144))..."
        } else {
            cell.postTextLabel.text = text as? String
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let post = posts[indexPath.row]
        let flags = post["flags"] as! Int
        if flags > 2 {
            showPostClosed()
        } else {
            if let postDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("Post Detail") as! PostDetailViewController? {
                postDetailViewController.post = post
                navigationItem.title = "Home"
                navigationController?.pushViewController(postDetailViewController, animated: true)
            }
        }
    }
    
    func showPostClosed() {
        
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: "This post has been flagged as inappropriate and is now closed.", preferredStyle: .Alert)
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
            navigationController?.popViewControllerAnimated(true)
        }
        actionSheetController.addAction(okAction)
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
}