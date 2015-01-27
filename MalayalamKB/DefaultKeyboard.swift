//
//  DefaultKeyboard.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 7/10/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//
import UIKit

func defaultKeyboard() -> Keyboard {
    
    
    
    var defaultKeyboard = Keyboard()
    
    for key in ["ൗ", "ൈ", "ാ", "ീ", "ൂ", "ബ", "ങ", "ഗ", "ദ", "ജ", "ഡ"] {
        var keyModel = Key(.Character)
        switch key {
        case "ൗ":
            
            keyModel.uppercaseKeyCap = "ഔ\n\(key)"
            keyModel.uppercaseOutput = "ഔ"
            keyModel.lowercaseOutput = key
            keyModel.isSwaram = true
        case "ൈ":
            keyModel.uppercaseKeyCap = "ഐ\n\(key)"
            keyModel.uppercaseOutput = "ഐ"
            keyModel.lowercaseOutput = key
            keyModel.isSwaram = true
        case "ാ":
            keyModel.uppercaseKeyCap = "ആ\n\(key)"
            keyModel.uppercaseOutput = "ആ"
            keyModel.lowercaseOutput = key
            keyModel.isSwaram = true
        case "ീ":
            keyModel.uppercaseKeyCap = "ഈ\n\(key)"
            keyModel.uppercaseOutput = "ഈ"
            keyModel.lowercaseOutput = key
            keyModel.isSwaram = true
        case "ൂ":
            keyModel.uppercaseKeyCap = "ഊ\n\(key)"
            keyModel.uppercaseOutput = "ഊ"
            keyModel.lowercaseOutput = key
            keyModel.isSwaram = true
       
        case "ബ":
            keyModel.uppercaseKeyCap = "ഭ\n\(key)"
            keyModel.uppercaseOutput = "ഭ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            
        case "ങ":
            keyModel.uppercaseKeyCap = "ഹ\n\(key)"
            keyModel.uppercaseOutput = "ഹ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            keyModel.primaryValue = 9
        
        case "ഗ":
            keyModel.uppercaseKeyCap = "ഘ\n\(key)"
            keyModel.uppercaseOutput = "ഘ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
      
        case "ദ":
            keyModel.uppercaseKeyCap = "ധ\n\(key)"
            keyModel.uppercaseOutput = "ധ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "ജ":
            keyModel.uppercaseKeyCap = "ഝ\n\(key)"
            keyModel.uppercaseOutput = "ഝ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        
        case "ഡ":
            keyModel.uppercaseKeyCap = "ഢ\n\(key)"
            keyModel.uppercaseOutput = "ഢ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        default:
            
            keyModel.setLetter(key)
            
        }
        defaultKeyboard.addKey(keyModel, row: 0, page: 0)
    }
    //+20141212 starting ipad
    let isPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
    if isPad {
        var backspace = Key(.Backspace)
        defaultKeyboard.addKey(backspace, row: 0, page: 0)
    }
    
    for key in ["ോ", "േ", "്", "ി", "ു", "പ", "റ", "ക", "ത", "ച", "ട"] { //"ത", "ന", "സ" , "ണ"
        var keyModel = Key(.Character)
        switch key {
        case "ോ":
            keyModel.uppercaseKeyCap = "ഓ\n\(key)"
            keyModel.uppercaseOutput = "ഓ"
            keyModel.lowercaseOutput = key
            keyModel.isSwaram = true
        case "േ":
            keyModel.uppercaseKeyCap = "ഏ\n\(key)"
            keyModel.uppercaseOutput = "ഏ"
            keyModel.lowercaseOutput = key
            keyModel.isSwaram = true
        case "്":
            keyModel.uppercaseKeyCap = "അ\n\(key)"
            keyModel.uppercaseOutput = "അ"
            keyModel.lowercaseOutput = key
            keyModel.isSwaram = true
        case "ി":
            keyModel.uppercaseKeyCap = "ഇ\n\(key)"
            keyModel.uppercaseOutput = "ഇ"
            keyModel.lowercaseOutput = key
            keyModel.isSwaram = true
        case "ു":
            keyModel.uppercaseKeyCap = "ഉ\n\(key)"
            keyModel.uppercaseOutput = "ഉ"
            keyModel.lowercaseOutput = key
            keyModel.isSwaram = true
        case "പ":
            keyModel.uppercaseKeyCap = "ഫ\n\(key)"
            keyModel.uppercaseOutput = "ഫ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            keyModel.secondaryValue = 5
        case "റ":
            keyModel.uppercaseKeyCap = "ര\n\(key)"
            keyModel.uppercaseOutput = "ര"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "ക":
            keyModel.uppercaseKeyCap = "ഖ\n\(key)"
            keyModel.uppercaseOutput = "ഖ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            keyModel.secondaryValue = 1
        case "ത":
            keyModel.uppercaseKeyCap = "ഥ\n\(key)"
            keyModel.uppercaseOutput = "ഥ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            keyModel.secondaryValue = 4
            
        case "ച":
            keyModel.uppercaseKeyCap = "ഛ\n\(key)"
            keyModel.uppercaseOutput = "ഛ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            keyModel.secondaryValue = 2
            
        case "ട":
            keyModel.uppercaseKeyCap = "ഠ\n\(key)"
            keyModel.uppercaseOutput = "ഠ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            keyModel.secondaryValue = 3
            
        default:
            
            keyModel.setLetter(key)
            
        }
        defaultKeyboard.addKey(keyModel, row: 1, page: 0)
    }
    
    var returnKey = Key(.Return)
    returnKey.uppercaseKeyCap = "return"
    returnKey.uppercaseOutput = "\n"
    returnKey.lowercaseOutput = "\n"
    if isPad {
        
        defaultKeyboard.addKey(returnKey, row: 1, page: 0)
    }
    
    var keyModel = Key(.Shift)
    defaultKeyboard.addKey(keyModel, row: 2, page: 0)
    
    for key in ["ൊ", "െ", "മ","ണ", "ന", "വ", "ല", "ള", "സ"] { //, "റ", "യ"
        var keyModel = Key(.Character)
        switch key {
        case "ൊ":
            keyModel.uppercaseKeyCap = "ഒ\n\(key)"
            keyModel.uppercaseOutput = "ഒ"
            keyModel.lowercaseOutput = key
            keyModel.isSwaram = true
        case "െ":
            keyModel.uppercaseKeyCap = "എ\n\(key)"
            keyModel.uppercaseOutput = "എ"
            keyModel.lowercaseOutput = key
            keyModel.isSwaram = true
        case "മ":
            keyModel.uppercaseKeyCap = "ം\n\(key)"
            keyModel.uppercaseOutput = "ം"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            keyModel.primaryValue = 5
        case "ണ":
            keyModel.uppercaseKeyCap = "ൺ\n\(key)"
            keyModel.uppercaseOutput = "ൺ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            keyModel.primaryValue = 7
        case "ന":
            keyModel.uppercaseKeyCap = "ൻ\n\(key)"
            keyModel.uppercaseOutput = "ൻ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            keyModel.primaryValue = 6
        case "വ":
            keyModel.uppercaseKeyCap = "ഴ\n\(key)"
            keyModel.uppercaseOutput = "ഴ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            
        case "ല":
            keyModel.uppercaseKeyCap = "ൽ\n\(key)"
            keyModel.uppercaseOutput = "ൽ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "ള":
            keyModel.uppercaseKeyCap = "ൾ\n\(key)"
            keyModel.uppercaseOutput = "ൾ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "സ":
            keyModel.uppercaseKeyCap = "ശ\n\(key)"
            keyModel.uppercaseOutput = "ശ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
       
        default:
            
            keyModel.setLetter(key)
            
        }
        
        defaultKeyboard.addKey(keyModel, row: 2, page: 0)
    }
    
    
    if isPad {
        
        /*var m1 = Key(.SpecialCharacter)
        m1.uppercaseKeyCap = "!\n,"
        m1.uppercaseOutput = "!"
        m1.lowercaseOutput = ","
        defaultKeyboard.addKey(m1, row: 2, page: 0)
        */
        var m2 = Key(.SpecialCharacter)
        m2.uppercaseKeyCap = ".\n,"
        m2.uppercaseOutput = "."
        m2.lowercaseOutput = ","
        defaultKeyboard.addKey(m2, row: 2, page: 0)
        
        var keyModel = Key(.Shift)
        defaultKeyboard.addKey(keyModel, row: 2, page: 0)
    }else{
        var backspace = Key(.Backspace)
        defaultKeyboard.addKey(backspace, row: 2, page: 0)
    }
    
    
    var keyModeChangeNumbers = Key(.ModeChange)
    keyModeChangeNumbers.uppercaseKeyCap = "123"
    keyModeChangeNumbers.toMode = 1
    defaultKeyboard.addKey(keyModeChangeNumbers, row: 3, page: 0)
    
    var keyboardChange = Key(.KeyboardChange)
    defaultKeyboard.addKey(keyboardChange, row: 3, page: 0)
    
    var settings = Key(.Settings)
    defaultKeyboard.addKey(settings, row: 3, page: 0)
    
    //m+20150105
    let ru: String = "ൃ"
    
    var keyModel1 = Key(.Character)
    keyModel1.uppercaseKeyCap = "ഋ\n\(ru)"
    keyModel1.uppercaseOutput = "ഋ"
    keyModel1.lowercaseOutput = ru
    keyModel1.isSwaram = true
    defaultKeyboard.addKey(keyModel1, row: 3, page: 0)
    
    
    
    
    var space = Key(.Space)
    space.uppercaseKeyCap = "space"
    space.uppercaseOutput = " "
    space.lowercaseOutput = " "
    defaultKeyboard.addKey(space, row: 3, page: 0)
    
    
    //m+20150105
    let rr: String = "ഞ"
    
    var keyModelrr = Key(.Character)
    keyModelrr.uppercaseKeyCap = "ർ\n\(rr)"
    keyModelrr.uppercaseOutput = "ർ"
    keyModelrr.lowercaseOutput = rr
    keyModelrr.isDoubleTappable = true
    keyModelrr.primaryValue = 8
    defaultKeyboard.addKey(keyModelrr, row: 3, page: 0)
    
    
    var keyModel2 = Key(.Character)
    keyModel2.uppercaseKeyCap = "ഷ\nയ"
    keyModel2.uppercaseOutput = "ഷ"
    keyModel2.lowercaseOutput = "യ"
    keyModel2.isDoubleTappable = true
    defaultKeyboard.addKey(keyModel2, row: 3, page: 0)
    
    
    if isPad {
        
        
        defaultKeyboard.addKey(Key(keyModeChangeNumbers), row: 3, page: 0)
        
        var dismiss = Key(.Dismiss)
        defaultKeyboard.addKey(dismiss, row: 3, page: 0)
    }else{
        //m+20150107
        /*var m2 = Key(.SpecialCharacter)
        m2.uppercaseKeyCap = ".\n,"
        m2.uppercaseOutput = "."
        m2.lowercaseOutput = ","
        defaultKeyboard.addKey(m2, row: 3, page: 0)
        */
        defaultKeyboard.addKey(Key(returnKey), row: 3, page: 0)

    }
    
    
    
    
    for key in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"] {
        var keyModel = Key(.SpecialCharacter)
        
        /*switch key {
            
        case "0":
            keyModel.uppercaseKeyCap = "൦\n\(key)"
            keyModel.uppercaseOutput = "൦"
            keyModel.lowercaseOutput = key
        case "1":
            keyModel.uppercaseKeyCap = "൧\n\(key)"
            keyModel.uppercaseOutput = "൧"
            keyModel.lowercaseOutput = key
        case "2":
            keyModel.uppercaseKeyCap = "൨\n\(key)"
            keyModel.uppercaseOutput = "൨"
            keyModel.lowercaseOutput = key
        case "3":
            keyModel.uppercaseKeyCap = "൩\n\(key)"
            keyModel.uppercaseOutput = "൩"
            keyModel.lowercaseOutput = key
        case "4":
            keyModel.uppercaseKeyCap = "൪\n\(key)"
            keyModel.uppercaseOutput = "൪"
            keyModel.lowercaseOutput = key
        case "5":
            keyModel.uppercaseKeyCap = "൫\n\(key)"
            keyModel.uppercaseOutput = "൫"
            keyModel.lowercaseOutput = key
            
        case "6":
            keyModel.uppercaseKeyCap = "൬\n\(key)"
            keyModel.uppercaseOutput = "൬"
            keyModel.lowercaseOutput = key
        case "7":
            keyModel.uppercaseKeyCap = "൭\n\(key)"
            keyModel.uppercaseOutput = "൭"
            keyModel.lowercaseOutput = key
        case "8":
            keyModel.uppercaseKeyCap = "൮\n\(key)"
            keyModel.uppercaseOutput = "൮"
            keyModel.lowercaseOutput = key
        case "9":
            keyModel.uppercaseKeyCap = "൯\n\(key)"
            keyModel.uppercaseOutput = "൯"
            keyModel.lowercaseOutput = key
            
        default:
            
            keyModel.setLetter(key)
            
        }*/
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 0, page: 1)
    }
    if isPad {
        
        defaultKeyboard.addKey(Key(.Backspace), row: 0, page: 1)
    }
    
    let cl = NSLocale.currentLocale()
    let symbol: NSString? = cl.objectForKey(NSLocaleCurrencySymbol) as? NSString
    var c = "₹"
    if symbol != nil {
        
        c = symbol!
    }
    
    for key in ["-", "/", ":", ";", "(", ")", c, "&", "@"] {
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 1, page: 1)
    }
    if isPad {
        
        defaultKeyboard.addKey(Key(returnKey), row: 1, page: 1)
    }else{
        
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter("\"")
        defaultKeyboard.addKey(keyModel, row: 1, page: 1)
        
    }
    
    var keyModeChangeSpecialCharacters = Key(.ModeChange)
    keyModeChangeSpecialCharacters.uppercaseKeyCap = "#+="
    keyModeChangeSpecialCharacters.toMode = 2
    defaultKeyboard.addKey(keyModeChangeSpecialCharacters, row: 2, page: 1)
    
    for key in [".", ",", "?", "!", "'"] {
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 2, page: 1)
    }
    
    if isPad {
        
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter("\"")
        defaultKeyboard.addKey(keyModel, row: 2, page: 1)
        
        var keyModeChangeSpecialCharacters2 = Key(.ModeChange)
        keyModeChangeSpecialCharacters2.uppercaseKeyCap = "#+="
        keyModeChangeSpecialCharacters2.toMode = 2
        defaultKeyboard.addKey(keyModeChangeSpecialCharacters2, row: 2, page: 1)
        
    }else{
        
        defaultKeyboard.addKey(Key(.Backspace), row: 2, page: 1)
        
    }
    
    
    
    var keyModeChangeLetters = Key(.ModeChange)
    keyModeChangeLetters.uppercaseKeyCap = "അക"
    keyModeChangeLetters.toMode = 0
    defaultKeyboard.addKey(keyModeChangeLetters, row: 3, page: 1)
    
    defaultKeyboard.addKey(Key(keyboardChange), row: 3, page: 1)
    
    defaultKeyboard.addKey(Key(settings), row: 3, page: 1)
    
    defaultKeyboard.addKey(Key(space), row: 3, page: 1)
    
    
    var keyModeld = Key(.Character)
    keyModeld.setLetter("ഃ")
    defaultKeyboard.addKey(keyModeld, row: 3, page: 1)

    
    if isPad {
        defaultKeyboard.addKey(Key(keyModeChangeLetters), row: 3, page: 1)
        
        var dismiss = Key(.Dismiss)
        defaultKeyboard.addKey(dismiss, row: 3, page: 1)
    }else{
        defaultKeyboard.addKey(Key(returnKey), row: 3, page: 1)
    }
    
    
    
    for key in ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="] {
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 0, page: 2)
    }
    if isPad {
        
        defaultKeyboard.addKey(Key(.Backspace), row: 0, page: 2)
    }
    
    var d = "£"
    if c == "₹" {
        c = "$"
    }else if c == "$" {
        c = "₹"
    }else{
        d = "$"
        c = "₹"
    }
    
    for key in ["_", "\\", "|", "~", "<", ">", c, d, "€"] {// ¥
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 1, page: 2)
    }
    
    if isPad {
        
        defaultKeyboard.addKey(Key(returnKey), row: 1, page: 2)
    }else{
        
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter("•")
        defaultKeyboard.addKey(keyModel, row: 1, page: 2)
        
    }
    
    defaultKeyboard.addKey(Key(keyModeChangeNumbers), row: 2, page: 2)
    
    for key in [".", ",", "?", "!", "'"] {
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 2, page: 2)
    }
    
    if isPad {
        
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter("\"")
        defaultKeyboard.addKey(keyModel, row: 2, page: 2)
        
        defaultKeyboard.addKey(Key(keyModeChangeNumbers), row: 2, page: 2)
        
    }else{
        
        defaultKeyboard.addKey(Key(.Backspace), row: 2, page: 2)
        
    }
    
    
    
    defaultKeyboard.addKey(Key(keyModeChangeLetters), row: 3, page: 2)
    
    defaultKeyboard.addKey(Key(keyboardChange), row: 3, page: 2)
    
    defaultKeyboard.addKey(Key(settings), row: 3, page: 2)
    
    defaultKeyboard.addKey(Key(space), row: 3, page: 2)
    
    var keyModelk = Key(.Character)
    keyModelk.setLetter("ൿ")
    defaultKeyboard.addKey(keyModelk, row: 3, page: 2)
    
    
    if isPad {
        defaultKeyboard.addKey(Key(keyModeChangeLetters), row: 3, page: 2)
        
        var dismiss = Key(.Dismiss)
        defaultKeyboard.addKey(dismiss, row: 3, page: 2)
    }else{
        defaultKeyboard.addKey(Key(returnKey), row: 3, page: 2)
    }

    /*
    for key in ["ഖ", "ഛ", "ഠ", "ഥ", "ഫ", "ഃ", "ൃ","ൗ", ";", "\""] {
        
        switch key {
            
        case "ഖ":
            var keyModel = Key(.Character)
            keyModel.uppercaseKeyCap = "ഘ\n\(key)"
            keyModel.uppercaseOutput = "ഘ"
            keyModel.lowercaseOutput = key
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
        case "ഛ":
            var keyModel = Key(.Character)
            keyModel.uppercaseKeyCap = "ഝ\n\(key)"
            keyModel.uppercaseOutput = "ഝ"
            keyModel.lowercaseOutput = key
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
        case "ഠ":
            var keyModel = Key(.Character)
            keyModel.uppercaseKeyCap = "ഢ\n\(key)"
            keyModel.uppercaseOutput = "ഢ"
            keyModel.lowercaseOutput = key
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
        case "ഥ":
            var keyModel = Key(.Character)
            keyModel.uppercaseKeyCap = "ധ\n\(key)"
            keyModel.uppercaseOutput = "ധ"
            keyModel.lowercaseOutput = key
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
        case "ഫ":
            var keyModel = Key(.Character)
            keyModel.uppercaseKeyCap = "ബ\n\(key)"
            keyModel.uppercaseOutput = "ബ"
            keyModel.lowercaseOutput = key
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
        case "ഃ":
            var keyModel = Key(.Character)
            keyModel.uppercaseKeyCap = "ൿ\n\(key)"
            keyModel.uppercaseOutput = "ൿ"
            keyModel.lowercaseOutput = key
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
            
        case "ൃ":
            var keyModel = Key(.Character)
            keyModel.uppercaseKeyCap = "ഋ\n\(key)"
            keyModel.uppercaseOutput = "ഋ"
            keyModel.lowercaseOutput = key
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
        case "ൗ":
            var keyModel = Key(.Character)
            keyModel.uppercaseKeyCap = "ഔ\n\(key)"
            keyModel.uppercaseOutput = "ഔ"
            keyModel.lowercaseOutput = key
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
        case ";":
            var keyModel = Key(.SpecialCharacter)
            keyModel.uppercaseKeyCap = ":\n\(key)"
            keyModel.uppercaseOutput = ":"
            keyModel.lowercaseOutput = key
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
        case "\"":
            var keyModel = Key(.SpecialCharacter)
            keyModel.uppercaseKeyCap = "'\n\(key)"
            keyModel.uppercaseOutput = "'"
            keyModel.lowercaseOutput = key
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
        default:
            var keyModel = Key(.SpecialCharacter)
            keyModel.setLetter(key)
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
        }
        
    }
    if isPad {
        
        defaultKeyboard.addKey(Key(returnKey), row: 1, page: 1)
    }
    
    var keyModeChangeSpecialCharacters = Key(.ModeChange)
    keyModeChangeSpecialCharacters.uppercaseKeyCap = "#+="
    keyModeChangeSpecialCharacters.toMode = 2
    defaultKeyboard.addKey(keyModeChangeSpecialCharacters, row: 2, page: 1)
    
    
    
    var keyModels = Key(.Shift)
    defaultKeyboard.addKey(keyModels, row: 2, page: 1)
    
    
    
    for key in [".", ",", "?", "!"] {//"'"
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 2, page: 1)
    }
    
    let cl = NSLocale.currentLocale()
    let symbol: NSString? = cl.objectForKey(NSLocaleCurrencySymbol) as? NSString
    var c = "₹"
    if symbol != nil {
        
        c = symbol!
    }
    
    if isPad {
        
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter(c)
        defaultKeyboard.addKey(keyModel, row: 2, page: 1)
        
        var keyModeChangeSpecialCharacters2 = Key(.ModeChange)
        keyModeChangeSpecialCharacters2.uppercaseKeyCap = "#+="
        keyModeChangeSpecialCharacters2.toMode = 2
        defaultKeyboard.addKey(keyModeChangeSpecialCharacters2, row: 2, page: 1)
        
    }else{
        
        defaultKeyboard.addKey(Key(.Backspace), row: 2, page: 1)
        
    }
    
    
    
    var keyModeChangeLetters = Key(.ModeChange)
    keyModeChangeLetters.uppercaseKeyCap = "അക"
    keyModeChangeLetters.toMode = 0
    defaultKeyboard.addKey(keyModeChangeLetters, row: 3, page: 1)
    
    defaultKeyboard.addKey(Key(keyboardChange), row: 3, page: 1)
    
    defaultKeyboard.addKey(Key(settings), row: 3, page: 1)
    
    
    
    
    defaultKeyboard.addKey(Key(space), row: 3, page: 1)
    
    
    
    if isPad {
        defaultKeyboard.addKey(Key(keyModeChangeLetters), row: 3, page: 1)
        
        var dismiss = Key(.Dismiss)
        defaultKeyboard.addKey(dismiss, row: 3, page: 1)
    }else{
        defaultKeyboard.addKey(Key(returnKey), row: 3, page: 1)
    }
    
    
    
    for key in ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="] {
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 0, page: 2)
    }
    if isPad {
        
        defaultKeyboard.addKey(Key(.Backspace), row: 0, page: 2)
    }
    
    
    //"-", "/", , "(", ")", c, "&", "@"
    for key in ["-","_", "\\", "|", "~", "<", ">", "(", ")", c] {// ¥
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 1, page: 2)
    }
    
    if isPad {
        
        defaultKeyboard.addKey(Key(returnKey), row: 1, page: 2)
    }else{
        
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter("•")
        defaultKeyboard.addKey(keyModel, row: 1, page: 2)
        
    }
    
    defaultKeyboard.addKey(Key(keyModeChangeNumbers), row: 2, page: 2)
    
    for key in ["/", ".", ",", "?", "!"] {
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 2, page: 2)
    }
    
    if isPad {
        
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter("\"")
        defaultKeyboard.addKey(keyModel, row: 2, page: 2)
        
        defaultKeyboard.addKey(Key(keyModeChangeNumbers), row: 2, page: 2)
        
    }else{
        
        defaultKeyboard.addKey(Key(.Backspace), row: 2, page: 2)
        
    }
    
    
    
    defaultKeyboard.addKey(Key(keyModeChangeLetters), row: 3, page: 2)
    
    defaultKeyboard.addKey(Key(keyboardChange), row: 3, page: 2)
    
    defaultKeyboard.addKey(Key(settings), row: 3, page: 2)
    
    defaultKeyboard.addKey(Key(space), row: 3, page: 2)
    
    if isPad {
        defaultKeyboard.addKey(Key(keyModeChangeLetters), row: 3, page: 2)
        
        var dismiss = Key(.Dismiss)
        defaultKeyboard.addKey(dismiss, row: 3, page: 2)
    }else{
        defaultKeyboard.addKey(Key(returnKey), row: 3, page: 2)
    }
    
    */
    
    return defaultKeyboard
}
