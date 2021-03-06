//
//  AppDelegate.swift
//  poli
//
//  Created by Vo, Van-Quan N on 2/22/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Parse.enableLocalDatastore()
        Parse.setApplicationId("biIZCFM9Ca2hdZtL1g65iIJI5QsmopRYy4iBJxme", clientKey: "yrlJxRybPagTbb2rtuxnRotm1r2OyB0iGZP5mCPy")
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        Fabric.with([Crashlytics.self])
        
        Flurry.startSession("3K48PRF5G7B4KZ7CFJTF")
        Flurry.logEvent("Launched application!")
        
        logIn()
        setUpUI()
        
        return true
    }
    
    func logIn() {
        if (PFUser.currentUser() == nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let logInViewController = storyboard.instantiateViewControllerWithIdentifier("Log In") as! LogInViewController
            window?.rootViewController = logInViewController
        }
    }
    
    func setUpUI() {
        UIApplication.sharedApplication().statusBarHidden = false
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        window!.tintColor = UIColor(red: 122/255, green: 119/255, blue: 240/255, alpha: 1.0)

    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}