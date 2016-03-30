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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        homeTableView.delegate = self
        homeTableView.dataSource = self
        automaticallyAdjustsScrollViewInsets = false
        homeTableView.rowHeight = UITableViewAutomaticDimension
        homeTableView.estimatedRowHeight = 80
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
        
        let user = PFUser.currentUser()
        let userId = user!.objectId as String?
        let network = user!["network"] as! String
        
        let userChannelQuery = PFQuery(className: "UserChannel")
        userChannelQuery.whereKey("user", equalTo: userId!)
        
        let channelQuery = PFQuery(className: "Channel")
        channelQuery.whereKey("network", equalTo: network)
        channelQuery.whereKey("name", matchesKey: "name", inQuery: userChannelQuery)
        
        let postQuery = PFQuery(className: "Post")
        postQuery.whereKey("type", equalTo: "post")
        postQuery.whereKey("channel", matchesKey: "name", inQuery: channelQuery)
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
        
        if let postDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("Post Detail") as! PostDetailViewController? {
            
            postDetailViewController.post = posts[indexPath.row]
            navigationItem.title = "Home"
            self.navigationController?.pushViewController(postDetailViewController, animated: true)
        }
    }
}