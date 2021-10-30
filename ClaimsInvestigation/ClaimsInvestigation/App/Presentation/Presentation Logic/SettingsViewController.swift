//
//  SettingsViewController.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 01/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var switchAutoSync: UISwitch!
    
    @IBOutlet weak var viewHigh: UIView!
    @IBOutlet weak var viewMedium: UIView!
    @IBOutlet weak var viewLow: UIView!
    
    @IBOutlet weak var viewHighLevel: UIView!
    @IBOutlet weak var viewMediumLevel: UIView!
    @IBOutlet weak var viewLowLevel: UIView!
    @IBOutlet weak var btnRevoke: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true

        createHeader()
        
        self.shadowEffect()
        
        self.addRadioViews()
        
        switchAutoSync.onTintColor = UIColor.lightGray
        switchAutoSync.isOn = HITPAUserDefaults.sharedUserDefaults.bool(forKey: "isAutoSync")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addRadioViews() {
        
        var radioLow = ""
        var radioMedium = ""
        var radioHigh = ""
        
        if (UserManager.sharedManager.isLowLevelCompression){
            radioLow = "1001"
        }else {
            radioLow = ""
        }
        
        let radioButtonLow = RadioButton.init(frame: CGRect(x:0.0,y:0.0,width:viewLow.frame.size.width,height:viewLow.frame.size.height), label: "Low Level", responseValue: radioLow, delegate: self, tag: 1001)
        viewLow.addSubview(radioButtonLow)
        
        if (UserManager.sharedManager.isMediumLevelCompression) {
            radioMedium = "1002"
        }else {
            radioMedium = ""
        }
        
        let radioButtonMedium = RadioButton.init(frame: CGRect(x:0.0,y:0.0,width:viewMedium.frame.size.width,height:viewMedium.frame.size.height), label: "Medium Level", responseValue: radioMedium, delegate: self, tag: 1002)
        viewMedium.addSubview(radioButtonMedium)
        
        if (UserManager.sharedManager.isHighLevelCompression) {
            radioHigh = "1003"
        }else {
            radioHigh = ""
        }
        
        let radioButtonHigh = RadioButton.init(frame: CGRect(x:0.0,y:0.0,width:viewHigh.frame.size.width,height:viewHigh.frame.size.height), label: "High Level", responseValue: radioHigh, delegate: self, tag: 1003)
        
        viewHigh.addSubview(radioButtonHigh)
        
    }
    
    func shadowEffect() {
        btnRevoke.layer.cornerRadius = 4.0
        
        let shadowSize : CGFloat = 2.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y: -shadowSize / 2,
                                                   width: btnRevoke.frame.size.width + shadowSize ,
                                                   height: btnRevoke.frame.size.height + shadowSize))
        btnRevoke.layer.masksToBounds = false
        btnRevoke.layer.shadowColor = UIColor.darkGray.cgColor
        btnRevoke.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        btnRevoke.layer.shadowRadius = 2.0
        btnRevoke.layer.shadowOpacity = 1.0
        btnRevoke.layer.shadowPath = shadowPath.cgPath
        btnRevoke.layer.shouldRasterize = true
        btnRevoke.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func createHeader() {
        
        let frame = UIScreen.main.bounds
        var xPos:CGFloat = 0.0
        var yPos:CGFloat = 20.0
        var width:CGFloat = frame.size.width
        var height:CGFloat = 60.0
        
        let headerView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        headerView.backgroundColor = ColorConstant.kThemeColor
        self.view.addSubview(headerView)
        
        xPos = 15.0
        width = 60.0
        height = 60.0
        yPos = 0.0
        let leftView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        headerView.addSubview(leftView)
        
        xPos = 0.0
        width = 30.0
        height = 30.0
        yPos = (leftView.frame.size.height - height)/2
        let backImage = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        backImage.image = #imageLiteral(resourceName: "ic_arrow_backward_white")
        backImage.contentMode = UIViewContentMode.scaleAspectFit
        leftView.addSubview(backImage)
        backImage.isUserInteractionEnabled = true
        
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(leftBarButtonTapped(_:)))
        leftView.addGestureRecognizer(backGesture)
        
        width = 80.0
        xPos = (leftView.frame.size.width) - 20.0
        height = 30.0
        yPos = (headerView.frame.size.height - height)/2
        
        let title = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        title.text = "Settings"
        title.textAlignment = NSTextAlignment.center
        title.font = UIFont.systemFont(ofSize: 18.0)
        title.textColor = UIColor.white
        leftView.addSubview(title)
        
    }
    
    //left bar button
    @objc func leftBarButtonTapped(_ sender : UIButton) -> Void {
        if self.navigationController == nil {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    @IBAction func actionAutoSyncCase(_ sender: UISwitch) {
        
        HITPAUserDefaults.sharedUserDefaults.set(sender.isOn, forKey: "isAutoSync")
        HITPAUserDefaults.sharedUserDefaults.synchronize()
    }
    
    @IBAction func revokeAccess(_ sender: UIButton) {
        
        HITPAUserDefaults.sharedUserDefaults.removeObject(forKey: "isAutoSync")
        
        switchAutoSync.setOn(false, animated: true)
        
        let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Revoke Successful", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
        self.view.addSubview(alertView)
        
        UserManager.sharedManager.isLowLevelCompression = false
        UserManager.sharedManager.isMediumLevelCompression = false
        UserManager.sharedManager.isHighLevelCompression = false

    }
}

extension SettingsViewController : RadioButtonProtocol
{
    func radioButtonWithSuperview(_ superView: UIView) {
        let superRadioSubvViews = superView.superview?.superview?.subviews
        for (_,item) in (superRadioSubvViews?.enumerated())!
        {
            
            let radioSubView = item.subviews
            let firstRadioGrp = radioSubView[0]
            let selectedRadioButton = firstRadioGrp.subviews[0].subviews[0]
            if firstRadioGrp.subviews[0].tag == superView.subviews[0].tag
            {
                selectedRadioButton.isHidden = false
                
                if(firstRadioGrp.subviews[0].tag == 1001) {
                    UserManager.sharedManager.isLowLevelCompression = true
                    UserManager.sharedManager.isMediumLevelCompression = false
                    UserManager.sharedManager.isHighLevelCompression = false
                }else if(firstRadioGrp.subviews[0].tag == 1002) {
                    UserManager.sharedManager.isMediumLevelCompression = true
                    UserManager.sharedManager.isLowLevelCompression = false
                    UserManager.sharedManager.isHighLevelCompression = false
                }else if (firstRadioGrp.subviews[0].tag == 1003) {
                    UserManager.sharedManager.isHighLevelCompression = true
                    UserManager.sharedManager.isLowLevelCompression = false
                    UserManager.sharedManager.isMediumLevelCompression = false
                }
            }
            else
            {
                selectedRadioButton.isHidden = true
            }
            if radioSubView.count > 1
            {
                let secondRadioGrp = radioSubView[1]
                let selectedRadioButton = secondRadioGrp.subviews[0].subviews[0]
                if secondRadioGrp.subviews[0].tag == superView.subviews[0].tag
                {
                    selectedRadioButton.isHidden = false
                }
                else
                {
                    selectedRadioButton.isHidden = true
                }
            }
            
        }
        
    }
}

extension SettingsViewController : UtilityProtocol
{
    func dismissAlert() {
        let alertView = self.view.subviews.last
        alertView?.removeFromSuperview()
    }
    
}

