//
//  KeyboardKey.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 6/9/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

// TODO: correct corner radius
// TODO: refactor

// popup constraints have to be setup with the topmost view in mind; hence these callbacks
protocol KeyboardKeyProtocol: class {
    func frameForPopup(key: KeyboardKey, direction: Direction) -> CGRect
    func willShowPopup(key: KeyboardKey, direction: Direction) //may be called multiple times during layout
    func willHidePopup(key: KeyboardKey)
    
}
protocol KeyboardKeyExtentionProtocol: class {
    
    func keyPressedExtention(value: String) //m+20150423
    func hideExtPoup(sender: KeyboardKey)
}

enum VibrancyType {
    case LightSpecial
    case DarkSpecial
    case DarkRegular
}

class KeyboardKey: UIControl {
    
    weak var delegate: KeyboardKeyProtocol?
    weak var delegateExtention: KeyboardKeyExtentionProtocol?
    
    var vibrancy: VibrancyType?
    
    var attributetext: NSAttributedString {
        
        didSet {

            self.label.attributedText = attributetext;
            
            //self.label.text = text
            
            self.label.frame = CGRectMake(self.labelInset, self.labelInset - 1, self.bounds.width - self.labelInset * 2, self.bounds.height - self.labelInset * 2) ////m+20150324 -3
            
            self.redrawText()
        }
    }
    
    var color: UIColor { didSet { updateColors() }}
    var underColor: UIColor { didSet { updateColors() }}
    var borderColor: UIColor { didSet { updateColors() }}
    var popupColor: UIColor { didSet { updateColors() }}
    var drawUnder: Bool { didSet { updateColors() }}
    var drawOver: Bool { didSet { updateColors() }}
    var drawBorder: Bool { didSet { updateColors() }}
    var underOffset: CGFloat { didSet { updateColors() }}
    
    var textColor: UIColor? { didSet { updateColors() }}//m+20150324
    var downColor: UIColor? { didSet { updateColors() }}
    var downUnderColor: UIColor? { didSet { updateColors() }}
    var downBorderColor: UIColor? { didSet { updateColors() }}
    var downTextColor: UIColor? { didSet { updateColors() }}
    
    var labelInset: CGFloat = 0 {
        didSet {
            if oldValue != labelInset {
                self.label.frame = CGRectMake(self.labelInset, self.labelInset - 1, self.bounds.width - self.labelInset * 2, self.bounds.height - self.labelInset * 2) //m+20150324 -3
            }
        }
    }
    
    var shouldRasterize: Bool = false {
        didSet {
            for view in [self.displayView, self.borderView, self.underView] {
                view?.layer.shouldRasterize = shouldRasterize
                view?.layer.rasterizationScale = UIScreen.mainScreen().scale
            }
        }
    }
    
    var popupDirection: Direction?
    
    override var enabled: Bool { didSet { updateColors() }}
    override var selected: Bool {
        didSet {
            updateColors()
        }
    }
    override var highlighted: Bool {
        didSet {
            updateColors()
        }
    }
    
    override var frame: CGRect {
        didSet {
            self.redrawText()
            
        }
    }
    
    var label: UILabel
    var popupLabel: UILabel?
    var shape: Shape? {
        didSet {
            if oldValue != nil && shape == nil {
                oldValue?.removeFromSuperview()
            }
            self.redrawShape()
            updateColors()
        }
    }
    
    var background: KeyboardKeyBackground
    var popup: KeyboardKeyBackground?
    var popupExtended: UIView? //+20150421
    var connector: KeyboardConnector?
    
    var displayView: ShapeView
    var borderView: ShapeView?
    var underView: ShapeView?
    
    var shadowView: UIView
    var shadowLayer: CALayer
    
    init(vibrancy optionalVibrancy: VibrancyType?) {
        self.vibrancy = optionalVibrancy
        
        self.displayView = ShapeView()
        self.underView = ShapeView()
        self.borderView = ShapeView()
        
        self.shadowLayer = CAShapeLayer()
        self.shadowView = UIView()
        
        self.label = UILabel()
        self.attributetext = NSAttributedString(string: "") //m+20150324
        
        self.color = UIColor.whiteColor()
        self.underColor = UIColor.grayColor()
        self.borderColor = UIColor.blackColor()
        self.popupColor = UIColor.whiteColor()
        self.drawUnder = true
        self.drawOver = true
        self.drawBorder = false
        self.underOffset = 1
        
        self.background = KeyboardKeyBackground(cornerRadius: 4, underOffset: self.underOffset)
        
        self.textColor = nil //m+20150324UIColor.blackColor()
        self.popupDirection = nil
        
        super.init(frame: CGRectZero)
        
        self.addSubview(self.shadowView)
        self.shadowView.layer.addSublayer(self.shadowLayer)
        
        self.addSubview(self.displayView)
        if let underView = self.underView {
            self.addSubview(underView)
        }
        if let borderView = self.borderView {
            self.addSubview(borderView)
        }
        
        self.addSubview(self.background)
        self.background.addSubview(self.label)
        
        let _: Void = {
            self.displayView.opaque = false
            self.underView?.opaque = false
            self.borderView?.opaque = false
            
            self.shadowLayer.shadowOpacity = Float(0.2)
            self.shadowLayer.shadowRadius = 4
            self.shadowLayer.shadowOffset = CGSizeMake(0, 3)
            
            self.borderView?.lineWidth = CGFloat(0.5)
            self.borderView?.fillColor = UIColor.clearColor()
            
            self.label.textAlignment = NSTextAlignment.Center
            self.label.baselineAdjustment = UIBaselineAdjustment.AlignCenters
            self.label.font = self.label.font.fontWithSize(22)
            self.label.adjustsFontSizeToFitWidth = true
            self.label.minimumScaleFactor = CGFloat(0.1)
            self.label.userInteractionEnabled = false
            self.label.numberOfLines = 2//+201412
            }()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func setNeedsLayout() {
        return super.setNeedsLayout()
    }
    
    var oldBounds: CGRect?
    override func layoutSubviews() {
        self.layoutPopupIfNeeded()
        
        let boundingBox = (self.popup != nil ? CGRectUnion(self.bounds, self.popup!.frame) : self.bounds)
        
        if self.bounds.width == 0 || self.bounds.height == 0 {
            return
        }
        if oldBounds != nil && CGSizeEqualToSize(boundingBox.size, oldBounds!.size) {
            return
        }
        oldBounds = boundingBox
        
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        self.background.frame = self.bounds
        self.label.frame = CGRectMake(self.labelInset, self.labelInset - 1, self.bounds.width - self.labelInset * 2, self.bounds.height - self.labelInset * 2) //m+20150324 -3
        
        self.displayView.frame = boundingBox
        self.shadowView.frame = boundingBox
        self.borderView?.frame = boundingBox
        self.underView?.frame = boundingBox
        
        CATransaction.commit()
        
        self.refreshViews()
    }
    
    func refreshViews() {
        self.refreshShapes()
        self.redrawText()
        self.redrawShape()
        self.updateColors()
    }
    
    func refreshShapes() {
        // TODO: dunno why this is necessary
        self.background.setNeedsLayout()
        
        self.background.layoutIfNeeded()
        self.popup?.layoutIfNeeded()
        self.connector?.layoutIfNeeded()
        
        let testPath = UIBezierPath()
        let edgePath = UIBezierPath()
        
        let unitSquare = CGRectMake(0, 0, 1, 1)
        
        // TODO: withUnder
        let addCurves = { (fromShape: KeyboardKeyBackground?, toPath: UIBezierPath, toEdgePaths: UIBezierPath) -> Void in
            if let shape = fromShape {
                let path = shape.fillPath
                let translatedUnitSquare = self.displayView.convertRect(unitSquare, fromView: shape)
                let transformFromShapeToView = CGAffineTransformMakeTranslation(translatedUnitSquare.origin.x, translatedUnitSquare.origin.y)
                path?.applyTransform(transformFromShapeToView)
                if path != nil { toPath.appendPath(path!) }
                if let edgePaths = shape.edgePaths {
                    for (_, anEdgePath) in edgePaths.enumerate() {
                        let editablePath = anEdgePath
                        editablePath.applyTransform(transformFromShapeToView)
                        toEdgePaths.appendPath(editablePath)
                    }
                }
            }
        }
        
        addCurves(self.popup, testPath, edgePath)
        addCurves(self.connector, testPath, edgePath)
        
        let shadowPath = UIBezierPath(CGPath: testPath.CGPath)
        
        addCurves(self.background, testPath, edgePath)
        
        let underPath = self.background.underPath
        let translatedUnitSquare = self.displayView.convertRect(unitSquare, fromView: self.background)
        let transformFromShapeToView = CGAffineTransformMakeTranslation(translatedUnitSquare.origin.x, translatedUnitSquare.origin.y)
        underPath?.applyTransform(transformFromShapeToView)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let _ = self.popup {
            self.shadowLayer.shadowPath = shadowPath.CGPath
        }
        
        self.underView?.curve = underPath
        self.displayView.curve = testPath
        self.borderView?.curve = edgePath
        
        if let borderLayer = self.borderView?.layer as? CAShapeLayer {
            borderLayer.strokeColor = UIColor.greenColor().CGColor
        }
        
        CATransaction.commit()
    }
    
    func layoutPopupIfNeeded() {
        if self.popup != nil && self.popupDirection == nil {
            self.shadowView.hidden = false
            self.borderView?.hidden = false
            
            self.popupDirection = Direction.Up
            
            self.layoutPopup(self.popupDirection!)
            self.configurePopup(self.popupDirection!)
            
            self.delegate?.willShowPopup(self, direction: self.popupDirection!)
        }
        else {
            self.shadowView.hidden = true
            self.borderView?.hidden = true
        }
    }
    
    func redrawText() {
        //        self.keyView.frame = self.bounds
        //        self.button.frame = self.bounds
        //
        //        self.button.setTitle(self.text, forState: UIControlState.Normal)
    }
    
    func redrawShape() {
        if let shape = self.shape {
            self.attributetext = NSAttributedString(string: "") //m+20150324
            shape.removeFromSuperview()
            self.addSubview(shape)
            
            let pointOffset: CGFloat = 4
            let size = CGSizeMake(self.bounds.width - pointOffset - pointOffset, self.bounds.height - pointOffset - pointOffset)
            shape.frame = CGRectMake(
                CGFloat((self.bounds.width - size.width) / 2.0),
                CGFloat((self.bounds.height - size.height) / 2.0),
                size.width,
                size.height)
            
            shape.setNeedsLayout()
        }
    }
    
    func updateColors() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let switchColors = self.highlighted || self.selected
        
        if switchColors {
            if let downColor = self.downColor {
                self.displayView.fillColor = downColor
            }
            else {
                self.displayView.fillColor = self.color
            }
            
            if let downUnderColor = self.downUnderColor {
                self.underView?.fillColor = downUnderColor
            }
            else {
                self.underView?.fillColor = self.underColor
            }
            
            if let downBorderColor = self.downBorderColor {
                self.borderView?.strokeColor = downBorderColor
            }
            else {
                self.borderView?.strokeColor = self.borderColor
            }
            
            if let downTextColor = self.downTextColor {
                self.label.textColor = downTextColor
                self.popupLabel?.textColor = downTextColor
                self.shape?.color = downTextColor
            }
            else {
                //m+20150324
                if self.textColor  != nil {
                    self.label.textColor = self.textColor
                }
                
                self.popupLabel?.textColor = self.textColor
                self.shape?.color = self.textColor
            }
        }
        else {
            self.displayView.fillColor = self.color
            
            self.underView?.fillColor = self.underColor
            
            self.borderView?.strokeColor = self.borderColor
            //m+20150324
            if self.textColor  != nil {
                self.label.textColor = self.textColor
            }
            
            self.popupLabel?.textColor = self.textColor
            self.shape?.color = self.textColor
        }
        
        if self.popup != nil {
            self.displayView.fillColor = self.popupColor
        }
        
        CATransaction.commit()
    }
    
    func layoutPopup(dir: Direction) {
        assert(self.popup != nil, "popup not found")
        
        if let popup = self.popup {
            if let delegate = self.delegate {
                let frame = delegate.frameForPopup(self, direction: dir)
                popup.frame = frame
                popupLabel?.frame = popup.bounds
            }
            else {
                popup.frame = CGRectZero
                popup.center = self.center
            }
        }
    }
    
    func configurePopup(direction: Direction) {
        assert(self.popup != nil, "popup not found")
        
        self.background.attach(direction)
        self.popup!.attach(direction.opposite())
        
        let kv = self.background
        let p = self.popup!
        
        self.connector?.removeFromSuperview()
        self.connector = KeyboardConnector(cornerRadius: 4, underOffset: self.underOffset, start: kv, end: p, startConnectable: kv, endConnectable: p, startDirection: direction, endDirection: direction.opposite())
        self.connector!.layer.zPosition = -1
        self.addSubview(self.connector!)
        
        //        self.drawBorder = true
        
        if direction == Direction.Up {
            //            self.popup!.drawUnder = false
            //            self.connector!.drawUnder = false
        }
    }
    //+20150421
    func showExpandPopup(value: String, isleft: Bool, famee: CGRect, isNumberPopup: Bool){
        

        if(highlighted){
            
            hidePopup()
            
            if self.popupExtended == nil {
            
             
                
                let arrayVals = value.componentsSeparatedByString(",")
                
                let isPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
                
                var widthh =  self.bounds.size.width
                var heightt =  self.bounds.size.height
                var xx = self.bounds.origin.x
                if(isPad){
                    widthh = 3.0 * widthh / 4.0
                    heightt -= 5;
                } else {
                    if (isNumberPopup ) {
                        widthh = 3.0 * widthh / 4.0
                        xx -= (widthh * CGFloat(3))
                    } else {
                        widthh += 2;
                    }
                }
                if isleft {
                    xx -= (widthh * CGFloat(arrayVals.count - 1))
                    if(isPad){
                        xx += 20;
                    }
                }
              
                let popup = UIView(frame: CGRectMake(xx , self.bounds.origin.y -  heightt - 2, widthh * CGFloat(arrayVals.count), heightt) )
                popup.backgroundColor = UIColor.whiteColor()
                
                var x = 0
                
                for eachChar in arrayVals {
                    
                    let btn: PopupButton = PopupButton()//UIButton.buttonWithType(UIButtonType.System) as! UIButton//PopupButton()
                    btn.frame = CGRectMake(CGFloat(x++) * widthh , 0.0 - heightt, widthh, heightt * 3)
                    btn.text = eachChar
                    //btn.setTitle(eachChar, forState: .Normal)
                    btn.tag = x
                    btn.addTarget(btn, action: Selector("highlightLabel:"), forControlEvents: [.TouchDragEnter, .TouchDragInside]  )
                    btn.addTarget(btn, action: Selector("unHighlightLabel:"), forControlEvents: [.TouchUpOutside, .TouchDragOutside, .TouchDragExit])
                    
                    btn.addTarget(self, action: Selector("selectedKey:"), forControlEvents: .TouchUpInside)
                    
                    popup.addSubview(btn)
                }
                

                popup.tag = 12
                self.addSubview(popup)
            
                self.popupExtended = popup


            }
        }
        
    }
    func selectedKey(sender: PopupButton) {
        
        if sender.label.highlighted {
            
            delegateExtention?.keyPressedExtention(sender.label.text!)
            
        }
        delegateExtention?.hideExtPoup(self)
    }

    func hideExtendedPopup(){
        
        //m+20150421
        if self.popupExtended != nil {
            
            self.popupExtended?.removeFromSuperview()
            self.popupExtended = nil
        }
    }
    func showPopup(value: String) { //m+20150101
        if self.popup == nil && self.popupExtended == nil { //m+20150422  
            self.layer.zPosition = 1000
            
            let popup = KeyboardKeyBackground(cornerRadius: 9.0, underOffset: self.underOffset)
            self.popup = popup
            self.addSubview(popup)
            
            let popupLabel = UILabel()
            popupLabel.textAlignment = self.label.textAlignment
            popupLabel.baselineAdjustment = self.label.baselineAdjustment
            popupLabel.font = self.label.font.fontWithSize(22 * 2)
            popupLabel.adjustsFontSizeToFitWidth = self.label.adjustsFontSizeToFitWidth
            popupLabel.minimumScaleFactor = CGFloat(0.1)
            popupLabel.userInteractionEnabled = false
            popupLabel.numberOfLines = 1
            popupLabel.frame = popup.bounds
            popupLabel.text = value//self.label.text
            popup.addSubview(popupLabel)
            self.popupLabel = popupLabel
            
            self.label.hidden = true
        }
    }
    
    func hidePopup() {
        if self.popup != nil {
            self.delegate?.willHidePopup(self)
            
            self.popupLabel?.removeFromSuperview()
            self.popupLabel = nil
            
            self.connector?.removeFromSuperview()
            self.connector = nil
            
            self.popup?.removeFromSuperview()
            self.popup = nil
            
            self.label.hidden = false
            self.background.attach(nil)
            
            self.layer.zPosition = 0
            
            self.popupDirection = nil
        }
        
    }
}

/*
PERFORMANCE NOTES

* CAShapeLayer: convenient and low memory usage, but chunky rotations
* drawRect: fast, but high memory usage (looks like there's a backing store for each of the 3 views)
* if I set CAShapeLayer to shouldRasterize, perf is *almost* the same as drawRect, while mem usage is the same as before
* oddly, 3 CAShapeLayers show the same memory usage as 1 CAShapeLayer — where is the backing store?
* might want to move to drawRect with combined draw calls for performance reasons — not clear yet
*/

class ShapeView: UIView {
    
    var shapeLayer: CAShapeLayer? //+roll let +20150421
    
    override class func layerClass() -> AnyClass {
        return CAShapeLayer.self
    }
    
    var curve: UIBezierPath? {
        didSet {
            if let layer = self.shapeLayer {
                layer.path = curve?.CGPath
            }
            else {
                self.setNeedsDisplay()
            }
        }
    }
    
    var fillColor: UIColor? {
        didSet {
            if let layer = self.shapeLayer {
                layer.fillColor = fillColor?.CGColor
            }
            else {
                self.setNeedsDisplay()
            }
        }
    }
    
    var strokeColor: UIColor? {
        didSet {
            if let layer = self.shapeLayer {
                layer.strokeColor = strokeColor?.CGColor
            }
            else {
                self.setNeedsDisplay()
            }
        }
    }
    
    var lineWidth: CGFloat? {
        didSet {
            if let layer = self.shapeLayer {
                if let lineWidth = self.lineWidth {
                    layer.lineWidth = lineWidth
                }
            }
            else {
                self.setNeedsDisplay()
            }
        }
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if let myLayer = self.layer as? CAShapeLayer {
            self.shapeLayer = myLayer
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawCall(rect:CGRect) {
        if self.shapeLayer == nil {
            if let curve = self.curve {
                if let lineWidth = self.lineWidth {
                    curve.lineWidth = lineWidth
                }
                
                if let fillColor = self.fillColor {
                    fillColor.setFill()
                    curve.fill()
                }
                
                if let strokeColor = self.strokeColor {
                    strokeColor.setStroke()
                    curve.stroke()
                }
            }
        }
    }
    
    //    override func drawRect(rect: CGRect) {
    //        if self.shapeLayer == nil {
    //            self.drawCall(rect)
    //        }
    //    }
}
