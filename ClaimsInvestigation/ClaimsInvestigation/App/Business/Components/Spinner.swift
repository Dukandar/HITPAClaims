//
//  Spinner.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 09/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

protocol SpinnerProtocol {
    func spinnerWithSuperview(_ superView:UIView, _ value : FieldDataMaster)
    func spinnerWithValue(_ superView:UIView, _ value : String)
}

class Spinner: UIView {

    var placeHolder : String? = nil
    var responseValue : String?
    var dropDownView: UIView! = nil
    var delegate: SpinnerProtocol?
    var isMandatory : Bool?
    var fieldType : String?
    var fieldId : Int?
    var isDependent: Bool? = nil
    var hideWarningView: Bool = false
    var warningLabel: String? = nil
    var isReadOnly: Bool? = nil

    convenience init(frame: CGRect,fieldId: Int,placeholder: String,responseValue: String, isMandatory: Bool,delegate: SpinnerProtocol, isDependent: Bool,hideWarningView: Bool, warningText: String,isReadOnly: Bool) {
        
        self.init()
        self.frame = frame
        placeHolder = placeholder
        self.responseValue = responseValue
        self.isMandatory = isMandatory
        self.delegate = delegate
        self.isDependent = isDependent
        self.fieldId = fieldId
        self.hideWarningView = hideWarningView
        self.warningLabel = warningText
        self.isReadOnly = isReadOnly
        self.setUpSpinner()
    }
    
    
    func setUpSpinner() {
        
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
        let spinnerImage = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        spinnerImage.image = #imageLiteral(resourceName: "icon_dropDown")
        viewContainer.addSubview(spinnerImage)
        xPos =  mandatoryImage.frame.origin.x + mandatoryImage.frame.size.width + 5.0
        yPos = 10.0
        width = viewContainer.frame.size.width - spinnerImage.frame.size.width - xPos
        height = self.frame.size.height - 2 * yPos

        let textField = TextField(frame: CGRect(x: xPos, y: yPos, width: width, height: height), placeholder: placeHolder!, responseValue : "")
        textField.placeholder = placeHolder!
        textField.font = DeviceType.IPAD ?   UIFont.systemFont(ofSize: 22.0) : UIFont.systemFont(ofSize: 18.0)
        textField.isEnabled = isDependent! ? false : true
        textField.textColor = isDependent! ? UIColor.lightGray : UIColor.black
        
        textField.isEnabled = false
        
        textField.adjustsFontSizeToFitWidth = true
        
        viewContainer.addSubview(textField)
        
        if fieldId == 175261 {
            textField.font = DeviceType.IPAD ?   UIFont.systemFont(ofSize: 18.0) : UIFont.systemFont(ofSize: 14.0)
        }
        
        self.isUserInteractionEnabled = isReadOnly! ? false : true
                
        if responseValue != "" && responseValue != nil {
            if let value = responseValue
            {
                let spinnerValue = placeHolder! != "" ? value :  DataModel.share.getFieldDataValueWithFieldID(fieldID: Int(value)!)
                textField.text = spinnerValue
                
                if isReadOnly! {
                    textField.textColor = UIColor.lightGray
                }

                Utility.sharedUtility.labelAnimation(textfield: textField, isHidden: false)
            }
        }else {
            self.isHidden = isDependent! ? true : false
        }
        
        //Spinner Button
        let button = UIButton(frame: viewContainer.frame)
        button.addTarget(self, action: #selector(spinnerBtnTapped(_:)), for: UIControlEvents.touchUpInside)
        viewContainer.addSubview(button)
        viewContainer.bringSubview(toFront: button)
        
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
    
    
    @IBAction func spinnerBtnTapped(_ sender: UIButton) {
        
        //  fetch specific field data from FieldDataMaster based on field id
        
        let viewControllers = Utility.sharedUtility.getViewController(view: self)
        viewControllers.view.endEditing(true)
        var fldDataMaster = [AnyObject]()
        
        fldDataMaster = DataModel.share.getFieldDataMaster(fieldID: fieldId!)
        
        for view in self.subviews[0].subviews {
            
            if view.isKind(of: TextField.self) {
                
                let textfield = view as! TextField
                let vctr = DropdownSearchViewController([fldDataMaster as AnyObject], textfield.placeholder!, self, delegate: self)
                vctr.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
                vctr.modalPresentationStyle = .overFullScreen
                viewControllers.present(vctr, animated: true, completion: nil)
            }
        }
    }

}

extension Spinner: DropDownSearch {
    
    func setDropDownSearchValue(_ value: FieldDataMaster, superview: UIView) {
        
        if ((value.fieldata_optionvalues) != nil) {
            
            for view in superview.subviews[0].subviews {
                
                if view.isKind(of: TextField.self) {
                    
                    let textfield = view as! TextField
                    textfield.text = value.fieldata_optionvalues
                    Utility.sharedUtility.labelAnimation(textfield: textfield, isHidden: false)
                   
                    if self.delegate != nil
                    {
                        self.delegate?.spinnerWithSuperview(self, value)
                    }
                }
            }
        }
    }
    
    func setDropDownStringValue(_ value: String, superview: UIView) {
        
        for view in superview.subviews[0].subviews {
            
            if view.isKind(of: TextField.self) {
                
                let textfield = view as! TextField
                textfield.text = value
                Utility.sharedUtility.labelAnimation(textfield: textfield, isHidden: false)
                
                if self.delegate != nil
                {
                    self.delegate?.spinnerWithValue(self, value)
                }
            }
        }
    }
    
}

extension SpinnerProtocol {
    func spinnerWithValue(_ superView:UIView, _ value : String) {
        
    }
}
