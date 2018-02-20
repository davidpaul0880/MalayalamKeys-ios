//
//  AppDelegate.swift
//  MalayalamEditor
//
//  Created by jijo on 12/29/14.
//  Copyright (c) 2014 jeesmon. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    var rootsplitview: UISplitViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        
        self.rootsplitview = splitViewController
        
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
        
        //copy userguide to document folder
        let arrayPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true);
        let basePath = arrayPath[0]//.stringByAppendingString("/help.html")
        
        let fmanager : FileManager = FileManager.default
        let bundle = Bundle.main;
      
        do{
            try fmanager.copyItem(atPath: bundle.path(forResource: "installation", ofType: "html")!, toPath: basePath as String);
            try fmanager.copyItem(atPath: bundle.path(forResource: "installation", ofType: "gif")!, toPath: basePath as String);
            try fmanager.copyItem(atPath: bundle.path(forResource: "help", ofType: "html")!, toPath: basePath as String);
            try fmanager.copyItem(atPath: bundle.path(forResource: "d1", ofType: "gif")!, toPath: basePath as String);
            try fmanager.copyItem(atPath: bundle.path(forResource: "d2", ofType: "gif")!, toPath: basePath as String);
            try fmanager.copyItem(atPath: bundle.path(forResource: "d3", ofType: "gif")!, toPath: basePath as String);
            try fmanager.copyItem(atPath: bundle.path(forResource: "issuevva", ofType: "png")!, toPath: basePath as String);
            try fmanager.copyItem(atPath: bundle.path(forResource: "issueyya", ofType: "png")!, toPath: basePath as String);
            try fmanager.copyItem(atPath: bundle.path(forResource: "issuempa", ofType: "png")!, toPath: basePath as String);
        } catch {
            
        }
        
        
        
        return true
    }

    func hideM(){
        
        self.rootsplitview?.preferredDisplayMode = UISplitViewControllerDisplayMode.primaryHidden
        
    }
    
    func hideMaster() {

        UIView.animate(withDuration: 0.2, delay: 0.2, options: UIViewAnimationOptions.curveEaseOut, animations: {
            
            self.hideM()
            
            }, completion:{
                
                (Bool) in self.rootsplitview?.preferredDisplayMode = UISplitViewControllerDisplayMode.automatic
                return ()
        
        })
        
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController {
                if topAsDetailController.filePath == nil {
                    // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                    return true
                }
            }
        }
        return false
    }

}

