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
    var objects = ["Setup & Usage", "User Guide", "About", "Review in iTunes"]//NSMutableArray(), "Preview"


    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let titleDict: NSDictionary = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [NSAttributedStringKey : AnyObject]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.tableView.rowHeight = 100
        // Do any additional setup after loading the view, typically from a nib.
        /*self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        */
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let indexPath = sender as? IndexPath {
            
            
            
            
            if (indexPath as NSIndexPath).row == 0 {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.modeDisplay = (indexPath as NSIndexPath).row
                let object = Bundle.main.path(forResource: "installation", ofType: "html")
                
                
                
                controller.filePath = object
            }
            else if (indexPath as NSIndexPath).row == 1 {
                let object = Bundle.main.path(forResource: "help", ofType: "html")
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.modeDisplay = (indexPath as NSIndexPath).row
                controller.filePath = object
                
            }
            else if (indexPath as NSIndexPath).row == 2 {
                let object = Bundle.main.path(forResource: "info", ofType: "html")
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.modeDisplay = (indexPath as NSIndexPath).row
                controller.filePath = object
                
            }else if (indexPath as NSIndexPath).row == 3 {
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.modeDisplay = (indexPath as NSIndexPath).row
                let iTunesLink = "itms-apps://itunes.apple.com/app/id957578340";
                UIApplication.shared.openURL(URL(string: iTunesLink)!)
                
                self.tableView.deselectRow(at: indexPath, animated: false)
                
                controller.filePath = nil;
            } else if (indexPath as NSIndexPath).row == 4 {
                
            }
            
            if (indexPath as NSIndexPath).row < 3 {
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.modeDisplay = (indexPath as NSIndexPath).row
                
                
                //controller.configureView()
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                
                let orientation = UIApplication.shared.statusBarOrientation
                
                if orientation.isPortrait {
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.hideMaster()
                    // Portrait
                } else {
                    // Landscape
                }

            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        
        let viewBg: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100))
        viewBg.backgroundColor = UIColor(red: 200/255, green: 120/255, blue: 0/255, alpha: 1)
        cell.selectedBackgroundView = viewBg
        
        let object = objects[(indexPath as NSIndexPath).row] as String
        cell.textLabel!.textColor = UIColor(red: 200/255, green: 120/255, blue: 0/255, alpha: 1)
        cell.textLabel!.textAlignment = NSTextAlignment.center
        cell.textLabel!.text = object
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).row == 4 {
            self.performSegue(withIdentifier: "ShowKeyboardPreview", sender: indexPath)
        }else {
        self.performSegue(withIdentifier: "ShowWebDetail", sender: indexPath)
        }
    }

}

