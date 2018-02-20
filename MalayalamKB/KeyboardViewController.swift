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
func metric(_ name: String) -> CGFloat {
    
    //+20141231
    //    if NSUserDefaults.standardUserDefaults().boolForKey(kDisablePopupKeys) {
    //        return 0
    //    }else{
    //+20150325
    if UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.pad {
        return CGFloat(metrics[name]!)
    } else {
        return CGFloat(metrics[name]!) * 1.3
    }
    // }
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
    
    let backspaceDelay: TimeInterval = 0.5
    let backspaceRepeat: TimeInterval = 0.07
    
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
    var backspaceDelayTimer: Timer?
    var backspaceRepeatTimer: Timer?
    
    enum AutoPeriodState {
        case noSpace
        case firstSpace
    }
    
    var autoPeriodState: AutoPeriodState = .noSpace
    var lastCharCountInBeforeContext: Int = 0
    //m+20150101
    var chandrakkaladoubletapped: Bool = false
    var lastchar: String = ""
    var lastKey: Key?
    //var lasttime: Double = 0
    
    enum ShiftState {
        case disabled
        case enabled
        case locked
        
        func uppercase() -> Bool {
            switch self {
            case .disabled:
                return false
            case .enabled:
                return true
            case .locked:
                return true
            }
        }
    }
    var shiftState: ShiftState {
        didSet {
            switch shiftState {
            case .disabled:
                self.updateKeyCaps(true)
            case .enabled:
                self.updateKeyCaps(false)
            case .locked:
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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        UserDefaults.standard.register(defaults: [
            //kAutoCapitalization: false, //+20141218
            //kKeyPadMalayalam: false,
            kPeriodShortcut: true,
            //kKoottaksharamShortcut: true, //m+20150109
            kCapitalizeSwarangal: true,
            kKeyboardClicks: true,
            kDisablePopupKeys: false
            ])
        //+roll
        UserDefaults.standard.set(false, forKey: kDisablePopupKeys)
        UserDefaults.standard.set(true, forKey: kPeriodShortcut)
        UserDefaults.standard.set(true, forKey: kCapitalizeSwarangal)
        //NSUserDefaults.standardUserDefaults().setBool(true, forKey: kKoottaksharamShortcut)
        UserDefaults.standard.set(false, forKey: kKeyboardClicks)
        
        self.keyboard = defaultKeyboard()
        
        self.shiftState = .disabled
        self.currentMode = 0
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.forwardingView = ForwardingView(frame: CGRect.zero)
        self.view.addSubview(self.forwardingView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardViewController.defaultsChanged(_:)), name: UserDefaults.didChangeNotification, object: nil)
        if darkMode() {
            //self.view.backgroundColor = UIColor.darkText.withAlphaComponent(0.7)
        }
        //self.view.backgroundColor = UIColor.blackColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    deinit {
        
        backspaceDelayTimer?.invalidate()
        backspaceRepeatTimer?.invalidate()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func defaultsChanged(_ notification: Notification) {
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
            kludge.isHidden = true
            
            
            
            let a = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
            let b = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
            let c = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
            let d = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
            self.view.addConstraints([a, b, c, d])
            
            self.kludge = kludge
        }
        // if self.heightConstraint == nil {
        //      self.keyboardHeight = self.heightForOrientation(true)
        //  }
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
            self.layout = type(of: self).layoutClass.init(model: self.keyboard, superview: self.forwardingView, layoutConstants: type(of: self).layoutConstants, globalColors: type(of: self).globalColors, darkMode: self.darkMode(), solidColorMode: self.solidColorMode())
            
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
        
        //GlobalColors.selectedColorMode = ColorMode.lightMode
        var darkmode = false //+20180216UserDefaults(suiteName: "group.com.jeesmon.apps.MalayalamEditor")!.bool(forKey: "darkmode")
        if darkmode == false{
            darkmode = { () -> Bool in
                let proxy = self.textDocumentProxy
                return proxy.keyboardAppearance == UIKeyboardAppearance.dark
                
            }()
        }
        print("darkmode = \(darkmode)")
        return darkmode
    }
    
    func solidColorMode() -> Bool {
        //return true //TODO: temporary, until vibrancy performance is fixed +roll ?
        let darkmode = false //+20180216UserDefaults(suiteName: "group.com.jeesmon.apps.MalayalamEditor")!.bool(forKey: "darkmode")
        if darkmode == false{
            return UIAccessibilityIsReduceTransparencyEnabled()
        }
        return darkmode
        //return UIAccessibilityIsReduceTransparencyEnabled()
    }
    
    var lastLayoutBounds: CGRect?
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        if view.bounds == CGRect.zero {
            return
        }

        self.setupLayout()
        
        let orientationSavvyBounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.heightForOrientation(false) )//+20151021
        if (lastLayoutBounds != nil && lastLayoutBounds == orientationSavvyBounds) {
            // do nothing
        }
        else {
            
            self.forwardingView.frame = orientationSavvyBounds
            self.layout?.layoutTemp()
            self.lastLayoutBounds = orientationSavvyBounds
        }
        
        self.bannerView?.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: metric("topBanner"))//+20150325
        let newOrigin = CGPoint(x: 0, y: self.view.bounds.height - self.forwardingView.bounds.height)
        self.forwardingView.frame.origin = newOrigin
        if isRotate {
            isRotate = false
            let ht = self.heightForOrientation(true)
            if self.keyboardHeight != ht { //+20180219
                self.keyboardHeight = ht
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        
        //+20150325
        if let aBanner = self.createBanner() {
            aBanner.isHidden = false
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
    var isRotate = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.bannerView?.isHidden = false //+20150325
        self.keyboardHeight = self.heightForOrientation(true)//+20151123
    }
    
    /*override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
     // optimization: ensures quick mode and shift transitions
     if let keyPool = self.layout?.keyPool {
     for view in keyPool {
     view.shouldRasterize = false
     }
     }
     }*/
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        self.forwardingView.resetTrackedViews()
        ////self.shiftStartingState = nil
        self.shiftWasMultitapped = false
        self.keyboardHeight = self.heightForOrientation(toInterfaceOrientation, withTopBanner: true)//+20151123
        isRotate = true
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator){
        
        self.forwardingView.resetTrackedViews()
        ////self.shiftStartingState = nil
        self.shiftWasMultitapped = false
        
        super.viewWillTransition(to: size, with: coordinator)
        self.keyboardHeight = self.heightForOrientation(true)//+20151123
        isRotate = true
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
    fileprivate struct SubStruct { static var staticVariable: Bool = false }
    
    class var workaroundClassVariable: Bool
    {
        get { return SubStruct.staticVariable }
        set { SubStruct.staticVariable = newValue }
    }
    class func isLanscapeKB() -> Bool {
        
        return workaroundClassVariable
    }
    
    func heightForOrientation(_ orientation: UIInterfaceOrientation, withTopBanner: Bool) -> CGFloat {
        let isPad = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
        
        //TODO: hardcoded stuff
        let actualScreenWidth = (UIScreen.main.nativeBounds.size.width / UIScreen.main.nativeScale)
        let canonicalPortraitHeight = (isPad ? CGFloat(264) : CGFloat(orientation.isPortrait && actualScreenWidth >= 400 ? 226 : 216))
        let canonicalLandscapeHeight = (isPad ? CGFloat(352) : CGFloat(162))
        let topBannerHeight = (withTopBanner ? metric("topBanner") : 0)
        KeyboardViewController.workaroundClassVariable = orientation.isLandscape
        
        return CGFloat(orientation.isPortrait ? canonicalPortraitHeight  + topBannerHeight  : canonicalLandscapeHeight  + topBannerHeight )
        
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
        let topBannerHeight = (withTopBanner ? metric("topBanner") : 0)
        //KeyboardViewController.workaroundClassVariable = orientation.isLandscape
        
        return CGFloat(!isLandscape ? canonicalPortraitHeight + topBannerHeight : canonicalLandscapeHeight + topBannerHeight)
        
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
                    
                    keyView.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)//+201412
                    
                    switch key.type {
                    case Key.KeyType.keyboardChange:
                        keyView.addTarget(self, action: #selector(KeyboardViewController.advanceTapped(_:)), for: .touchUpInside)
                    case Key.KeyType.backspace:
                        let cancelEvents: UIControlEvents = [UIControlEvents.touchUpInside, UIControlEvents.touchUpInside, UIControlEvents.touchDragExit, UIControlEvents.touchUpOutside, UIControlEvents.touchCancel, UIControlEvents.touchDragOutside]
                        
                        keyView.addTarget(self, action: #selector(KeyboardViewController.backspaceDown(_:)), for: .touchDown)
                        keyView.addTarget(self, action: #selector(KeyboardViewController.backspaceUp(_:)), for: cancelEvents)
                    case Key.KeyType.shift:
                        keyView.addTarget(self, action: #selector(KeyboardViewController.shiftDown(_:)), for: .touchUpInside)
                        keyView.addTarget(self, action: #selector(KeyboardViewController.shiftDoubleTapped(_:)), for: .touchDownRepeat)
                    case Key.KeyType.modeChange:
                        keyView.addTarget(self, action: #selector(KeyboardViewController.modeChangeTapped(_:)), for: .touchUpInside)
                    case Key.KeyType.settings:
                        keyView.addTarget(self, action: #selector(KeyboardViewController.toggleSettings(_:)), for: .touchUpInside)
                    case Key.KeyType.dismiss:
                        keyView.addTarget(self, action: #selector(KeyboardViewController.dismissKB(_:)), for: .touchUpInside)//+20141212
                    default:
                        break
                    }
                    
                    if key.hasOutput && key.type != Key.KeyType.numberMalayalam {
                        
                        keyView.addTarget(self, action: #selector(KeyboardViewController.keyPressedHelper(_:)), for: .touchUpInside)
                    }
                    
                    if key.isCharacter {
                        //+20150101
                        //+roll && !NSUserDefaults.standardUserDefaults().boolForKey(kDisablePopupKeys
                        if (UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.pad ) {
                            
                            keyView.addTarget(self, action: #selector(KeyboardViewController.showPopup(_:)), for: [.touchDown, .touchDragInside, .touchDragEnter])
                            keyView.addTarget(self, action: #selector(hidePopup(_:)), for: .touchDragExit)
                            keyView.addTarget(self, action: #selector(KeyboardViewController.hidePopupDelay(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragOutside])
                            
                        }
                        
                        //m+20150421
                        //let longp =  UILongPressGestureRecognizer(target: self, action: Selector("showExpandPopup:"))
                        //keyView.addGestureRecognizer(longp)
                        
                        //m+20150101
                        if key.lowercaseOutput == "്" {
                            keyView.addTarget(self, action: #selector(KeyboardViewController.chandrakkalaDoubleTapped(_:)), for: .touchDownRepeat)
                        }
                        if key.isDoubleTappable {
                            keyView.addTarget(self, action: #selector(KeyboardViewController.characterDoubleTapped(_:)), for: .touchDownRepeat)
                        }
                    }
                    
                    if key.type != Key.KeyType.shift && key.type != Key.KeyType.modeChange {
                        keyView.addTarget(self, action: #selector(KeyboardViewController.highlightKey(_:)), for: [.touchDown, .touchDragInside, .touchDragEnter])
                        //keyView.addTarget(self, action: Selector("highlightKey:"), forControlEvents: .TouchDown)
                        keyView.addTarget(self, action: #selector(KeyboardViewController.unHighlightKey(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragOutside, .touchDragExit])
                    }
                    if (key.type != Key.KeyType.settings){
                        keyView.addTarget(self, action: #selector(KeyboardViewController.hideExtPoup(_:)), for: [.touchUpInside, .touchUpOutside])
                    }
                    
                    keyView.addTarget(self, action: #selector(KeyboardViewController.playKeySound), for: .touchDown)
                }
            }
        }
    }
    @objc func hidePopup(_ sender: KeyboardKey) {
        sender.hidePopup()
    }
    /////////////////
    // POPUP DELAY //
    /////////////////
    
    var keyWithDelayedPopup: KeyboardKey?
    var popupDelayTimer: Timer?
    //+20150421
    /*func showExpandPopup(gestureRecognizer: UIGestureRecognizer) {
     println("here")
     let sender : KeyboardKey  = gestureRecognizer.view as! KeyboardKey
     sender.showExpandPopup("A")
     }*/
    @objc func showPopup(_ sender: KeyboardKey) {
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
    
    @objc func hidePopupDelay(_ sender: KeyboardKey) {
        self.popupDelayTimer?.invalidate()
        
        if sender != self.keyWithDelayedPopup {
            self.keyWithDelayedPopup?.hidePopup()
            self.keyWithDelayedPopup = sender
        }
        
        if sender.popup != nil {
            self.popupDelayTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(KeyboardViewController.hidePopupCallback), userInfo: nil, repeats: false)
        }
    }
    
    @objc func hidePopupCallback() {
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
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    // TODO: this is currently not working as intended; only called when selection changed -- iOS bug
    override func textDidChange(_ textInput: UITextInput?) {
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
        self.autoPeriodState = .noSpace
    }
    
    func setHeight(_ height: CGFloat) {
        if self.heightConstraint == nil {
            self.heightConstraint = NSLayoutConstraint(
                item:self.view,
                attribute:NSLayoutAttribute.height,
                relatedBy:NSLayoutRelation.equal,
                toItem:nil,
                attribute:NSLayoutAttribute.notAnAttribute,
                multiplier:0,
                constant:height)
            self.heightConstraint!.priority = UILayoutPriority(rawValue: 990)
            //UIViewAlertForUnsatisfiableConstraints warning here
            self.view.addConstraint(self.heightConstraint!) // TODO: what if view already has constraint added?
            
            //+20180208
            //self.forwardingView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            //self.forwardingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }
        else {
            self.heightConstraint?.constant = height
        }
        self.view.layoutIfNeeded()//+20151125
    }
    
    func updateAppearances(_ appearanceIsDark: Bool) {
        self.layout?.solidColorMode = self.solidColorMode()
        self.layout?.darkMode = appearanceIsDark
        self.layout?.updateKeyAppearanceTemp()
        
        self.bannerView?.darkMode = appearanceIsDark //+20150325
        //+20151024self.settingsView?.darkMode = appearanceIsDark
    }
    var clickedtime : Double = 0 //+20151123
    @objc func highlightKey(_ sender: KeyboardKey) {
        
        clickedtime = CACurrentMediaTime()
        sender.isHighlighted = true
        //m+20150421
        
        if let modell = self.layout?.keyForView(sender) {
            
            if  let extvalues = modell.extentionValuesCase(self.shiftState.uppercase()) {
                
                var delaytime = timeForPopupDisplay
                if modell.primaryValue == 10 {
                    delaytime = 0
                }
                
                
                let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(delaytime * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                    
                    if sender.isHighlighted && (CACurrentMediaTime() - self.clickedtime) > (delaytime - 0.03){
                        
                        //sender.downColor = UIColor.whiteColor() //issue with darkmode if set white
                        self.bannerView?.alpha = 0.8
                        
                        self.forwardingView.longPressKey = sender
                        
                        for (_, key) in self.layout!.modelToView {
                            
                            if key != sender {
                                
                                key.alpha = 0.8
                                key.isEnabled = false
                                
                            }else{
                                
                            }
                            
                        }
                        let firstButton =  sender.showExpandPopup(extvalues, isleft: modell.isLeftExtention , famee: self.view.bounds, isNumberPopup:(modell.primaryValue == 10), isTopRow: modell.isTopRow, isDarkMode: self.darkMode())//primaryValue == 10 to identify the mal number key
                        sender.delegateExtention = self
                        if (firstButton != nil) {
                            
                            if (!self.forwardingView.lastTouchPosition!.equalTo(CGPoint.zero)) {
                                let viewN = self.forwardingView.findNearestView(self.forwardingView.lastTouchPosition!)
                                if (viewN != nil) {
                                    self.forwardingView.handleControl(sender, controlEvent: .touchDragExit)
                                    self.forwardingView.ownView(self.forwardingView.lastTouch!, viewToOwn: viewN)
                                    self.forwardingView.handleControl(viewN, controlEvent: .touchDragInside)//+20151113
                                }
                            }
                        }
                    }
                    
                })
            }
        }
        
    }
    //m+20150421 also called from delegate
    @objc func hideExtPoup(_ sender: KeyboardKey) {
        
        self.bannerView?.alpha = 1.0
        for (_, key) in self.layout!.modelToView {
            
            
            key.alpha = 1
            key.isEnabled = true
            
            if key.popupExtended != nil {
                
                sender.downColor = GlobalColors.lightModeSpecialKeyiPad
                key.isHighlighted = false
                key.hideExtendedPopup()
                
                key.delegateExtention = nil;
            }
            
        }
        self.forwardingView.longPressKey = nil
    }
    
    @objc func unHighlightKey(_ sender: KeyboardKey) {
        
        if sender.popupExtended == nil { //m+20150422
            
            sender.isHighlighted = false
        }
        
        
    }
    //m+20150423
    func keyPressedAfter(){
        
        //m+20150325
        let previousContext:String? = self.textDocumentProxy.documentContextBeforeInput//+20150916
        
        if let banner = self.bannerView as? PredictiveBanner {
            
            if previousContext == nil || previousContext!.isEmpty {
                
                banner.clearBanner()
                
            }else{
                
                
                if lastchar == " " {
                    banner.clearBanner()
                }else{
                    
                    let range = previousContext!.range(of: " ", options: NSString.CompareOptions.backwards)
                    
                    if range != nil {
                        let lastword = previousContext!.substring(from: range!.upperBound)
                        
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
            
        }
    }
    //m+20150423 Delegate from popupbutton
    func keyPressedExtention(_ value: String){
        
        let textDocumentProxy = self.textDocumentProxy as UIKeyInput
        
        lastchar = value
        needChandrakkala = false
        textDocumentProxy.insertText(value)
        
        keyPressedAfter()
        //+20150930
        if self.shiftState == ShiftState.enabled {
            self.shiftState = ShiftState.disabled
        }
        
        self.setCapsIfNeeded()
    }
    @objc func keyPressedHelper(_ sender: KeyboardKey) {
        //+20141229self.playKeySound()
        
        if let model = self.layout?.keyForView(sender) {
            self.keyPressed(model)
            
            keyPressedAfter()
            
            
            // auto exit from special char subkeyboard
            if model.type == Key.KeyType.space || model.type == Key.KeyType.return {
                self.setMode(0)
            }
            else if model.lowercaseOutput == "'" {
                self.setMode(0)
            }
            else if model.type == Key.KeyType.character {
                self.setMode(0)
            }
            
            // auto period on double space
            // TODO: timeout
            
            //var lastCharCountInBeforeContext: Int = 0
            //var readyForDoubleSpacePeriod: Bool = true
            
            self.handleAutoPeriod(model)
            // TODO: reset context
        }
        
        if self.shiftState == ShiftState.enabled {
            self.shiftState = ShiftState.disabled
        }
        
        self.setCapsIfNeeded()
    }
    
    func handleAutoPeriod(_ key: Key) {
        if !UserDefaults.standard.bool(forKey: kPeriodShortcut) {
            return
        }
        
        if self.autoPeriodState == .firstSpace {
            if key.type != Key.KeyType.space {
                self.autoPeriodState = .noSpace
                return
            }
            
            let charactersAreInCorrectState = { () -> Bool in
                let previousContext = self.textDocumentProxy.documentContextBeforeInput//+20150916
                
                if previousContext == nil || (previousContext!).characters.count < 3 {
                    return false
                }
                
                var index = previousContext!.endIndex
                //swift3
                index = previousContext!.index(before: index) //index = <#T##Collection corresponding to `index`##Collection#>.index(before: index)
                if previousContext![index] != " " {
                    return false
                }
                
                index = previousContext!.index(before: index) //index = <#T##Collection corresponding to `index`##Collection#>.index(before: index)
                if previousContext![index] != " " {
                    return false
                }
                
                index = previousContext!.index(before: index) //index = <#T##Collection corresponding to `index`##Collection#>.index(before: index)
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
            
            self.autoPeriodState = .noSpace
        }
        else {
            if key.type == Key.KeyType.space {
                self.autoPeriodState = .firstSpace
            }
        }
    }
    
    func cancelBackspaceTimers() {
        self.backspaceDelayTimer?.invalidate()
        self.backspaceRepeatTimer?.invalidate()
        self.backspaceDelayTimer = nil
        self.backspaceRepeatTimer = nil
    }
    
    @objc func backspaceDown(_ sender: KeyboardKey) {
        
        self.cancelBackspaceTimers()
        lastchar = "" //+20150129
        lastKey = nil //+20150129
        //+20141229self.playKeySound()
        
        //+20150916if let textDocumentProxy = self.textDocumentProxy as? UIKeyInput {
        let textDocumentProxy = self.textDocumentProxy as UIKeyInput
        
        textDocumentProxy.deleteBackward()
        //+20150326
        let previousContext:String? = self.textDocumentProxy.documentContextBeforeInput
        
        if let banner = self.bannerView as? PredictiveBanner {
            
            if previousContext == nil || previousContext!.isEmpty {
                
                banner.clearBanner()
                
            }else{
                
                let range = previousContext!.range(of: " ", options: NSString.CompareOptions.backwards)
                
                if range != nil {
                    let lastword = previousContext!.substring(from: range!.upperBound)
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
        
        
        //}
        //m+20150101
        // trigger for subsequent deletes
        self.backspaceDelayTimer = Timer.scheduledTimer(timeInterval: backspaceDelay - backspaceRepeat, target: self, selector: #selector(KeyboardViewController.backspaceDelayCallback), userInfo: nil, repeats: false)
    }
    
    @objc func backspaceUp(_ sender: KeyboardKey) {
        self.cancelBackspaceTimers()
        self.setCapsIfNeeded()//+20150930
    }
    
    @objc func backspaceDelayCallback() {
        self.backspaceDelayTimer = nil
        self.backspaceRepeatTimer = Timer.scheduledTimer(timeInterval: backspaceRepeat, target: self, selector: #selector(KeyboardViewController.backspaceRepeatCallback), userInfo: nil, repeats: true)
    }
    
    @objc func backspaceRepeatCallback() {
        
        self.playKeySound()
        //+20150916if let textDocumentProxy = self.textDocumentProxy as? UIKeyInput {
        let textDocumentProxy = self.textDocumentProxy as UIKeyInput
        textDocumentProxy.deleteBackward()
        //m+20150101
        //}
    }
    
    @objc func shiftDown(_ sender: KeyboardKey) {
        //+20141229self.playKeySound()
        
        //m+20150108
        lastKey = nil
        lastchar = "sd" //+20150129
        
        if self.shiftWasMultitapped {
            self.shiftWasMultitapped = false
            return
        }
        
        switch self.shiftState {
        case .disabled:
            self.shiftState = .enabled
        case .enabled:
            self.shiftState = .disabled
        case .locked:
            self.shiftState = .disabled
        }
        
        (sender.shape as? ShiftShape)?.withLock = false
    }
    var needChandrakkala : Bool = false
    //m+20150101
    @objc func characterDoubleTapped(_ sender: KeyboardKey) {
        
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
    @objc func chandrakkalaDoubleTapped(_ sender: KeyboardKey) {
        
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
    
    @objc func shiftDoubleTapped(_ sender: KeyboardKey) {
        
        if lastchar == "sd" {//+20150129
            
            self.shiftWasMultitapped = true
            
            switch self.shiftState {
            case .disabled:
                self.shiftState = .locked
            case .enabled:
                self.shiftState = .locked
            case .locked:
                self.shiftState = .disabled
            }
        }
        
    }
    
    // TODO: this should be uppercase, not lowercase
    func updateKeyCaps(_ lowercase: Bool) {
        if self.layout != nil {
            //let actualUppercase = true// (NSUserDefaults.standardUserDefaults().boolForKey(kSmallLowercase) ? !lowercase : true)
            
            
            //ToDo:only for first page +20150929
            for (pageIndex, page) in self.keyboard.pages.enumerated() {
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
                                
                                if model.type == Key.KeyType.shift {
                                    switch self.shiftState {
                                    case .disabled:
                                        key.isHighlighted = false
                                    case .enabled:
                                        key.isHighlighted = true
                                    case .locked:
                                        key.isHighlighted = true
                                    }
                                    
                                    (key.shape as? ShiftShape)?.withLock = (self.shiftState == .locked)
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
    func updateKeyCapsForSwarangal(_ lowercase: Bool) {
        if self.layout != nil {
            //let actualUppercase = true// (NSUserDefaults.standardUserDefaults().boolForKey(kSmallLowercase) ? !lowercase : true)
            
            
            //ToDo:only for first page +20150929
            for (pageIndex, page) in self.keyboard.pages.enumerated() {
                if pageIndex == 0 {
                    let numRows = page.rows.count
                    for i in 0..<numRows {
                        let numKeys = page.rows[i].count
                        
                        for j in 0..<numKeys {
                            let model = page.rows[i][j]
                            if model.isSwaram {
                                if let key = self.layout?.modelToView[model] {
                                    
                                    key.attributetext = model.keyCapForCase(!lowercase) //+20150323 actualUppercase //m+20150324
                                    
                                    if model.type == Key.KeyType.shift {
                                        switch self.shiftState {
                                        case .disabled:
                                            key.isHighlighted = false
                                        case .enabled:
                                            key.isHighlighted = true
                                        case .locked:
                                            key.isHighlighted = true
                                        }
                                        
                                        (key.shape as? ShiftShape)?.withLock = (self.shiftState == .locked)
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
    @objc func modeChangeTapped(_ sender: KeyboardKey) {
        //+20141229self.playKeySound()
        
        if let toMode = self.layout?.viewToModel[sender]?.toMode {
            self.currentMode = toMode
        }
    }
    //+20141212
    @objc func dismissKB(_ sender: KeyboardKey){
        
        self.dismissKeyboard();
        
    }
    @objc func advanceTapped(_ sender: KeyboardKey) {
        self.forwardingView.resetTrackedViews()
        //self.shiftStartingState = nil
        self.shiftWasMultitapped = false
        
        self.advanceToNextInputMode()
    }
    func setMode(_ mode: Int) {
        for (pageIndex, page) in self.keyboard.pages.enumerated() {
            for (_, row) in page.rows.enumerated() {
                for (_, key) in row.enumerated() {
                    if self.layout?.modelToView[key] != nil {
                        let keyView = self.layout?.modelToView[key]
                        keyView?.isHidden = (pageIndex != mode)
                    }
                }
            }
        }
    }
    
    @IBAction func toggleSettings(_ sender : UIControl) {//+20151022 added argument
        //+20141229self.playKeySound()
        if self.settingsView == nil {
            print("am here to create")
            if let aSettings = self.createSettings() {
                
                print("am here created")
                aSettings.darkMode = self.darkMode()
                
                aSettings.isHidden = true
                self.view.addSubview(aSettings)
                self.settingsView = aSettings
                
                aSettings.translatesAutoresizingMaskIntoConstraints = false
                
                let widthConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
                let heightConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0)
                let centerXConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
                let centerYConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
                
                self.view.addConstraint(widthConstraint)
                self.view.addConstraint(heightConstraint)
                self.view.addConstraint(centerXConstraint)
                self.view.addConstraint(centerYConstraint)
            }
        }
        
        
        
        if let settings = self.settingsView {
            print("am hereto hide")
            let hidden = settings.isHidden
            hidden ? print("settings hidden yes") : print("settings not hidden")
            settings.isHidden = !hidden
            self.forwardingView.isHidden = hidden
            self.forwardingView.isUserInteractionEnabled = !hidden
            self.bannerView?.isHidden = hidden//+20150325
            if settings.isHidden {
                self.view.bringSubview(toFront: self.forwardingView)
                if (self.bannerView != nil) { self.view.bringSubview(toFront: self.bannerView!) }
            } else {
                self.view.bringSubview(toFront: settings)
            }
            print("am not here")
        }
    }
    
    // TODO: make this work if cursor position is shifted
    func setCapsIfNeeded() {
        //+20150929
        if self.shouldAutoCapitalize() {
            switch self.shiftState {
            case .disabled:
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
    
    func characterIsPunctuation(_ character: Character) -> Bool {
        return (character == ".") || (character == "!") || (character == "?")
    }
    
    func characterIsNewline(_ character: Character) -> Bool {
        return (character == "\n") || (character == "\r")
    }
    
    func characterIsWhitespace(_ character: Character) -> Bool {
        // there are others, but who cares
        return (character == " ") || (character == "\n") || (character == "\r") || (character == "\t")
    }
    
    func stringIsWhitespace(_ string: String?) -> Bool {
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
                let previousCharacter = beforeContext[beforeContext.characters.index(before: beforeContext.endIndex)]
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
        
        return UserDefaults.standard.bool(forKey: kCapitalizeSwarangal)//+20150929
        
    }
    
    // this only works if full access is enabled
    @objc func playKeySound() {
        if !UserDefaults.standard.bool(forKey: kKeyboardClicks) {
            return
        }
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
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
    func keyPressed(_ key: Key) {
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
        // note thloadat dark mode is not yet valid here, so we just put false for clarity
        //return ExtraView(globalColors: self.dynamicType.globalColors, darkMode: false, solidColorMode: self.solidColorMode())
        //+20150325
        //
        //        if NSUserDefaults.standardUserDefaults().boolForKey(kDisablePopupKeys) {
        //            return nil
        //        } else{
        //            return PredictiveBanner(keyboard: self)
        //        }
        
        return PredictiveBanner(keyboard: self)
    }
    
    // a settings view that replaces the keyboard when the settings button is pressed
    func createSettings() -> ExtraView? {
        // note that dark mode is not yet valid here, so we just put false for clarity
        let settingsView = DefaultSettings(globalColors: type(of: self).globalColors, darkMode: false, solidColorMode: self.solidColorMode())
        settingsView.backButton?.addTarget(self, action: #selector(KeyboardViewController.toggleSettings(_:)), for: UIControlEvents.touchUpInside)
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
    var dataStore : WordsDAO!
    var searchText :String?
    
    let scrolview : UIScrollView = UIScrollView()
    
    convenience init(keyboard: KeyboardViewController) {
        self.init(globalColors: nil, darkMode: keyboard.darkMode(), solidColorMode: keyboard.solidColorMode())
        self.keyboard = keyboard
        //+20150326
        dataStore = WordsDAO()
        dataStore.initWithDataBase()
        //self.backgroundColor = UIColor.blueColor()
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
    
    deinit {
        dataStore.closeAll()
    }
    override func setNeedsLayout() {
        super.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrolview.frame = self.frame
        self.scrolview.center = self.center
        
        
    }
    
    @objc func handleBtnPress(_ sender: UIButton) {
        if self.keyboard != nil {
            
            //if let textDocumentProxy = self.keyboard!.textDocumentProxy as? UIKeyInput {
            let textDocumentProxy = self.keyboard!.textDocumentProxy as UIKeyInput
            
            if searchText != nil {
                
                //+20151021
                if let previousContext:String? = self.keyboard!.textDocumentProxy.documentContextBeforeInput {
                    
                    let array1: [String]? = previousContext?.components(separatedBy: CharacterSet.whitespacesAndNewlines)
                    if (array1 != nil && array1!.count > 0 ) {
                        
                        let ct2 = array1!.last!.utf16.count
                        for i in 0  ..< ct2 {
                            
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
            
            self.clearBanner()
            self.updateAlternateKeyList(sender.titleLabel!.text!, Mode: 1)
            
            //}
            
            
        }
    }
    
    func applyConstraints(_ currentView: UIButton, prevView: UIView?, nextView: UIView?, firstView: UIView) {
        
        
        let parentView = self
        
        var leftConstraint: NSLayoutConstraint
        var rightConstraint: NSLayoutConstraint
        var topConstraint: NSLayoutConstraint
        var bottomConstraint: NSLayoutConstraint
        
        // Constrain to top of parent view
        topConstraint = NSLayoutConstraint(item: currentView, attribute: .top, relatedBy: .equal, toItem: parentView,
                                           attribute: .top, multiplier: 1.0, constant: 1)
        
        // Constraint to bottom of parent too
        bottomConstraint = NSLayoutConstraint(item: currentView, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1.0, constant: 1)
        
        // If last, constrain to right
        if nextView == nil {
            rightConstraint = NSLayoutConstraint(item: currentView, attribute: .trailing, relatedBy: .equal, toItem: parentView, attribute: .trailing, multiplier: 1.0, constant: 1)
        } else {
            rightConstraint = NSLayoutConstraint(item: currentView, attribute: .trailing, relatedBy: .equal, toItem: nextView, attribute: .leading, multiplier: 1.0, constant: 1)
        }
        
        // If first, constrain to left of parent
        if prevView == nil {
            leftConstraint = NSLayoutConstraint(item: currentView, attribute: .leading, relatedBy: .equal, toItem: parentView, attribute: .leading, multiplier: 1.0, constant: 1)
        } else {
            leftConstraint = NSLayoutConstraint(item: currentView, attribute: .leading, relatedBy: .equal, toItem: prevView, attribute: .trailing, multiplier: 1.0, constant: -1)
            
            
        }
        let widthConstraint = NSLayoutConstraint(item: firstView, attribute: .width, relatedBy: .equal, toItem: currentView, attribute: .width, multiplier: 1.0, constant: 0)
        
        widthConstraint.priority = UILayoutPriority(rawValue: 800)
        
        addConstraint(widthConstraint)
        
        addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        
    }
    
    func clearBanner(){
        
        let sv = scrolview.subviews
        for v in sv {
            v.removeFromSuperview()
        }
        scrolview.scrollRectToVisible(CGRect(x: 0,y: 0,width: 1,height: 1), animated: false)
    }
    func updateAlternateKeyList(_ str: String?, Mode mode: Int32) {
        
        clearBanner()
        
        searchText = str
        
        
        let objects = dataStore.getAllMatchedWords(str, mode: mode)
        
        
        if objects?.count == 0 {
            
            searchText = ""
            return
        }
        
        
        
        scrolview.backgroundColor = UIColor.clear
        
        var i:CGFloat = 0
        var wdth:CGFloat = 0
        var preButton : UIButton?
        for char in objects! {
            
            let btn: UIButton = UIButton(type: UIButtonType.system)
            
            
            let text:String = char as! String
            var startx:CGFloat = 0
            if preButton != nil {
                
                startx = preButton!.frame.origin.x + preButton!.frame.size.width + 1
            }
            
            let sizee: CGSize = (text as NSString).size(withAttributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 16)]);
            
            
            btn.frame = CGRect(x: startx, y: 1, width: sizee.width+10, height: scrolview.frame.size.height-2)
            btn.setTitle(text, for: UIControlState())
            
            
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
            
            btn.setTitleColor(UIColor(white: 1.0, alpha: 1.0), for: UIControlState())
            
            //btn.setContentHuggingPriority(1000, forAxis: .Horizontal)
            //btn.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
            
            btn.addTarget(self, action: #selector(PredictiveBanner.handleBtnPress(_:)), for: .touchUpInside)
            
            scrolview.addSubview(btn)
            preButton = btn
            wdth += preButton!.frame.size.width
            wdth += 1
            i += 1
        }
        
        if wdth < self.frame.size.width {
            
            let firstBtn = scrolview.subviews[0] as! UIButton
            let lastN = (objects?.count)!-1
            var prevBtn: UIButton?
            var nextBtn: UIButton?
            
            for (n, view) in scrolview.subviews.enumerated() {
                let btn = view as! UIButton
                
                btn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
                btn.sizeToFit()
                btn.translatesAutoresizingMaskIntoConstraints = false
                btn.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
                btn.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
                
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
            
            scrolview.contentSize = CGSize(width: wdth, height: scrolview.frame.size.height)
        }
        
        
        
        
    }
    func updateAppearance() {
        
        
        //self.scrolview.sizeToFit()
    }
    
    
}




