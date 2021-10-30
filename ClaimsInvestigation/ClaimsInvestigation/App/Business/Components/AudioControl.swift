//
//  AudioControl.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 03/09/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

protocol AudioControlProtocol {
    func audioControlWithSuperview(superView:UIView,name : String,audioDetails : [String:AnyObject])
    func removeAudioWithTag(tag: String)
    func playAudioWithTagAndName(tag: Int,name:String)
}

class AudioControl: UIView {

    var placeHolder : String? = nil
    var delegate: AudioControlProtocol?
    var responseValue : String?
    var webRefNumber : String?
    var isMandatory : Bool?
    
    convenience  init(frame: CGRect,placeHolderText: String,  responseValue : String, webRefNumber : String,isMandatory: Bool, delegate: AudioControlProtocol) {
        
        self.init()
        self.frame = frame
        self.webRefNumber = webRefNumber
        placeHolder = placeHolderText
        self.responseValue = responseValue
        self.isMandatory = isMandatory
        self.delegate = delegate
        
        self.setUpAudioControl()
    }
    
    func setUpAudioControl()
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
        cameraView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(audioGestureTapped(_:))))
        optionlView.addSubview(cameraView)
        
        //Cancel
        width = 34.0
        height = 34.0
        xPos = (cameraView.frame.size.width - width) / 2.0
        yPos = (cameraView.frame.size.height - height) / 2.0
        let cameraImage = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        cameraImage.image =  #imageLiteral(resourceName: "ic_play_arrow_black")
        cameraView.addSubview(cameraImage)
        //Cancel image
        let cancelView = UIView(frame: CGRect(x: cameraView.frame.size.width, y: 0.0, width: optionlView.frame.size.width / 2.0, height: optionlView.frame.size.height))
        cancelView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelGestureTapped(_:))))
        optionlView.addSubview(cancelView)
        //Cancel
        width = 34.0
        height = 34.0
        xPos = (cancelView.frame.size.width - width) / 2.0
        yPos = (cancelView.frame.size.height - height) / 2.0
        let cancelImage = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        cancelImage.image = #imageLiteral(resourceName: "ic_close_dark")
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
    
    //MARK: - Action
    @IBAction func audioGestureTapped(_ sender : UITapGestureRecognizer)
    {
        let audioVctr = AudioPlayerViewController(audioName: self.responseValue!, webRefNumber: self.webRefNumber!)
        let viewController = Utility.sharedUtility.getViewController(view: self)

        viewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        viewController.modalPresentationStyle = .overFullScreen
        viewController.present(audioVctr, animated: true, completion: nil)
    }
    @IBAction func cancelGestureTapped(_ sender : UITapGestureRecognizer)
    {
        self.endEditing(true)
        
        let viewController = Utility.sharedUtility.getViewController(view: self)
        let alertView = Utility.sharedUtility.alertView(controller: viewController, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Do you want to delete the audio?", buttonOneTitle: "Yes", buttonTwoTitle: "No", tag: 1)
        viewController.view.addSubview(alertView)
    }

}

extension AudioControl : UtilityProtocol
{
    func dismissAlert()
    {
        let viewController = Utility.sharedUtility.getViewController(view: self)
        viewController.view.subviews.last?.removeFromSuperview()
    }
    
    func pushToViewController()
    {
        if DocumentDirectory.shareDocumentDirectory.deleteAudioFromDirectory(name: self.responseValue!, webRefNumber: self.webRefNumber!)
        {
            let viewController = Utility.sharedUtility.getViewController(view: self)
            viewController.view.subviews.last?.removeFromSuperview()
            
            if self.delegate != nil
            {
                self.delegate?.removeAudioWithTag(tag: self.responseValue!)
            }
        }
    }
}

