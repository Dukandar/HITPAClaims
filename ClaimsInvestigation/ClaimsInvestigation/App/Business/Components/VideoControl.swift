//
//  VideoControl.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 03/09/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

protocol VideoControlProtocol {
    func videoControlWithSuperview(_ superView:UIView,_ name : String)
    func removeVideoWithTag(tag: String)
}

class VideoControl: UIView {
    
    var placeHolder : String? = nil
    var delegate: VideoControlProtocol?
    var responseValue : String?
    var webRefNumber : String?
    var isMandatory : Bool?
    var videoDetails : [String:Any]?
    
    convenience  init(frame: CGRect,placeHolderText: String,  responseValue : String, webRefNumber : String,isMandatory: Bool, videoDetails:[String:Any],delegate: VideoControlProtocol) {
        self.init()
        self.frame = frame
        self.webRefNumber = webRefNumber
        placeHolder = placeHolderText
        self.responseValue = responseValue
        self.isMandatory = isMandatory
        self.delegate = delegate
        self.videoDetails = videoDetails
        
        self.setUpVideoControl()
    }
    
    func setUpVideoControl()
    {
        var xPos   :CGFloat    = 0.0
        var yPos   :CGFloat    = 0.0
        var width  :CGFloat    = self.frame.size.width
        var height :CGFloat    = self.frame.size.height
        
        //Optional view
        width = 80.0
        height = self.frame.size.height
        xPos = self.frame.size.width - width
        let optionlView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        self.addSubview(optionlView)
        
        //Camera image
        let cameraView = UIView(frame: CGRect(x: 0.0, y: 0.0, width:
            optionlView.frame.size.width / 2.0, height: optionlView.frame.size.height))
        cameraView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(videoGestureTapped(_:))))
        optionlView.addSubview(cameraView)
        
        var thumbImage : UIImage?
        
        if let responseValue =  responseValue, responseValue.count > 0
        {
            thumbImage = DocumentDirectory.shareDocumentDirectory.getVideoThumbImageWithName(name: self.responseValue!, webRefNumber: self.webRefNumber!)
        }
        cameraView.isUserInteractionEnabled = thumbImage != nil ? true : false
        //Cancel
        width = 34.0
        height = 34.0
        xPos = (cameraView.frame.size.width - width) / 2.0
        yPos = (cameraView.frame.size.height - height) / 2.0
        let cameraImage = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        cameraImage.image = (thumbImage != nil) ? thumbImage : #imageLiteral(resourceName: "ic_error_outline_amber")
        cameraImage.isHidden = (thumbImage != nil) ? false : true
        cameraView.addSubview(cameraImage)
        //Cancel image
        let cancelView = UIView(frame: CGRect(x: cameraView.frame.size.width, y: 0.0, width: optionlView.frame.size.width / 2.0, height: optionlView.frame.size.height))
        cancelView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelGestureTapped(_:))))
        cancelView.tag = 10000
        optionlView.addSubview(cancelView)
        //Cancel
        width = 34.0
        height = 34.0
        xPos = (cancelView.frame.size.width - width) / 2.0
        yPos = (cancelView.frame.size.height - height) / 2.0
        let cancelImage = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        cancelImage.image =  #imageLiteral(resourceName: "ic_close_dark")
        cancelView.addSubview(cancelImage)
        
        xPos = 10.0
        yPos = 0.0
        width = self.frame.size.width - ((cameraView.frame.size.width * 2)) - xPos
        height = self.frame.size.height
        let label = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        label.text = placeHolder
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        self.addSubview(label)
    }
    
    func viewController(_ view: UIView) -> UIViewController {
        var responder: UIResponder? = view
        while !(responder is UIViewController) {
            responder = responder?.next
            if nil == responder {
                break
            }
        }
        return (responder as? UIViewController)!
    }
    
    //MARK: - Action
    @IBAction func videoGestureTapped(_ sender : UITapGestureRecognizer)
    {
        let videoVctr = VideoPlayerViewController(videoName: self.responseValue!, webRefNumber: self.webRefNumber!)
        
        videoVctr.videoDetails = self.videoDetails!
        videoVctr.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        videoVctr.modalPresentationStyle = .overFullScreen
        
        let viewController = Utility.sharedUtility.getViewController(view: self)
        viewController.present(videoVctr, animated: true, completion: nil)
    }
    
    @IBAction func cancelGestureTapped(_ sender : UITapGestureRecognizer)
    {
        self.endEditing(true)
        
        let viewController = Utility.sharedUtility.getViewController(view: self)
        let alertView = Utility.sharedUtility.alertView(controller: viewController, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Do you want to delete the video?", buttonOneTitle: "Yes", buttonTwoTitle: "No", tag: 1)
        viewController.view.addSubview(alertView)
    }
    
}

extension VideoControl : UtilityProtocol
{
    func dismissAlert()
    {
        let viewController = Utility.sharedUtility.getViewController(view: self)
        viewController.view.subviews.last?.removeFromSuperview()
    }
    
    func pushToViewController()
    {
        if DocumentDirectory.shareDocumentDirectory.deleteVideoFromDirectory(name: self.responseValue!.appending(".m4v"), webRefNumber: self.webRefNumber!)
        {            
            let viewController = Utility.sharedUtility.getViewController(view: self)
            viewController.view.subviews.last?.removeFromSuperview()
            
            if self.delegate != nil
            {
                self.delegate?.removeVideoWithTag(tag: self.responseValue!)
            }
        }
    }
}


