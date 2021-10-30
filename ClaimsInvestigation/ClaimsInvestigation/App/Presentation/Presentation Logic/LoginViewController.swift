//
//  LoginViewControllerr.swift
//  ClaimsInvestigation
//
//  Created by Selma D. Souza on 30/07/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var btnForgotPwd: UIButton!
    @IBOutlet weak var btnLogin: Button!
    @IBOutlet weak var hidePassword: UIImageView!
    @IBOutlet weak var viewPasswordBG: UIView!
    @IBOutlet weak var viewLoginBG: UIView!
    @IBOutlet weak var viewBackground: View!
    @IBOutlet weak var txtUsername: TextField!
    @IBOutlet weak var txtPassword: TextField!
    
     override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.isNavigationBarHidden = true
        
        initialSetup()
            
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initialSetup() {
        
        self.txtPassword.isSecureTextEntry = true
        
        self.txtPassword.attributedPlaceholder = NSAttributedString(string: "Password",
                                                               attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        
        self.txtUsername.attributedPlaceholder = NSAttributedString(string: "Username",
                                                                    attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
       
        btnForgotPwd.titleLabel?.adjustsFontSizeToFitWidth = true
        
        viewLoginBG.layer.cornerRadius = 4.0
        viewLoginBG.layer.borderWidth = 1.0
        viewLoginBG.layer.borderColor = ColorConstant.kBorderColor
        viewLoginBG.layer.masksToBounds = true
        
        viewPasswordBG.layer.cornerRadius = 4.0
        viewPasswordBG.layer.borderWidth = 1.0
        viewPasswordBG.layer.borderColor = ColorConstant.kBorderColor
        viewPasswordBG.layer.masksToBounds = true
    }

    @IBAction func actionForgotPWD(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let forgotPWDVC = ForgotPasswordViewController(nibName:"ForgotPasswordViewController",bundle:nil)
        
        if self.navigationController == nil {
            self.present(forgotPWDVC, animated: true, completion: nil)
        }else {
            self.navigationController?.pushViewController(forgotPWDVC, animated: true)
        }
    }
    
    @IBAction func actionLogin(_ sender: UIButton) {
        
        self.view.endEditing(true)
        var params  :[String:String] = [:]
        let apiName  = "Login"
        
        params["UserName"] = txtUsername.text
        params["Password"] = txtPassword.text
        params[APIOptions.kType] = "External"
        params[APIOptions.kDeviceOS] = "IOS"
        
        params[APIOptions.kDeviceModel] = Utility.sharedUtility.deviceModelName()
        params[APIOptions.kOSVersion] = Configuration.sharedConfiguration.getVersion()
        
        let errormessage = Validation.sharedValidations.validateLoginWithParams(params: params)
        
        if errormessage.count > 0 {
            
            let message = Validation.sharedValidations.getErrorStringFromErrorDescription(error: errormessage)
            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: message, buttonOneTitle: "OK", buttonTwoTitle: "", tag: 5)
            self.view.addSubview(alertView)
        }
        else {
            
           if Utility.sharedUtility.isInternetAvailable() {
            
            Utility.sharedUtility.showActivity(message: "", view: self.view)
            
            HITPAAPI.sharedAPI.postAPIWithParams(params: params, methodName: apiName, completionHandler: { (data, error) in
                
                if data == nil && error == nil {
                    DispatchQueue.main.async {
                        Utility.sharedUtility.stopActivity(view: self.view)

                        let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Internal server error", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                        self.view.addSubview(alertView)
                    }
                }else if(error != nil) {
                    DispatchQueue.main.async {
                        Utility.sharedUtility.stopActivity(view: self.view)

                        let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: (error?.localizedDescription)!, buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                        self.view.addSubview(alertView)
                    }
                }else {
                    
                    let response = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : AnyObject]
                    
                    if (response!!["ErrorMessage"] as! String) == ""
                    {
                        UserManager.sharedManager.syncUserInfo(response!)
                        
                        DispatchQueue.main.async {
                            
                            Utility.sharedUtility.stopActivity(view: self.view)
                            
                            let homeVC = HomeViewController.init(nibName: "HomeViewController", bundle: nil)
                            
                            if self.navigationController != nil {
                                self.navigationController?.pushViewController(homeVC, animated: true)
                            }else{
                                self.present(homeVC, animated: true, completion: nil)
                            }
                        }
                    }else  if (response!!["ErrorMessage"] as! String).count > 0 {
                        DispatchQueue.main.async {
                           Utility.sharedUtility.stopActivity(view: self.view)
                           let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: (response!!["ErrorMessage"] as! String), buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                           self.view.addSubview(alertView)
                        }
                    }else{
                        DispatchQueue.main.async {
                            Utility.sharedUtility.stopActivity(view: self.view)

                            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Invalid credentials", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                            self.view.addSubview(alertView)
                        }                        
                    }
                }
            })
                
            }else {
                let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "No internet connection", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                self.view.addSubview(alertView)
            }
        }
    }
    
    @IBAction func actionHideShowPWD(_ sender: UITapGestureRecognizer) {
        
        if txtPassword.isSecureTextEntry {
            hidePassword.isHidden = true
            txtPassword.isSecureTextEntry = false
        }else {
            hidePassword.isHidden = false
            txtPassword.isSecureTextEntry = true
        }
        
    }
}

extension LoginViewController : UtilityProtocol
{
    func dismissAlert() {
        let alertView = self.view.subviews.last
        alertView?.removeFromSuperview()
    }
    
}

