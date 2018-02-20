//
//  ImageKey.swift
//  TastyImitationKeyboard
//
//  Created by Alexei Baboulevitch on 11/2/14.
//  Copyright (c) 2014 Alexei Baboulevitch. All rights reserved.
//

import UIKit

class ImageKey: KeyboardKey {
    
    //+20141212
    var isdismiss: Bool = false
    
    init(vibrancy optionalVibrancy: VibrancyType?, isdismissalkb: Bool) {
        
        isdismiss = isdismissalkb;
        super.init(vibrancy: optionalVibrancy)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var image: UIImageView? {
        willSet {
            let anImage = image
            anImage?.removeFromSuperview()
        }
        didSet {
            if let imageView = image {
                self.addSubview(imageView)
                imageView.contentMode = UIViewContentMode.scaleAspectFit
                self.redrawImage()
                updateColors()
            }
        }
    }
    
    override func updateColors() {
        super.updateColors()
        
        let switchColors = self.isHighlighted || self.isSelected
        
        if switchColors {
            if let downTextColor = self.downTextColor {
                self.image?.tintColor = downTextColor
            }
            else {
                self.image?.tintColor = self.textColor
            }
        }
        else {
            self.image?.tintColor = self.textColor
        }
    }
    
    override func refreshShapes() {
        super.refreshShapes()
        self.redrawImage()
    }
    
    func redrawImage() {
        if let image = self.image {
            var imageSize = CGSize(width: 20, height: 20)
            if isdismiss {
                imageSize = CGSize(width: 45, height: 45)
            }
            let imageOrigin = CGPoint(
                x: (self.bounds.width - imageSize.width) / CGFloat(2),
                y: (self.bounds.height - imageSize.height) / CGFloat(2))
            var imageFrame = CGRect.zero
            imageFrame.origin = imageOrigin
            imageFrame.size = imageSize
            
            image.frame = imageFrame
        }
    }
}
