//
//  TextBox.swift
//  ClaimsInvestigation

//
//  Created by Vivek Saini on 27/07/18.
//  Copyright © 2018 iNubeSolutions. All rights reserved.
//

import UIKit

protocol TextBoxProtocol {
    func textFieldWithSuperview(_ superView:UIView, value:String, placeholder:String)
}

class TextBox: UIView {

    var placeHolder : String? = nil
    var isMandatory : Bool?
    var isDependent : Bool? = nil
    var responseValue : String?
    var type : String?
    var delegate : TextBoxProtocol?
    var hideWarning: Bool = false
    var isReadOnly: Bool? = nil
    var fieldID: Int64? = nil

    var warningLabel: String?
    
    convenience init(frame:CGRect, placeHolder: String, isMandatory: Bool, isDependent:Bool, responseValue:String, type: String,delegate: TextBoxProtocol,hideWarningView: Bool,warningText: String,isReadOnly: Bool,fieldID:Int64) {
        
        self.init()
        self.frame = frame
        
        self.placeHolder = placeHolder
        self.isDependent = isDependent
        self.isMandatory = isMandatory
        self.responseValue = responseValue
        self.type = type
        self.delegate = delegate
        self.hideWarning = hideWarningView
        self.warningLabel = warningText
        self.isReadOnly = isReadOnly
        self.fieldID = fieldID
        
        self.setUpTextBox()
        
    }
    
    func setUpTextBox() {
        
        var xPos: CGFloat = 4.0
        var yPos: CGFloat = 4.0
        var width: CGFloat = self.frame.size.width - 8.0
        var height: CGFloat = self.frame.size.height - 8.0
        
        let viewContainer = UIView()
        viewContainer.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        viewContainer.backgroundColor = UIColor.white
        self.addSubview(viewContainer)
        viewContainer.layer.cornerRadius = 4.0
        viewContainer.layer.masksToBounds = true
        
        xPos = 0.0
        yPos = 10.0
        height = 10.0
        width = 10.0

        let mandatoryImage = UIImageView()
        mandatoryImage.frame = CGRect(x: xPos, y: yPos , width: width, height: height)
        mandatoryImage.image = #imageLiteral(resourceName: "icon_mandatory")
        mandatoryImage.isHidden = isMandatory! ? false : true
        mandatoryImage.tag = Int(truncating: isMandatory! as NSNumber)
        viewContainer.addSubview(mandatoryImage)
        
        xPos = mandatoryImage.frame.origin.x + mandatoryImage.frame.size.width + 5.0
        yPos = 5.0
        width = viewContainer.frame.size.width - xPos - 10.0
        height = viewContainer.frame.size.height - 5.0
        
        self.isUserInteractionEnabled = isReadOnly! ? false : true
        
        let textBox = TextField(frame: CGRect(x: xPos, y: yPos, width: width, height: height), placeholder: placeHolder!, responseValue : "")
        
        textBox.autocapitalizationType = .words
        textBox.textColor = isDependent! ? UIColor.lightGray : UIColor.black
        textBox.placeholder = placeHolder!
        textBox.autocorrectionType = .no
        textBox.text = ""
        textBox.delegate = self
        viewContainer.addSubview(textBox)
        
        if self.isUserInteractionEnabled {
            textBox.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 22.0) : UIFont.systemFont(ofSize: 18.0)
        }else {
            textBox.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 22.0) : UIFont.systemFont(ofSize: 16.0)
        }
        
        if self.fieldID == 175373 {
            
            if UIScreen.main.bounds.width > 320 {
                textBox.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 18.0) : UIFont.systemFont(ofSize: 13.0)
            }else {
                textBox.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 18.0) : UIFont.systemFont(ofSize: 12.0)
            }
            textBox.sizeToFit()
        }
        
        textBox.adjustsFontSizeToFitWidth = true
        
        if type == DataType.kNumeric || type == DataType.kContact || type == DataType.kHeightTextBox {
            textBox.keyboardType = .phonePad
            
            let numberToolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 45.0))
            numberToolbar.barStyle = .default
            numberToolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTapped(_:)))]
            numberToolbar.sizeToFit()
            textBox.inputAccessoryView = numberToolbar
            textBox.tag = (type == DataType.kContact) ? 1000 : 0
            
        }else if (type == DataType.kEmail) {
            textBox.keyboardType = .emailAddress
        }
        
        if responseValue != "" && responseValue != nil {
            textBox.text = responseValue!
            
            if isReadOnly! {
                textBox.textColor = UIColor.lightGray
            }
            
            let placeHolderLabel = Utility.sharedUtility.getLabelWithSuperView(superView: textBox)
            if textBox.placeholder != nil {
                placeHolderLabel.text = textBox.placeholder!
                Utility.sharedUtility.labelAnimation(textfield: textBox, isHidden: false)
            }
            
        }else {
            self.isHidden = isDependent! ? true : false
        }
    }

    
    @IBAction func doneButtonTapped(_ sender:UIButton) {
        self.endEditing(true)
    }
    
    func viewController(_ view: UIView) -> UIViewController {
        var responder: UIResponder? = view
        while !(responder is UIViewController) {
            responder = responder?.next
            if nil == responder {
                break
            }
        }
        return (responder as? UIViewController)!
    }
    
    func setPlaceHolderValue(_ label : UILabel)
    {
        if let _ = label.text
        {
            
        }else
        {
            label.text = self.placeHolder
        }
        
    }
}

extension TextBox:UITextFieldDelegate
{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let lineView = textField.superview?.superview?.superview?.viewWithTag(1000)
        if(lineView != nil){
            lineView!.layer.borderColor = UIColor.lightGray.cgColor
            lineView!.layer.borderWidth = 1.0
        }
        
        let subviews = textField.subviews
        let placeholderLbl = subviews[0] as! UILabel
        setPlaceHolderValue(placeholderLbl)
        let viewController = Utility.sharedUtility.getViewController(view: self)
        KeyBoard.shareKeyboard.keyboardAnimationWithTextField(textField: textField, view:  viewController.view, isMove: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.count > 0
        {
            Utility.sharedUtility.labelAnimation(textfield: textField, isHidden: false)
            
        }else if (textField.text?.count)! <= 1 || (string == "" && range.location == 0 && (textField.text?.count)! == 1)
        {
            Utility.sharedUtility.labelAnimation(textfield: textField, isHidden: true)
        }
        
        if type! == DataType.kNumeric || type == DataType.kContact || type == DataType.kHeightTextBox
        {
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let viewController = Utility.sharedUtility.getViewController(view: self)
        KeyBoard.shareKeyboard.keyboardAnimationWithTextField(textField: textField, view:  viewController.view, isMove: false)

        if self.delegate != nil {
            self.delegate?.textFieldWithSuperview(self, value:textField.text!, placeholder:textField.placeholder ?? "")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
