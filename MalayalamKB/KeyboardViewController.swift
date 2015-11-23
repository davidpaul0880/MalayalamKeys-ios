//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Alexei Baboulevitch on 6/9/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit
import AudioToolbox
//import CoreData //+20150325
let timeForKoottaksharamShortcut = 0.7
let timeForPopupDisplay = 0.3

let metrics: [String:Float] = [
    "topBanner": 30
]
func metric(name: String) -> CGFloat {
    
    //+20141231
    if NSUserDefaults.standardUserDefaults().boolForKey(kDisablePopupKeys) {
        return 0
    }else{
        //+20150325
        if UIDevice.currentDevice().userInterfaceIdiom != UIUserInterfaceIdiom.Pad {
            return CGFloat(metrics[name]!)
        } else {
            return CGFloat(metrics[name]!) * 1.3
        }
    }
}

// TODO: move this somewhere else and localize
//let kAutoCapitalization = "kAutoCapitalization"
let kPeriodShortcut = "kPeriodShortcut"
let kKeyboardClicks = "kKeyboardClicks"
let kDisablePopupKeys = "kDisablePopupKeys"
//let kKoottaksharamShortcut = "kKoottaksharamShortcut" //m+20150109
let kCapitalizeSwarangal = "kCapitalizeSwarangal"
//let kKeyPadMalayalam = "kKeyPadMalayalam"

class KeyboardViewController: UIInputViewController, KeyboardKeyExtentionProtocol {
    
    let backspaceDelay: NSTimeInterval = 0.5
    let backspaceRepeat: NSTimeInterval = 0.07
    
    var keyboard: Keyboard!
    var forwardingView: ForwardingView!
    var layout: KeyboardLayout?
    var heightConstraint: NSLayoutConstraint?
    
    var bannerView: ExtraView? //+20150325
    var settingsView: ExtraView?
    
    //m+20150325
    var typedKeys:String = ""
    
    
    var currentMode: Int {
        didSet {
            //+20150102if oldValue != currentMode {
                setMode(currentMode)
            //}
        }
    }
    
    var backspaceActive: Bool {
        get {
            return (backspaceDelayTimer != nil) || (backspaceRepeatTimer != nil)
        }
    }
    var backspaceDelayTimer: NSTimer?
    var backspaceRepeatTimer: NSTimer?
    
    enum AutoPeriodState {
        case NoSpace
        case FirstSpace
    }
    
    var autoPeriodState: AutoPeriodState = .NoSpace
    var lastCharCountInBeforeContext: Int = 0
    //m+20150101
    var chandrakkaladoubletapped: Bool = false
    var lastchar: String = ""
    var lastKey: Key?
    //var lasttime: Double = 0
    
    enum ShiftState {
        case Disabled
        case Enabled
        case Locked
        
        func uppercase() -> Bool {
            switch self {
            case Disabled:
                return false
            case Enabled:
                return true
            case Locked:
                return true
            }
        }
    }
    var shiftState: ShiftState {
        didSet {
            switch shiftState {
            case .Disabled:
                self.updateKeyCaps(true)
            case .Enabled:
                self.updateKeyCaps(false)
            case .Locked:
                self.updateKeyCaps(false)
            }
        }
    }
    
    var shiftWasMultitapped: Bool = false
    
    var keyboardHeight: CGFloat {
        get {
            if let constraint = self.heightConstraint {
                return constraint.constant
            }
            else {
                return 0
            }
        }
        set {
            self.setHeight(newValue)
        }
    }
    
    // TODO: why does the app crash if this isn't here?
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        NSUserDefaults.standardUserDefaults().registerDefaults([
            //kAutoCapitalization: false, //+20141218
            //kKeyPadMalayalam: false,
            kPeriodShortcut: true,
            //kKoottaksharamShortcut: true, //m+20150109
            kCapitalizeSwarangal: true,
            kKeyboardClicks: true,
            kDisablePopupKeys: false
        ])
        //+roll
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: kDisablePopupKeys)
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: kPeriodShortcut)
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: kCapitalizeSwarangal)
        //NSUserDefaults.standardUserDefaults().setBool(true, forKey: kKoottaksharamShortcut)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: kKeyboardClicks)
        
        self.keyboard = defaultKeyboard()
        
        self.shiftState = .Disabled
        self.currentMode = 0
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.forwardingView = ForwardingView(frame: CGRectZero)
        self.view.addSubview(self.forwardingView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("defaultsChanged:"), name: NSUserDefaultsDidChangeNotification, object: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    deinit {
        
        backspaceDelayTimer?.invalidate()
        backspaceRepeatTimer?.invalidate()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func defaultsChanged(notification: NSNotification) {
        //let defaults = notification.object as! NSUserDefaults
        self.updateKeyCaps(!self.shiftState.uppercase())
    }
    
    // without this here kludge, the height constraint for the keyboard does not work for some reason
    var kludge: UIView?
    func setupKludge() {
        if self.kludge == nil {
            let kludge = UIView()
            self.view.addSubview(kludge)
            kludge.translatesAutoresizingMaskIntoConstraints = false
            kludge.hidden = true
            
            let a = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
            let b = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
            let c = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            let d = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            self.view.addConstraints([a, b, c, d])
            
            self.kludge = kludge
        }
    }
    
    /*
    BUG NOTE

    For some strange reason, a layout pass of the entire keyboard is triggered 
    whenever a popup shows up, if one of the following is done:

    a) The forwarding view uses an autoresizing mask.
    b) The forwarding view has constraints set anywhere other than init.

    On the other hand, setting (non-autoresizing) constraints or just setting the
    frame in layoutSubviews works perfectly fine.

    I don't really know what to make of this. Am I doing Autolayout wrong, is it
    a bug, or is it expected behavior? Perhaps this has to do with the fact that
    the view's frame is only ever explicitly modified when set directly in layoutSubviews,
    and not implicitly modified by various Autolayout constraints
    (even though it should really not be changing).
    */
    
    var constraintsAdded: Bool = false
    func setupLayout() {
        if !constraintsAdded {
            self.layout = self.dynamicType.layoutClass.init(model: self.keyboard, superview: self.forwardingView, layoutConstants: self.dynamicType.layoutConstants, globalColors: self.dynamicType.globalColors, darkMode: self.darkMode(), solidColorMode: self.solidColorMode())
            
            self.layout?.initialize()
            self.setupKeys()
            self.setMode(0)
            
            self.setupKludge()
            
            self.updateKeyCaps(!self.shiftState.uppercase())
            self.setCapsIfNeeded()
            
            self.updateAppearances(self.darkMode())
            self.addInputTraitsObservers()
            
            self.constraintsAdded = true
        }
    }
    
    // only available after frame becomes non-zero
    func darkMode() -> Bool {
        let darkMode = { () -> Bool in
            let proxy = self.textDocumentProxy 
            return proxy.keyboardAppearance == UIKeyboardAppearance.Dark
            
        }()
        
        return darkMode
    }
    
    func solidColorMode() -> Bool {
        //return true //TODO: temporary, until vibrancy performance is fixed +roll ?
        
        return UIAccessibilityIsReduceTransparencyEnabled()
        //return UIAccessibilityIsReduceTransparencyEnabled()
    }
    
    var lastLayoutBounds: CGRect?
    override func viewDidLayoutSubviews() {
        if view.bounds == CGRectZero {
            return
        }
        
        self.setupLayout()
        
        let orientationSavvyBounds = CGRectMake(0, 0, self.view.bounds.width, self.heightForOrientation(false))//+20151021
        if (lastLayoutBounds != nil && lastLayoutBounds == orientationSavvyBounds) {
            // do nothing
        }
        else {
            self.forwardingView.frame = orientationSavvyBounds
            self.layout?.layoutTemp()
            self.lastLayoutBounds = orientationSavvyBounds
        }
        
        self.bannerView?.frame = CGRectMake(0, 0, self.view.bounds.width, metric("topBanner"))//+20150325
        
        let newOrigin = CGPointMake(0, self.view.bounds.height - self.forwardingView.bounds.height)
        self.forwardingView.frame.origin = newOrigin
    }
    
    override func loadView() {
        super.loadView()
        
        //+20150325
        if let aBanner = self.createBanner() {
            aBanner.hidden = true
            self.view.insertSubview(aBanner, belowSubview: self.forwardingView)
            self.bannerView = aBanner
        }
        
        //+20151023 to fix crash when click on settings button after types 3-4 lines
        /*self.settingsView = createSettings()
        self.settingsView!.darkMode = self.darkMode()
        
        self.settingsView!.hidden = true
        self.view.addSubview(self.settingsView!)
       
        self.settingsView!.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(item: self.settingsView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: self.settingsView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: self.settingsView!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: self.settingsView!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        
        self.view.addConstraint(widthConstraint)
        self.view.addConstraint(heightConstraint)
        self.view.addConstraint(centerXConstraint)
        self.view.addConstraint(centerYConstraint)
        */
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.bannerView?.hidden = false //+20150325
        self.keyboardHeight = self.heightForOrientation(false)//+20151123
    }
    
    /*override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        // optimization: ensures quick mode and shift transitions
        if let keyPool = self.layout?.keyPool {
            for view in keyPool {
                view.shouldRasterize = false
            }
        }
    }*/
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.forwardingView.resetTrackedViews()
        //self.shiftStartingState = nil
        self.shiftWasMultitapped = false
        
        // optimization: ensures smooth animation
        /*if let keyPool = self.layout?.keyPool {
            for view in keyPool {
                view.shouldRasterize = true
            }
        }*/
        
        self.keyboardHeight = self.heightForOrientation(toInterfaceOrientation, withTopBanner: false)//+20151123
    }
    /*+20150421override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.keyboardHeight = self.heightForOrientation(toInterfaceOrientation, withTopBanner: true)
    }*/
    /*override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator){
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        self.keyboardHeight = self.heightForOrientation(UIDevice.currentDevice().orientation, withTopBanner: true)
    }*/
    //+20141217
    // Workaround:
    private struct SubStruct { static var staticVariable: Bool = false }
    
    class var workaroundClassVariable: Bool
    {
        get { return SubStruct.staticVariable }
        set { SubStruct.staticVariable = newValue }
    }
    class func isLanscapeKB() -> Bool {
        
        return workaroundClassVariable
    }
    
    func heightForOrientation(orientation: UIInterfaceOrientation, withTopBanner: Bool) -> CGFloat {
        let isPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
        
               //TODO: hardcoded stuff
        let actualScreenWidth = (UIScreen.mainScreen().nativeBounds.size.width / UIScreen.mainScreen().nativeScale)
        let canonicalPortraitHeight = (isPad ? CGFloat(264) : CGFloat(orientation.isPortrait && actualScreenWidth >= 400 ? 226 : 216))
        let canonicalLandscapeHeight = (isPad ? CGFloat(352) : CGFloat(162))
        let topBannerHeight = (withTopBanner ? metric("topBanner") : 0)
        KeyboardViewController.workaroundClassVariable = orientation.isLandscape
        
        return CGFloat(orientation.isPortrait ? canonicalPortraitHeight  + topBannerHeight  : canonicalLandscapeHeight  + topBannerHeight )
        
    }
    
    func heightForOrientation(withTopBanner: Bool) -> CGFloat {
        let isPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
        
        //+20151123
        let screenSize = UIScreen.mainScreen().bounds.size
        let screenH = screenSize.height
        let screenW = screenSize.width
        let isLandscape =  !(self.view.frame.size.width == screenW * ((screenW < screenH) ? 1 : 0) + screenH * ((screenW > screenH) ? 1 : 0))
        KeyboardViewController.workaroundClassVariable = isLandscape
        
        
        //TODO: hardcoded stuff
        let actualScreenWidth = (UIScreen.mainScreen().nativeBounds.size.width / UIScreen.mainScreen().nativeScale)
        //let canonicalPortraitHeight = (isPad ? CGFloat(264) : CGFloat(orientation.isPortrait && actualScreenWidth >= 400 ? 226 : 216))
        let canonicalPortraitHeight = (isPad ? CGFloat(264) : CGFloat(!isLandscape && actualScreenWidth >= 400 ? 226 : 216))
        let canonicalLandscapeHeight = (isPad ? CGFloat(352) : CGFloat(162))
        let topBannerHeight = (withTopBanner ? metric("topBanner") : 0)
        //KeyboardViewController.workaroundClassVariable = orientation.isLandscape
        
        
        return CGFloat(!isLandscape ? canonicalPortraitHeight  + topBannerHeight  : canonicalLandscapeHeight  + topBannerHeight )
        
        //return CGFloat(orientation.isPortrait ? canonicalPortraitHeight  + topBannerHeight  : canonicalLandscapeHeight  + topBannerHeight )
        
    }
    
    
    
    /*
    BUG NOTE

    None of the UIContentContainer methods are called for this controller.
    */
    
    //override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    //    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    //}
    
    func setupKeys() {
        if self.layout == nil {
            return
        }
        
        for page in keyboard.pages {
            for rowKeys in page.rows { // TODO: quick hack
                for key in rowKeys {
                    let keyView = self.layout!.viewForKey(key)! // TODO: check
                    
                    keyView.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)//+201412
                    
                    switch key.type {
                    case Key.KeyType.KeyboardChange:
                        keyView.addTarget(self, action: "advanceTapped:", forControlEvents: .TouchUpInside)
                    case Key.KeyType.Backspace:
                        let cancelEvents: UIControlEvents = [UIControlEvents.TouchUpInside, UIControlEvents.TouchUpInside, UIControlEvents.TouchDragExit, UIControlEvents.TouchUpOutside, UIControlEvents.TouchCancel, UIControlEvents.TouchDragOutside]
                        
                        keyView.addTarget(self, action: "backspaceDown:", forControlEvents: .TouchDown)
                        keyView.addTarget(self, action: "backspaceUp:", forControlEvents: cancelEvents)
                    case Key.KeyType.Shift:
                        keyView.addTarget(self, action: Selector("shiftDown:"), forControlEvents: .TouchUpInside)
                        keyView.addTarget(self, action: Selector("shiftDoubleTapped:"), forControlEvents: .TouchDownRepeat)
                    case Key.KeyType.ModeChange:
                        keyView.addTarget(self, action: Selector("modeChangeTapped:"), forControlEvents: .TouchUpInside)
                    case Key.KeyType.Settings:
                        keyView.addTarget(self, action: Selector("toggleSettings:"), forControlEvents: .TouchUpInside)
                    case Key.KeyType.Dismiss:
                        keyView.addTarget(self, action: Selector("dismissKB:"), forControlEvents: .TouchUpInside)//+20141212
                    default:
                        break
                    }
                    
                    if key.hasOutput && key.type != Key.KeyType.NumberMalayalam {
                        
                       keyView.addTarget(self, action: "keyPressedHelper:", forControlEvents: .TouchUpInside)
                    }
                    
                    if key.isCharacter {
                        //+20150101
                        //+roll && !NSUserDefaults.standardUserDefaults().boolForKey(kDisablePopupKeys
                        if (UIDevice.currentDevice().userInterfaceIdiom != UIUserInterfaceIdiom.Pad ) {

                            keyView.addTarget(self, action: Selector("showPopup:"), forControlEvents: [.TouchDown, .TouchDragInside, .TouchDragEnter])
                            keyView.addTarget(keyView, action: Selector("hidePopup"), forControlEvents: .TouchDragExit)
                            keyView.addTarget(self, action: Selector("hidePopupDelay:"), forControlEvents: [.TouchUpInside, .TouchUpOutside, .TouchDragOutside])
                            
                        }

                        //m+20150421
                        //let longp =  UILongPressGestureRecognizer(target: self, action: Selector("showExpandPopup:"))
                        //keyView.addGestureRecognizer(longp)
                        
                        //m+20150101
                        if key.lowercaseOutput == "്" {
                            keyView.addTarget(self, action: Selector("chandrakkalaDoubleTapped:"), forControlEvents: .TouchDownRepeat)
                        }
                        if key.isDoubleTappable {
                            keyView.addTarget(self, action: Selector("characterDoubleTapped:"), forControlEvents: .TouchDownRepeat)
                        }
                    }
                    
                    if key.type != Key.KeyType.Shift && key.type != Key.KeyType.ModeChange {
                        keyView.addTarget(self, action: Selector("highlightKey:"), forControlEvents: [.TouchDown, .TouchDragInside, .TouchDragEnter])
                        //keyView.addTarget(self, action: Selector("highlightKey:"), forControlEvents: .TouchDown)
                        keyView.addTarget(self, action: Selector("unHighlightKey:"), forControlEvents: [.TouchUpInside, .TouchUpOutside, .TouchDragOutside, .TouchDragExit])
                    }
                    if (key.type != Key.KeyType.Settings){
                        keyView.addTarget(self, action: Selector("hideExtPoup:"), forControlEvents: [.TouchUpInside, .TouchUpOutside])
                    }
                    
                    keyView.addTarget(self, action: Selector("playKeySound"), forControlEvents: .TouchDown)
                }
            }
        }
    }
    
    /////////////////
    // POPUP DELAY //
    /////////////////
    
    var keyWithDelayedPopup: KeyboardKey?
    var popupDelayTimer: NSTimer?
    //+20150421
    /*func showExpandPopup(gestureRecognizer: UIGestureRecognizer) {
        println("here")
        let sender : KeyboardKey  = gestureRecognizer.view as! KeyboardKey
        sender.showExpandPopup("A")
    }*/
    func showPopup(sender: KeyboardKey) {
        if sender == self.keyWithDelayedPopup {
            self.popupDelayTimer?.invalidate()
        }
        //m+20150101
        if let key = self.layout?.keyForView(sender) {
            
            var scase: Bool = self.shiftState.uppercase()
            if !scase && key.isSwaram {//+20150129
                
                scase = (self.shouldAutoCapitalize() && self.isNeedUpperSwaram())
                
            }
            
            let k = key.outputForCase(scase)
            sender.showPopup(k)
        }
    }
    
    func hidePopupDelay(sender: KeyboardKey) {
        self.popupDelayTimer?.invalidate()
        
        if sender != self.keyWithDelayedPopup {
            self.keyWithDelayedPopup?.hidePopup()
            self.keyWithDelayedPopup = sender
        }
        
        if sender.popup != nil {
            self.popupDelayTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("hidePopupCallback"), userInfo: nil, repeats: false)
        }
    }
    
    func hidePopupCallback() {
        self.keyWithDelayedPopup?.hidePopup()
        self.keyWithDelayedPopup = nil
        self.popupDelayTimer = nil
    }
    
    /////////////////////
    // POPUP DELAY END //
    /////////////////////
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    override func textWillChange(textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    // TODO: this is currently not working as intended; only called when selection changed -- iOS bug
    override func textDidChange(textInput: UITextInput?) {
        //m+20150325
        let previousContext:String? = self.textDocumentProxy.documentContextBeforeInput
        if previousContext == nil {
            typedKeys = ""
        }
        //m+20150101
        self.contextChanged()
    }
    
    func contextChanged() {
        self.setCapsIfNeeded()
        self.autoPeriodState = .NoSpace
    }
    
    func setHeight(height: CGFloat) {
        if self.heightConstraint == nil {
            self.heightConstraint = NSLayoutConstraint(
                item:self.view,
                attribute:NSLayoutAttribute.Height,
                relatedBy:NSLayoutRelation.Equal,
                toItem:nil,
                attribute:NSLayoutAttribute.NotAnAttribute,
                multiplier:0,
                constant:height)
            self.heightConstraint!.priority = 1000
            //UIViewAlertForUnsatisfiableConstraints warning here
            self.view.addConstraint(self.heightConstraint!) // TODO: what if view already has constraint added?
        }
        else {
            self.heightConstraint?.constant = height
        }
    }
    
    func updateAppearances(appearanceIsDark: Bool) {
        self.layout?.solidColorMode = self.solidColorMode()
        self.layout?.darkMode = appearanceIsDark
        self.layout?.updateKeyAppearanceTemp()
        
        self.bannerView?.darkMode = appearanceIsDark //+20150325
        //+20151024self.settingsView?.darkMode = appearanceIsDark
    }
    var clickedtime : Double = 0 //+20151123
    func highlightKey(sender: KeyboardKey) {
        
        clickedtime = CACurrentMediaTime()
        sender.highlighted = true
        //m+20150421
        
        if let modell = self.layout?.keyForView(sender) {
            
            if  let extvalues = modell.extentionValuesCase(self.shiftState.uppercase()) {
                
                var delaytime = timeForPopupDisplay
                if modell.primaryValue == 10 {
                    delaytime = 0
                }
                
                
                let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delaytime * Double(NSEC_PER_SEC)))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
               
                    if sender.highlighted && (CACurrentMediaTime() - self.clickedtime) > (delaytime - 0.03){
                        
                        //sender.downColor = UIColor.whiteColor() //issue with darkmode if set white
                        self.bannerView?.alpha = 0.8
                        
                        self.forwardingView.longPressKey = sender
                        
                        for (_, key) in self.layout!.modelToView {
                            
                            if key != sender {
                                
                                key.alpha = 0.8
                                key.enabled = false
                                
                            }else{
                              
                            }
                            
                        }
                        let firstButton =  sender.showExpandPopup(extvalues, isleft: modell.isLeftExtention , famee: self.view.bounds, isNumberPopup:(modell.primaryValue == 10), isTopRow: modell.isTopRow)//primaryValue == 10 to identify the mal number key
                        sender.delegateExtention = self
                        if (firstButton != nil) {
                            
                            if (!CGPointEqualToPoint(self.forwardingView.lastTouchPosition!, CGPointZero)) {
                                let viewN = self.forwardingView.findNearestView(self.forwardingView.lastTouchPosition!)
                                if (viewN != nil) {
                                    self.forwardingView.handleControl(sender, controlEvent: .TouchDragExit)
                                    self.forwardingView.ownView(self.forwardingView.lastTouch!, viewToOwn: viewN)
                                    self.forwardingView.handleControl(viewN, controlEvent: .TouchDragInside)//+20151113
                                }
                            }
                        }
                    }
                    
                })
            }
        }
        
    }
    //m+20150421 also called from delegate
    func hideExtPoup(sender: KeyboardKey) {
       
        self.bannerView?.alpha = 1.0
        for (_, key) in self.layout!.modelToView {
            
            
            key.alpha = 1
            key.enabled = true
            
            if key.popupExtended != nil {
                
                sender.downColor = GlobalColors.lightModeSpecialKeyiPad
                key.highlighted = false
                key.hideExtendedPopup()
                
                key.delegateExtention = nil;
            }
           
        }
        self.forwardingView.longPressKey = nil
    }

    func unHighlightKey(sender: KeyboardKey) {
        
        if sender.popupExtended == nil { //m+20150422
            
            sender.highlighted = false
        }
        
        
    }
    //m+20150423
    func keyPressedAfter(){
        
        //m+20150325
        //let previousContext:String? = self.textDocumentProxy.documentContextBeforeInput//+20150916
        
        /*+rollif let banner = self.bannerView as? PredictiveBanner {
            
            if previousContext == nil || previousContext!.isEmpty {
                
                banner.clearBanner()
                
            }else{
                
                
                if lastchar == " " {
                    banner.clearBanner()
                }else{
                    
                    let range = previousContext!.rangeOfString(" ", options: NSStringCompareOptions.BackwardsSearch)
                    
                    if range != nil {
                        let lastword = previousContext!.substringFromIndex(range!.endIndex)
                        
                        let ct = lastword.utf16.count
                        //("ct = \(ct)")
                        if ct == 1 {
                            banner.updateAlternateKeyList(lastword, Mode:0)
                        }else if ct > 1 {
                            banner.updateAlternateKeyList(lastword, Mode:1)
                        }
                        
                        
                        
                    }else{
                        let ct = previousContext!.utf16.count
                        //("ct2 = \(ct)")
                        if ct == 1 {
                        
                            banner.updateAlternateKeyList(previousContext, Mode:0)
                        }else if ct > 1 {
                            banner.updateAlternateKeyList(previousContext, Mode:1)
                        }
                        
                    }
                    
                    
                    
                }
                
                
            }
            
        }*/
    }
    //m+20150423 Delegate from popupbutton
    func keyPressedExtention(value: String){
        
        let textDocumentProxy = self.textDocumentProxy as UIKeyInput
        
        lastchar = value
        needChandrakkala = false
        textDocumentProxy.insertText(value)
        
        keyPressedAfter()
        //+20150930
        if self.shiftState == ShiftState.Enabled {
            self.shiftState = ShiftState.Disabled
        }
        
        self.setCapsIfNeeded()
    }
    func keyPressedHelper(sender: KeyboardKey) {
        //+20141229self.playKeySound()
        
        if let model = self.layout?.keyForView(sender) {
            self.keyPressed(model)
            
            keyPressedAfter()

            
            // auto exit from special char subkeyboard
            if model.type == Key.KeyType.Space || model.type == Key.KeyType.Return {
                self.setMode(0)
            }
            else if model.lowercaseOutput == "'" {
                self.setMode(0)
            }
            else if model.type == Key.KeyType.Character {
                self.setMode(0)
            }
            
            // auto period on double space
            // TODO: timeout
            
            //var lastCharCountInBeforeContext: Int = 0
            //var readyForDoubleSpacePeriod: Bool = true
            
            self.handleAutoPeriod(model)
            // TODO: reset context
        }
        
        if self.shiftState == ShiftState.Enabled {
            self.shiftState = ShiftState.Disabled
        }
        
        self.setCapsIfNeeded()
    }
    
    func handleAutoPeriod(key: Key) {
        if !NSUserDefaults.standardUserDefaults().boolForKey(kPeriodShortcut) {
            return
        }
        
        if self.autoPeriodState == .FirstSpace {
            if key.type != Key.KeyType.Space {
                self.autoPeriodState = .NoSpace
                return
            }
            
            let charactersAreInCorrectState = { () -> Bool in
                let previousContext = self.textDocumentProxy.documentContextBeforeInput//+20150916
                
                if previousContext == nil || (previousContext!).characters.count < 3 {
                    return false
                }
                
                var index = previousContext!.endIndex
                
                index = index.predecessor()
                if previousContext![index] != " " {
                    return false
                }
                
                index = index.predecessor()
                if previousContext![index] != " " {
                    return false
                }
                
                index = index.predecessor()
                let char = previousContext![index]
                if self.characterIsWhitespace(char) || self.characterIsPunctuation(char) || char == "," {
                    return false
                }
                
                return true
            }()
            
            if charactersAreInCorrectState {//+20150916
                needChandrakkala = false
                self.textDocumentProxy.deleteBackward()
                self.textDocumentProxy.deleteBackward()
                self.textDocumentProxy.insertText(".")
                self.textDocumentProxy.insertText(" ")
            }
            
            self.autoPeriodState = .NoSpace
        }
        else {
            if key.type == Key.KeyType.Space {
                self.autoPeriodState = .FirstSpace
            }
        }
    }
    
    func cancelBackspaceTimers() {
        self.backspaceDelayTimer?.invalidate()
        self.backspaceRepeatTimer?.invalidate()
        self.backspaceDelayTimer = nil
        self.backspaceRepeatTimer = nil
    }
    
    func backspaceDown(sender: KeyboardKey) {
        
        self.cancelBackspaceTimers()
        lastchar = "" //+20150129
        lastKey = nil //+20150129
        //+20141229self.playKeySound()
        
        //+20150916if let textDocumentProxy = self.textDocumentProxy as? UIKeyInput {
        let textDocumentProxy = self.textDocumentProxy as UIKeyInput
            
            textDocumentProxy.deleteBackward()
            //+20150326
            /*+rolllet previousContext:String? = self.textDocumentProxy.documentContextBeforeInput
            
            if let banner = self.bannerView as? PredictiveBanner {
                
                if previousContext == nil || previousContext!.isEmpty {

                    banner.clearBanner()
                    
                }else{
                    
                    let range = previousContext!.rangeOfString(" ", options: NSStringCompareOptions.BackwardsSearch)
                    
                    if range != nil {
                        let lastword = previousContext!.substringFromIndex(range!.endIndex)
                        let ct = lastword.utf16.count
                        if ct == 1 {
                            banner.updateAlternateKeyList(lastword, Mode:0)
                        }else if ct > 1{
                            banner.updateAlternateKeyList(lastword, Mode:1)
                        }
                        
                        
                    }else{
                       
                        let ct = previousContext!.utf16.count
                        if ct == 1 {
                       
                            banner.updateAlternateKeyList(previousContext, Mode:0)
                        }else if ct > 1 {
                            banner.updateAlternateKeyList(previousContext, Mode:1)
                        }
                    }
                }
            }
            */
        
        //}
        //m+20150101
        // trigger for subsequent deletes
        self.backspaceDelayTimer = NSTimer.scheduledTimerWithTimeInterval(backspaceDelay - backspaceRepeat, target: self, selector: Selector("backspaceDelayCallback"), userInfo: nil, repeats: false)
    }
    
    func backspaceUp(sender: KeyboardKey) {
        self.cancelBackspaceTimers()
        self.setCapsIfNeeded()//+20150930
    }
    
    func backspaceDelayCallback() {
        self.backspaceDelayTimer = nil
        self.backspaceRepeatTimer = NSTimer.scheduledTimerWithTimeInterval(backspaceRepeat, target: self, selector: Selector("backspaceRepeatCallback"), userInfo: nil, repeats: true)
    }
    
    func backspaceRepeatCallback() {
        
        self.playKeySound()
        //+20150916if let textDocumentProxy = self.textDocumentProxy as? UIKeyInput {
        let textDocumentProxy = self.textDocumentProxy as UIKeyInput
        textDocumentProxy.deleteBackward()
            //m+20150101
        //}
    }
    
    func shiftDown(sender: KeyboardKey) {
        //+20141229self.playKeySound()
        
        //m+20150108
        lastKey = nil
        lastchar = "sd" //+20150129
        
        if self.shiftWasMultitapped {
            self.shiftWasMultitapped = false
            return
        }
        
        switch self.shiftState {
        case .Disabled:
            self.shiftState = .Enabled
        case .Enabled:
            self.shiftState = .Disabled
        case .Locked:
            self.shiftState = .Disabled
        }
        
        (sender.shape as? ShiftShape)?.withLock = false
    }
    var needChandrakkala : Bool = false
    //m+20150101
    func characterDoubleTapped(sender: KeyboardKey) {
        
        needChandrakkala = false
        if !self.shiftState.uppercase() {
            if let key = self.layout?.keyForView(sender) {
                
                //+20150916if let proxy = (self.textDocumentProxy as? UIKeyInput) {
                //let proxy = self.textDocumentProxy as UIKeyInput
                    
                    
                    let k = key.outputForCase(self.shiftState.uppercase())
                    if k == lastchar && k != "ര" {
                       //+20151123
                            //proxy.insertText("്")
                            needChandrakkala = true
                        
                        
                        //proxy.deleteBackward()
                    }
                    
                    
                //}
                
            }
        }else{
            if let key = self.layout?.keyForView(sender) {
                //+20150916if let proxy = (self.textDocumentProxy as? UIKeyInput) {
                //let proxy = self.textDocumentProxy as UIKeyInput
                    
                    let k = key.outputForCase(self.shiftState.uppercase())
                    if k == lastchar && (k == "ശ" || k == "റ") {
                        
                            //+20151123
                            //proxy.insertText("്")
                        needChandrakkala = true
                        
                    }
                
                //}
            }
        }
    }
    //m+20150101
    func chandrakkalaDoubleTapped(sender: KeyboardKey) {
        
        if !self.shiftState.uppercase() {
            if let _ = self.layout?.keyForView(sender) {
                
                //+20150916if let proxy = (self.textDocumentProxy as? UIKeyInput) {
                    
                    chandrakkaladoubletapped = true
                    //let k = key.outputForCase(self.shiftState.uppercase())
                    
                    //m+20151227proxy.deleteBackward()
                    
                //}
                
            }
        }
        
    }

    func shiftDoubleTapped(sender: KeyboardKey) {
        
        if lastchar == "sd" {//+20150129
            
            self.shiftWasMultitapped = true
            
            switch self.shiftState {
            case .Disabled:
                self.shiftState = .Locked
            case .Enabled:
                self.shiftState = .Locked
            case .Locked:
                self.shiftState = .Disabled
            }
        }
        
    }
    
    // TODO: this should be uppercase, not lowercase
    func updateKeyCaps(let lowercase: Bool) {
        if self.layout != nil {
            //let actualUppercase = true// (NSUserDefaults.standardUserDefaults().boolForKey(kSmallLowercase) ? !lowercase : true)
            
            
            //ToDo:only for first page +20150929
            for (pageIndex, page) in self.keyboard.pages.enumerate() {
                if pageIndex == 0 {
                    let numRows = page.rows.count
                    for i in 0..<numRows {
                        let numKeys = page.rows[i].count
                        
                        for j in 0..<numKeys {
                            let model = page.rows[i][j]
                            var lowerc : Bool = lowercase
                            if lowercase {//+20151011
                                if model.isSwaram {
                                    lowerc = !self.isNeedUpperSwaram()
                                }
                            }
                            if let key = self.layout?.modelToView[model] {
                                
                                key.attributetext = model.keyCapForCase(!lowerc) //+20150323 actualUppercase //m+20150324
                                
                                if model.type == Key.KeyType.Shift {
                                    switch self.shiftState {
                                    case .Disabled:
                                        key.highlighted = false
                                    case .Enabled:
                                        key.highlighted = true
                                    case .Locked:
                                        key.highlighted = true
                                    }
                                    
                                    (key.shape as? ShiftShape)?.withLock = (self.shiftState == .Locked)
                                }
                            }
                            
                        }
                    }
                    
                }
            }
            
            
            /*for (model, key) in self.layout!.modelToView {
                key.attributetext = model.keyCapForCase(!lowercase) //+20150323 actualUppercase //m+20150324
                
                if model.type == Key.KeyType.Shift {
                    switch self.shiftState {
                    case .Disabled:
                        key.highlighted = false
                    case .Enabled:
                        key.highlighted = true
                    case .Locked:
                        key.highlighted = true
                    }
                    
                    (key.shape as? ShiftShape)?.withLock = (self.shiftState == .Locked)
                }
            }*/
        }
    }
    //+20150929
    func updateKeyCapsForSwarangal(lowercase: Bool) {
        if self.layout != nil {
            //let actualUppercase = true// (NSUserDefaults.standardUserDefaults().boolForKey(kSmallLowercase) ? !lowercase : true)
            
            
            //ToDo:only for first page +20150929
            for (pageIndex, page) in self.keyboard.pages.enumerate() {
                if pageIndex == 0 {
                    let numRows = page.rows.count
                    for i in 0..<numRows {
                        let numKeys = page.rows[i].count
                        
                        for j in 0..<numKeys {
                            let model = page.rows[i][j]
                            if model.isSwaram {
                                if let key = self.layout?.modelToView[model] {
                                    
                                    key.attributetext = model.keyCapForCase(!lowercase) //+20150323 actualUppercase //m+20150324
                                    
                                    if model.type == Key.KeyType.Shift {
                                        switch self.shiftState {
                                        case .Disabled:
                                            key.highlighted = false
                                        case .Enabled:
                                            key.highlighted = true
                                        case .Locked:
                                            key.highlighted = true
                                        }
                                        
                                        (key.shape as? ShiftShape)?.withLock = (self.shiftState == .Locked)
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
    func modeChangeTapped(sender: KeyboardKey) {
        //+20141229self.playKeySound()
        
        if let toMode = self.layout?.viewToModel[sender]?.toMode {
            self.currentMode = toMode
        }
    }
    //+20141212
    func dismissKB(sender: KeyboardKey){
        
        self.dismissKeyboard();
        
    }
    func advanceTapped(sender: KeyboardKey) {
        self.forwardingView.resetTrackedViews()
        //self.shiftStartingState = nil
        self.shiftWasMultitapped = false
        
        self.advanceToNextInputMode()
    }
    func setMode(mode: Int) {
        for (pageIndex, page) in self.keyboard.pages.enumerate() {
            for (_, row) in page.rows.enumerate() {
                for (_, key) in row.enumerate() {
                    if self.layout?.modelToView[key] != nil {
                        let keyView = self.layout?.modelToView[key]
                        keyView?.hidden = (pageIndex != mode)
                    }
                }
            }
        }
    }
    
    @IBAction func toggleSettings(sender : UIControl) {//+20151022 added argument
        //+20141229self.playKeySound()
        if self.settingsView == nil {
            print("am here to create")
            if let aSettings = self.createSettings() {
                
                print("am here created")
                aSettings.darkMode = self.darkMode()
                
                aSettings.hidden = true
                self.view.addSubview(aSettings)
                self.settingsView = aSettings
                
                aSettings.translatesAutoresizingMaskIntoConstraints = false
                
                let widthConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
                let heightConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
                let centerXConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
                let centerYConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
                
                self.view.addConstraint(widthConstraint)
                self.view.addConstraint(heightConstraint)
                self.view.addConstraint(centerXConstraint)
                self.view.addConstraint(centerYConstraint)
            }
        }
        
        
        
        if let settings = self.settingsView {
            print("am hereto hide")
            let hidden = settings.hidden
            hidden ? print("settings hidden yes") : print("settings not hidden")
            settings.hidden = !hidden
            self.forwardingView.hidden = hidden
            self.forwardingView.userInteractionEnabled = !hidden
            self.bannerView?.hidden = hidden//+20150325
            if settings.hidden {
                self.view.bringSubviewToFront(self.forwardingView)
                if (self.bannerView != nil) { self.view.bringSubviewToFront(self.bannerView!) }
            } else {
                self.view.bringSubviewToFront(settings)
            }
            print("am not here")
        }
    }
    
    // TODO: make this work if cursor position is shifted
    func setCapsIfNeeded() {
        //+20150929
        if self.shouldAutoCapitalize() {
            switch self.shiftState {
            case .Disabled:
                self.updateKeyCapsForSwarangal(!self.isNeedUpperSwaram())
            default:
                break
            /*case .Enabled:
                self.shiftState = .Enabled
            case .Locked:
                self.shiftState = .Locked*/
            }
        }
    }
    
    func characterIsPunctuation(character: Character) -> Bool {
        return (character == ".") || (character == "!") || (character == "?")
    }
    
    func characterIsNewline(character: Character) -> Bool {
        return (character == "\n") || (character == "\r")
    }
    
    func characterIsWhitespace(character: Character) -> Bool {
        // there are others, but who cares
        return (character == " ") || (character == "\n") || (character == "\r") || (character == "\t")
    }
    
    func stringIsWhitespace(string: String?) -> Bool {
        if string != nil {
            for char in (string!).characters {
                if !characterIsWhitespace(char) {
                    return false
                }
            }
        }
        return true
    }
    //+20150929
    func isNeedUpperSwaram() -> Bool {
        
        let documentProxy = self.textDocumentProxy as UITextDocumentProxy
        //+20150916var beforeContext = documentProxy.documentContextBeforeInput
        
        if let beforeContext = documentProxy.documentContextBeforeInput {
            if !beforeContext.isEmpty {
                let previousCharacter = beforeContext[beforeContext.endIndex.predecessor()]
                return self.characterIsWhitespace(previousCharacter)
            } else {
                return true
            }
            
        }
        else {
            return true
        }
    }

    func shouldAutoCapitalize() -> Bool {
        
        return NSUserDefaults.standardUserDefaults().boolForKey(kCapitalizeSwarangal)//+20150929
        
    }
    
    // this only works if full access is enabled
    func playKeySound() {
        if !NSUserDefaults.standardUserDefaults().boolForKey(kKeyboardClicks) {
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            AudioServicesPlaySystemSound(1104)
        })
    }
    
    //////////////////////////////////////
    // MOST COMMONLY EXTENDABLE METHODS //
    //////////////////////////////////////
    
    class var layoutClass: KeyboardLayout.Type { get { return KeyboardLayout.self }}
    class var layoutConstants: LayoutConstants.Type { get { return LayoutConstants.self }}
    class var globalColors: GlobalColors.Type { get { return GlobalColors.self }}
    //https://www.cocoanetics.com/2009/12/double-tapping-on-buttons/
    func keyPressed(key: Key) {
        //+20150918if let proxy = (self.textDocumentProxy as? UIKeyInput) {
            //m+20141209
            let proxy = self.textDocumentProxy as UIKeyInput
        
            var scase: Bool = self.shiftState.uppercase()
            
            if !scase && key.isSwaram { //m+20150127
                
                /*if NSUserDefaults.standardUserDefaults().boolForKey(kCapitalizeSwarangal) {
                    let previousContext = (self.textDocumentProxy as? UITextDocumentProxy)?.documentContextBeforeInput
                    
                    if previousContext != nil  {
                        
                        var index = previousContext!.endIndex
                        
                        index = index.predecessor()
                        if previousContext![index] == " " {
                            scase = true
                        }
                    }else{
                        scase = true
                    }
                }*/
                scase = (self.shouldAutoCapitalize() && self.isNeedUpperSwaram())
                
            }
            
            
            let keyOutput = key.outputForCase(scase)
            
            //m+20150108
            /*if NSUserDefaults.standardUserDefaults().boolForKey(kKoottaksharamShortcut) {
                let nowtime = CACurrentMediaTime()
                if lastKey != nil && lasttime > 0 && nowtime - lasttime < timeForKoottaksharamShortcut  {
                    if lastKey!.primaryValue + key.secondaryValue == 10 {
                        proxy.insertText("്")
                        
                    }
                }
                lastKey = key
                lasttime = nowtime
            }*/
            
            
            //m+20150101
            
            if keyOutput == "്" {
                
                needChandrakkala = false
                if chandrakkaladoubletapped {
                    
                    let endChar: Character = "\u{200C}"
                    proxy.insertText("\(endChar)")
                    
                }else {
                    
                    proxy.insertText(keyOutput)
                    //proxy.deleteBackward()
                }
                
            }else{
                if needChandrakkala {
                    proxy.insertText("്")
                    needChandrakkala = false
                }
                proxy.insertText(keyOutput)
            }
            
            lastchar = keyOutput
            chandrakkaladoubletapped = false
            
        //}
    }
    
    // a banner that sits in the empty space on top of the keyboard
    func createBanner() -> ExtraView? {
        // note that dark mode is not yet valid here, so we just put false for clarity
        //return ExtraView(globalColors: self.dynamicType.globalColors, darkMode: false, solidColorMode: self.solidColorMode())
        //+20150325
        //
        if NSUserDefaults.standardUserDefaults().boolForKey(kDisablePopupKeys) {
            return nil
        } else{
            return PredictiveBanner(keyboard: self)
        }
        
    }
    
    // a settings view that replaces the keyboard when the settings button is pressed
    func createSettings() -> ExtraView? {
        // note that dark mode is not yet valid here, so we just put false for clarity
        let settingsView = DefaultSettings(globalColors: self.dynamicType.globalColors, darkMode: false, solidColorMode: self.solidColorMode())
        settingsView.backButton?.addTarget(self, action: Selector("toggleSettings:"), forControlEvents: UIControlEvents.TouchUpInside)
        return settingsView
    }
}

//// does not work; drops CPU to 0% when run on device
//extension UIInputView: UIInputViewAudioFeedback {
//    public var enableInputClicksWhenVisible: Bool {
//        return true
//    }
//}

//+20150325
class PredictiveBanner: ExtraView {
    
    //var label: UILabel = UILabel()
    weak var keyboard: KeyboardViewController?
    //+rollvar dataStore : WordsDAO!
    var searchText :String?
    
    let scrolview : UIScrollView = UIScrollView()

    convenience init(keyboard: KeyboardViewController) {
        self.init(globalColors: nil, darkMode: false, solidColorMode: false)
        self.keyboard = keyboard
        //+20150326
        //+rolldataStore = WordsDAO()
        //+rolldataStore.initWithDataBase()
        
        self.addSubview(scrolview)
        
        self.updateAppearance()
    }
    
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
        self.keyboard = nil
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*+rolldeinit {
        dataStore.closeAll()
    }*/
    override func setNeedsLayout() {
        super.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrolview.frame = self.frame
        self.scrolview.center = self.center

       
    }
    
    func handleBtnPress(sender: UIButton) {
        if self.keyboard != nil {
            
            //if let textDocumentProxy = self.keyboard!.textDocumentProxy as? UIKeyInput {
            let textDocumentProxy = self.keyboard!.textDocumentProxy as UIKeyInput
            
                if searchText != nil {
                    
                    //+20151021
                    if let previousContext:String? = self.keyboard!.textDocumentProxy.documentContextBeforeInput {
                        
                        let array1: [String]? = previousContext?.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        if (array1 != nil && array1!.count > 0 ) {
                            
                            let ct2 = array1!.last!.utf16.count
                            for var i = 0 ; i < ct2 ; i++ {
                                
                                textDocumentProxy.deleteBackward()
                            }
                        }
                        
                    }
                    
                    /*let previousContext:String? = (self.keyboard!.textDocumentProxy as? UITextDocumentProxy)?.documentContextBeforeInput
                    
                    
                    let array1: [String]? = previousContext?.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    
                    let ct1 = count(array1!.last!)
                    let ct2 = count(array1!.last!.utf16)
                    for var i = 0 ; i < ct1 ; i++ {
                        
                        textDocumentProxy.deleteBackward()
                    }
                    
                    
                    println("ct1 = \(ct1)")
                    println("ct2 = \(ct2)")
                    
                   
                    let ct = ct2 - ct1
                    
                    //textDocumentProxy.insertText(" ")
                    //(self.keyboard!.textDocumentProxy as? UITextDocumentProxy)?.adjustTextPositionByCharacterOffset(-1)
                    
                    if ct > 0 {
                        
                        println("ct = \(ct)")
                        
                        
                        let previousContext2:String? = (self.keyboard!.textDocumentProxy as? UITextDocumentProxy)?.documentContextBeforeInput
                        let array2: [String]? = previousContext2?.componentsSeparatedByString(" ") //CharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        
                        //("previousContext2_\(previousContext2)_end")
                        
                        
                        
                        if array2 != nil {
                            
                            println("previousContextValue_\(array2!.last!.utf16)_end")
                            
                            let newct = count(array2!.last!.utf16)
                            
                            println("newct = \(newct)")
                            
                            if newct == ct {
                                
                                for var i = 0 ; i < ct ; i++ {
                                    
                                    //textDocumentProxy.deleteBackward()
                                }
                            }
                        }
                        
                        
                        
                    }*/
                    
                    /*
                    let previousContext2:String? = (self.keyboard!.textDocumentProxy as? UITextDocumentProxy)?.documentContextBeforeInput
                    
                    var index = previousContext2!.endIndex
                    
                    index = index.predecessor()
                    if previousContext2![index] != " "{
                        
                        let array2: [String]? = previousContext2?.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        
                        for var i = 0 ; i < count(array2!.last!.utf16) ; i++ {
                            
                            textDocumentProxy.deleteBackward()
                        }
                    }
                    
                    */
                    
                    
                    /*
                    let range = previousContext!.rangeOfString(" ", options: NSStringCompareOptions.BackwardsSearch)
                    
                    if range != nil {
                        let lastword = previousContext!.substringFromIndex(range!.endIndex)
                        let ct = count(lastword)
                        
                        for var i = 0 ; i<ct ; i++ {
                            textDocumentProxy.deleteBackward()
                        }
                        
                        
                        
                    }else{
                        let ct = count(previousContext!)
                        
                        for var i = 0 ; i<ct ; i++ {
                            textDocumentProxy.deleteBackward()
                        }

                        
                    }
                    
                    
                    let previousContext:String? = (self.keyboard!.textDocumentProxy as? UITextDocumentProxy)?.documentContextBeforeInput
                    
                    
                    let array1: [String]? = previousContext?.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    
                    let newstr = array1!.last! as NSString
                    
                    //let countt = count(searchText!.utf16)
                    let countt = newstr.length //count(array1!.last!.utf16)
                    
                    for var i = countt-1 ; i > 0 ; i-- {
                        
                        let previousContext2:String? = (self.keyboard!.textDocumentProxy as? UITextDocumentProxy)?.documentContextBeforeInput
                        

                        
                        
                        if previousContext2 == " " {
                     
                            break
                        }
                        
                        
                        
                        textDocumentProxy.deleteBackward()
                    }
                    */
                }
                
                textDocumentProxy.insertText(sender.titleLabel!.text!)
                //textDocumentProxy.insertText(" ")
                
                //+rollself.clearBanner()
                //+rollself.updateAlternateKeyList(sender.titleLabel!.text!, Mode: 1)
                
            //}
            
            
        }
    }
    
    func applyConstraints(currentView: UIButton, prevView: UIView?, nextView: UIView?, firstView: UIView) {
        
        
        let parentView = self
        
        var leftConstraint: NSLayoutConstraint
        var rightConstraint: NSLayoutConstraint
        var topConstraint: NSLayoutConstraint
        var bottomConstraint: NSLayoutConstraint
        
        // Constrain to top of parent view
        topConstraint = NSLayoutConstraint(item: currentView, attribute: .Top, relatedBy: .Equal, toItem: parentView,
            attribute: .Top, multiplier: 1.0, constant: 1)
        
        // Constraint to bottom of parent too
        bottomConstraint = NSLayoutConstraint(item: currentView, attribute: .Bottom, relatedBy: .Equal, toItem: parentView, attribute: .Bottom, multiplier: 1.0, constant: 1)
        
        // If last, constrain to right
        if nextView == nil {
            rightConstraint = NSLayoutConstraint(item: currentView, attribute: .Trailing, relatedBy: .Equal, toItem: parentView, attribute: .Trailing, multiplier: 1.0, constant: 1)
        } else {
            rightConstraint = NSLayoutConstraint(item: currentView, attribute: .Trailing, relatedBy: .Equal, toItem: nextView, attribute: .Leading, multiplier: 1.0, constant: 1)
        }
        
        // If first, constrain to left of parent
        if prevView == nil {
            leftConstraint = NSLayoutConstraint(item: currentView, attribute: .Leading, relatedBy: .Equal, toItem: parentView, attribute: .Leading, multiplier: 1.0, constant: 1)
        } else {
            leftConstraint = NSLayoutConstraint(item: currentView, attribute: .Leading, relatedBy: .Equal, toItem: prevView, attribute: .Trailing, multiplier: 1.0, constant: -1)
            
            
        }
        let widthConstraint = NSLayoutConstraint(item: firstView, attribute: .Width, relatedBy: .Equal, toItem: currentView, attribute: .Width, multiplier: 1.0, constant: 0)
        
        widthConstraint.priority = 800
        
        addConstraint(widthConstraint)
        
        addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        
    }
    
    /*+rollfunc clearBanner(){
        
        let sv = scrolview.subviews
        for v in sv {
            v.removeFromSuperview()
        }
        scrolview.scrollRectToVisible(CGRectMake(0,0,1,1), animated: false)
    }*/
    /*+rollfunc updateAlternateKeyList(str: String?, Mode mode: Int32) {
        
        clearBanner()
        
        searchText = str
        
        
        let objects = dataStore.getAllMatchedWords(str, mode: mode)
        
        
        if objects.count == 0 {
            
            searchText = ""
            return
        }
        
      
       
        scrolview.backgroundColor = UIColor.clearColor()
        
        var i:CGFloat = 0
        var wdth:CGFloat = 0
        var preButton : UIButton?
        for char in objects {
            
            let btn: UIButton = UIButton(type: UIButtonType.System)
            
            
            let text:String = char as! String
            var startx:CGFloat = 0
            if preButton != nil {
                
                startx = preButton!.frame.origin.x + preButton!.frame.size.width + 1
            }
            
            let sizee: CGSize = (text as NSString).sizeWithAttributes([NSFontAttributeName:UIFont.systemFontOfSize(16)]);
            
            
            btn.frame = CGRectMake(startx, 1, sizee.width+10, scrolview.frame.size.height-2)
            btn.setTitle(text, forState: .Normal)
            
            
            //btn.frame = CGRectMake(0, 0, 20, 20)
            //btn.setTitle(char as? String, forState: .Normal)
            //btn.titleLabel!.sizeToFit()
            //btn.sizeToFit()
            //m+btn.titleLabel?.font = UIFont.systemFontOfSize(16)
            //btn.setTranslatesAutoresizingMaskIntoConstraints(false)
            if darkMode {//+20150421
                btn.backgroundColor = UIColor(red: CGFloat(12)/CGFloat(255), green: CGFloat(12)/CGFloat(255), blue: CGFloat(12)/CGFloat(255), alpha: 1)
            }else{
                btn.backgroundColor = UIColor(red: 191/255.0, green: 136/255.0, blue: 65/255, alpha: 1)// UIColor(hue: (216/360.0), saturation: 0.1, brightness: 0.81, alpha: 1)

            }
            
            btn.setTitleColor(UIColor(white: 1.0, alpha: 1.0), forState: .Normal)
            
            //btn.setContentHuggingPriority(1000, forAxis: .Horizontal)
            //btn.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
            
            btn.addTarget(self, action: Selector("handleBtnPress:"), forControlEvents: .TouchUpInside)
            
            scrolview.addSubview(btn)
            preButton = btn
            wdth += preButton!.frame.size.width
            wdth += 1
            i++
        }
        
        if wdth < self.frame.size.width {
            
            let firstBtn = scrolview.subviews[0] as! UIButton
            let lastN = objects.count-1
            var prevBtn: UIButton?
            var nextBtn: UIButton?
            
            for (n, view) in scrolview.subviews.enumerate() {
                let btn = view as! UIButton
                
                btn.frame = CGRectMake(0, 0, 20, 20)
                btn.sizeToFit()
                btn.translatesAutoresizingMaskIntoConstraints = false
                btn.setContentHuggingPriority(1000, forAxis: .Horizontal)
                btn.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
                
                if n == lastN {
                    nextBtn = nil
                } else {
                    nextBtn = scrolview.subviews[n+1] as? UIButton
                }
                
                if n == 0 {
                    prevBtn = nil
                } else {
                    prevBtn = scrolview.subviews[n-1] as? UIButton
                }
                
                applyConstraints(btn, prevView: prevBtn, nextView: nextBtn, firstView: firstBtn)
            }
            
        }else{
        
            scrolview.contentSize = CGSizeMake(wdth, scrolview.frame.size.height)
        }
        
        
        
        
    }*/
    func updateAppearance() {
       
        
        //self.scrolview.sizeToFit()
    }
    
    
}




