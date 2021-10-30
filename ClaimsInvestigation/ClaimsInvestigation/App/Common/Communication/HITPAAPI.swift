//
//  HITPAAPI.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 31/07/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

struct APIOptions {
    static let kPOST                = "POST"
    static let kGET                 = "GET"
    static let kContentType         = "application/json"
    static let kContentLength       = "Content-Length"
    static let kType                = "Type"
    static let kDeviceOS            = "DeviceOS"
    static let kDeviceModel         = "DeviceModel"
    static let kOSVersion           = "OSVersion"
}

private var HITPAAPIInstance : HITPAAPI? = nil

class HITPAAPI: NSObject {
    
    static var sharedAPI : HITPAAPI {
        
        if HITPAAPIInstance == nil {
            HITPAAPIInstance = HITPAAPI()
        }
        return HITPAAPIInstance!
    }
    
    
    
    //GET Method
    func getAPIWith(path : String,completionHandler : @escaping(Data? , Error?)-> ()){
        if(path.count > 0){
            var request = URLRequest(url: URL(string :path)!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 60.0)
            request.httpMethod = APIOptions.kGET
            request.addValue(APIOptions.kContentType, forHTTPHeaderField: "Content-Type")
            let session = URLSession.shared
            let sessionTask = session.dataTask(with: request, completionHandler: { (data,response,error) -> Void in
            if data != nil
                {
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode != 200 {
                            completionHandler(nil, error)
                               
                        }
                        else {
                               completionHandler(data, error)
                        }
                    }
                       
                   }else {
                       completionHandler(data, error)
                   }
               })
            sessionTask.resume()
        }
        
    }
    
    
    //Post API
    func postAPIWithParams(params : [String : String] ,methodName: String ,completionHandler : @escaping(Data? , Error?)-> ())
    {
        if let jsonObject = try? JSONSerialization.data(withJSONObject: params, options: [])
        {
            if let content = String(data: jsonObject, encoding: String.Encoding.utf8)
            {
                print(params)
                var request = URLRequest(url: URL(string : "\(Configuration.sharedConfiguration.ServiceUrl())\(methodName)")!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 60.0)
                request.httpMethod = APIOptions.kPOST
                request.addValue(APIOptions.kContentType, forHTTPHeaderField: "Content-Type")
                let postLength = String(format: "%lu", content.count)
                request.setValue(postLength, forHTTPHeaderField: APIOptions.kContentLength)
                
                request.httpBody = content.data(using: String.Encoding.utf8)
                
                let session = URLSession.shared
                let sessionTask = session.dataTask(with: request, completionHandler: { (data,response,error) -> Void in
                    if data != nil
                    {
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode != 200 {
                                completionHandler(nil, error)
                                
                            }
                            else {
                                completionHandler(data, error)
                            }
                        }
                        
                    }else {
                        completionHandler(data, error)
                    }
                    
                })
                sessionTask.resume()
            }
        }
    }
    
    
    //Forgot Password
    func forgotPassword(username : String , completionHandler : @escaping(Data?,Error?)-> ())
    {
        var request = URLRequest(url: URL(string : "\(Configuration.sharedConfiguration.ServiceUrl())GetNewPassword?username=\(username)")!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 60.0)
        request.httpMethod = APIOptions.kGET
        request.addValue(APIOptions.kContentType, forHTTPHeaderField: "Content-Type")
        let sestion = URLSession.shared
        let sestionTask = sestion.dataTask(with: request, completionHandler: {(data,response,error) -> Void in
            if data != nil
            {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        completionHandler(nil, error)
                        
                    }
                    else {
                        completionHandler(data, error)
                    }
                }
            }else {
                completionHandler(data, error)
            }
        })
        sestionTask.resume()
        
    }
        
    //Get Assigned Cases Details
    func getAssignedCasesDetailsWithParams(params : [String : AnyObject] ,methodName: String ,completionHandler : @escaping(Data? , Error?)-> ())
    {
        if let jsonObject = try? JSONSerialization.data(withJSONObject: params, options: [])
        {
            if let content = String(data: jsonObject, encoding: String.Encoding.utf8)
            {
                var request = URLRequest(url: URL(string : "\(Configuration.sharedConfiguration.ServiceUrl())\(methodName)")!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 120.0)
                request.httpMethod = APIOptions.kPOST
                request.addValue(APIOptions.kContentType, forHTTPHeaderField: "Content-Type")
                let postLength = String(format: "%lu", content.count)
                request.setValue(postLength, forHTTPHeaderField: APIOptions.kContentLength)
                
                request.httpBody = content.data(using: String.Encoding.utf8)
                
                let session = URLSession.shared
                let sessionTask = session.dataTask(with: request, completionHandler: { (data,response,error) -> Void in
                    if data != nil
                    {
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode != 200 {
                                completionHandler(nil, error)
                                
                            }
                            else {
                                completionHandler(data, error)
                            }
                        }
                        
                    }else {
                        completionHandler(data, error)
                    }
                    
                })
                sessionTask.resume()
            }
        }
    }
    
    
    func uploadCaseDetailsWithParams(params : [String : AnyObject] ,methodName: String ,completionHandler : @escaping(Data? , Error?)-> ()) {

        if let jsonObject = try? JSONSerialization.data(withJSONObject: params, options: [])
        {
            if let content = String(data: jsonObject, encoding: String.Encoding.utf8)
            {
                var request = URLRequest(url: URL(string : "\(Configuration.sharedConfiguration.ServiceUrl())\(methodName)")!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 120.0)
                request.httpMethod = APIOptions.kPOST
                request.addValue(APIOptions.kContentType, forHTTPHeaderField: "Content-Type")
                let postLength = String(format: "%lu", content.count)
                request.setValue(postLength, forHTTPHeaderField: APIOptions.kContentLength)

                request.httpBody = content.data(using: String.Encoding.utf8)

                let session = URLSession.shared

                let sessionTask = session.dataTask(with: request, completionHandler: { (data,response,error) -> Void in
                    if data != nil
                    {
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode != 200 {
                                completionHandler(nil, error)
                            }
                            else {
                                completionHandler(data, error)
                            }
                        }

                    }else {
                        completionHandler(data, error)
                    }

                })
                sessionTask.resume()
            }
        }
    }
 
    
//    func uploadCaseDetailsWithParams(params : [String : AnyObject] ,methodName: String ,completionHandler : @escaping(Data? , Error?)-> ()) {
//
//        if let jsonObject = try? JSONSerialization.data(withJSONObject: params, options: [])
//        {
//            if let content = String(data: jsonObject, encoding: String.Encoding.utf8)
//            {
//                var request = URLRequest(url: URL(string : "\(Configuration.sharedConfiguration.ServiceUrl())\(methodName)")!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 120.0)
//                request.httpMethod = APIOptions.kPOST
//                request.addValue(APIOptions.kContentType, forHTTPHeaderField: "Content-Type")
//                let postLength = String(format: "%lu", content.count)
//                request.setValue(postLength, forHTTPHeaderField: APIOptions.kContentLength)
//
//                request.httpBody = content.data(using: String.Encoding.utf8)
//
//                BackgroundSession.shared.start(request)
//
//            }
//        }
//    }
   
    
    

}
