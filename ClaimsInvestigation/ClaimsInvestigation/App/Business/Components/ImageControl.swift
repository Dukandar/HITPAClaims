//
//  ImageControl.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 10/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit



protocol ImageControlProtocol {
    func imageControlWithSuperview(_ superView:UIView, _ name : String, _ imageDetails : [String:AnyObject])
    func removeImageWithTag(tag: String)
}

class ImageControl: UIView {

    var placeHolder: String? = nil
    var isMandatory: Bool?
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var responseValue: String?
    var imageDetails : [String:Any]?
    var refNumber: String?
    var delegate: ImageControlProtocol?
    
    var isReadOnly: Bool? = nil
    var isDependent: Bool? = nil
    
    convenience  init(frame: CGRect,placeHolderText: String, responseValue : String,refNumber : String, isMandatory: Bool,imageDetails:[String:Any],delegate: ImageControlProtocol,isReadOnly: Bool,isDependent:Bool) {
        
        self.init()
        self.frame = frame
        self.placeHolder = placeHolderText
        self.responseValue = responseValue
        self.refNumber = refNumber
        self.delegate = delegate
        self.isMandatory = isMandatory
        self.imageDetails = imageDetails
        
        setUpImageControl()
    }
    
    
    func setUpImageControl() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationStatusUpdate), name: NSNotification.Name(rawValue: "locationUpdate"), object: nil)
        
        var xPos   :CGFloat    = 0.0
        var yPos   :CGFloat    = 0.0
        var width  :CGFloat    = self.frame.size.width
        var height :CGFloat    = self.frame.size.height
        
        //Optional view
        width = 80.0
        height = self.frame.size.height
        xPos = self.frame.size.width - width
        let optionalView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        self.addSubview(optionalView)
        
        //Camera image
        let cameraView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: optionalView.frame.size.width / 2.0, height: optionalView.frame.size.height))
        cameraView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageGestureTapped(_:))))
        optionalView.addSubview(cameraView)
        var image : UIImage?
        
        if let responseValue =  responseValue, responseValue.count > 0
        {
            image = DocumentDirectory.shareDocumentDirectory.getImageWithImageTag(imageTag: self.responseValue!, webRefNumber: self.refNumber!)
        }
        cameraView.isUserInteractionEnabled = image != nil ? true : false
        //Cancel
        width = 34.0
        height = 34.0
        xPos = (cameraView.frame.size.width - width) / 2.0
        yPos = (cameraView.frame.size.height - height) / 2.0
        let cameraImage = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        cameraImage.image = (image != nil) ? image : #imageLiteral(resourceName: "ic_error_outline_amber")
        cameraImage.isHidden = (image != nil) ? false : true
        cameraView.addSubview(cameraImage)
        //Cancel image
        let cancelView = UIView(frame: CGRect(x: cameraView.frame.size.width, y: 0.0, width: optionalView.frame.size.width / 2.0, height: optionalView.frame.size.height))
        cancelView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelGestureTapped(_:))))
        optionalView.addSubview(cancelView)
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
    @IBAction func cancelGestureTapped(_ sender : UITapGestureRecognizer)
    {
        self.endEditing(true)
        
        let viewController = Utility.sharedUtility.getViewController(view: self)
        let alertView = Utility.sharedUtility.alertView(controller: viewController, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Do you want to delete the image?", buttonOneTitle: "Yes", buttonTwoTitle: "No", tag: 1)
        viewController.view.addSubview(alertView)
    }
    
    @IBAction func imageGestureTapped(_ sender : UITapGestureRecognizer)
    {
        let imageView = sender.view?.subviews[0] as! UIImageView
        let imageVctr = ImageViewController(image: imageView.image!,imageDetails:imageDetails!)
        imageVctr.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        imageVctr.modalPresentationStyle = .overFullScreen

        let viewController = Utility.sharedUtility.getViewController(view: self)
        viewController.present(imageVctr, animated: true, completion: nil)
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

}

extension ImageControl : ImageControlViewProtocol
{
    func cameraControlWithImage(image: UIImage, imageDetail: [String : AnyObject]) {
    }
    
    func cameraControlWithImage(image : UIImage)
    {
        let subViews = self.subviews[0].subviews
        let cancelImage = subViews[0].subviews[0] as! UIImageView
        cancelImage.isHidden = false
        cancelImage.image = image
        
        if self.delegate != nil
        {
            let imageData = NSData.init(data:  UIImageJPEGRepresentation(image, 1)!)
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateString = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "hh:mm:ss:SSS"
            let timeString = dateFormatter.string(from: date)
            let imageDetails = ["latitude":latitude,"longitude":longitude,"lastModifiedTime":timeString,"lastModifiedDate":dateString,"size":"\(imageData.length) Bytes"] as [String : AnyObject]
            self.imageDetails = imageDetails
            self.delegate?.imageControlWithSuperview(self, placeHolder!, imageDetails)
        }
    }
}

extension ImageControl : TextFieldProtocol  {
    
    func textFieldWithValue(_ value: String,_ placeholder: String, textField : UITextField) {
        if self.delegate != nil {
            self.delegate?.imageControlWithSuperview(self, textField.text!, [:])
        }
    }
    
    func videoWithThumb(thumb: UIImage) {
        
        let subViews = self.subviews[0].subviews
        let cancelView = subViews[1]
        cancelView.tag = 20000
        let cancelImage = subViews[0].subviews[0] as! UIImageView
        cancelImage.isHidden = false
        cancelImage.image = thumb
        let cameraView = subViews[0]
        cameraView.isUserInteractionEnabled = true
        let cameraImage = subViews[1].subviews[0] as! UIImageView
        cameraImage.image = #imageLiteral(resourceName: "failed")
    }
    
}

extension ImageControl : Location {
    
    func locationWithLatLong(latitude: Double, longitude: Double, location: String) {
        print(longitude)
        print(latitude)
        self.longitude = longitude
        self.latitude = latitude
    }
    
    func locationDisabled(){
        let viewController = Utility.sharedUtility.getViewController(view: self)
        let alertView = Utility.sharedUtility.alertView(controller: viewController, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Please enable the location", buttonOneTitle: "OK", buttonTwoTitle: "Cancel", tag: 2)
        viewController.view.addSubview(alertView)
    }
    
    @IBAction func locationStatusUpdate() {
        LocationManager.sharedLocation.locationStatus(delegate: self)
    }
}

extension ImageControl : UtilityProtocol
{
    func dismissAlert()
    {
        let viewController = Utility.sharedUtility.getViewController(view: self)
        viewController.view.subviews.last?.removeFromSuperview()
    }
    
    func pushToViewController()
    {
        if DocumentDirectory.shareDocumentDirectory.deleteImageFromDirectory(name: self.responseValue!.appending(".jpg"),webRefNumber: self.refNumber!)
        {
            let viewController = Utility.sharedUtility.getViewController(view: self)
            viewController.view.subviews.last?.removeFromSuperview()
            
            if self.delegate != nil
            {
                self.delegate?.removeImageWithTag(tag: self.responseValue!)
            }
        }
    }
    
    func pushToNextViewController() {
        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.openURL(settingsURL as URL)
        }
    }
}

