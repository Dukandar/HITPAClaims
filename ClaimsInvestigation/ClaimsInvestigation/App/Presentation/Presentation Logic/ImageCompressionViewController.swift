//
//  ImageCompressionViewController.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 10/10/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

protocol ImageCompressionProtocol {
    func uploadCaseWithIDAndWebRefNumber(caseID: Int64,webRefNum: String)
}

class ImageCompressionViewController: UIViewController {

    @IBOutlet weak var heightConstraint_Label: NSLayoutConstraint!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var lblCompressionText: UILabel!
    @IBOutlet weak var viewRemember: UIView!
    @IBOutlet weak var viewHigh: UIView!
    @IBOutlet weak var viewMedium: UIView!
    @IBOutlet weak var viewLow: UIView!
    @IBOutlet weak var heightLayout_viewMain: NSLayoutConstraint!
    
    var caseID : Int64?
    var webRefNumber : String?
    var delegate : ImageCompressionProtocol? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.addRadioViews()
        
        self.addRememberView()
    }
    
    func addRadioViews() {
        
        var radioLow = ""
        var radioMedium = ""
        var radioHigh = ""
        
        if (UserManager.sharedManager.isLowLevelCompression){
            radioLow = "5001"
        }else {
            radioLow = ""
        }
        
        let radioButtonLow = RadioButton.init(frame: CGRect(x:0.0,y:0.0,width:viewLow.frame.size.width,height:viewLow.frame.size.height), label: "", responseValue: radioLow, delegate: self, tag: 5001)
        viewLow.addSubview(radioButtonLow)
        
        if (UserManager.sharedManager.isMediumLevelCompression) {
            radioMedium = "5002"
        }else {
            radioMedium = ""
        }
        
        let radioButtonMedium = RadioButton.init(frame: CGRect(x:0.0,y:0.0,width:viewMedium.frame.size.width,height:viewMedium.frame.size.height), label: "", responseValue: radioMedium, delegate: self, tag: 5002)
        viewMedium.addSubview(radioButtonMedium)
        
        if (UserManager.sharedManager.isHighLevelCompression) {
            radioHigh = "5003"
        }else {
            radioHigh = ""
        }
        
        let radioButtonHigh = RadioButton.init(frame: CGRect(x:0.0,y:0.0,width:viewHigh.frame.size.width,height:viewHigh.frame.size.height), label: "", responseValue: radioHigh, delegate: self, tag: 5003)
        
        viewHigh.addSubview(radioButtonHigh)
    }
    
    func addRememberView() {
        
        heightLayout_viewMain.constant = heightLayout_viewMain.constant - heightConstraint_Label.constant
        heightConstraint_Label.constant = 0.0
        
        viewRemember.layer.cornerRadius = 5.0
        viewRemember.layer.borderWidth = 1.0
        viewRemember.layer.borderColor = UIColor.black.cgColor
        
        let checkBoxImage = UIImageView(frame: CGRect(x: 5.0, y: 5.0, width: viewRemember.frame.size.width - 10.0, height: viewRemember.frame.size.height - 10.0))
        checkBoxImage.image = #imageLiteral(resourceName: "ic_done_white")
        checkBoxImage.isHidden = true
        viewRemember.addSubview(checkBoxImage)
        
    }
    
    @IBAction func confirmSelection(_ sender: Any) {
                
        self.dismiss(animated: true) {
            
            self.delegate?.uploadCaseWithIDAndWebRefNumber(caseID: self.caseID!, webRefNum: self.webRefNumber!)
        }
    }
    
    @IBAction func cancelSelection(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
   
    @IBAction func viewRememberTapped(_ sender: UITapGestureRecognizer) {
        
        let checkBoxImage = sender.view?.subviews[0] as! UIImageView
        if checkBoxImage.isHidden {
            checkBoxImage.isHidden = false
            sender.view?.backgroundColor = ColorConstant.kThemeColor
            
            UIView.animate(withDuration: 0.4, animations: {
                
                self.heightConstraint_Label.constant = 54.0
                
                self.heightLayout_viewMain.constant = self.heightLayout_viewMain.constant + self.heightConstraint_Label.constant
                var compressionText = ""
                if (UserManager.sharedManager.isLowLevelCompression){
                    compressionText = "Low"
                }else if (UserManager.sharedManager.isMediumLevelCompression){
                    compressionText = "Medium"
                }
                else if (UserManager.sharedManager.isHighLevelCompression){
                    compressionText = "High"
                }
                self.lblCompressionText.text = "By selecting this, default compression level is set to \(compressionText). You can change this later in Settings."
                
                self.view.layoutSubviews()
                
            }, completion: nil)

        }else {
            checkBoxImage.isHidden = true
            sender.view?.backgroundColor = UIColor.white
            
            UIView.animate(withDuration: 0.4, animations: {
                
                self.heightLayout_viewMain.constant = self.heightLayout_viewMain.constant - self.heightConstraint_Label.constant
                self.heightConstraint_Label.constant = 0.0
                
                self.view.layoutSubviews()
                
            }, completion: nil)
            
        }
    }
    
}
extension ImageCompressionViewController : RadioButtonProtocol
{
    func radioButtonWithSuperview(_ superView: UIView) {
        let superRadioSubvViews = superView.superview?.superview?.superview?.subviews
        for (_,item) in ((superRadioSubvViews?.enumerated())!)
        {
            
            let radioSubView = item.subviews
            let firstRadioGrp = radioSubView[1]
            let selectedRadioButton = firstRadioGrp.subviews[0].subviews[0]
            if selectedRadioButton.tag == superView.subviews[0].tag
            {
                selectedRadioButton.subviews[0].isHidden = false
                
                if(superView.subviews[0].tag == 5001) {
                    UserManager.sharedManager.isLowLevelCompression = true
                    UserManager.sharedManager.isMediumLevelCompression = false
                    UserManager.sharedManager.isHighLevelCompression = false
                    
                    if !self.lblCompressionText.isHidden {
                         self.lblCompressionText.text = "By selecting this, default compression level is set to Low. You can change this later in Settings."
                    }
                    
                }else if(superView.subviews[0].tag == 5002) {
                    UserManager.sharedManager.isMediumLevelCompression = true
                    UserManager.sharedManager.isLowLevelCompression = false
                    UserManager.sharedManager.isHighLevelCompression = false
                    
                    if !self.lblCompressionText.isHidden {
                        self.lblCompressionText.text = "By selecting this, default compression level is set to Medium. You can change this later in Settings."
                    }
                    
                }else if (superView.subviews[0].tag == 5003) {
                    UserManager.sharedManager.isHighLevelCompression = true
                    UserManager.sharedManager.isLowLevelCompression = false
                    UserManager.sharedManager.isMediumLevelCompression = false
                    
                    if !self.lblCompressionText.isHidden {
                        self.lblCompressionText.text = "By selecting this, default compression level is set to High. You can change this later in Settings."
                    }
                }
            }
            else
            {
                selectedRadioButton.subviews[0].isHidden = true
            }
            
            
        }
        
    }
}

extension ImageCompressionViewController : MediaUploadProtocol, UtilityProtocol {
    
    // If Media uploaded successfully then upload Case Data
    
    func mediaUploadWithStatus(status: Bool) {
        
        if status {
        }
    }
    
    func dismissAlert() {
        let alertView = self.view.subviews.last
        alertView?.removeFromSuperview()
    }
    
    func pushToViewController() {
        
        let alertView = self.view.subviews.last
        alertView?.removeFromSuperview()
        
    }
    
    func pushToNextViewController() {
        
        let alertView = self.view.subviews.last
        alertView?.removeFromSuperview()
        
    }
    
}
