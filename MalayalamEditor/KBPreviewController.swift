//
//  KBPreviewController.swift
//  MalayalamEditor
//
//  Created by jijo Pulikkottil on 11/08/16.
//  Copyright © 2016 jeesmon. All rights reserved.
//

import UIKit
import MalayalamKB

class KBPreviewController: UIViewController {

    @IBOutlet weak var txtField: UITextView!
    let kb = KeyboardViewController()
    override func viewDidLoad() {
        super.viewDidLoad()

        let height = heightForOrientation(true)
        //self.addChildViewController(kb)
        var safeAreaBottom: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            if let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom { // iPhone X
                safeAreaBottom = bottom
            }
        }
        kb.view.frame = CGRect(x: 0, y: self.view.frame.size.height - height - safeAreaBottom, width: self.view.frame.size.width, height: height)//352
        //let txt = UITextField(frame:CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width, height))
        //kb.inputAccessoryView = txt
        txtField.inputView = kb.inputView
        
        
//        if #available(iOS 11.0, *) {
//            if let _ = UIApplication.shared.keyWindow?.safeAreaInsets.bottom { // iPhone X
//                txtField.inputAccessoryView = kb.inputView
//            } else {
//                txtField.inputView = kb.inputView
//            }
//        } else {
//            txtField.inputView = kb.inputView
//        }
        //self.view.addSubview(kb.view)
        // Do any additional setup after loading the view.
    }

    func heightForOrientation(_ withTopBanner: Bool) -> CGFloat {
        let isPad = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
        
        //+20151123
        let screenSize = UIScreen.main.bounds.size
        let screenH = screenSize.height
        let screenW = screenSize.width
        
        let isLandscape =  !(self.view.frame.size.width == (screenW * ((screenW < screenH) ? 1 : 0) + screenH * ((screenW > screenH) ? 1 : 0)))
        
        KeyboardViewController.workaroundClassVariable = isLandscape
        
        
        //TODO: hardcoded stuff
        let actualScreenWidth = (UIScreen.main.nativeBounds.size.width / UIScreen.main.nativeScale)
        //let canonicalPortraitHeight = (isPad ? CGFloat(264) : CGFloat(orientation.isPortrait && actualScreenWidth >= 400 ? 226 : 216))
        let canonicalPortraitHeight = (isPad ? CGFloat(264) : CGFloat(!isLandscape && actualScreenWidth >= 400 ? 226 : 216))
        let canonicalLandscapeHeight = (isPad ? CGFloat(352) : CGFloat(162))
        let topBannerHeight: CGFloat = (withTopBanner ? 30.0 : 0.0)
        //KeyboardViewController.workaroundClassVariable = orientation.isLandscape
        
        return CGFloat(!isLandscape ? canonicalPortraitHeight + topBannerHeight : canonicalLandscapeHeight + topBannerHeight)
        
        //return CGFloat(orientation.isPortrait ? canonicalPortraitHeight  + topBannerHeight  : canonicalLandscapeHeight  + topBannerHeight )
        
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
