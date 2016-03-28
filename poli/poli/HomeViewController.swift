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
        
        let userId = PFUser.currentUser()!.objectId as String?
        let network = PFUser.currentUser()!["network"] as! String
        
        let userChannelQuery = PFQuery(className: "UserChannel")
        userChannelQuery.whereKey("user", equalTo: userId!)
        
        let channelQuery = PFQuery(className: "Channel")
        channelQuery.whereKey("name", matchesKey: "name", inQuery: userChannelQuery)
        
        let postQuery = PFQuery(className: "Post")
        postQuery.whereKey("network", equalTo: network)
        postQuery.whereKey("channel", matchesKey: "name", inQuery: channelQuery)
        postQuery.orderByDescending("createdAt")
        postQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            self.posts = objects!
            self.homeTableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Post", forIndexPath: indexPath) as! HomeTableViewCell
        let post = posts[indexPath.row]
        
        cell.postTextLabel.text = post["text"] as? String
        cell.channelLabel.text = post["channel"] as? String
        
        let createdAt = post.createdAt as NSDate?
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        let createdAtString = dateFormatter.stringFromDate(createdAt!)
        
        cell.timeStampLabel.text = createdAtString
        
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