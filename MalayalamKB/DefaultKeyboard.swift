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
            
            keyModel.isSwaram = true
            keyModel.keyText = "ഔ\n\(key)"
            //keyModel.lowercaseKeyCap = key
            keyModel.uppercaseOutput = "ഔ"
            keyModel.lowercaseOutput = key
            
        case "ൈ":
            keyModel.isSwaram = true
            keyModel.keyText = "ഐ\n\(key)"
            keyModel.uppercaseOutput = "ഐ"
            keyModel.lowercaseOutput = key
            
        case "ാ":
            keyModel.isSwaram = true
            keyModel.keyText = "ആ\n\(key)"
            keyModel.uppercaseOutput = "ആ"
            keyModel.lowercaseOutput = key
            
        case "ീ":
            keyModel.isSwaram = true
            keyModel.keyText = "ഈ\n\(key)"
            keyModel.uppercaseOutput = "ഈ"
            keyModel.lowercaseOutput = key
            
        case "ൂ":
            keyModel.isSwaram = true
            keyModel.keyText = "ഊ\n\(key)"
            keyModel.uppercaseOutput = "ഊ"
            keyModel.lowercaseOutput = key
            
       
        case "ബ":
            keyModel.keyText = "ഭ\n\(key)"
            keyModel.uppercaseOutput = "ഭ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            
        case "ങ":
            keyModel.keyText = "ഹ\n\(key)"
            keyModel.uppercaseOutput = "ഹ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            keyModel.primaryValue = 9
        
        case "ഗ":
            keyModel.keyText = "ഘ\n\(key)"
            keyModel.uppercaseOutput = "ഘ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
      
        case "ദ":
            keyModel.keyText = "ധ\n\(key)"
            keyModel.uppercaseOutput = "ധ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "ജ":
            keyModel.keyText = "ഝ\n\(key)"
            keyModel.uppercaseOutput = "ഝ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        
        case "ഡ":
            keyModel.keyText = "ഢ\n\(key)"
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
    
    for key in ["ോ", "േ", "്", "ി", "ു", "പ", "ര", "ക", "ത", "ച", "ട"] { //"ത", "ന", "സ" , "ണ"
        var keyModel = Key(.Character)
        switch key {
        case "ോ":
            keyModel.isSwaram = true
            keyModel.keyText = "ഓ\n\(key)"
            keyModel.uppercaseOutput = "ഓ"
            keyModel.lowercaseOutput = key
            
        case "േ":
            keyModel.isSwaram = true
            keyModel.keyText = "ഏ\n\(key)"
            keyModel.uppercaseOutput = "ഏ"
            keyModel.lowercaseOutput = key
            
        case "്":
            keyModel.isSwaram = true
            keyModel.keyText = "അ\n\(key)"
            keyModel.uppercaseOutput = "അ"
            keyModel.lowercaseOutput = key
            
        case "ി":
            keyModel.isSwaram = true
            keyModel.keyText = "ഇ\n\(key)"
            keyModel.uppercaseOutput = "ഇ"
            keyModel.lowercaseOutput = key
            
        case "ു":
            keyModel.isSwaram = true
            keyModel.keyText = "ഉ\n\(key)"
            keyModel.uppercaseOutput = "ഉ"
            keyModel.lowercaseOutput = key
            
        case "പ":
            keyModel.keyText = "ഫ\n\(key)"
            keyModel.uppercaseOutput = "ഫ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            keyModel.secondaryValue = 5
        case "ര":
            keyModel.keyText = "റ\n\(key)"
            keyModel.uppercaseOutput = "റ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "ക":
            keyModel.keyText = "ഖ\n\(key)"
            keyModel.uppercaseOutput = "ഖ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            keyModel.secondaryValue = 1
        case "ത":
            keyModel.keyText = "ഥ\n\(key)"
            keyModel.uppercaseOutput = "ഥ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            keyModel.secondaryValue = 4
            
        case "ച":
            keyModel.keyText = "ഛ\n\(key)"
            keyModel.uppercaseOutput = "ഛ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            keyModel.secondaryValue = 2
            
        case "ട":
            keyModel.keyText = "ഠ\n\(key)"
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
    returnKey.keyText = "return"
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
            keyModel.isSwaram = true
            keyModel.keyText = "ഒ\n\(key)"
            keyModel.uppercaseOutput = "ഒ"
            keyModel.lowercaseOutput = key
            
        case "െ":
            keyModel.isSwaram = true
            keyModel.keyText = "എ\n\(key)"
            keyModel.uppercaseOutput = "എ"
            keyModel.lowercaseOutput = key
            
        case "മ":
            keyModel.keyText = "ം\n\(key)"
            keyModel.uppercaseOutput = "ം"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            keyModel.primaryValue = 5
        case "ണ":
            keyModel.keyText = "ൺ\n\(key)"
            keyModel.uppercaseOutput = "ൺ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            keyModel.primaryValue = 7
        case "ന":
            keyModel.keyText = "ൻ\n\(key)"
            keyModel.uppercaseOutput = "ൻ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            keyModel.primaryValue = 6
        case "വ":
            keyModel.keyText = "ഴ\n\(key)"
            keyModel.uppercaseOutput = "ഴ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            
        case "ല":
            keyModel.keyText = "ൽ\n\(key)"
            keyModel.uppercaseOutput = "ൽ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "ള":
            keyModel.keyText = "ൾ\n\(key)"
            keyModel.uppercaseOutput = "ൾ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "സ":
            keyModel.keyText = "ശ\n\(key)"
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
        m1.keyText = "!\n,"
        m1.uppercaseOutput = "!"
        m1.lowercaseOutput = ","
        defaultKeyboard.addKey(m1, row: 2, page: 0)
        */
        var m2 = Key(.SpecialCharacter)
        m2.keyText = ".\n,"
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
    keyModeChangeNumbers.keyText = "123"
    keyModeChangeNumbers.toMode = 1
    defaultKeyboard.addKey(keyModeChangeNumbers, row: 3, page: 0)
    
    var keyboardChange = Key(.KeyboardChange)
    defaultKeyboard.addKey(keyboardChange, row: 3, page: 0)
    
    var settings = Key(.Settings)
    defaultKeyboard.addKey(settings, row: 3, page: 0)
    
    //m+20150105
    let ru: String = "ൃ"
    
    var keyModel1 = Key(.Character)
    keyModel1.isSwaram = true
    keyModel1.keyText = "ഋ\n\(ru)"
    keyModel1.uppercaseOutput = "ഋ"
    keyModel1.lowercaseOutput = ru
    
    defaultKeyboard.addKey(keyModel1, row: 3, page: 0)
    
    
    
    
    var space = Key(.Space)
    space.keyText = "space"
    space.uppercaseOutput = " "
    space.lowercaseOutput = " "
    defaultKeyboard.addKey(space, row: 3, page: 0)
    
    
    //m+20150105
    let rr: String = "ഞ"
    
    var keyModelrr = Key(.Character)
    keyModelrr.keyText = "ർ\n\(rr)"
    keyModelrr.uppercaseOutput = "ർ"
    keyModelrr.lowercaseOutput = rr
    keyModelrr.isDoubleTappable = true
    keyModelrr.primaryValue = 8
    defaultKeyboard.addKey(keyModelrr, row: 3, page: 0)
    
    
    var keyModel2 = Key(.Character)
    keyModel2.keyText = "ഷ\nയ"
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
        m2.keyText = ".\n,"
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
            keyModel.keyText = "൦\n\(key)"
            keyModel.uppercaseOutput = "൦"
            keyModel.lowercaseOutput = key
        case "1":
            keyModel.keyText = "൧\n\(key)"
            keyModel.uppercaseOutput = "൧"
            keyModel.lowercaseOutput = key
        case "2":
            keyModel.keyText = "൨\n\(key)"
            keyModel.uppercaseOutput = "൨"
            keyModel.lowercaseOutput = key
        case "3":
            keyModel.keyText = "൩\n\(key)"
            keyModel.uppercaseOutput = "൩"
            keyModel.lowercaseOutput = key
        case "4":
            keyModel.keyText = "൪\n\(key)"
            keyModel.uppercaseOutput = "൪"
            keyModel.lowercaseOutput = key
        case "5":
            keyModel.keyText = "൫\n\(key)"
            keyModel.uppercaseOutput = "൫"
            keyModel.lowercaseOutput = key
            
        case "6":
            keyModel.keyText = "൬\n\(key)"
            keyModel.uppercaseOutput = "൬"
            keyModel.lowercaseOutput = key
        case "7":
            keyModel.keyText = "൭\n\(key)"
            keyModel.uppercaseOutput = "൭"
            keyModel.lowercaseOutput = key
        case "8":
            keyModel.keyText = "൮\n\(key)"
            keyModel.uppercaseOutput = "൮"
            keyModel.lowercaseOutput = key
        case "9":
            keyModel.keyText = "൯\n\(key)"
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
        
        c = symbol! as String
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
    keyModeChangeSpecialCharacters.keyText = "#+="
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
        keyModeChangeSpecialCharacters2.keyText = "#+="
        keyModeChangeSpecialCharacters2.toMode = 2
        defaultKeyboard.addKey(keyModeChangeSpecialCharacters2, row: 2, page: 1)
        
    }else{
        
        defaultKeyboard.addKey(Key(.Backspace), row: 2, page: 1)
        
    }
    
    
    
    var keyModeChangeLetters = Key(.ModeChange)
    keyModeChangeLetters.keyText = "അക"
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
            keyModel.keyText = "ഘ\n\(key)"
            keyModel.uppercaseOutput = "ഘ"
            keyModel.lowercaseOutput = key
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
        case "ഛ":
            var keyModel = Key(.Character)
            keyModel.keyText = "ഝ\n\(key)"
            keyModel.uppercaseOutput = "ഝ"
            keyModel.lowercaseOutput = key
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
        case "ഠ":
            var keyModel = Key(.Character)
            keyModel.keyText = "ഢ\n\(key)"
            keyModel.uppercaseOutput = "ഢ"
            keyModel.lowercaseOutput = key
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
        case "ഥ":
            var keyModel = Key(.Character)
            keyModel.keyText = "ധ\n\(key)"
            keyModel.uppercaseOutput = "ധ"
            keyModel.lowercaseOutput = key
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
        case "ഫ":
            var keyModel = Key(.Character)
            keyModel.keyText = "ബ\n\(key)"
            keyModel.uppercaseOutput = "ബ"
            keyModel.lowercaseOutput = key
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
        case "ഃ":
            var keyModel = Key(.Character)
            keyModel.keyText = "ൿ\n\(key)"
            keyModel.uppercaseOutput = "ൿ"
            keyModel.lowercaseOutput = key
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
            
        case "ൃ":
            var keyModel = Key(.Character)
            keyModel.keyText = "ഋ\n\(key)"
            keyModel.uppercaseOutput = "ഋ"
            keyModel.lowercaseOutput = key
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
        case "ൗ":
            var keyModel = Key(.Character)
            keyModel.keyText = "ഔ\n\(key)"
            keyModel.uppercaseOutput = "ഔ"
            keyModel.lowercaseOutput = key
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
        case ";":
            var keyModel = Key(.SpecialCharacter)
            keyModel.keyText = ":\n\(key)"
            keyModel.uppercaseOutput = ":"
            keyModel.lowercaseOutput = key
            defaultKeyboard.addKey(keyModel, row: 1, page: 1)
        case "\"":
            var keyModel = Key(.SpecialCharacter)
            keyModel.keyText = "'\n\(key)"
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
    keyModeChangeSpecialCharacters.keyText = "#+="
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
        keyModeChangeSpecialCharacters2.keyText = "#+="
        keyModeChangeSpecialCharacters2.toMode = 2
        defaultKeyboard.addKey(keyModeChangeSpecialCharacters2, row: 2, page: 1)
        
    }else{
        
        defaultKeyboard.addKey(Key(.Backspace), row: 2, page: 1)
        
    }
    
    
    
    var keyModeChangeLetters = Key(.ModeChange)
    keyModeChangeLetters.keyText = "അക"
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
