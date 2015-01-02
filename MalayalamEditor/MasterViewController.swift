//
//  MasterViewController.swift
//  MalayalamEditor
//
//  Created by jijo on 12/29/14.
//  Copyright (c) 2014 jeesmon. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = ["How to Install", "User Guide", "About"]//NSMutableArray(), "Preview"


    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.tableView.rowHeight = 100
        // Do any additional setup after loading the view, typically from a nib.
        /*self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        */
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            
            
            let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
            controller.modeDisplay = indexPath.row
            
            if indexPath.row == 0 {
                
                let object = NSBundle.mainBundle().pathForResource("installation", ofType: "html")
                
                
                
                controller.filePath = object
            }
            else if indexPath.row == 1 {
                let object = NSBundle.mainBundle().pathForResource("help", ofType: "html")
                
                
                
                controller.filePath = object
                
            }
            else if indexPath.row == 2 {
                let object = NSBundle.mainBundle().pathForResource("info", ofType: "html")
                
                
                
                controller.filePath = object
                
            }
            //controller.configureView()
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
            
            
                let orientation = UIApplication.sharedApplication().statusBarOrientation
                
                if orientation.isPortrait {
                    
                    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                    appDelegate.hideMaster()
                    // Portrait
                } else {
                    // Landscape
                }
            
            
            
            
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        let viewBg: UIView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 100))
        viewBg.backgroundColor = UIColor(red: 250/255, green: 150/255, blue: 10/255, alpha: 1)
        cell.selectedBackgroundView = viewBg
        
        let object = objects[indexPath.row] as String
        cell.textLabel!.textColor = UIColor(red: 250/255, green: 150/255, blue: 10/255, alpha: 1) 
        cell.textLabel!.textAlignment = NSTextAlignment.Center
        cell.textLabel!.text = object
        
        return cell
    }


}

