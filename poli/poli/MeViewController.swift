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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.title = "Me"
        
        meTableView.dataSource = self
        meTableView.delegate = self
        meTableView.rowHeight = UITableViewAutomaticDimension
        meTableView.estimatedRowHeight = 80
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewDidAppear(animated: Bool) {
        getPosts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getPosts() {
        
        let user = PFUser.currentUser()
        let userId = user!.objectId as String?
        
        let query = PFQuery(className: "Post")
        query.whereKey("creator", equalTo: userId!)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                self.posts = objects!
                self.meTableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Me", forIndexPath: indexPath) as! MeTableViewCell
        let post = posts[indexPath.row]
        
        let createdAt = post.createdAt as NSDate?
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        let createdAtString = dateFormatter.stringFromDate(createdAt!)
        cell.timeStampLabel.text = createdAtString
        
        let type = post["type"] as? String
        if type == "post" {
            
            cell.typeLabel.text = "Post"
            cell.detailLabel.text = post["channel"] as? String
            
        } else {
            
            cell.typeLabel.text = "Comment"
            
            let query = PFQuery(className: "Post")
            query.getObjectInBackgroundWithId((post["post"] as? String)!) {
                (object: PFObject?, error: NSError?) -> Void in
                
                if error == nil {
                    cell.detailLabel.text = object!["text"] as? String
                }
            }
        }
        
        let text = post["text"] as? NSString
        if text!.length > 144 {
            cell.cellTextLabel.text = "\(text!.substringToIndex(144))..."
        } else {
            cell.cellTextLabel.text = text as? String
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let postDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("Post Detail") as! PostDetailViewController? {
            
            let post = posts[indexPath.row]
            let type = post["type"] as? String
            
            if type == "post" {
                
                postDetailViewController.post = post
                self.navigationController?.pushViewController(postDetailViewController, animated: true)
                
            } else {
                
                let query = PFQuery(className: "Post")
                query.getObjectInBackgroundWithId((post["post"] as? String)!) {
                    (object: PFObject?, error: NSError?) -> Void in
                    
                    if error == nil {
                        postDetailViewController.post = object!
                        self.navigationController?.pushViewController(postDetailViewController, animated: true)
                    }
                }
            }
        }
    }
}