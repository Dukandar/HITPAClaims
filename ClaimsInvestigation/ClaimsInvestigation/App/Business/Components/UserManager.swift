//
//  UserManager.swift
//  ClaimsInvestigation

//
//  Created by Vivek Saini on 26/07/18.
//  Copyright © 2018 iNubeSolutions. All rights reserved.
//

import UIKit

struct Params {
    static let kInvestigatorName : String       = "InvestigatorName"
    static let kInvestigatorCode : String = "InvestigatorCode"
    static let kInvestigatorContact : String = "InvestogatorContact"
    static let kAuthToken : String = "AuthToken"
}

struct Key {
    static let kUserInfo : String = "UserInfo"
    static let kDeviceUUID : String = "DeviceUUID"
    static let kCompressionLevel : String = "compressionLevel"
}

private var userManagerInstance: UserManager? = nil

class UserManager: NSObject {
    
    var investigatorName: String? = nil
    var investigatorCode: String? = nil
    var investigatorContact: String? = nil
    var authToken: String? = nil
    var isLowLevelCompression: Bool = false
    var isMediumLevelCompression: Bool = true
    var isHighLevelCompression: Bool = false
    var isAutoSyncEnabled: Bool? = nil
    var casePriority: Int = 4
    var isInboxSelected: Bool = true
    
    static var sharedManager: UserManager {
        if userManagerInstance == nil {
            userManagerInstance = UserManager()
        }
        return userManagerInstance!
    }
    
    func syncUserInfo(_ userData : [String : AnyObject]?)
    {
        if userData != nil
        {
            if userData?[Params.kInvestigatorName] != nil && ((userData?[Params.kInvestigatorName] as! String).count) > 0
            {
                investigatorName = userData?[Params.kInvestigatorName] as? String
            }
            
            if userData?[Params.kInvestigatorCode] != nil && !(userData?[Params.kInvestigatorCode] is NSNull) && ((userData?[Params.kInvestigatorCode] as! String).count) > 0
            {
                investigatorCode = userData?[Params.kInvestigatorCode] as? String
            }
            
            if userData?[Params.kInvestigatorContact] != nil && !(userData?[Params.kInvestigatorContact] is NSNull) && ((userData?[Params.kInvestigatorContact] as! String).count) > 0
            {
                investigatorContact = userData?[Params.kInvestigatorContact] as? String
            }
            
            if userData?[Params.kAuthToken] != nil && ((userData?[Params.kAuthToken] as! String).count) > 0
            {
                authToken = userData?[Params.kAuthToken] as? String
            }
            
        }
        
        if isValidUser()
        {
            saveUser(userData: userData!)
        }
        
        //Login response
        if DataModel.share.insertIntoLogin(data: userData!) {
            print("saved")
        }else {
            print("error in saving...")
        }
    }
    
    
    func isValidUser() -> Bool {
        self.getUser()
        return investigatorName != nil
    }
    
    func saveUser(userData : [String : AnyObject])
    {
        var userInfo = [String : Any]()
        userInfo["investigatorName"] = investigatorName
        userInfo["investigatorCode"] = investigatorCode
        userInfo["investigatorContact"] = investigatorContact
        userInfo["authToken"] = authToken
        HITPAUserDefaults.sharedUserDefaults.setValue(userInfo, forKey: Key.kUserInfo)
        HITPAUserDefaults.sharedUserDefaults.synchronize()
    }
    
    func getUser()
    {
        let userInfo : [String : Any]? = HITPAUserDefaults.sharedUserDefaults.value(forKey: Key.kUserInfo) as! [String : Any]?
        if userInfo != nil
        {
            investigatorCode = userInfo?["investigatorCode"] as? String
            investigatorName = userInfo?["investigatorName"] as? String
            investigatorContact = userInfo?["investigatorContact"] as? String

            authToken = userInfo?["authToken"] as? String
        }
    }
    
    func deleteUser()
    {
        HITPAUserDefaults.sharedUserDefaults.removeObject(forKey: Key.kUserInfo)
        HITPAUserDefaults.sharedUserDefaults.synchronize()
    }

}
