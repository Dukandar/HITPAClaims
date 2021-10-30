//
//  VideoInfoViewController.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 28/09/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

class VideoInfoViewController: UIViewController {

    @IBOutlet weak var lblize: UILabel!
    @IBOutlet weak var lblCaptureDate: UILabel!
    @IBOutlet weak var lblCaptureTime: UILabel!
    @IBOutlet weak var lblLatitude: UILabel!
    @IBOutlet weak var lblLongitude: UILabel!
    
    var infoDictionary : [String:Any]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if (infoDictionary?.count)! > 0 {
            self.lblize.text = ((infoDictionary!["size"] as? String) != nil) ? (infoDictionary!["size"] as? String) : "0 Bytes"
            self.lblCaptureTime.text = infoDictionary!["time"] as? String
            self.lblLatitude.text = ((infoDictionary!["latitude"]) != nil) ? "\((infoDictionary!["latitude"])!)" : "0.0"
            self.lblCaptureDate.text = infoDictionary!["date"] as? String
            self.lblLongitude.text = ((infoDictionary!["longitude"]) != nil) ? "\((infoDictionary!["longitude"])!)" : "0.0"
        }
    }

    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
