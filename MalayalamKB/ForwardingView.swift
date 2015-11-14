//
//  ForwardingView.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 7/19/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

class ForwardingView: UIView {
    
    var touchToView: [UITouch:UIView]
    var longPressKey: UIControl?
    var lastTouchPosition: CGPoint? //+20151113
    var lastTouch: UITouch?
    
    override init(frame: CGRect) {
        self.touchToView = [:]
        
        super.init(frame: frame)
        
        self.contentMode = UIViewContentMode.Redraw
        self.multipleTouchEnabled = true
        self.userInteractionEnabled = true
        self.opaque = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // Why have this useless drawRect? Well, if we just set the backgroundColor to clearColor,
    // then some weird optimization happens on UIKit's side where tapping down on a transparent pixel will
    // not actually recognize the touch. Having a manual drawRect fixes this behavior, even though it doesn't
    // actually do anything.
    override func drawRect(rect: CGRect) {}
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent!) -> UIView? {
        if self.hidden || self.alpha == 0 || !self.userInteractionEnabled {
            return nil
        }
        else {
            return (CGRectContainsPoint(self.bounds, point) ? self : nil)
        }
    }
    
    func handleControl(view: UIView?, controlEvent: UIControlEvents) {
        if let control = view as? UIControl {
            
                let targets = control.allTargets() as NSSet
                for target in targets.allObjects { // TODO: Xcode crashes
                    let actions = control.actionsForTarget(target, forControlEvent: controlEvent)
                   
                    if (actions != nil) {
                        for action in actions! {
                            let selector = Selector(action )
                            control.sendAction(selector, to: target, forEvent: nil)
                        }
                    }
                }
            }
            
        
    }
    
    // TODO: there's a bit of "stickiness" to Apple's implementation
    func findNearestView(position: CGPoint) -> UIView? {
        if !self.bounds.contains(position) {
            return nil
        }
        
        var closest: (UIView, CGFloat)? = nil
        
        for anyView in self.subviews {
            let view = anyView 
            
            if view.hidden {
                continue
            }
            
            //m+20140522view.alpha = 1
            
            //var isFound = false
            
            //m+20140522
            if let popview = view.viewWithTag(12) {
                
                //("view = \(view.description)")
                
                //let widthh = 3.0 * view.frame.size.width / 4.0
                //let heightt = 3.0 * view.frame.size.height / 4.0
                
                //let parentrect = CGRectMake(view.frame.origin.x , view.frame.origin.y -  heightt - 2, 0, 0)
                //var rectClosest = CGRectZero
                
                for anyBtnView in popview.subviews {
                    
                    let viewbtn = anyBtnView 
                    
                    let rect1 = popview.convertRect(viewbtn.frame, toView: self)

                    //var rect1 = viewbtn.frame
                    //rect1.origin.x += parentrect.origin.x
                    //rect1.origin.y += parentrect.origin.y
                    
                    //("rect = \(rect1.origin.x),\(rect1.origin.y),\(rect1.size.width),\(rect1.size.height)")
                    
                    let distance = distanceBetween(rect1, point: position)
                    //("distance = \(distance)")
                    
                    if closest != nil {
                        if distance < closest!.1 {
                            closest = (viewbtn, distance)
                            //rectClosest = rect1
                        }
                    }
                    else {
                        closest = (viewbtn, distance)
                        //rectClosest = rect1
                    }
                    
                    
                }
                
                
                if popview.bounds.contains(position) {
                    
                    return closest!.0
                }
                
            }
            
            if let f = view as? UIControl {
                
                if f.enabled {
                    
                    let distance = distanceBetween(view.frame, point: position)
                    
                    if closest != nil {
                        if distance < closest!.1 {
                            closest = (view, distance)
                        }
                    }
                    else {
                        closest = (view, distance)
                    }
                }
                
            }
            
            //("distance2 = \(distance)")
            
            //("closest!.0 = \(closest!.0.description)")
            
        }
        
        if closest != nil {
            return closest!.0
        }
        else {
            return nil
        }
    }
    
    // http://stackoverflow.com/questions/3552108/finding-closest-object-to-cgpoint b/c I'm lazy
    func distanceBetween(rect: CGRect, point: CGPoint) -> CGFloat {
        if CGRectContainsPoint(rect, point) {
            return 0
        }
        
        var closest = rect.origin
        
        if (rect.origin.x + rect.size.width < point.x) {
            closest.x += rect.size.width
        }
        else if (point.x > rect.origin.x) {
            closest.x = point.x
        }
        if (rect.origin.y + rect.size.height < point.y) {
            closest.y += rect.size.height
        }
        else if (point.y > rect.origin.y) {
            closest.y = point.y
        }
        
        let a = pow(Double(closest.y - point.y), 2)
        let b = pow(Double(closest.x - point.x), 2)
        return CGFloat(sqrt(a + b));
    }
    
    // reset tracked views without cancelling current touch
    func resetTrackedViews() {
        for view in self.touchToView.values {
            self.handleControl(view, controlEvent: .TouchCancel)
        }
        self.touchToView.removeAll(keepCapacity: true)
    }
    
    func ownView(newTouch: UITouch, viewToOwn: UIView?) -> Bool {
        var foundView = false
        
        if viewToOwn != nil {
            for (touch, view) in self.touchToView {
                if viewToOwn == view {
                    if touch == newTouch {
                        break
                    }
                    else {
                        self.touchToView[touch] = nil
                        foundView = true
                    }
                    break
                }
            }
        }
        
        self.touchToView[newTouch] = viewToOwn
        return foundView
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for obj in touches {
            let touch = obj 
            let position = touch.locationInView(self)
            lastTouchPosition = position
            lastTouch = touch
            let view = findNearestView(position)
            
            let viewChangedOwnership = self.ownView(touch, viewToOwn: view)
            
            if !viewChangedOwnership {
                self.handleControl(view, controlEvent: .TouchDown)
                
                if touch.tapCount > 1 {
                    // two events, I think this is the correct behavior but I have not tested with an actual UIControl
                    self.handleControl(view, controlEvent: .TouchDownRepeat)
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for obj in touches {
            let touch = obj 
            let position = touch.locationInView(self)
            lastTouchPosition = position
            lastTouch = touch
            let oldView = self.touchToView[touch]
            let newView = findNearestView(position)
            
            //("newview = \(newView?.description)")
            
            //m+20150422
            if let control = newView as? UIControl {
                
                if control.enabled {
                    
                    if oldView != newView {
                        self.handleControl(oldView, controlEvent: .TouchDragExit)
                        
                        let viewChangedOwnership = self.ownView(touch, viewToOwn: newView)
                        
                        if !viewChangedOwnership {
                            self.handleControl(newView, controlEvent: .TouchDragEnter)
                        }
                        else {
                            self.handleControl(newView, controlEvent: .TouchDragInside)
                        }
                    }
                    else {
                        self.handleControl(oldView, controlEvent: .TouchDragInside)
                    }
                }else{//m+20150423
                    /*
                    if oldView!.tag > 0 && oldView != newView  {
                        
                        self.handleControl(oldView, controlEvent: .TouchDragExit)
                    }else{
                        
                        self.handleControl(oldView, controlEvent: .TouchDragInside)
                    }*/
                }
            }
            
            
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for obj in touches {
            let touch = obj 
            
            let view = self.touchToView[touch]
            
            let touchPosition = touch.locationInView(self)
            lastTouchPosition = touchPosition
            lastTouch = touch
            if self.bounds.contains(touchPosition) {
                //m+20150422
                if let control = view as? UIControl {
                    if control.enabled {
                        //("endeddd enabled")
                        self.handleControl(view, controlEvent: .TouchUpInside)
                    }else{
                        //("endeddd --f")
                        //this is to input same pressed key when touch-up from anywhere
                        self.handleControl(longPressKey , controlEvent: .TouchUpInside)
                    }
                }
                
                
            }
            else {
                //("endeddd cancel")
                self.handleControl(view, controlEvent: .TouchCancel)
            }
            
            self.touchToView[touch] = nil
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        for obj in touches! {
            let touch = obj
            lastTouchPosition = CGPointZero
            lastTouch = nil
            let view = self.touchToView[touch]
            
            self.handleControl(view, controlEvent: .TouchCancel)
            
            self.touchToView[touch] = nil
        }
    }
}
