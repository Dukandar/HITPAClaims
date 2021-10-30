//
//  CaseUpload.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 23/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import Foundation
import UIKit

struct UploadStatus {
    static let kError            = "An error occured. Please try again later"
    static let kServerError        = "Internal server error"
    static let kResponseSuccess    = "Case Uploaded Successfully"
}

protocol CaseUploadProtocol {
    func uploadStatus(_ message:String)
}

private var  caseUploadInstance : CaseUpload? = nil

class CaseUpload: NSObject{
    
    var webRefNumber : String?
    var delegate:CaseUploadProtocol?
    var isCaseUploading : Bool = false
    var completionHandler: (Bool) -> Void = {_ in }
    var caseView : UIView?
    
    static var  shareCaseUpload : CaseUpload
    {
        if caseUploadInstance == nil
        {
            caseUploadInstance = CaseUpload()
        }
        return caseUploadInstance!
    }
    
    func uploadResponse(webRefNumber:String,caseID: Int64,delegate: CaseUploadProtocol, completionHandler:@escaping(Bool) -> ()) {
        
        if isCaseUploading {
            return
        }
        isCaseUploading = true
        self.completionHandler = completionHandler
        self.delegate = delegate
        self.webRefNumber = webRefNumber
        let queueDetails = ["caseID": caseID,"investigatorCode":UserManager.sharedManager.investigatorCode!,"webReferenceNumber":self.webRefNumber!,"isMediaUploading":true,"uploadLabelValue":"Uploading Data (10%)","progressValue":10] as [String : AnyObject]
        if DataModel.share.updateUploadQueueDetails(queueDetails) {
            print("updated queue")
        }

        var params  :[String:AnyObject] = [:]
        var arrResponseDetails = [AnyObject]()
        
        let apiName  = "SaveInvestigationData"
        
        let caseData = DataModel.share.getCaseDetailsForCaseID(webRefNumber: UserManager.sharedManager.investigatorCode!, caseID: caseID)
        
        if caseData.count > 0 {
            
            params["CaseID"] = caseID as AnyObject
            params["AuthToken"] = (UserManager.sharedManager.authToken)! as AnyObject
            params["InvestigatorID"] = UserManager.sharedManager.investigatorCode! as AnyObject
            
            params["TabReferenceNumber"] = ((DataModel.share.nullToNil(value: (caseData[0].value(forKey: "tabReferenceNumber") as AnyObject))) != nil ? (caseData[0].value(forKey: "tabReferenceNumber") as AnyObject) : "" as AnyObject)
            
            let date = Date()
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            let result = dateformatter.string(from: date)
            
            params["InvestigationDateTime"] = result as AnyObject
            
            params["PlaceOfInspection"] = ((DataModel.share.nullToNil(value: (caseData[0].value(forKey: "investigationPlace") as AnyObject))) != nil ? (caseData[0].value(forKey: "investigationPlace") as AnyObject) : "" as AnyObject)
            
            for (_,item) in (caseData as! [CaseDetail]).enumerated() {
                
                var responseDetails: [String: AnyObject] = [:]
                
                if (item.fieldID == 175206) {
                    params["UserName"] = item.fieldValue as AnyObject
                }
                
                responseDetails["FieldID"] = item.fieldID as AnyObject
                responseDetails["FieldValue"] = item.fieldValue as AnyObject
                
                responseDetails["isDocument"] = true as AnyObject
                
                responseDetails["DocumentValue"] = [] as AnyObject
                
                arrResponseDetails.append(responseDetails as AnyObject)
            }
            
            params["ResponseDetails"] = arrResponseDetails as AnyObject
            //objInvestigatorPDFDetails
            var objInvestigatorPDFDetails : [String :  AnyObject] = [:]
            objInvestigatorPDFDetails["HosptilizationReason"] = ((caseData.filter({($0 as!CaseDetail).fieldID == 175763})[0]) as! CaseDetail).fieldValue as AnyObject
            objInvestigatorPDFDetails["TreatmentRelavance"] = ((caseData.filter({($0 as!CaseDetail).fieldID == 175764})[0]) as! CaseDetail).fieldValue  as AnyObject
            objInvestigatorPDFDetails["InvCaseSymptoms"] = ((caseData.filter({($0 as!CaseDetail).fieldID == 175765})[0]) as! CaseDetail).fieldValue as AnyObject
            objInvestigatorPDFDetails["PatientSymptoms"] = ((caseData.filter({($0 as!CaseDetail).fieldID == 175766})[0]) as! CaseDetail).fieldValue as AnyObject
            objInvestigatorPDFDetails["PatientDiagnostics"] = ((caseData.filter({($0 as!CaseDetail).fieldID == 175767})[0]) as! CaseDetail).fieldValue as AnyObject
            objInvestigatorPDFDetails["DiagnosticTestDocuments"] = ((caseData.filter({($0 as!CaseDetail).fieldID == 175768})[0]) as! CaseDetail).fieldValue as AnyObject
            
            let fieldDataDetails = DataModel.share.getFieldDataMaster(fieldID:175769)
            
            if(fieldDataDetails.count
                > 0){
                let fieldValue = (fieldDataDetails.filter({($0 as! FieldDataMaster).id == 188214})[0] as! FieldDataMaster).fieldata_optionvalues
                 objInvestigatorPDFDetails["InvOpinion"] = fieldValue as AnyObject
            }else{
                 objInvestigatorPDFDetails["InvOpinion"] = "" as AnyObject
            }
            
            objInvestigatorPDFDetails["InvRemarks"] = ((caseData.filter({($0 as!CaseDetail).fieldID == 175770})[0]) as! CaseDetail).fieldValue as AnyObject
            params["objInvestigatorPDFDetails"] = objInvestigatorPDFDetails as AnyObject
        }
        
        print("")
        HITPAAPI.sharedAPI.uploadCaseDetailsWithParams(params: params , methodName: apiName, completionHandler: { (data, error) in

            if data == nil && error == nil {

                self.delegate?.uploadStatus(UploadStatus.kServerError)

            }else if(error != nil) {

                self.delegate?.uploadStatus(UploadStatus.kError)
            }else {
                let response = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : AnyObject]

                if (Int((response!!["ErrorCode"]) as! String) == 0)
                {
                    self.delegate?.uploadStatus(UploadStatus.kResponseSuccess)
                }else {
                    self.delegate?.uploadStatus(UploadStatus.kError)
                }
            }
        })

    }
    
}


