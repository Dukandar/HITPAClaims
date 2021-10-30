//
//  TextField.swift
//  ClaimsInvestigation

//
//  Created by Vivek Saini on 20/07/18.
//  Copyright © 2018 iNubeSolutions. All rights reserved.
//

import UIKit

protocol TextFieldProtocol {
    func textFieldWithValue(_ value: String,_ placeholder: String, textField : UITextField)
}

class TextField: UITextField {
    
    var txtFieldDelegate : TextFieldProtocol?
    var isSecureEditing:Bool = false
    var responseValue: String?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        placeHolderLabel()
        
    }
    
     init(frame: CGRect, placeholder : String, responseValue : String) {
        super.init(frame: frame)
        delegate = self
        self.placeholder = placeholder
        self.responseValue = responseValue
        placeHolderLabel()
    }
    
    
    //Place holder label
    func placeHolderLabel()
    {
        var xPos,yPos,width,height : CGFloat
            
        xPos = 0.0
        yPos = 14.0
        width = self.frame.size.width
        height = 20.0
        let placeHolderlbl = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        placeHolderlbl.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 14.0) : UIFont.systemFont(ofSize: 13.0)
        placeHolderlbl.textColor = UIColor.lightGray
        placeHolderlbl.isHidden = true
        placeHolderlbl.text = self.placeholder
        placeHolderlbl.sizeToFit()
        
        self.addSubview(placeHolderlbl)
        
        if responseValue != "" && responseValue != nil {
            self.text = responseValue!
            Utility.sharedUtility.labelAnimation(textfield: self, isHidden: false)
        }
        
    }
    
    func setPlaceHolderValue(_ label: UILabel) {
        
        if let _ = label.text {
            
        }else {
            label.text = self.placeholder
        }
    }
}

extension TextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let vc = Utility.sharedUtility.getViewController(view: self)
        
        KeyBoard.shareKeyboard.keyboardAnimationWithTextField(textField: textField, view:  vc.view, isMove: true)
        if textField.isSecureTextEntry == true && (textField.text?.count)! > 0 {
            isSecureEditing = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var filtered:String! = nil
        if textField.tag == 1 {
            let alphabets = "0123456789 "
            let characerSet = (NSCharacterSet.init(charactersIn: alphabets)).inverted
            filtered = (string.components(separatedBy: characerSet)).joined(separator: "")
            
        }
        if string.count > 0
        {
            if textField.tag == 1 {
                if string == filtered {
                    Utility.sharedUtility.labelAnimation(textfield: textField, isHidden: false)
                }
                else {
                    return false
                }
            }
            else {
                if(string == " "){
                    return false
                }else{
                    Utility.sharedUtility.labelAnimation(textfield: textField, isHidden: false)
                }
            }
            
        }else if (textField.text?.count)! <= 1 || (string == "" && range.location == 0 && (textField.text?.count)! == 1) || (string == "" && isSecureEditing && textField.isSecureTextEntry)
        {
            Utility.sharedUtility.labelAnimation(textfield: textField, isHidden: true)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let viewController = Utility.sharedUtility.getViewController(view: self)
        KeyBoard.shareKeyboard.keyboardAnimationWithTextField(textField: textField, view:  viewController.view, isMove: false)
        if self.txtFieldDelegate != nil {
            self.txtFieldDelegate?.textFieldWithValue(textField.text!, textField.placeholder!, textField: textField)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
