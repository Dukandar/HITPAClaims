//
//  LaunchScreenViewController.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 27/09/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        versionLabel.text = "Version: " + Configuration.sharedConfiguration.getVersion()
        self.navigationController?.navigationBar.isHidden = true
        self.activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        
        if DataModel.share.getSectionMasterWithFormID().count > 0 {
            print("already loaded csv.")
            
            let delayTime = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.nextViewController()
            }
            
        }else {
            
            CSVReader.sharedInstance.csvReader { (bool) -> Void  in
                if bool! {
                    print("cvs are loaded now...")
                    
                    let delayTime = DispatchTime.now() + 4
                    DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        self.nextViewController()
                    } 
                }
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func nextViewController()
    {
        // reset MenuRow for Next launch
        if (UserManager.sharedManager.isValidUser()) {
            
            if (HITPAUserDefaults.sharedUserDefaults.value(forKey: "RowSelected") != nil) {
                
                HITPAUserDefaults.sharedUserDefaults.set(0, forKey: "RowSelected")
                HITPAUserDefaults.sharedUserDefaults.synchronize()
            } 
        }
        let vctr = (UserManager.sharedManager.isValidUser()) ? HomeViewController(nibName: "HomeViewController", bundle: nil) : LoginViewController(nibName: "LoginViewController", bundle: nil)
        
        self.navigationController?.pushViewController(vctr, animated: true)
    }
    
}
