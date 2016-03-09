//
//  ChannelsViewController.swift
//  poli
//
//  Created by Vo, Van-Quan N on 3/7/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class ChannelsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var channelsTableView: UITableView!
    var channels:[PFObject] = []
    var selectedChannels:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Channels"

        channelsTableView.dataSource = self
        channelsTableView.delegate = self
        automaticallyAdjustsScrollViewInsets = false
    }

//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapSelectAll(sender: AnyObject) {
    }
    
    @IBAction func tapUnselectAll(sender: AnyObject) {
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Post", forIndexPath: indexPath) as! HomeTableViewCell
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }

}
