//
//  ImageViewController.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 03/09/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var image : UIImage?
    var imageDetails : [String:Any]?
    
    var navVC: UINavigationController?
    
    convenience init( image : UIImage, imageDetails : [String:Any] )
    {
        self.init()
        self.image = image
        self.imageDetails = imageDetails
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white

        self.imageView.image = image
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func dismissButtonTapped(_ sender : UIButton)
    {
        
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showImageInfoView(_ sender: UIButton) {
        
        let vctr = VideoInfoViewController()
        vctr.infoDictionary = self.imageDetails
        vctr.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        vctr.modalPresentationStyle = .overFullScreen
        self.present(vctr, animated: true, completion: nil)
    }
    
    func topMostController() -> UIViewController {
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
    
}


