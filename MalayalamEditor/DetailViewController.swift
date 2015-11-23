//
//  DetailViewController.swift
//  VaramozhiEditor
//
//  Created by jijo pulikkottil on 12/23/14.
//  Copyright (c) 2014 jeesmon. All rights reserved.
//
import iAd
import UIKit


class DetailViewController: UIViewController , UIWebViewDelegate, ADBannerViewDelegate {
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var bottomLayout: NSLayoutConstraint!
    
    @IBOutlet weak var topLayout: NSLayoutConstraint!
    var bannerView: ADBannerView!
    
    var modeDisplay: Int = 0
    
    var filePath: String? {
        didSet {
            // Update the view.
            //self.configureView()
        }
    }
    
    func configureView() {
        
        
        if modeDisplay == 0 {
            
            self.title = "Setup & Usage"
            
            
        }else if modeDisplay == 1 {
            
            self.title = "User Guide"
            
        }else if modeDisplay == 2 {
            
            self.title = "About"
        }else {
            self.title = ""
        }
        
        if let detail: String = self.filePath {
            
            /*if modeDisplay == 0 {
                if webView != nil {
                    let arrayPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true);
                    let basepath = arrayPath[0]
                    print(basepath)
                    //let fm = NSFileManager.defaultManager();
                    //fm.copyItemAtURL(<#T##srcURL: NSURL##NSURL#>, toURL: <#T##NSURL#>)
                    let url = NSURL(fileURLWithPath: "\(basepath)/installation.html")
                    webView.loadRequest(NSURLRequest(URL: url))
                }
            }
            else if modeDisplay == 1 {
                if webView != nil {
                    let arrayPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true);
                    let basepath = arrayPath[0]
                    print(basepath)
                    //let fm = NSFileManager.defaultManager();
                    //fm.copyItemAtURL(<#T##srcURL: NSURL##NSURL#>, toURL: <#T##NSURL#>)
                    let url = NSURL(fileURLWithPath: "\(basepath)/help.html")
                    webView.loadRequest(NSURLRequest(URL: url))
                }
            } else {*/
                if webView != nil && modeDisplay < 3{
                    let url = NSURL(fileURLWithPath: detail)
                    webView.loadRequest(NSURLRequest(URL: url))
                }
           // }
            
            
        }
        
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
       
        bannerView = ADBannerView(adType: .Banner)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.delegate = self
        bannerView.hidden = true
        view.addSubview(bannerView)
        
        let viewsDictionary = ["bannerView": bannerView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bannerView]|", options: [], metrics: nil, views: viewsDictionary))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[bannerView]|", options: [], metrics: nil, views: viewsDictionary))
        
        self.edgesForExtendedLayout = UIRectEdge.None
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        //let isPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
        if self.filePath == nil {
            self.filePath = NSBundle.mainBundle().pathForResource("installation", ofType: "html")
        }
        self.configureView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        activity.startAnimating()
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView){
        
        activity.stopAnimating()
    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?){
        
        activity.stopAnimating()
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        print("banner loaded")
        bottomLayout.constant = -(banner.frame.size.height)
        bannerView.hidden = false
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        print("banner ntot loaded")
        bottomLayout.constant = 0
        bannerView.hidden = true
    }
}

