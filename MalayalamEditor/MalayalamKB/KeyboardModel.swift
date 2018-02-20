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
    
    func addKey(_ key: Key, row: Int, page: Int) {
        if self.pages.count <= page {
            for _ in self.pages.count...page {
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
    
    func addKey(_ key: Key, row: Int) {
        if self.rows.count <= row {
            for _ in self.rows.count...row {
                self.rows.append([])
            }
        }

        self.rows[row].append(key)
    }
}

class Key: Hashable {
    enum KeyType {
        case character
        case specialCharacter
        case shift
        case backspace
        case numberMalayalam
        case modeChange
        case keyboardChange
        case period
        case space
        case `return`
        case settings
        case dismiss
        case other
    }
    
    var type: KeyType
    
    //m+20150324
    var keyText : String {
        
        didSet{
            
            
            let range = keyText.range(of: "\n.*", options :.regularExpression)
            //+20150929let skipSaram = (NSUserDefaults.standardUserDefaults().boolForKey(kCapitalizeSwarangal) && isSwaram)
            
            if range != nil {//m+20150401 !skipSaram &&
                
                var mainColor = UIColor.black
                let darkmode = false //+20180216UserDefaults(suiteName: "group.com.jeesmon.apps.MalayalamEditor")!.bool(forKey: "darkmode")
                if darkmode == true{
                    mainColor = UIColor.white
                }
                
                var bigSize: CGFloat = 24
                var smallSize: CGFloat = 20
                let isPad = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
                if !isPad {
                    bigSize = 22;
                    smallSize = 20;
                }
                let myMutableString1 = NSMutableAttributedString(string: keyText)
                myMutableString1.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.lightGray, NSAttributedStringKey.font : UIFont.systemFont(ofSize: smallSize)], range: NSMakeRange(1, (keyText as NSString).length-1))
                myMutableString1.addAttributes([NSAttributedStringKey.foregroundColor : mainColor, NSAttributedStringKey.font : UIFont.systemFont(ofSize: bigSize)], range: NSMakeRange(0, 1))
                
                self.uppercaseKeyCap = myMutableString1
                
                let myMutableString = NSMutableAttributedString(string: keyText)
                myMutableString.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.lightGray, NSAttributedStringKey.font : UIFont.systemFont(ofSize: smallSize)], range: NSMakeRange(0, 1))
                myMutableString.addAttributes([NSAttributedStringKey.foregroundColor : mainColor, NSAttributedStringKey.font : UIFont.systemFont(ofSize: bigSize)], range: NSMakeRange(1, (keyText as NSString).length-1))
                
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
    var isTopRow: Bool = false
    
    var isCharacter: Bool {
        get {
            switch self.type {
            case
            .character,
            .specialCharacter,
            .period:
                return true
            default:
                return false
            }
        }
    }
    
    var isSpecial: Bool {
        get {
            switch self.type {
            case .shift:
                return true
            case .backspace:
                return true
            case .modeChange:
                return true
            case .keyboardChange:
                return true
            case .return:
                return true
            case .space:
                return true
            case .settings:
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
    
    func setLetter(_ letter: String) {
        self.lowercaseOutput = (letter as NSString).lowercased
        self.uppercaseOutput = (letter as NSString).uppercased
        //m+20150324 ToDO:j to fix ku nu color in darkmode
        /*if self.lowercaseOutput != nil {
        
            self.lowercaseKeyCap = NSAttributedString(string: self.lowercaseOutput!)
        }*/
        if self.uppercaseOutput != nil {
            
            self.uppercaseKeyCap = NSAttributedString(string: self.uppercaseOutput!)
        }
        

    }
    func extentionValuesCase(_ uppercase: Bool) -> String? {
        
        if uppercase {
            return self.extentionValuesUpper
        }else{
            return self.extentionValues
        }
    }
    
    func outputForCase(_ uppercase: Bool) -> String {
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
    
    func keyCapForCase(_ uppercase: Bool) -> NSAttributedString {//m+20150324
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
