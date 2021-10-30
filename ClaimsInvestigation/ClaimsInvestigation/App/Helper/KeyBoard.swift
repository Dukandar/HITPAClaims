//
//  KeyBoard.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 27/07/18.
//  Copyright © 2018 iNubeSolutions. All rights reserved.
//

import UIKit

struct MoveKeyboard {
    static let KEYBOARD_ANIMATION_DURATION : CGFloat = 0.3
    static let MINIMUM_SCROLL_FRACTION  :   CGFloat = 0.2
    static let MAXIMUM_SCROLL_FRACTION  :   CGFloat = 0.8
    static let PORTRATE_KEYBOARD_HEIGHT :   CGFloat = 216.0
}

private var keyBoardInstance : KeyBoard? = nil

class KeyBoard: NSObject {
    
    var animateDistance : CGFloat = 0.0
    
    static var shareKeyboard: KeyBoard
    {
        if (keyBoardInstance == nil)
        {
            keyBoardInstance = KeyBoard()
        }
        return keyBoardInstance!
    }
    
    //TextFiled Animation
    func keyboardAnimationWithTextField(textField : UITextField , view : UIView , isMove : Bool)
    {
        if (isMove)
        {
            animateDistance = 0.0
            let textFieldRect : CGRect = view.window!.convert(textField.bounds, from: textField)
            let viewRect : CGRect = view.window!.convert(view.bounds, from: view)
            
            let midline : CGFloat = textFieldRect.origin.y + 0.5 * textFieldRect.size.height
            let numerator : CGFloat = midline - viewRect.origin.y - MoveKeyboard.MINIMUM_SCROLL_FRACTION * viewRect.size.height
            let denominator : CGFloat = (MoveKeyboard.MAXIMUM_SCROLL_FRACTION - MoveKeyboard.MINIMUM_SCROLL_FRACTION) * viewRect.size.height
            var heightFraction : CGFloat = numerator / denominator
            
            if heightFraction < 0.0 {
                heightFraction = 0.0
            } else if heightFraction > 1.0 {
                heightFraction = 1.0
            }
            animateDistance = floor(MoveKeyboard.PORTRATE_KEYBOARD_HEIGHT * heightFraction)
        }
        var viewFrame : CGRect = view.frame
        viewFrame.origin.y -= (isMove) ? animateDistance : -animateDistance
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(TimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        view.frame = viewFrame
        UIView.commitAnimations()
        
    }
    
    //TextView Animation
    func keyboardAnimationWithTextView(textView : UITextView , view : UIView , isMove : Bool)
    {
        if (isMove)
        {
            let textViewRect : CGRect = view.window!.convert(textView.bounds, from: textView)
            let viewRect : CGRect = view.window!.convert(view.bounds, from: view)
            let midline : CGFloat = textViewRect.origin.y + 0.5 * textViewRect.size.height
            let numerator : CGFloat = midline - viewRect.origin.y - MoveKeyboard.MINIMUM_SCROLL_FRACTION * viewRect.size.height
            let denominator : CGFloat = (MoveKeyboard.MAXIMUM_SCROLL_FRACTION - MoveKeyboard.MINIMUM_SCROLL_FRACTION) * viewRect.size.height
            var heightFraction : CGFloat = numerator / denominator
            
            if heightFraction < 0.50 {
                heightFraction = 0.0
            } else if heightFraction > 1.0 {
                heightFraction = 1.0
            }
            animateDistance = floor(MoveKeyboard.PORTRATE_KEYBOARD_HEIGHT * heightFraction)
        }
        var viewFrame : CGRect = view.frame
        viewFrame.origin.y -= (isMove) ? animateDistance : -animateDistance
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(TimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        view.frame = viewFrame
        UIView.commitAnimations()
        
    }
    
}
