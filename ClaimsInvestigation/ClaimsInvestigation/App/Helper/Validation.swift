//
//  Validation.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 20/07/18.
//  Copyright © 2018 iNubeSolutions. All rights reserved.
//

import Foundation

private var validationsInstance = Validation()

class Validation: NSObject {
    
    class var sharedValidations: Validation {
        return validationsInstance
    }
    
    //login validation
    func validateLoginWithParams(params:Dictionary<String,String>) -> Array<String> {
        
        var errorMessage = [String]()
        if params["UserName"] == nil || (params["UserName"]?.count)! <= 0 {
            errorMessage.append("Please Enter Username")
        }
        
        if params["Password"] == nil || (params["Password"]?.count)! <= 0 {
            errorMessage.append("Please Enter Password")
        }
        
//        if errorMessage.count <= 0 {
//            if !emailValidationWithEmail(email: params["email"]!) {
//                errorMessage.append("Please Enter Valid Email ID")
//            }
//        }
        
        return errorMessage
    }
    
    //Forgot password validation
    func validateForgotPasswordWithParam(param:[String : String]) -> [String]
    {
        var errorMessage : [String] = []
        if param["UserName"] == nil || (param["UserName"]?.count)! <= 0
        {
            errorMessage.append("Please Enter UserName")
        }
        
//        if errorMessage.count <= 0 {
//            if !emailValidationWithEmail(email: param["email"]!) {
//                errorMessage.append("Please Enter Valid Email ID")
//            }
//        }
        
        return errorMessage
    }
    
    //CHANGE password validation
    func validateChangePasswordWithParam(params:[String : String]) -> [String]
    {
        var errorMessage : [String] = []
        if params["OldPassword"] == nil || (params["OldPassword"]?.count)! <= 0
        {
            errorMessage.append("Please Enter Old Password")
        }
        if params["NewPassword"] == nil || (params["NewPassword"]?.count)! <= 0
        {
            errorMessage.append("Please Enter New Password")
        }
        if params["ConfirmPassword"] == nil || (params["ConfirmPassword"]?.count)! <= 0
        {
            errorMessage.append("Please Enter Confirm Password")
        }
        if errorMessage.count == 0 {
            if (params["OldPassword"]?.count)! < 8 {
                errorMessage.append("Old Password Length Should be Atleast 8 Characters")
            }else {
                if (params["NewPassword"]?.count)! < 8 {
                    errorMessage.append("New Password Length Should be Atleast 8 Characters")
                }
                else {
                    if passwordValidationWithNumber(password: params["NewPassword"]!) {
                        if params["NewPassword"]! != params["ConfirmPassword"]! {
                            errorMessage.append("Passwords do not Match. Please Re-try")
                            
                        }
                    }else {
                        errorMessage.append("Please Enter Valid Password")
                    }
                }
                
            }
            
        }
        return errorMessage
    }
    
    //otp generation validation
    func validateOtpDetailsWithParams(params:Dictionary<String,String>) -> Array<String> {
        
        var errorMessage = [String]()
        if params["FirstName"] == nil || (params["FirstName"]?.count)! <= 0 {
            errorMessage.append("Please Enter Name")
        }
        
        if params["email"] == nil || (params["email"]?.count)! <= 0 {
            errorMessage.append("Please Enter Email ID")
        }
        
        if params["PhoneNumber"] == nil || (params["PhoneNumber"]?.count)! <= 0 {
            errorMessage.append("Please Enter Mobile Number")
        }
        
        if errorMessage.count <= 0 {
            if !emailValidationWithEmail(email: params["Email"]!) {
                errorMessage.append("Please Enter Valid Email ID")
            }
            
            if (params["PhoneNumber"]?.count)! < 10 {
                errorMessage.append("Please Enter Valid Mobile Number")
            }
        }
        
        return errorMessage
    }
    
    
    //registration validation
    func validateRegisterDetailsWithParams(params:Dictionary<String,String>) -> Array<String> {
        
        var errorMessage = [String]()
        if params["FirstName"] == nil || (params["FirstName"]?.count)! <= 0 {
            errorMessage.append("Please Enter Name")
        }
        
        if params["email"] == nil || (params["email"]?.count)! <= 0 {
            errorMessage.append("Please Enter Email ID")
        }
        
        if params["PhoneNumber"] == nil || (params["PhoneNumber"]?.count)! <= 0 {
            errorMessage.append("Please Enter Mobile Number")
        }
        
        if params["OTP"] == nil || (params["OTP"]?.count)! <= 0 {
            errorMessage.append("Please Enter OTP")
        }
        
        if params["password"] == nil || (params["password"]?.count)! <= 0 {
            errorMessage.append("Please Enter Password")
        }
        
        if params["AadharNo"] == nil || (params["AadharNo"]?.count)! <= 0 {
            errorMessage.append("Please Enter aadhar number")
        }
        
        if params["PanCardNo"] == nil || (params["PanCardNo"]?.count)! <= 0 {
            errorMessage.append("Please Enter Pan number")
        }
        
        if params["GST"] == nil || (params["GST"]?.count)! <= 0 {
            errorMessage.append("Please Enter GST number")
        }
        
        if errorMessage.count <= 0 {
            if !emailValidationWithEmail(email: params["Email"]!) {
                errorMessage.append("Please Enter Valid Email ID")
            }
            
            if (params["PhoneNumber"]?.count)! < 10 {
                errorMessage.append("Please Enter Valid Mobile Number")
            }
            
            if !passwordValidationWithNumber(password: params["Password"]!) {
                errorMessage.append("Please Enter Valid Password")
            }
            
            if (params["PanCardNo"]?.count)! > 0 {
                if !panValidationWithNumber(panNumber: params["PanCardNo"]!) {
                    errorMessage.append("Please Enter Valid Pan Number")
                }
            }
            
            if (params["AadharNo"]?.count)! > 0 {
                if !adhaarValidationWithNumber(adhaarNumber: params["AadharNo"]!) {
                    errorMessage.append("Please Enter Valid Aadhar Number")
                }
            }
            
            if (params["GST"]?.count)! > 0 {
                if !gstTinValidationWithGST(gstinNumber: params["GST"]!) {
                    errorMessage.append("Please Enter Valid GST Number")
                }
            }
        }
        
        return errorMessage
    }
    
    //add policy validation
    func validateAddPolicyForHealthWithParams(params:Dictionary<String,String>) -> Array<String> {
        
        var errorMessage = [String]()
        if params["PolicyNo"] == nil || (params["PolicyNo"]?.count)! <= 0 {
            errorMessage.append("Please Enter Policy Number")
        }
        
        if params["PolicyExpiryDate"] == nil || (params["PolicyExpiryDate"]?.count)! <= 0 {
            errorMessage.append("Please Select Policy Expiry Date")
        }
        
        if params["InsuredDOB"] == nil || (params["InsuredDOB"]?.count)! <= 0 {
            errorMessage.append("Please Select Proposer DOB")
        }
        
        if errorMessage.count <= 0 {
            if (params["PolicyNo"]?.count)! < 16 {
                errorMessage.append("Policy Number Should be Minimum 16 Characters")
            }
        }
        
        return errorMessage
    }
    
    func validateAddPolicyForMotorWithParams(params:Dictionary<String,String>) -> Array<String> {
        
        var errorMessage = [String]()
        if params["PolicyNo"] == nil || (params["PolicyNo"]?.count)! <= 0 {
            errorMessage.append("Please Enter Policy Number")
        }
        
        if params["PolicyExpiryDate"] == nil || (params["PolicyExpiryDate"]?.count)! <= 0 {
            errorMessage.append("Please Enter Policy Expiry Date")
        }
        
        let regNumber = "\(params["regNumberOne"]!)\(params["regNumberTwo"]!)\(params["regNumberThree"]!)\(params["regNumberFour"]!)"
        if  regNumber.count <= 0 {
            errorMessage.append("Please Enter Registration Number")
        }
        
        if errorMessage.count <= 0 {
            if (params["PolicyNo"]?.count)! < 16 {
                errorMessage.append("Policy Number Should be Minimum 16 Characters")
            }
            if params["regNumberOne"] == nil || (params["regNumberOne"]?.count)! <= 0  || params["regNumberTwo"] == nil || (params["regNumberTwo"]?.count)! <= 0  || params["regNumberThree"] == nil || (params["regNumberThree"]?.count)! <= 0 || params["regNumberFour"] == nil || (params["regNumberFour"]?.count)! <= 0 {
                errorMessage.append("Please Enter Valid Registration Number")
            }
            
        }
        
        return errorMessage
    }
    
    //UPDATE DETAILS validation
    func validateUpdateDetailsWithParams(params:Dictionary<String,String>) -> Array<String> {
        
        var errorMessage = [String]()
        if (params["PanCardNo"] == nil || (params["PanCardNo"]?.count)! <= 0) && (params["AadharNo"] == nil || (params["AadharNo"]?.count)! <= 0) && (params["EIANumber"] == nil || (params["EIANumber"]?.count)! <= 0) {
            errorMessage.append("Please Enter any one of the Details")
        }
        
        //        if params["AadharNo"] == nil || (params["AadharNo"]?.count)! <= 0 {
        //            errorMessage.append("Enter aadhar number")
        //        }
        
        if errorMessage.count <= 0 {
            if (params["PanCardNo"]?.count)! > 0 {
                if !panValidationWithNumber(panNumber: params["PanCardNo"]!) {
                    errorMessage.append("Please Enter Valid Pan Number")
                }
            }
            
            if (params["AadharNo"]?.count)! > 0 {
                if !adhaarValidationWithNumber(adhaarNumber: params["AadharNo"]!) {
                    errorMessage.append("Please Enter Valid Aadhar Number")
                }
            }
            
            if (params["EIANumber"]?.count)! > 0 {
                if (params["EIANumber"]?.count)! == 13 {
                    if (params["EIACreatedBy"]?.count)! <= 0 {
                        errorMessage.append("Please Select the Service Provider with whom EIA was Created")
                    }
                    
                }else {
                    errorMessage.append("Please Enter Valid EIA Number")
                }
            }
        }
        
        return errorMessage
    }
    
    
    //raise complaint validation
    func validateRaiseComplaintWithParams(params:Dictionary<String,String>) -> Array<String> {
        
        var errorMessage = [String]()
        if params["Category"] == nil || (params["Category"]?.count)! <= 0 {
            errorMessage.append("Please Select Request Type")
        }
        
        if params["SubCategory"] == nil || (params["SubCategory"]?.count)! <= 0 {
            errorMessage.append("Please Select Request Subtype")
        }
        
        if params["PolicyNumber"] == nil || (params["PolicyNumber"]?.count)! <= 0 {
            errorMessage.append("Please Enter Policy Number")
        }
        
        if params["Remarks"] == nil || (params["Remarks"]?.count)! <= 0 {
            errorMessage.append("Please Enter Request Remark")
        }
        
        if params["SubCategory"] != nil && params["SubCategory"] == "Update Current Address" {
            if params["ModifiedAddress"] == nil || (params["ModifiedAddress"]?.count)! <= 0 {
                errorMessage.append("Please Enter Current Address")
            }
        }
        
        
        
        return errorMessage
    }
    
    //intimate claim validation
    func validateIntimateClaimWithParams(params:Dictionary<String,Any>) -> Array<String> {
        
        var errorMessage = [String]()
        
        if params["NatureOfLoss"] == nil || ((params["NatureOfLoss"] as! String).count) <= 0 {
            errorMessage.append("Please Select Nature of Loss")
        }
        
        if params["AccidentTime"] == nil || ((params["AccidentTime"] as! String).count) <= 0 {
            errorMessage.append("Please Select the Date and Time of Loss")
        }
        
        if params["TypeOfLoss"] == nil || ((params["TypeOfLoss"] as! String).count) <= 0 {
            errorMessage.append("Please Select Type of Loss")
        }
        
        if params["LocationName"] == nil || ((params["LocationName"] as! String).count) <= 0 {
            errorMessage.append("Please Select Current Vehicle Location")
        }else if String(describing: params["LocationName"]!) == "Spot" || String(describing: params["LocationName"]!) == "Repairer" {
            if params["VehicleLocation"] == nil || ((params["VehicleLocation"] as! String).count) <= 0 {
                errorMessage.append("Please Enter Vehicle Location")
            }
        }
        if params["TPLoss"] != nil && ((params["TPLoss"] as! Bool && params["NatureOfLoss"] != nil && (params["NatureOfLoss"] as! String) != "Theft" ) || (params["NatureOfLoss"] != nil && (params["NatureOfLoss"] as! String) == "Theft")) {
            if params["FIRNo"] == nil || ((params["FIRNo"] as! String).count) <= 0 {
                errorMessage.append("Please Enter FIR Number")
            }
            if params["FIRDate"] == nil || ((params["FIRDate"] as! String).count) <= 0 {
                errorMessage.append("Please Select FIR Lodged Date and Time")
            }
        }
        
        if errorMessage.count <= 0 {
            if params["FIRDate"] != nil && (params["FIRDate"] as! String) != "" {
                let firDate = params["FIRDate"] as! String
                let accidentDate = params["AccidentTime"] as! String
                
                if firDate > accidentDate {
                    
                }else {
                    errorMessage.append("Date and Time of Loss Cannot be Greater than or same as FIR Lodged Date and Time")
                }
            }
        }
        
        return errorMessage
    }
    
    
    //Health claim intimation validation
    func validateHealthIntimateClaimWithParams(params:Dictionary<String,Any>) -> Array<String> {
        
        var errorMessage = [String]()
        if params["HospitalID"] == nil || ((params["PatientName"] as! String).count) <= 0{
            errorMessage.append("Please Search for Valid Hospital Name")
        }
        
        if params["PatientName"] == nil || ((params["PatientName"] as! String).count) <= 0 {
            errorMessage.append("Please Select Patient Name")
        }
        
        if params["Diagnosis"] == nil || ((params["Diagnosis"] as! String).count) <= 0 {
            errorMessage.append("Please Enter Diagnosis")
        }
        
        if params["DateOfAdmission"] == nil || ((params["DateOfAdmission"] as! String).count) <= 0 {
            errorMessage.append("Please Select Date & Time of Admission")
        }
        
        if params["DateOfDischarge"] == nil || ((params["DateOfDischarge"]as! String).count) <= 0 {
            errorMessage.append("Please Select Date & Time of Discharge")
        }
        
        if params["ClaimAmount"] == nil || ((params["ClaimAmount"]as! String).count) <= 0 {
            errorMessage.append("Please Enter Claim Amount")
        }
        
        if errorMessage.count <= 0 {
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "dd MMM yyyy hh:mm a"
            let admissiondate = dateformatter.date(from: params["DateOfAdmission"] as! String)
            let dischargedate = dateformatter.date(from: params["DateOfDischarge"] as! String)
            
            if admissiondate! == dischargedate! || admissiondate! < dischargedate! {
                
            }else {
                errorMessage.append("Admission Date Cannot be Greater than Discharge Date")
            }
            
            
        }
        
        return errorMessage
    }
    
    
    func emailValidationWithEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let regExPredicate:NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return regExPredicate.evaluate(with: email)
    }
    
    func panValidationWithNumber(panNumber:String) -> Bool {
        let panRegEx = "[A-Z]{5}[0-9]{4}[A-Z]{1}"
        
        let panExPredicate:NSPredicate = NSPredicate(format: "SELF MATCHES %@", panRegEx)
        return panExPredicate.evaluate(with: panNumber)
    }
    
    func adhaarValidationWithNumber(adhaarNumber:String) -> Bool {
        let adhaarRegEx = "\\d{12}"
        
        let adhaarExPredicate:NSPredicate = NSPredicate(format: "SELF MATCHES %@", adhaarRegEx)
        return adhaarExPredicate.evaluate(with: adhaarNumber)
    }
    
    func gstTinValidationWithGST(gstinNumber:String) -> Bool{
        let gstRegex = "\\d{2}[A-Z]{5}\\d{4}[A-Z]{1}\\d[Z]{1}[A-Z\\d]{1}"
        
        let gstExPredicate:NSPredicate = NSPredicate(format: "SELF MATCHES %@", gstRegex)
        return gstExPredicate.evaluate(with: gstinNumber)
    }
    
    func passwordValidationWithNumber(password:String) -> Bool {
        let passwordRegEx = "^(?=.*[A-Z])(?=.*\\d)(?=.*[@#$%^&*()])[A-Za-z\\d@#$%^&*()]{8,}$"
        
        
        let passwordExPredicate:NSPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordExPredicate.evaluate(with: password)
    }
    
    //error string
    func getErrorStringFromErrorDescription(error:Array<String>) -> String {
        var errorString: String = ""
        for (_, item) in error.enumerated() {
            errorString.append("- \(item)\n")
        }
        return errorString
    }
    
}
