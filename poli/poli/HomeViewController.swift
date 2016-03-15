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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getPosts() {
        
        let user = PFUser.currentUser()
        let network = user!["network"] as! String
        let userId = user!.objectId as String?
        
        let channelQuery = PFQuery(className: "Channel")
        channelQuery.whereKey("network", equalTo: network)
        channelQuery.whereKey("users", equalTo: userId!)
        
        let postQuery = PFQuery(className: "Post")
        postQuery.whereKey("channel", matchesKey: "objectId", inQuery: channelQuery)
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
        return self.posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Post", forIndexPath: indexPath) as! HomeTableViewCell
        let post = posts[indexPath.row]
        
        cell.postTextLabel.text = post["text"] as? String
        
        let createdAt = post.createdAt as NSDate?
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        let createdAtString = dateFormatter.stringFromDate(createdAt!)
        
        cell.timeStampLabel.text = createdAtString
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let postDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("Post Detail") as! PostDetailViewController? {
            postDetailViewController.post = posts[indexPath.row]
            navigationItem.title = nil
            self.navigationController?.pushViewController(postDetailViewController, animated: true)
        }
    }
}