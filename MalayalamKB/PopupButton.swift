//
//  PopupButton.swift
//  MalayalamEditor
//
//  Created by jijo on 4/22/15.
//  Copyright (c) 2015 jeesmon. All rights reserved.
//

import UIKit

class PopupButton: UIControl {
    
    var label: UILabel!
    
    var text : String? {
        
        didSet {
            self.label.text = text
        }
    }
    
    var textColor:UIColor?
    var textColorSelected:UIColor?
    
    var bgColor:UIColor?
    var bgColorSelected:UIColor?
    
    init(){
        
        label = UILabel()
        
        
        self.textColor = UIColor.blackColor()
        self.textColorSelected = UIColor.whiteColor()
        
        self.bgColor = UIColor.whiteColor()
        self.bgColorSelected = GlobalColors.lightModeSpecialKeyiPad
        
        super.init(frame: CGRectZero)
        
        self.label.textAlignment = NSTextAlignment.Center
        //self.label.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        self.label.userInteractionEnabled = false
        self.label.frame = CGRectMake(0.0, self.bounds.height / 3.0, self.bounds.width, self.bounds.height / 3.0)
        
        self.label.textColor = self.textColor
        self.label.backgroundColor = self.bgColor
        
        self.addSubview(self.label)
    }
    override func layoutSubviews() {
        
        super.layoutSubviews()
        self.label.frame = CGRectMake(1.0, self.bounds.height / 3.0 + 1, self.bounds.width - 2, self.bounds.height / 3.0 - 2)
    }
    func highlightLabel(sender: PopupButton) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.label.textColor = self.textColorSelected
        self.label.backgroundColor = self.bgColorSelected
        
        self.label.highlighted = true
        
        CATransaction.commit()
        
        
    }
    func unHighlightLabel(sender: PopupButton) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.label.textColor = self.textColor
        self.label.backgroundColor = self.bgColor
        
        self.label.highlighted = false
        
        CATransaction.commit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}
