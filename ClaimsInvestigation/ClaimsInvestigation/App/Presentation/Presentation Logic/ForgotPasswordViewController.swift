//
//  ForgotPasswordViewController.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 30/07/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var viewBackground: View!
    @IBOutlet weak var txtEmailField: TextField!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var btnBack: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initialSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initialSetup() {
        
        self.txtEmailField.attributedPlaceholder = NSAttributedString(string: "Username",
                                                                    attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])

        viewEmail.layer.cornerRadius = 4.0
        viewEmail.layer.borderWidth = 1.0
        viewEmail.layer.borderColor = ColorConstant.kBorderColor
        viewEmail.layer.masksToBounds = true
    }
    
    @IBAction func actionSubmitEmail(_ sender: UIButton) {
        
        btnSubmit.isEnabled = false
        
        self.view.endEditing(true)
        var param :[String : String] = [:]
        param["UserName"] = self.txtEmailField.text
        let errorMessage = Validation.sharedValidations.validateForgotPasswordWithParam(param: param)
        if errorMessage.count > 0
        {
            let message = Validation.sharedValidations.getErrorStringFromErrorDescription(error: errorMessage)
            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: message, buttonOneTitle: "OK", buttonTwoTitle: "", tag: 5)
            self.view.addSubview(alertView)
            
            btnSubmit.isEnabled = true

        }else
        {
            if Utility.sharedUtility.isInternetAvailable() {
                
                Utility.sharedUtility.showActivity(message: "", view: self.view)
                
                HITPAAPI.sharedAPI.forgotPassword(username: self.txtEmailField.text!, completionHandler: { (data, error) in
                    
                    if data == nil && error == nil {
                        DispatchQueue.main.async {
                            Utility.sharedUtility.stopActivity(view: self.view)

                            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Internal server error", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                            self.view.addSubview(alertView)
                        }
                    }else if(error != nil) {
                        DispatchQueue.main.async {
                            Utility.sharedUtility.stopActivity(view: self.view)

                            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "An error occured. Please try again later.", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                            self.view.addSubview(alertView)
                        }
                    }else {
                        let response = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : AnyObject]
                        
                        if (response!!["ErrorMessage"] as! String) == "Sucess"
                        {
                            DispatchQueue.main.async {
                                
                                Utility.sharedUtility.stopActivity(view: self.view)
                                
                                let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Password sent to the registered mail", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                                self.view.addSubview(alertView)
                                
                            }
                            
                        }else
                        {
                            DispatchQueue.main.async {
                                Utility.sharedUtility.stopActivity(view: self.view)

                                let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: (response!!["ErrorMessage"] as! String), buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                                self.view.addSubview(alertView)
                            }
                        }
                    }
                })
                
            }else {
                let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "No internet connection", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                self.view.addSubview(alertView)
            }
            
            btnSubmit.isEnabled = true
        }
    }
    @IBAction func popToLogin(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
}

extension ForgotPasswordViewController : UtilityProtocol
{
    
    func dismissAlert() {
        let alertView = self.view.subviews.last
        alertView?.removeFromSuperview()
        
    }
    
    
    
}
