//
//  MyNavigationController.swift
//  poli
//
//  Created by Vo, Van-Quan N on 4/13/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class MyNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setUpUI() {
        let navBackgroundImage:UIImage! = UIImage(named: "NavBarBackground.png")
        UINavigationBar.appearance().setBackgroundImage(navBackgroundImage, forBarMetrics: .Default)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        navigationBar.tintColor = UIColor.whiteColor()
    }
}
