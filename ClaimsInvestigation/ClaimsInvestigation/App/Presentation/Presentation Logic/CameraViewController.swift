//
//  CameraViewController.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 10/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//


import UIKit
import AVFoundation

protocol CameraProtocol {
    func cameraWithImage(image: UIImage,imageTag: String)
}

class CameraViewController: UIViewController {
    @IBOutlet weak var imgViewCamera: UIImageView!
    @IBOutlet weak var viewCamera: UIView!
    @IBOutlet weak var viewCapture: UIView!
    @IBOutlet var saveGesture: UITapGestureRecognizer!
    
    var delegate : CameraProtocol? = nil
    var imageName : String? = nil
    var refNumber : String? = nil
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var error: NSError?
    
    var saveImage: UIImage? = nil
    var timeInt: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveGesture.isEnabled = false
        
        let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaType.video) && $0.position == AVCaptureDevice.Position.back }
        if (devices.first) != nil  {
            do
            {
                try captureSession.addInput(AVCaptureDeviceInput(device: devices.first!))
                captureSession.sessionPreset = AVCaptureSession.Preset.photo
                captureSession.startRunning()
                stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
                if captureSession.canAddOutput(stillImageOutput) {
                    captureSession.addOutput(stillImageOutput)
                }
                let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                let frame = Configuration.sharedConfiguration.bounds()
                previewLayer.bounds = CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height - 68.0)
                previewLayer.position = CGPoint(x: frame.midX, y: frame.midY)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.viewCamera.layer.addSublayer(previewLayer)
            }catch
            {
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveImageTapped(_ sender: UITapGestureRecognizer) {
        
        timeInt = (Utility.sharedUtility.getMillisecondsFromDateTime(Date()))
        
        //to do - image to potrait
        let imageView = self.viewCamera.subviews.last as! UIImageView
        UIGraphicsBeginImageContextWithOptions(viewCamera.frame.size, false, 0)
        let rect = CGRect(x: 0.0, y: 0.0, width: viewCamera.frame.size.width, height: viewCamera.frame.size.height)
        imageView.draw(rect)
        let savedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if DocumentDirectory.shareDocumentDirectory.writeImageIntoDirectory(imageTag: "\(timeInt!)", image:  savedImage!,webRefNumber: refNumber!)
        {
            Utility.sharedUtility.stopActivity(view: self.view)
            
            saveImage = savedImage!
            
            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Image saved successfully", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 1)
            
            self.view.addSubview(alertView)
        }
    }
    @IBAction func captureImageTapped(_ sender: UITapGestureRecognizer) {
        
        if  let videoConnection = stillImageOutput.connection(with: AVMediaType.video)
        {
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                if imageDataSampleBuffer != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!)
                    let image = UIImage(data: imageData!)
                    DispatchQueue.main.async {
                        
                        //Preview image
                        let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.viewCamera.frame.size.width, height: self.viewCamera.frame.size.height))
                        imageView.image = image
                        self.viewCamera.addSubview(imageView)
                        self.captureSession.stopRunning()
                        self.viewCapture.isHidden = true
                        
                        self.saveGesture.isEnabled = true
                    }
                }
            }
        }

    }
    
    @IBAction func discardImageTapped(_ sender: UITapGestureRecognizer) {
        self.viewCamera.subviews.last?.removeFromSuperview()
        self.captureSession.startRunning()
        
        self.dismiss(animated: true, completion: nil)
    }

}
extension CameraViewController : UtilityProtocol
{
    func dismissAlert() {
        let alertView = self.view.subviews.last
        alertView?.removeFromSuperview()
        
    }
    
    func pushToViewController()
    {
        if self.delegate != nil {
            self.delegate?.cameraWithImage(image: saveImage!,imageTag: "\(timeInt!)")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func pushToNextViewController() {
        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.openURL(settingsURL as URL)
        }
    }
}

