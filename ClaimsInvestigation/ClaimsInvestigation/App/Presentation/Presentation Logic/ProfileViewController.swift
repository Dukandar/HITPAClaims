//
//  ProfileViewController.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 31/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var lblInvestigatorName: UILabel!
    @IBOutlet weak var lblInvestigatorID: UILabel!
    @IBOutlet weak var lblInvestigatorContact: UILabel!
    @IBOutlet weak var lblInvestigatorCode: UILabel!
    
    @IBOutlet weak var lblInvestigatorMaxCase: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblInvestigatorName.text = UserManager.sharedManager.investigatorName!
        
        lblInvestigatorID.text = "0"
        lblInvestigatorCode.text = UserManager.sharedManager.investigatorCode!
        
        lblInvestigatorContact.text = UserManager.sharedManager.investigatorContact!
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func dismissView(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
