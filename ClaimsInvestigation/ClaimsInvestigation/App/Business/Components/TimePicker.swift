//
//  TimePicker.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 29/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

protocol TimeProtocol {
    func timePickerWithSuperview(_ superView:UIView,timeString : String)
}

class TimePicker: UIView {
    
    var placeHolder : String? = nil
    var delegate: TimeProtocol?
    var responseValue : String?
    var isMandatory : Bool?
    var hideWarningView: Bool = false
    var warningLabel: String?
    var isReadOnly: Bool? = nil
    var isDependent: Bool? = nil

    
    convenience  init(frame: CGRect,placeHolderText: String, responseValue : String, isMandatory: Bool,delegate: TimeProtocol,isDependent: Bool,hideWarningView: Bool, warningText: String,isReadOnly: Bool) {
        self.init()
        self.frame = frame
        placeHolder = placeHolderText
        self.responseValue = responseValue
        self.isMandatory = isMandatory
        self.delegate = delegate
        self.hideWarningView = hideWarningView
        self.warningLabel = warningText
        self.isReadOnly = isReadOnly
        self.isDependent = isDependent

        self.setUpTimePicker()
    }
    
    func setUpTimePicker()
    {
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
        
        width = 34.0
        height = 34.0
        xPos = self.frame.size.width - width - 5.0
        yPos = (self.frame.size.height - height)/2
        let timeImage = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        timeImage.image = #imageLiteral(resourceName: "ic_timepicker_black")
        viewContainer.addSubview(timeImage)
        
        xPos = mandatoryImage.frame.origin.x + mandatoryImage.frame.size.width
        yPos = 4.0
        width = self.frame.size.width - timeImage.frame.size.width - xPos
        height = self.frame.size.height
        let textField = TextField(frame: CGRect(x: xPos, y: yPos, width: width, height: height), placeholder: placeHolder!, responseValue : "")
        textField.isEnabled = false
        viewContainer.addSubview(textField)
        
        textField.textColor = isDependent! ? UIColor.lightGray : UIColor.black
        
        self.isUserInteractionEnabled = isReadOnly! ? false : true

        if responseValue != "" && responseValue != nil {
            textField.text = responseValue!
            
            if isReadOnly! {
                textField.textColor = UIColor.lightGray
            }

            Utility.sharedUtility.labelAnimation(textfield: textField, isHidden: false)
        }
        else {
            self.isHidden = isDependent! ? true : false
        }
        
        //Button
        let button = UIButton(frame: viewContainer.frame)
        button.addTarget(self, action: #selector(timeBtnTapped(_:)), for: UIControlEvents.touchUpInside)
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
    
    @IBAction func timeBtnTapped(_ sender : UIButton)
    {
        let viewControllers = Utility.sharedUtility.getViewController(view: self)
        viewControllers.view.endEditing(true)
        let vctr = TimePickerViewController(superview: self, delegate: self)
        vctr.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        vctr.modalPresentationStyle = .overFullScreen
        viewControllers.present(vctr, animated: true, completion: nil)
    }
    
}

extension TimePicker : TimePickerProtocol
{
    func selectedTime(_ time: Date, superview: UIView){
        
        let timeString = Utility.sharedUtility.getTimeStringFromTime(time)
        
        for view in superview.subviews[0].subviews {
            if view.isKind(of: TextField.self) {
                
                let textfield = view as! TextField
                Utility.sharedUtility.labelAnimation(textfield: textfield, isHidden: false)
                textfield.text = timeString
                
                if self.delegate != nil
                {
                    self.delegate?.timePickerWithSuperview(self, timeString: timeString)
                }
            }
        }
    }
}

