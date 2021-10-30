//
//  MediaControl.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 03/09/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

struct MediaControlType {
    static let kImageControl = "image"
    static let kAudioControl = "audio"
    static let kVideoControl = "video"
}

protocol MediaControlProtocol {
    func mediaControlWithSuperview(superView:UIView,name : String,mediaDetails : [String:AnyObject])
}

class MediaControl: UIView {

    var placeHolder: String? = nil
    var isMandatory: Bool?
    var responseValue: String?
    var imageDetails : [String:AnyObject]?
    var refNumber: String?
    var delegate: MediaControlProtocol?
    var hideWarningView: Bool = false
    var warningLabel: String?
    var isReadOnly: Bool? = nil
    var isDependent: Bool? = nil
    var mediaDetails : [String:AnyObject]?
    
    convenience  init(frame: CGRect,placeHolderText: String, responseValue : String,refNumber : String, isMandatory: Bool,mediaDetails:[String:AnyObject],delegate: MediaControlProtocol,hideWarningView: Bool, warningText: String,isReadOnly: Bool,isDependent:Bool) {
        
        self.init()
        self.frame = frame
        self.placeHolder = placeHolderText
        self.responseValue = responseValue
        self.refNumber = refNumber
        self.delegate = delegate
        self.isMandatory = isMandatory
        self.warningLabel = warningText
        self.hideWarningView = hideWarningView
        self.isReadOnly = isReadOnly
        self.isDependent = isDependent
        self.mediaDetails = mediaDetails
        
        setUpMediaControl()
    }
    func setUpMediaControl() {
        
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
        
        width = 10.0
        xPos = 0.0
        yPos = 5.0
        height = 10.0
        let mandatoryImage = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        mandatoryImage.image = #imageLiteral(resourceName: "icon_mandatory")
        mandatoryImage.isHidden = isMandatory! ? false : true
        mandatoryImage.tag = Int(truncating: isMandatory! as NSNumber)
        viewContainer.addSubview(mandatoryImage)
        
        self.isUserInteractionEnabled = isReadOnly! ? false : true
        
        xPos = mandatoryImage.frame.origin.x + mandatoryImage.frame.size.width
        width = viewContainer.frame.size.width - (2 * xPos)
        height = 1.0
        
        yPos = 5.0
        height = viewContainer.frame.size.height - (yPos)
        xPos = mandatoryImage.frame.size.width
        width = viewContainer.frame.size.width - 50.0
        
        let textArea = UITextView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        textArea.text = placeHolder!
        
        if self.isUserInteractionEnabled {
            textArea.textContainerInset = UIEdgeInsetsMake(25.0, 0.0, 0.0, 0.0)
            textArea.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 17.0) : UIFont.systemFont(ofSize: 14.0)

        }else {
            textArea.textContainerInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
            textArea.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 16.0) : UIFont.systemFont(ofSize: 13.0)
        }
        textArea.delegate = self
        textArea.textColor = UIColor.lightGray
        textArea.autocapitalizationType = .sentences
        textArea.autocorrectionType = .no
        textArea.showsVerticalScrollIndicator = false
        viewContainer.addSubview(textArea)
        
        xPos = 5.0
        yPos = 0.0
        height = 25.0
        width = width - 2 * xPos
        let placeHolderlbl = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        placeHolderlbl.font = UIFont.systemFont(ofSize: 14.0)
        placeHolderlbl.textColor = UIColor.black
        placeHolderlbl.isHidden = true
        placeHolderlbl.text = placeHolder!
        textArea.addSubview(placeHolderlbl)
        
        if responseValue != "" && responseValue != nil {
            textArea.text = responseValue!
//            textArea.textColor = UIColor.black
            
            textArea.textColor = isReadOnly! ? UIColor.lightGray : UIColor.black

            Utility.sharedUtility.textviewLabelAnimation(textview: textArea, isHidden: false)
        }else {
            self.isHidden = isDependent! ? true : false
        }
        
        width = DeviceType.IPAD ? 44.0 : 34.0
        height = DeviceType.IPAD ? 44.0 : 34.0
        xPos = viewContainer.frame.size.width - width
        yPos = (viewContainer.frame.size.height - height)/2
        let imageControl = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        imageControl.image = #imageLiteral(resourceName: "ic_input_black")
        imageControl.contentMode = UIViewContentMode.scaleAspectFit
        viewContainer.addSubview(imageControl)
        
        imageControl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mediaControlBtnTapped(_:))))
        imageControl.isUserInteractionEnabled = true
        
    }
    
    @IBAction func mediaControlBtnTapped(_ sender : UITapGestureRecognizer){
        
        self.endEditing(true)
        let viewController = Utility.sharedUtility.getViewController(view: self)

        let subViews = self.subviews[0].subviews
        
        for view in subViews {
            if (view.isKind(of: UITextView.self)) {
                
                let textView = view as! UITextView
                
                if (textView.text.count == 0) || (textView.text == placeHolder!) {
                    
                    textView.textColor = UIColor.red
                    
                }else {
                    
                    let vctr = ImageControlViewController()
                    vctr.delegate = self
                    
                    // added for WebRef -> TabRef
                    vctr.webRefNumber = self.refNumber!
                    
                    if (mediaDetails?.count)! > 0 {
                        vctr.fieldID = ((mediaDetails!["fieldID"] as AnyObject) as! NSNumber as! Int)
                        vctr.mediaNameString = (textView.text)
                    }
                    vctr.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                    vctr.modalPresentationStyle = .overFullScreen
                    
                    viewController.present(vctr, animated: true, completion: nil)
                }
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

extension MediaControl : TextFieldProtocol,ImageControlViewProtocol  {
    
    func cameraControlWithImage(image: UIImage, imageDetail: [String : AnyObject]) {
        
        if self.delegate != nil {
            
            self.delegate?.mediaControlWithSuperview(superView: self, name: "", mediaDetails: imageDetail)
        }
    }
    
    func textFieldWithValue(_ value: String,_ placeholder: String, textField : UITextField) {
        
        self.endEditing(true)
        
        if (textField.text?.isEmpty)! {
            
        }else {
            
            if self.delegate != nil {
                self.delegate?.mediaControlWithSuperview(superView: self, name: textField.text!, mediaDetails: ["placeholder":textField.text as AnyObject])
            }
        }
    }
}


extension MediaControl : UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        textView.textColor = UIColor.black
        
        KeyBoard.shareKeyboard.keyboardAnimationWithTextView(textView: textView, view: (textView.superview?.superview?.superview?.superview)!, isMove: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        KeyBoard.shareKeyboard.keyboardAnimationWithTextView(textView: textView, view: (textView.superview?.superview?.superview?.superview)!, isMove: false)
        
        if self.delegate != nil {
            self.delegate?.mediaControlWithSuperview(superView: self, name: "", mediaDetails: ["placeholder":textView.text as AnyObject])
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




