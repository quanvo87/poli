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
    var contents = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Me"
        setUpUI()
        setUpTableView()
    }
    
    override func viewDidAppear(animated: Bool) {
        checkIfUserIsBanned()
        getContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //# MARK: - Set Up UI
    func setUpUI() {
        self.view.backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 241/255, alpha: 1)
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
                self.contents = objects!
                self.meTableView.reloadData()
            }
        }
    }
    
    //# MARK: - Table View
    func setUpTableView() {
        meTableView.dataSource = self
        meTableView.delegate = self
        meTableView.backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 241/255, alpha: 1)
        meTableView.rowHeight = UITableViewAutomaticDimension
        meTableView.estimatedRowHeight = 80
        meTableView.separatorStyle = .None
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        meTableView.addSubview(refreshControl)
        
        automaticallyAdjustsScrollViewInsets = false
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return contents.count
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Me", forIndexPath: indexPath) as! MeTableViewCell
        let content = contents[indexPath.section]
        
        cell.timeStampLabel.text = (content.createdAt! as NSDate).toString()
        
        if content["type"] as? String == "post" {
            cell.typeLabel.text = "Post"
            cell.detailLabel.text = content["channel"] as? String
            
        } else {
            cell.typeLabel.text = "Comment"
            let query = PFQuery(className: "Content")
            query.whereKey("type", equalTo: "post")
            query.getObjectInBackgroundWithId((content["post"] as? String)!) {
                (object: PFObject?, error: NSError?) in
                if error == nil {
                    cell.detailLabel.text = object!["text"] as? String
                }
            }
        }
        
        cell.cellTextLabel.text = (content["text"] as! NSString).stringByTrimmingCharacters(200)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let postDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("Post Detail") as! PostDetailViewController? {
            let content = contents[indexPath.section]
            if content["type"] as? String == "post" {
                postDetailViewController.post = content
                self.navigationController?.pushViewController(postDetailViewController, animated: true)
            } else {
                let query = PFQuery(className: "Content")
                query.whereKey("type", equalTo: "post")
                query.getObjectInBackgroundWithId((content["post"] as? String)!) {
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