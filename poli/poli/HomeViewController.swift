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
        setUpUI()
        getUserData()
        setUpTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationItem.title = ""
    }
    
    override func viewDidAppear(animated: Bool) {
        checkIfUserIsBanned()
        getPosts()
    }
    
    override func viewWillDisappear(animated: Bool) {
        posts = []
        homeTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //# MARK: - Set Up UI
    func setUpUI() {
        self.view.backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 241/255, alpha: 1)
        
        let logo = UIImage(named: "NavBarLogo.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
    //# MARK: - Get User Data
    func getUserData() {
        let user = PFUser.currentUser()
        userId = (user!.objectId as String?)!
        network = user!["network"] as! String
    }
    
    //# MARK: - Get Posts
    func getPosts() {
        let flagQuery = PFQuery(className: "Flag")
        flagQuery.whereKey("user", equalTo: userId)
        
        let userChannelQuery = PFQuery(className: "UserChannel")
        userChannelQuery.whereKey("user", equalTo: userId)
        
        let channelQuery = PFQuery(className: "Content")
        channelQuery.whereKey("type", containedIn: ["default channel", "custom channel"])
        channelQuery.whereKey("network", equalTo: network)
        channelQuery.whereKey("name", matchesKey: "name", inQuery: userChannelQuery)
        channelQuery.whereKey("flags", lessThan: 3)
        channelQuery.whereKey("creator", doesNotMatchKey: "content", inQuery: flagQuery)
        channelQuery.whereKey("objectId", doesNotMatchKey: "content", inQuery: flagQuery)
        
        let postQuery = PFQuery(className: "Content")
        postQuery.whereKey("type", equalTo: "post")
        postQuery.whereKey("network", equalTo: network)
        postQuery.whereKey("channel", matchesKey: "name", inQuery: channelQuery)
        postQuery.whereKey("flags", lessThan: 3)
        postQuery.whereKey("creator", doesNotMatchKey: "content", inQuery: flagQuery)
        postQuery.whereKey("objectId", doesNotMatchKey: "content", inQuery: flagQuery)
        postQuery.orderByDescending("createdAt")
        postQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) in
            if error == nil {
                self.posts = objects!
                self.homeTableView.reloadData()
            }
        }
    }
    
    //# MARK: - Table View
    func setUpTableView() {
        homeTableView.delegate = self
        homeTableView.dataSource = self
        homeTableView.backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 241/255, alpha: 1)
        homeTableView.rowHeight = UITableViewAutomaticDimension
        homeTableView.estimatedRowHeight = 80
        homeTableView.separatorStyle = .None
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(HomeViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        homeTableView.addSubview(refreshControl)
        
        automaticallyAdjustsScrollViewInsets = false
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return posts.count
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Post", forIndexPath: indexPath) as! HomeTableViewCell
        let post = posts[indexPath.section]
        cell.channelLabel.text = post["channel"] as? String
        cell.timeStampLabel.text = (post.createdAt! as NSDate).toString()
        cell.postTextLabel.text = post["text"] as? String
        cell.commentsCountLabel.text = (post["comments"] as! Int).stringNumberOfContents("comment")
        cell.accessoryType = .None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let post = posts[indexPath.section]
        let flags = post["flags"] as! Int
        if flags < 3 {
            showPostDetail(post)
        } else {
            self.showAlert("This post has been flagged as inappropriate and is now closed.")
            getPosts()
        }
    }
    
    func showPostDetail(post: PFObject) {
        if let postDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("Post Detail") as! PostDetailViewController? {
            postDetailViewController.post = post
            navigationItem.title = "Home"
            navigationController?.pushViewController(postDetailViewController, animated: true)
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        getPosts()
        refreshControl.endRefreshing()
    }
}