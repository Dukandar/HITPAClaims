//
//  DatePicker.swift
//  ClaimsInvestigation

//
//  Created by Vivek Saini on 29/07/18.
//  Copyright © 2018 iNubeSolutions. All rights reserved.
//

import UIKit

protocol DateProtocol {
    func datePickerWithSuperview(_ superView: UIView, date : Date)
}

class DatePicker: UIView {
    
    var placeHolder: String? = nil
    var calendarView: UIView? = nil
    var delegate: DateProtocol?
    var responseValue: String?
    var isMandatory: Bool?
    var isDependent: Bool? = nil
    var isEmpty: Bool = false
    var hideWarningView: Bool = false
    var isReadOnly: Bool? = nil
    var warningLabel: String?
    
    convenience init(frame: CGRect, placeholder: String,responseValue: String, isMandatory: Bool,delegate: DateProtocol, isDependent: Bool,hideWarningView: Bool, warningText: String,isReadOnly: Bool) {
        
        self.init()
        self.frame = frame
        placeHolder = placeholder
        self.isMandatory = isMandatory
        self.delegate = delegate
        self.responseValue = responseValue
        self.isDependent = isDependent
        self.hideWarningView = hideWarningView
        self.warningLabel = warningText
        self.isReadOnly = isReadOnly
        self.setUpDatePicker()
        
    }
    
    func setUpDatePicker() {
        
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

        
        width = DeviceType.IPAD ? 44.0 : 34.0
        height = DeviceType.IPAD ? 44.0 : 34.0
        xPos = viewContainer.frame.size.width - width
        yPos = (viewContainer.frame.size.height - height)/2
        let dateImage = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        dateImage.image = #imageLiteral(resourceName: "Layer 1424px")
        dateImage.contentMode = UIViewContentMode.scaleAspectFit
        viewContainer.addSubview(dateImage)
    
        
        xPos = mandatoryImage.frame.origin.x + mandatoryImage.frame.size.width + 5.0
        yPos = 10.0
        width = viewContainer.frame.size.width - dateImage.frame.size.width - xPos
        height = viewContainer.frame.size.height - yPos

        let textField = TextField(frame: CGRect(x: xPos, y: yPos, width: width, height: height), placeholder: placeHolder!, responseValue : "")
        textField.placeholder = placeHolder!
        textField.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 18.0) : UIFont.systemFont(ofSize: 16.0)
        textField.textColor = isDependent! ? UIColor.lightGray : UIColor.black
        
        self.isUserInteractionEnabled = isReadOnly! ? false : true
        
        
        let placeHolderLabel = Utility.sharedUtility.getLabelWithSuperView(superView: textField)
        placeHolderLabel.text = textField.placeholder!
        viewContainer.addSubview(textField)
        
        
        if responseValue != "" && responseValue != nil {
            textField.text = responseValue!
            
            if isReadOnly! {
                textField.textColor = UIColor.lightGray
            }
            let placeholderLabel = Utility.sharedUtility.getLabelWithSuperView(superView: textField)
            placeholderLabel.text = textField.placeholder!
            Utility.sharedUtility.labelAnimation(textfield: textField, isHidden: false)
        }
        else {
            self.isHidden = isDependent! ? true : false
        }
        
        //Date Button
        let button = UIButton(frame: viewContainer.frame)
        button.addTarget(self, action: #selector(dateBtnTapped(_:)), for: UIControlEvents.touchUpInside)
        viewContainer.addSubview(button)
        
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
    
    @IBAction func dateBtnTapped(_ sender : UIButton)
    {
//        let view = self.subviews[0].subviews[4]
//        if (view.isHidden) {
//            
//        }else {
//            view.isHidden = true
//        }
        
        let lineView = self.superview?.viewWithTag(1000)
        if(lineView != nil){
            lineView!.layer.borderColor = UIColor.lightGray.cgColor
            lineView!.layer.borderWidth = 1.0
        }

        let viewControllers = Utility.sharedUtility.getViewController(view: self)
        viewControllers.view.endEditing(true)
        let vctr = DatePickerViewController(superview: self, delegate: self)
        vctr.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        vctr.modalPresentationStyle = .overFullScreen
        viewControllers.present(vctr, animated: true, completion: nil)
    
    }
}

extension DatePicker : DatePickerProtocol, UtilityProtocol
{
    func selectedDate(_ date: Date, superview: UIView)
    {
        let dateString = Utility.sharedUtility.getDateStringFromDate(date)
        
        for view in superview.subviews[0].subviews {
            if view.isKind(of: TextField.self) {
                
                let textfield = view as! TextField
                Utility.sharedUtility.labelAnimation(textfield: textfield, isHidden: false)
                textfield.text = dateString
                
                if self.delegate != nil
                {
                    self.delegate?.datePickerWithSuperview(self, date: date)
                }
            }
        }

    }
    
    func dismissAlertWithMessage(message:String)
    {
        let vctr = Utility.sharedUtility.getViewController(view: self)
        let alertView = Utility.sharedUtility.alertView(controller: vctr, delegate: self, title: Configuration.sharedConfiguration.appName(), message: message, buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
        alertView.tag = 1
        vctr.view.addSubview(alertView)
    }
    
    func dismissAlert()
    {
        let vctr = Utility.sharedUtility.getViewController(view: self)
        let alertView = vctr.view.subviews.last
        vctr.navigationController?.navigationBar.isUserInteractionEnabled = true
        alertView?.removeFromSuperview()
    }
}
