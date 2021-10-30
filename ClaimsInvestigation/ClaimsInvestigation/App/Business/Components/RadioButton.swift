//
//  RadioButton.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 06/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

protocol RadioButtonProtocol {
    func radioButtonWithSuperview(_ superView:UIView)
}

class RadioButton: UIView {
    
    var label : String? = nil
    var delegate: RadioButtonProtocol?
    var responseValue : String?
    var Tag : Int = 0
    
    convenience  init(frame: CGRect,label : String?, responseValue : String,  delegate: RadioButtonProtocol,tag : Int) {
        self.init()
        self.frame = frame
        self.label = label
        self.responseValue = responseValue
        self.delegate = delegate
        self.Tag = tag
        setupRadioGroup()
    }
    
    func setupRadioGroup()
    {
        var xPos : CGFloat = 0.0
        var yPos : CGFloat = 0.0
        var width : CGFloat = self.frame.size.width
        var height : CGFloat = self.frame.size.height
        
        //outer radio view
        xPos = 4.0
        width = DeviceType.IPAD ? 30.0 : 20.0
        height = DeviceType.IPAD ? 30.0 : 20.0
        yPos = (self.frame.size.height - height) / 2.0
        let outerfreshQuoteRadioView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        outerfreshQuoteRadioView.tag = self.Tag
        outerfreshQuoteRadioView.backgroundColor = UIColor.clear
        outerfreshQuoteRadioView.layer.cornerRadius = width / 2.0
        outerfreshQuoteRadioView.layer.borderColor = ColorConstant.kThemeColor.cgColor
        outerfreshQuoteRadioView.layer.borderWidth = 1.0
        self.addSubview(outerfreshQuoteRadioView)
        
        //inner radio view
        width = DeviceType.IPAD ? 10.0 : 8.0
        height = DeviceType.IPAD ? 10.0 : 8.0
        xPos = (outerfreshQuoteRadioView.frame.size.width - width) / 2.0
        yPos = (outerfreshQuoteRadioView.frame.size.height - height) / 2.0
        let innerfreshQuoteRadioView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        innerfreshQuoteRadioView.backgroundColor = ColorConstant.kThemeColor
        
        innerfreshQuoteRadioView.isHidden = true
        innerfreshQuoteRadioView.layer.cornerRadius = width / 2.0
        outerfreshQuoteRadioView.addSubview(innerfreshQuoteRadioView)
        
        //radio button label
        xPos = outerfreshQuoteRadioView.frame.size.width + 16.0
        yPos = outerfreshQuoteRadioView.frame.origin.y
        width = self.frame.size.width - xPos
        height = self.frame.size.height
        let radioButtonLabel = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        //(self.label == "Mode of payment(cash/credit card/in one go/multiple time In case of reimbursement)") ? "Mode of payment(cash/credit card/in one go/multiple time,In case of reimbursement)" : self.label
        radioButtonLabel.text = self.label
        radioButtonLabel.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 20.0) : UIFont.systemFont(ofSize: 18.0)
        radioButtonLabel.textColor = UIColor.black
        radioButtonLabel.numberOfLines = 0
        if !DeviceType.IPAD {
            radioButtonLabel.sizeToFit()
        }
        self.addSubview(radioButtonLabel)
        
        if responseValue != "" && responseValue != nil && responseValue! == String(describing: self.Tag) {
            innerfreshQuoteRadioView.isHidden = false
        }
        
        let radioButtonTap = UITapGestureRecognizer(target: self, action: #selector(radioButtonTapped(_:)))
        radioButtonTap.view?.tag = self.Tag
        self.addGestureRecognizer(radioButtonTap)
    }
    
    @IBAction func radioButtonTapped(_ sender: UITapGestureRecognizer) {
        self.endEditing(true)
        let lineView = self.superview?.superview?.viewWithTag(1000)
        if(lineView != nil){
            lineView!.layer.borderColor = UIColor.lightGray.cgColor
            lineView!.layer.borderWidth = 1.0
        }
        if self.delegate != nil {
            self.delegate?.radioButtonWithSuperview(self)
        }
        
    }
}
