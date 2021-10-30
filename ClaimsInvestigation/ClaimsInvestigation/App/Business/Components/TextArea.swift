//
//  TextArea.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 08/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

protocol TextAreaProtocol {
    func textViewWithSuperview(_ superView:UIView, value:String, placeholder:String)
}

class TextArea: UIView {
    
    var placeHolder : String? = nil
    var responseValue : String?
    var delegate: TextAreaProtocol?
    var isMandatory : Bool?
    var hideWarning: Bool = false
    var warningLabel: String?
    var isReadOnly: Bool? = nil
    var isDependent : Bool? = nil
    
    convenience  init(frame: CGRect,placeHolderText: String, responseValue : String, isMandatory: Bool, delegate: TextAreaProtocol,hideWarningView: Bool,warningText: String,isReadOnly: Bool,isDependent : Bool) {
        self.init()
        self.frame = frame
        placeHolder = placeHolderText
        self.responseValue = responseValue
        self.isMandatory = isMandatory
        self.delegate = delegate
        self.hideWarning = hideWarningView
        self.warningLabel = warningText
        self.isReadOnly = isReadOnly
        self.isDependent = isDependent
        
        self.setUpTextArea()
    }
    
    func setUpTextArea()
    {
        var xPos: CGFloat = 4.0
        var yPos: CGFloat = 4.0
        var width: CGFloat = self.frame.size.width - 8.0
        var height: CGFloat = self.frame.size.height - 8.0
        
        let viewContainer = UIView()
        viewContainer.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        viewContainer.backgroundColor = UIColor.white
        self.addSubview(viewContainer)
        
        width = 10.0
        xPos = 0.0
        yPos = 10.0
        height = 10.0
        let mandatoryImage = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        mandatoryImage.image = #imageLiteral(resourceName: "icon_mandatory")
        mandatoryImage.isHidden = isMandatory! ? false : true
        mandatoryImage.tag = Int(truncating: isMandatory! as NSNumber)
        viewContainer.addSubview(mandatoryImage)
        
        xPos = mandatoryImage.frame.origin.x + mandatoryImage.frame.size.width
        yPos = 4.0
        width = viewContainer.frame.size.width - xPos * 2
        height = viewContainer.frame.size.height - yPos * 2
        
        let textArea = UITextView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        textArea.text = placeHolder!
        textArea.delegate = self
        textArea.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 16.0) : UIFont.systemFont(ofSize: 14.0)
        textArea.textColor = UIColor.lightGray
        textArea.textContainerInset = UIEdgeInsetsMake(30.0, 0.0, 0.0, 0.0)
        textArea.backgroundColor = UIColor.white
        textArea.autocapitalizationType = .sentences
        textArea.autocorrectionType = .no
        viewContainer.addSubview(textArea)
        
        xPos = 5.0
        yPos = 20.0
        height = 30.0
        width = width - 2 * xPos
        let placeHolderlbl = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        placeHolderlbl.font = UIFont.systemFont(ofSize: 14.0)
        placeHolderlbl.textColor = UIColor.black
        placeHolderlbl.isHidden = true
        placeHolderlbl.text = placeHolder!
        textArea.addSubview(placeHolderlbl)
        
        self.isUserInteractionEnabled = isReadOnly! ? false : true
            
        if responseValue != "" && responseValue != nil {
            
            textArea.text = responseValue!
//            textArea.textColor = UIColor.black
            textArea.textColor = isReadOnly! ? UIColor.lightGray : UIColor.black
            
            Utility.sharedUtility.textviewLabelAnimation(textview: textArea, isHidden: false)

        }else {
            self.isHidden = isDependent! ? true : false
            
            if self.isReadOnly! {
                textArea.textContainerInset = UIEdgeInsetsMake(10.0, 0.0, 0.0, 0.0)
            }
        }
        
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
    
}

extension TextArea : UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView) {
        let lineView = textView.superview?.superview?.superview?.viewWithTag(1000)
        if(lineView != nil){
            lineView!.layer.borderColor = UIColor.lightGray.cgColor
            lineView!.layer.borderWidth = 1.0
        }
        
        KeyBoard.shareKeyboard.keyboardAnimationWithTextView(textView: textView, view: (textView.superview?.superview?.superview?.superview)!, isMove: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        KeyBoard.shareKeyboard.keyboardAnimationWithTextView(textView: textView, view: (textView.superview?.superview?.superview?.superview)!, isMove: false)
        if self.delegate != nil {
            self.delegate?.textViewWithSuperview(self, value: textView.text!, placeholder: placeHolder!)
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == placeHolder! {
            textView.text = ""
            textView.textColor = UIColor.black
            
            Utility.sharedUtility.textviewLabelAnimation(textview: textView, isHidden: false)
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            if textView.text == "" {
                textView.text = placeHolder!
                textView.textColor = UIColor.lightGray
                Utility.sharedUtility.textviewLabelAnimation(textview: textView, isHidden: true)
            }
            return false
        }

        return true
    }
}

extension String {
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    var camelCasedString: String {
        return self.components(separatedBy: " ")
            .map { return $0.lowercased().capitalizingFirstLetter() }
            .joined()
    }

}




