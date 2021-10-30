//
//  BackgroundSession.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 30/10/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

class BackgroundSession: NSObject {
    
    static let shared = BackgroundSession()
    
    static let identifier = "uploadtask.bg"
    
    private var session: URLSession!
    
    var savedCompletionHandler: (() -> Void)?
    
    private override init() {
        super.init()
        
        let configuration = URLSessionConfiguration.background(withIdentifier: BackgroundSession.identifier)
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    func start(_ request: URLRequest) {
        session.downloadTask(with: request).resume()
    }
    
    func startUpload(_ request: URLRequest) {
        session.downloadTask(with: request).resume()
        
    }
}

extension BackgroundSession: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.savedCompletionHandler?()
            self.savedCompletionHandler = nil
        }
    }
}

extension BackgroundSession: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            // handle failure here
            print("\(error.localizedDescription)")
        }
    }
}

extension BackgroundSession: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            let json = try JSONSerialization.jsonObject(with: data)
            
            print("\(json)")
            // do something with json
        } catch {
            print("\(error.localizedDescription)")
        }
    }
}
