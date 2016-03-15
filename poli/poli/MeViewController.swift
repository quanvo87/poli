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
    var cells = [PFObject]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.title = "Me"
        
        meTableView.dataSource = self
        meTableView.delegate = self
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewDidAppear(animated: Bool) {
        getCells()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getCells() {
        
        var cells = [PFObject]()
        let user = PFUser.currentUser()
        let userId = user!.objectId as String?
        
        let postQuery = PFQuery(className: "Post")
        postQuery.whereKey("creator", equalTo: userId!)
        postQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            cells.appendContentsOf(objects!)
            
            let commentQuery = PFQuery(className: "Comment")
            commentQuery.whereKey("creator", equalTo: userId!)
            commentQuery.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                cells.appendContentsOf(objects!)
                
                self.cells = cells.sort({ $0.createdAt!.compare($1.createdAt!) == .OrderedDescending })
                self.meTableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Me", forIndexPath: indexPath) as! MeTableViewCell
        let content = cells[indexPath.row]
        
        let type = content["class"] as? String
        
        if type == "post" {
            
            cell.typeLabel.text = "Post"
            cell.detailLabel.text = content["channelName"] as? String
            
        } else if type == "comment" {
            
            cell.typeLabel.text = "Comment"
            
            let query = PFQuery(className: "Post")
            query.getObjectInBackgroundWithId((content["post"] as? String)!) {
                (object: PFObject?, error: NSError?) -> Void in
                
                cell.detailLabel.text = object!["text"] as? String
            }
        }
        
        cell.cellTextLabel.text = content["text"] as? String
        
        let createdAt = content.createdAt as NSDate?
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        let createdAtString = dateFormatter.stringFromDate(createdAt!)
        
        cell.timeStampLabel.text = createdAtString
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let postDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("Post Detail") as! PostDetailViewController? {
            
            let content = cells[indexPath.row]
            let type = content["class"] as? String
            
            if type == "post" {
                
                postDetailViewController.post = content
                self.navigationController?.pushViewController(postDetailViewController, animated: true)
                
            } else if type == "comment" {
                
                let query = PFQuery(className: "Post")
                query.getObjectInBackgroundWithId((content["post"] as? String)!) {
                    (object: PFObject?, error: NSError?) -> Void in
                    
                    postDetailViewController.post = object!
                    self.navigationController?.pushViewController(postDetailViewController, animated: true)
                }
            }
        }
    }
}