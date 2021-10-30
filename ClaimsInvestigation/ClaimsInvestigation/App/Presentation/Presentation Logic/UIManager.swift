//
//  UIManager.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 03/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

struct UIManagerNotificationKey {
    static let kUserLogin   : String  = "UserLogin"
    static let kUserLogout  : String  = "UserLogout"
    static let kUploadDone  : String  = "UploadDone"
    static let kUploadStarted: String = "UploadStarted"

}

private var instanceUIManager: UIManager? = nil

class UIManager: NSObject {
    
    var navController : UINavigationController? =  nil
    
    static var shareInstance : UIManager {
        
        if (instanceUIManager == nil) {
            instanceUIManager = UIManager()
        }
        return instanceUIManager!
    }
    
    override init() {
        super.init()
        self.rootViewController()
    }
    
    func rootViewController() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        navController = appDelegate.window?.rootViewController as? UINavigationController
        
        NotificationCenter.default.addObserver(self, selector: #selector(login), name: NSNotification.Name(UIManagerNotificationKey.kUserLogin), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(logOut), name: Notification.Name(UIManagerNotificationKey.kUserLogout), object: nil)
    }
    
    @objc func login()  {
        
        if (navController != nil && ((navController?.topViewController) is LoginViewController) ) {
            let vctr = HomeViewController()
            navController?.pushViewController(vctr, animated: true)
        }else {
            navController?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @objc func logOut() {
        
        UserManager.sharedManager.deleteUser()
        
        let vctr = LoginViewController()
        
        navController?.present(vctr, animated: true, completion: nil)
        
    }

}
