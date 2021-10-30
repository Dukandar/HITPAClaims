//
//  Configuration.swift
//  ClaimsInvestigation

//
//  Created by Vivek Saini on 26/07/18.
//  Copyright © 2018 iNubeSolutions. All rights reserved.
//

import UIKit

struct FontsFamily {
    
    static let kRegular   = UIFont.systemFont(ofSize: 17.0)
}

private var configurationInstance: Configuration? = nil

class Configuration: NSObject {
    
    var infoDictionary : [String:Any]? = nil
    
    override init() {
        infoDictionary = Bundle.main.infoDictionary!
    }
    
    static var sharedConfiguration: Configuration {
        
        if configurationInstance == nil {
            configurationInstance = Configuration()
        }
        return configurationInstance!
    }
    
    func appName() -> String {
        return infoDictionary!["AppName"] as! String
    }
    
    func getVersion() -> String {
        return infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    func ServiceUrl()-> String
    {
        return infoDictionary!["HITPAServiceURL"] as! String
    }
    
    func getSurveyID() -> String {
        return (infoDictionary!["SurveyID"] as! String)
    }
    
    func bounds() -> CGRect {
        return UIScreen.main.bounds
    }
    
    func getUDID() -> String {
        return (UIDevice.current.identifierForVendor?.uuidString)!
    }
    
    func getFTPUname() -> String {
        return infoDictionary!["FTPUname"] as! String
    }
    
    func getFTPPword() -> String {
        return infoDictionary!["FTPPword"] as! String
    }
    
    func getFTPUrlString() -> String {
        return infoDictionary!["FTPUrlString"] as! String
    }
    func getFTPDirPath() -> String {
        return infoDictionary!["FTPDirPath"] as! String
    }

}
