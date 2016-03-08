//
//  ChannelPickerViewController.swift
//  poli
//
//  Created by Vo, Van-Quan N on 3/7/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class ChannelPickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var channelsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        channelsTableView.dataSource = self
        channelsTableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
}