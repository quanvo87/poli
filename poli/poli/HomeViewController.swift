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
        
        setUpTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationItem.title = "poli - " + network
        getPosts()
    }
    
    override func viewWillDisappear(animated: Bool) {
        posts = []
        homeTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //# MARK: - Table View
    func setUpTableView() {
        homeTableView.delegate = self
        homeTableView.dataSource = self
        homeTableView.rowHeight = UITableViewAutomaticDimension
        homeTableView.estimatedRowHeight = 80
        automaticallyAdjustsScrollViewInsets = false
    }
    
    func getPosts() {
        let userChannelQuery = PFQuery(className: "UserChannel")
        userChannelQuery.whereKey("user", equalTo: userId)
        
        let channelQuery = PFQuery(className: "Content")
        channelQuery.whereKey("type", containedIn: ["default channel", "custom channel"])
        channelQuery.whereKey("network", equalTo: network)
        channelQuery.whereKey("name", matchesKey: "name", inQuery: userChannelQuery)
        channelQuery.whereKey("flags", lessThan: 3)
        
        let postQuery = PFQuery(className: "Content")
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
        
        let date = post.createdAt! as NSDate
        cell.timeStampLabel.text = date.toString()
        
        cell.channelLabel.text = post["channel"] as? String
        
        let text = post["text"] as! NSString
        cell.postTextLabel.text = text.stringByTrimmingCharacters(144)

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let post = posts[indexPath.row]
        let flags = post["flags"] as! Int
        if flags < 3 {
            showPostDetail(post)
        } else {
            self.showAlert("This post has been flagged as inappropriate and is now closed.")
        }
    }
    
    func showPostDetail(post: PFObject) {
        if let postDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("Post Detail") as! PostDetailViewController? {
            postDetailViewController.post = post
            navigationItem.title = "Home"
            navigationController?.pushViewController(postDetailViewController, animated: true)
        }
    }
}