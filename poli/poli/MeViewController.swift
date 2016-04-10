//
//  MeViewController.swift
//  poli
//
//  Created by Vo, Van-Quan N on 3/7/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class MeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var meTableView: UITableView!
    var posts = [PFObject]()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MeViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Me"
        setUpTableView()
    }
    
    override func viewDidAppear(animated: Bool) {
        checkIfUserIsBanned()
        getContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //# MARK: - Get Content
    func getContent() {
        let user = PFUser.currentUser()
        let userId = user!.objectId as String?
        let query = PFQuery(className: "Content")
        query.whereKey("type", containedIn: ["post", "comment"])
        query.whereKey("creator", equalTo: userId!)
        query.whereKey("flags", lessThan: 3)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) in
            if error == nil {
                self.posts = objects!
                self.meTableView.reloadData()
            }
        }
    }
    
    //# MARK: - Table View
    func setUpTableView() {
        meTableView.dataSource = self
        meTableView.delegate = self
        meTableView.rowHeight = UITableViewAutomaticDimension
        meTableView.estimatedRowHeight = 80
        meTableView.addSubview(self.refreshControl)
        automaticallyAdjustsScrollViewInsets = false
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Me", forIndexPath: indexPath) as! MeTableViewCell
        let post = posts[indexPath.row]
        
        cell.timeStampLabel.text = (post.createdAt! as NSDate).toString()
        
        if post["type"] as? String == "post" {
            cell.typeLabel.text = "Post"
            cell.detailLabel.text = post["channel"] as? String
            
        } else {
            cell.typeLabel.text = "Comment"
            let query = PFQuery(className: "Content")
            query.whereKey("type", equalTo: "post")
            query.getObjectInBackgroundWithId((post["post"] as? String)!) {
                (object: PFObject?, error: NSError?) in
                if error == nil {
                    cell.detailLabel.text = object!["text"] as? String
                }
            }
        }
        
        cell.cellTextLabel.text = (post["text"] as! NSString).stringByTrimmingCharacters(144)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let postDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("Post Detail") as! PostDetailViewController? {
            let post = posts[indexPath.row]
            
            if post["type"] as? String == "post" {
                postDetailViewController.post = post
                self.navigationController?.pushViewController(postDetailViewController, animated: true)
                
            } else {
                let query = PFQuery(className: "Content")
                query.whereKey("type", equalTo: "post")
                query.getObjectInBackgroundWithId((post["post"] as? String)!) {
                    (object: PFObject?, error: NSError?) in
                    if error == nil {
                        postDetailViewController.post = object!
                        self.navigationController?.pushViewController(postDetailViewController, animated: true)
                    }
                }
            }
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        getContent()
        refreshControl.endRefreshing()
    }
}