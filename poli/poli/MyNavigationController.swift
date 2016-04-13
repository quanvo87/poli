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
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
//        UIApplication.sharedApplication().statusBarStyle = .LightContent

        // gradient
        let gradientLayer = CAGradientLayer()
        let purpleColor = UIColor(red: 122/255.0, green: 119/255.0, blue: 240/255.0,alpha: 1.0)
        let greenColor = UIColor(red: 109/255.0, green: 215/255.0, blue: 196/255.0,alpha: 1.0)
        gradientLayer.frame = navigationBar.bounds
        gradientLayer.colors =  [purpleColor, greenColor].map{$0.CGColor}
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // Render the gradient to UIImage
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Set the UIImage as background property
        navigationBar.setBackgroundImage(image, forBarMetrics: UIBarMetrics.Default)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
