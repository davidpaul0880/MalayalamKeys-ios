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
    
    for key in ["്‌", "ാ‍", "ി", "ീ", "ു", "ൂ", "െ", "േ", "ൈ", "ൊ"] {
        var keyModel = Key(.Character)
        switch key {
        case "്‌":
            keyModel.uppercaseKeyCap = "അ\n\(key)"
            keyModel.uppercaseOutput = "അ"
            keyModel.lowercaseOutput = key
        case "ാ‍":
            keyModel.uppercaseKeyCap = "ആ\n\(key)"
            keyModel.uppercaseOutput = "ആ"
            keyModel.lowercaseOutput = key
        case "ി":
            keyModel.uppercaseKeyCap = "ഇ\n\(key)"
            keyModel.uppercaseOutput = "ഇ"
            keyModel.lowercaseOutput = key
        case "ീ":
            keyModel.uppercaseKeyCap = "ഈ\n\(key)"
            keyModel.uppercaseOutput = "ഈ"
            keyModel.lowercaseOutput = key
        case "ു":
            keyModel.uppercaseKeyCap = "ഉ\n\(key)"
            keyModel.uppercaseOutput = "ഉ"
            keyModel.lowercaseOutput = key
            
        case "ൂ":
            keyModel.uppercaseKeyCap = "ഊ\n\(key)"
            keyModel.uppercaseOutput = "ഊ"
            keyModel.lowercaseOutput = key
            
        case "െ":
            keyModel.uppercaseKeyCap = "എ\n\(key)"
            keyModel.uppercaseOutput = "എ"
            keyModel.lowercaseOutput = key
            
        case "േ":
            keyModel.uppercaseKeyCap = "ഏ\n\(key)"
            keyModel.uppercaseOutput = "ഏ"
            keyModel.lowercaseOutput = key
        case "ൈ":
            keyModel.uppercaseKeyCap = "ഐ\n\(key)"
            keyModel.uppercaseOutput = "ഐ"
            keyModel.lowercaseOutput = key
        case "ൊ":
            keyModel.uppercaseKeyCap = "ഒ\n\(key)"
            keyModel.uppercaseOutput = "ഒ"
            keyModel.lowercaseOutput = key
            
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
    
    for key in ["ക", "ങ", "ച", "ഞ", "ട", "ണ", "ത", "ന", "സ", "ോ"] {
        var keyModel = Key(.Character)
        switch key {
        case "ക":
            keyModel.uppercaseKeyCap = "ഗ\n\(key)"
            keyModel.uppercaseOutput = "ഗ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "ങ":
            keyModel.uppercaseKeyCap = "ശ\n\(key)"
            keyModel.uppercaseOutput = "ശ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "ച":
            keyModel.uppercaseKeyCap = "ജ\n\(key)"
            keyModel.uppercaseOutput = "ജ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "ഞ":
            keyModel.uppercaseKeyCap = "ഷ\n\(key)"
            keyModel.uppercaseOutput = "ഷ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "ട":
            keyModel.uppercaseKeyCap = "ഡ\n\(key)"
            keyModel.uppercaseOutput = "ഡ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "ണ":
            keyModel.uppercaseKeyCap = "ൺ\n\(key)"
            keyModel.uppercaseOutput = "ൺ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "ത":
            keyModel.uppercaseKeyCap = "ദ\n\(key)"
            keyModel.uppercaseOutput = "ദ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "ന":
            keyModel.uppercaseKeyCap = "ൻ\n\(key)"
            keyModel.uppercaseOutput = "ൻ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "സ":
            keyModel.uppercaseKeyCap = "ഹ\n\(key)"
            keyModel.uppercaseOutput = "ഹ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "ോ":
            keyModel.uppercaseKeyCap = "ഓ\n\(key)"
            keyModel.uppercaseOutput = "ഓ"
            keyModel.lowercaseOutput = key
            
            
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
    
    for key in ["പ","മ","യ", "വ", "ല", "ള", "റ"] {
        var keyModel = Key(.Character)
        switch key {
            
        case "പ":
            keyModel.uppercaseKeyCap = "ഭ\n\(key)"
            keyModel.uppercaseOutput = "ഭ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "മ":
            keyModel.uppercaseKeyCap = "ം\n\(key)"
            keyModel.uppercaseOutput = "ം"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "യ":
            keyModel.uppercaseKeyCap = "ഴ\n\(key)"
            keyModel.uppercaseOutput = "ഴ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
        case "വ":
            keyModel.uppercaseKeyCap = "ര\n\(key)"
            keyModel.uppercaseOutput = "ര"
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
        case "റ":
            keyModel.uppercaseKeyCap = "ർ\n\(key)"
            keyModel.uppercaseOutput = "ർ"
            keyModel.lowercaseOutput = key
            keyModel.isDoubleTappable = true
            
        default:
            
            keyModel.setLetter(key)
            
        }
        
        defaultKeyboard.addKey(keyModel, row: 2, page: 0)
    }
    
    
    if isPad {
        
        var m1 = Key(.SpecialCharacter)
        m1.uppercaseKeyCap = "!\n,"
        m1.uppercaseOutput = "!"
        m1.lowercaseOutput = ","
        defaultKeyboard.addKey(m1, row: 2, page: 0)
        
        var m2 = Key(.SpecialCharacter)
        m2.uppercaseKeyCap = "?\n."
        m2.uppercaseOutput = "?"
        m2.lowercaseOutput = "."
        defaultKeyboard.addKey(m2, row: 2, page: 0)
        
        var keyModel = Key(.Shift)
        defaultKeyboard.addKey(keyModel, row: 2, page: 0)
    }else{
        var backspace = Key(.Backspace)
        defaultKeyboard.addKey(backspace, row: 2, page: 0)
    }
    
    
    var keyModeChangeNumbers = Key(.ModeChange)
    keyModeChangeNumbers.uppercaseKeyCap = "123ഖ"
    keyModeChangeNumbers.toMode = 1
    defaultKeyboard.addKey(keyModeChangeNumbers, row: 3, page: 0)
    
    var keyboardChange = Key(.KeyboardChange)
    defaultKeyboard.addKey(keyboardChange, row: 3, page: 0)
    
    var settings = Key(.Settings)
    defaultKeyboard.addKey(settings, row: 3, page: 0)
    
    var space = Key(.Space)
    space.uppercaseKeyCap = "space"
    space.uppercaseOutput = " "
    space.lowercaseOutput = " "
    defaultKeyboard.addKey(space, row: 3, page: 0)
    
    if isPad {
        
        
        defaultKeyboard.addKey(Key(keyModeChangeNumbers), row: 3, page: 0)
        
        var dismiss = Key(.Dismiss)
        defaultKeyboard.addKey(dismiss, row: 3, page: 0)
    }else{
        defaultKeyboard.addKey(Key(returnKey), row: 3, page: 0)
    }
    
    
    
    
    for key in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"] {
        var keyModel = Key(.SpecialCharacter)
        
        switch key {
            
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
            
        }
        
        defaultKeyboard.addKey(keyModel, row: 0, page: 1)
    }
    if isPad {
        
        defaultKeyboard.addKey(Key(.Backspace), row: 0, page: 1)
    }
    
    
    
    /*for key in ["-", "/", ":", ";", "(", ")", c, "&", "@"] {
    var keyModel = Key(.SpecialCharacter)
    keyModel.setLetter(key)
    defaultKeyboard.addKey(keyModel, row: 1, page: 1)
    }*/
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
    
    
    
    return defaultKeyboard
}
