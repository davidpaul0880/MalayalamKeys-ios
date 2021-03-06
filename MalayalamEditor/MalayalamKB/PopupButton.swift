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
    var darkMode: Bool
    var text : String? {
        
        didSet {
            self.label.text = text
        }
    }
    
    var textColor:UIColor?
    var textColorSelected:UIColor?
    
    var bgColor:UIColor?
    var bgColorSelected:UIColor?
    
    init(isDarkmode: Bool){
        
        label = UILabel()
        
        darkMode = isDarkmode
        //if darkMode {
            self.textColor = GlobalColors.popupButtonTextColor
            self.textColorSelected = GlobalColors.popupButtonSelectedTextColor
            self.bgColor = GlobalColors.popupButtonBGColor
            
            self.bgColorSelected = GlobalColors.popupButtonSelectedBGColor
        //} else {
            //self.textColor = UIColor.blackColor()
           // self.textColorSelected = UIColor.whiteColor()
        
           // self.bgColor = UIColor.whiteColor()
           // self.bgColorSelected = GlobalColors.lightModeSpecialKeyiPad
        //}
        super.init(frame: CGRect.zero)
        
        //self.backgroundColor = self.bgColor
        self.label.textAlignment = NSTextAlignment.center
        //self.label.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        self.label.isUserInteractionEnabled = false
        self.label.frame = CGRect(x: 0.0, y: self.bounds.height / 3.0, width: self.bounds.width, height: self.bounds.height / 3.0)
        self.label.adjustsFontSizeToFitWidth = true;
        self.label.minimumScaleFactor = CGFloat(0.6)
        self.label.textColor = self.textColor
        self.label.backgroundColor = self.bgColor
        
        self.addSubview(self.label)
    }
    override func layoutSubviews() {
        
        super.layoutSubviews()
        self.label.frame = CGRect(x: 1.0, y: self.bounds.height / 3.0 + 1, width: self.bounds.width - 2, height: self.bounds.height / 3.0 - 2)
    }
    func highlightLabel(_ sender: PopupButton) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.label.textColor = self.textColorSelected
        self.label.backgroundColor = self.bgColorSelected
        
        self.label.isHighlighted = true
        
        CATransaction.commit()
        
        
    }
    func unHighlightLabel(_ sender: PopupButton) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.label.textColor = self.textColor
        self.label.backgroundColor = self.bgColor
        
        self.label.isHighlighted = false
        
        CATransaction.commit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}
