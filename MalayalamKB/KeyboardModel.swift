//
//  KeyboardModel.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 7/10/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import Foundation
import UIKit

var counter = 0

class Keyboard {
    var pages: [Page]
    
    init() {
        self.pages = []
    }
    
    func addKey(key: Key, row: Int, page: Int) {
        if self.pages.count <= page {
            for i in self.pages.count...page {
                self.pages.append(Page())
            }
        }
        
        self.pages[page].addKey(key, row: row)
    }
}

class Page {
    var rows: [[Key]]
    
    init() {
        self.rows = []
    }
    
    func addKey(key: Key, row: Int) {
        if self.rows.count <= row {
            for i in self.rows.count...row {
                self.rows.append([])
            }
        }

        self.rows[row].append(key)
    }
}

class Key: Hashable {
    enum KeyType {
        case Character
        case SpecialCharacter
        case Shift
        case Backspace
        case ModeChange
        case KeyboardChange
        case Period
        case Space
        case Return
        case Settings
        case Dismiss
        case Other
    }
    
    var type: KeyType
    
    //m+20150324
    var keyText : String {
        
        didSet{
            
            
            let range = keyText.rangeOfString("\n.*", options :.RegularExpressionSearch)
            let skipSaram = (NSUserDefaults.standardUserDefaults().boolForKey(kCapitalizeSwarangal) && isSwaram)
            
            if !skipSaram && range != nil {//m+20150401
                
                let myMutableString1 = NSMutableAttributedString(string: keyText)
                myMutableString1.addAttributes([NSForegroundColorAttributeName : UIColor.grayColor(), NSFontAttributeName : UIFont.systemFontOfSize(20)], range: NSMakeRange(1, (keyText as NSString).length-1))
                myMutableString1.addAttributes([NSForegroundColorAttributeName : UIColor.blackColor(), NSFontAttributeName : UIFont.systemFontOfSize(24)], range: NSMakeRange(0, 1))
                
                self.uppercaseKeyCap = myMutableString1
                
                
                let myMutableString = NSMutableAttributedString(string: keyText)
                myMutableString.addAttributes([NSForegroundColorAttributeName : UIColor.grayColor(), NSFontAttributeName : UIFont.systemFontOfSize(20)], range: NSMakeRange(0, 1))
                myMutableString.addAttributes([NSForegroundColorAttributeName : UIColor.blackColor(), NSFontAttributeName : UIFont.systemFontOfSize(24)], range: NSMakeRange(1, (keyText as NSString).length-1))
               
                self.lowercaseKeyCap = myMutableString
                
                
            }else{
                
                self.uppercaseKeyCap = NSAttributedString(string: keyText)
            }
        }
        
        
    }
    
    var uppercaseKeyCap: NSAttributedString?
    var lowercaseKeyCap: NSAttributedString?
    var uppercaseOutput: String?
    var lowercaseOutput: String?
    var toMode: Int? //if the key is a mode button, this indicates which page it links to
    var isDoubleTappable: Bool //m+20150101
    var primaryValue: Int8 //+20150108
    var secondaryValue: Int8
    var isSwaram: Bool
    var extentionValues: String?
    var extentionValuesUpper: String?
    var isLeftExtention: Bool = false
    
    var isCharacter: Bool {
        get {
            switch self.type {
            case
            .Character,
            .SpecialCharacter,
            .Period:
                return true
            default:
                return false
            }
        }
    }
    
    var isSpecial: Bool {
        get {
            switch self.type {
            case .Shift:
                return true
            case .Backspace:
                return true
            case .ModeChange:
                return true
            case .KeyboardChange:
                return true
            case .Return:
                return true
            case .Space:
                return true
            case .Settings:
                return true
            default:
                return false
            }
        }
    }
    
    var hasOutput: Bool {
        get {
            return (self.uppercaseOutput != nil) || (self.lowercaseOutput != nil)
        }
    }
    
    // TODO: this is kind of a hack
    var hashValue: Int
    
    init(_ type: KeyType) {
        //+m+20150101
        self.isDoubleTappable = false
        self.primaryValue = 0
        self.secondaryValue = 0
        self.isSwaram = false
        
        self.type = type
        self.hashValue = counter
        counter += 1
        keyText = "" //m+20150324
    }
    
    convenience init(_ key: Key) {
        self.init(key.type)
        
        self.uppercaseKeyCap = key.uppercaseKeyCap
        self.lowercaseKeyCap = key.lowercaseKeyCap
        self.uppercaseOutput = key.uppercaseOutput
        self.lowercaseOutput = key.lowercaseOutput
        self.toMode = key.toMode
    }
    
    func setLetter(letter: String) {
        self.lowercaseOutput = (letter as NSString).lowercaseString
        self.uppercaseOutput = (letter as NSString).uppercaseString
        //m+20150324
        if self.lowercaseOutput != nil {
        
            self.lowercaseKeyCap = NSAttributedString(string: self.lowercaseOutput!)
        }
        if self.uppercaseOutput != nil {
            
            self.uppercaseKeyCap = NSAttributedString(string: self.uppercaseOutput!)
        }
        

    }
    func extentionValuesCase(uppercase: Bool) -> String? {
        
        if uppercase {
            return self.extentionValuesUpper
        }else{
            return self.extentionValues
        }
    }
    
    func outputForCase(uppercase: Bool) -> String {
        if uppercase {
            if self.uppercaseOutput != nil {
                return self.uppercaseOutput!
            }
            else if self.lowercaseOutput != nil {
                return self.lowercaseOutput!
            }
            else {
                return ""
            }
        }
        else {
            if self.lowercaseOutput != nil {
                return self.lowercaseOutput!
            }
            else if self.uppercaseOutput != nil {
                return self.uppercaseOutput!
            }
            else {
                return ""
            }
        }
    }
    
    func keyCapForCase(uppercase: Bool) -> NSAttributedString {//m+20150324
        if uppercase {
            if self.uppercaseKeyCap != nil {
                return self.uppercaseKeyCap!
            }
            else if self.lowercaseKeyCap != nil {
                return self.lowercaseKeyCap!
            }
            else {
                return NSAttributedString(string : "")
            }
        }
        else {
            if self.lowercaseKeyCap != nil {
                return self.lowercaseKeyCap!
            }
            else if self.uppercaseKeyCap != nil {
                return self.uppercaseKeyCap!
            }
            else {
                return NSAttributedString(string : "")
            }
        }
    }
}

func ==(lhs: Key, rhs: Key) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
