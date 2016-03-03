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
    var posts:[PFObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.homeTableView.delegate = self
        self.homeTableView.dataSource = self
        
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        getPosts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getPosts() {
        let query = PFQuery(className:"Post")
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.posts = objects!
                self.homeTableView.reloadData()
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "HomeTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! HomeTableViewCell
        let post = posts[indexPath.row]
        
        let createdAt = post.createdAt as NSDate?
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        let createdAtString = dateFormatter.stringFromDate(createdAt!)
        
        cell.postTextLabel.text = post["text"] as? String
        cell.timeStampLabel.text = createdAtString
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let postDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("PostDetail") as! PostDetailViewController? {
//            postDetailViewController.post = posts[indexPath.row]
            self.navigationController?.pushViewController(postDetailViewController, animated: true)
        }
    }
}