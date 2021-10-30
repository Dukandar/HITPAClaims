//
//  CheckBox.swift
//  ClaimsInvestigation

//
//  Created by Vivek Saini on 29/07/18.
//  Copyright © 2018 iNubeSolutions. All rights reserved.
//

import UIKit

protocol CheckBoxProtocol {
    func checkBoxWithSuperview(_ superView:UIView, value:String)
}

class CheckBox: UIView {
    
    var placeHolder : String? = nil
    var responseValue : String?
    var isMandatory : Bool?
    var type : String?
    var isDependent : Bool? = nil
    var fieldID:Int?
    var isReadOnly: Bool? = nil
    
    var delegate : CheckBoxProtocol?
    
    convenience  init(frame: CGRect,placeHolderText: String, responseValue : String, isMandatory: Bool, type: String, isDependent : Bool,fieldID:Int,delegate:CheckBoxProtocol,isReadOnly: Bool) {
        self.init()
        self.frame = frame
        placeHolder = placeHolderText
        self.responseValue = responseValue
        self.isMandatory = isMandatory
        self.type = type
        self.isDependent = isDependent
        self.delegate = delegate
        self.fieldID = fieldID
        self.isReadOnly = isReadOnly
        self.setUpCheckBox()
    }
    
    func setUpCheckBox()
    {
        var xPos   :CGFloat    = 0.0
        var yPos   :CGFloat    = 0.0
        var width  :CGFloat    = self.frame.size.width
        var height :CGFloat    = self.frame.size.height
        
        width = 10.0
        xPos = 0.0
        yPos = 10.0
        height = 10.0
        let mandatoryImage = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        mandatoryImage.image = #imageLiteral(resourceName: "icon_mandatory")
        mandatoryImage.isHidden = isMandatory! ? false : true
//        if let value = responseValue,value.count > 0,value == "true"   vivek
        if let value = responseValue,value.count > 0
        {
//            mandatoryImage.isHidden = true
        }
        mandatoryImage.tag = Int(truncating: isMandatory! as NSNumber)
        self.addSubview(mandatoryImage)
        
        width = DeviceType.IPAD ? 40.0 : 30.0
        xPos = mandatoryImage.frame.origin.x + mandatoryImage.frame.size.width + 5.0
        height = DeviceType.IPAD ? 40.0 : 30.0
        yPos = (self.frame.size.height - height)/2.0
        
        let cellCheckBox = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        cellCheckBox.layer.cornerRadius = 5.0
        cellCheckBox.layer.borderWidth = 1.0
        cellCheckBox.layer.borderColor = UIColor.black.cgColor
        self.addSubview(cellCheckBox)
        
        let checkMarkTap = UITapGestureRecognizer(target: self, action: #selector(checkBoxTapped(_:)))
        cellCheckBox.addGestureRecognizer(checkMarkTap)
        

        xPos = (cellCheckBox.frame.size.width - width)/2.0
        yPos = (cellCheckBox.frame.size.height - height)/2.0
        let checkBoxImage = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        checkBoxImage.image = #imageLiteral(resourceName: "ic_done_white")
        checkBoxImage.isHidden = true
        cellCheckBox.addSubview(checkBoxImage)
        
        self.isUserInteractionEnabled = isReadOnly! ? false : true
        
//        if let value = responseValue,value.count > 0,value == "true"    vivek
        if let value = responseValue,value.count > 0
        {
            checkBoxImage.isHidden = false
            cellCheckBox.backgroundColor = ColorConstant.kThemeColor
        }
        
        xPos = cellCheckBox.frame.origin.x + cellCheckBox.frame.size.width + 5.0
        yPos = 0.0
        width = self.frame.size.width - xPos
        height = self.frame.size.height
        let label = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        //label.text = placeHolder!
        label.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 18.0) :  UIFont.systemFont(ofSize: 16.0)
        let labelText = placeHolder!
        
        let attributeText = labelText.replacingOccurrences(of: "\\n", with: "\n\n")
        label.attributedText = Utility.sharedUtility.justifyLabel(str: attributeText)
        
        label.numberOfLines = 0
        
        //label.sizeToFit()
        self.addSubview(label)
        var frame = self.frame
        frame.size.height = label.frame.size.height
        self.frame = frame
    }
    
    
    @IBAction func doneButtonTapped(_ sender:UIButton) {
        self.endEditing(true)
    }
    
    @IBAction func checkBoxTapped(_ sender:UITapGestureRecognizer) {
        let checkBoxImage = sender.view?.subviews[0] as! UIImageView
        
        if checkBoxImage.isHidden {
            checkBoxImage.isHidden = false
            sender.view?.backgroundColor = ColorConstant.kThemeColor
        }else {
            checkBoxImage.isHidden = true
            sender.view?.backgroundColor = UIColor.white
        }
        
        let lineView = self.superview?.superview?.viewWithTag(1000)
        if(lineView != nil){
            lineView!.layer.borderColor = UIColor.lightGray.cgColor
            lineView!.layer.borderWidth = 1.0
        }
        
        if self.delegate != nil {
            self.delegate?.checkBoxWithSuperview(self, value: String(!(checkBoxImage.isHidden)))
        }
        
    }
    
}
