//
//  VideoViewController.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 16/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

protocol VideoProtocol {
    func videoWithImageTag(_ image : UIImage,nameTag: String,infoDict: [String:AnyObject])
}

class VideoViewController: UIViewController {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var lblRecordTime: UILabel!
    @IBOutlet weak var imgViewRecording: UIImageView!
    @IBOutlet weak var viewTimer: UIView!
    @IBOutlet var saveGesture: UITapGestureRecognizer!
    @IBOutlet weak var btnSaveStopRecord: UIButton!
    
    var videoName : String? = nil
    var webRefNumber : String? = nil
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCaptureStillImageOutput()
    var movieOutput = AVCaptureMovieFileOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var currentTime : Int = 0
    var delegate : VideoProtocol? = nil
    var timer = Timer()
    var videoThumbUrl: URL? = nil
    var videoSize: String? = nil
    var isVideoCompressed: Bool = false
    var latitude: Float = 0.0
    var longitude: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        videoName = "\(Int(Utility.sharedUtility.getMillisecondsFromDateTime(Date()))!)"
        
        self.locationStatusUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        for device in devices {
            if device.position == AVCaptureDevice.Position.back{
                do{
                    let input = try AVCaptureDeviceInput(device: device )
                    if captureSession.canAddInput(input){
                        captureSession.addInput(input)
                        sessionOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
                        if captureSession.canAddOutput(sessionOutput){
                            captureSession.addOutput(sessionOutput)
                            captureSession.startRunning()
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                            
                            previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                            videoView.layer.addSublayer(previewLayer)
                            previewLayer.position = CGPoint(x: self.videoView.frame.width / 2, y: self.videoView.frame.height / 2)
                            previewLayer.bounds = videoView.frame
                        }
                        captureSession.addOutput(movieOutput)
                    }
                }catch
                {
                    print("Error")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func popUpView(_ sender: Any) {
        
        self.movieOutput.stopRecording()
        self.captureSession.stopRunning()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func startStopRecording(_ sender: UIButton) {
        
        if LocationManager.sharedLocation.checkForLocationAuthorization() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                
                let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Location is Disabled! Please enable location", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                self.view.addSubview(alertView)
                
                break
            case .authorizedAlways, .authorizedWhenInUse:
                
                if !sender.isSelected
                {
                    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                    let videoName = "\(self.videoName!).mov"
                    
                    self.lblRecordTime.text = "00:00"
                    
                    let fileUrl = paths[0].appendingPathComponent(videoName)
                    print(fileUrl)
                    
                    try? FileManager.default.removeItem(at: fileUrl)
                    
                    movieOutput.startRecording(to: fileUrl, recordingDelegate: self)
                    
                    Timer.cancelPreviousPerformRequests(withTarget: self, selector: #selector(currentTime(_:)), object: nil)

                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(currentTime(_:)), userInfo: nil, repeats: true)
                    self.imgViewRecording.image = #imageLiteral(resourceName: "icon_camera_video_stop")
                    
                    sender.isSelected = true
                    
                    saveGesture.isEnabled = false
                    
                }else
                {
                    self.timer.invalidate()
                    self.imgViewRecording.image = #imageLiteral(resourceName: "icon_camera_video_start")
                    self.movieOutput.stopRecording()
                    self.currentTime = 0
                    
                    sender.isSelected = false
                    saveGesture.isEnabled = true
                }
                break
            }
        } else {
            
            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Location is Disabled! Please enable location", buttonOneTitle: "Dismiss", buttonTwoTitle: "Enable", tag: 2)
            
            self.view.addSubview(alertView)
        }
        
    }
    
    @IBAction func startRecording(_ sender: UITapGestureRecognizer) {
        
        if !self.movieOutput.isRecording
        {
            let fileManager = FileManager()
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let videoName = "\(self.webRefNumber!)/\(DirectoryName.kVideo)/\(self.videoName!).mov"
            let fileUrl = paths[0].appendingPathComponent(videoName)
            let directoryPath = fileUrl.absoluteString
            let url = URL(string: directoryPath)
            if fileManager.fileExists(atPath: (url?.path)!)
            {
                do
                {
                    try fileManager.removeItem(atPath: (url?.path)!)
                }catch
                {
                    print("error")
                }
            }
            try? FileManager.default.removeItem(at: fileUrl)
            
            movieOutput.startRecording(to: fileUrl, recordingDelegate: self)
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(currentTime(_:)), userInfo: nil, repeats: true)
            self.imgViewRecording.image = #imageLiteral(resourceName: "icon_camera_video_stop")
            
        }else
        {
            self.timer.invalidate()
            self.imgViewRecording.image = #imageLiteral(resourceName: "icon_camera_video_start")
            self.movieOutput.stopRecording()
            self.currentTime = 0
            self.lblRecordTime.text = "00:00"
        }
    }
    
    @IBAction func saveRecording(_ sender: UITapGestureRecognizer) {
        
        if self.currentTime == 0 {
            if self.isVideoCompressed {
                
                let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Video saved successfully", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 1)
                
                self.view.addSubview(alertView)
                
            }else {
                
                let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Please wait,Optimization in progress...", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                
                self.view.addSubview(alertView)
            }
        }
    }
    
    @IBAction func discardRecording(_ sender: UITapGestureRecognizer) {
        
        let fileManager = FileManager()
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let videoName = "\(self.webRefNumber!)/\(DirectoryName.kVideo)/\(self.videoName!).mov"
        let fileUrl = paths[0].appendingPathComponent(videoName)
        let directoryPath = fileUrl.absoluteString
        let url = URL(string: directoryPath)
        if fileManager.fileExists(atPath: (url?.path)!)
        {
            do
            {
                try fileManager.removeItem(atPath: (url?.path)!)
            }catch
            {
                print("error")
            }
        }
        try? FileManager.default.removeItem(at: fileUrl)
        
        self.timer.invalidate()
        self.imgViewRecording.image = #imageLiteral(resourceName: "icon_camera_video_start")
        self.movieOutput.stopRecording()
        self.currentTime = 0
        self.lblRecordTime.text = "00:00"
        
        saveGesture.isEnabled = false
        
        btnSaveStopRecord.isSelected = false
        
    }
    
    @IBAction func currentTime(_ sender : Timer)
    {
        currentTime += 1
        if currentTime > 600 {
            self.timer.invalidate()
            self.imgViewRecording.image = #imageLiteral(resourceName: "icon_camera_video_start")
            self.movieOutput.stopRecording()
            self.currentTime = 0
            self.lblRecordTime.text = "00:00"
        }
        if currentTime <= 60 && currentTime >= 10 {
            self.lblRecordTime.text = "00:\(currentTime)"
        }
        else if currentTime > 60 {
            self.lblRecordTime.text = "\(currentTime / 60):\(currentTime % 60)"
        }else if currentTime < 10 {
            self.lblRecordTime.text = "00:0\(currentTime)"
        }
    }
    
}

extension VideoViewController: AVCaptureFileOutputRecordingDelegate
{
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        guard let data = NSData(contentsOf: outputFileURL as URL) else {
            return
        }
        
        print("File size before compression: \(Double(data.length / 1048576)) mb")
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let videoNameOriginal = "\(self.videoName!).mov"
        
        let fileUrlOriginal = paths[0].appendingPathComponent(videoNameOriginal)
        print(fileUrlOriginal)
        
        let videoName = "\(self.videoName!).m4v"
        let fileUrl = paths[0].appendingPathComponent(videoName)
        print(fileUrl)
        
        let compressedURL = fileUrl
        
        videoThumbUrl = compressedURL

        compressVideo(inputURL: outputFileURL as URL, outputURL: compressedURL) { (exportSession) in
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
            case .unknown:
                break
            case .waiting:
                break
            case .exporting:
                break
            case .completed:
                guard let compressedData = NSData(contentsOf: compressedURL) else {
                    return
                }
                
                print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                
                self.videoSize = "\(Double(compressedData.length))"
                
                self.isVideoCompressed = true
                
                try? FileManager.default.removeItem(at: fileUrlOriginal)
                
            case .failed:
                break
            case .cancelled:
                break
            }
        }
        
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    
}
extension VideoViewController : UtilityProtocol
{
    func dismissAlert() {
        
        let alertView = self.view.subviews.last
        alertView?.removeFromSuperview()
    }
    
    func pushToViewController()
    {
        let thumbImage = Utility.sharedUtility.getThumbImageFromVideoWithURL(url: videoThumbUrl!)
        
        let tempDict = ["latitude":self.latitude,"longitude":self.longitude,"size":self.videoSize!] as [String : Any]
        
        if self.delegate != nil
        {
            self.delegate?.videoWithImageTag(thumbImage,nameTag: self.videoName!, infoDict: tempDict as [String : AnyObject])
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func pushToNextViewController() {
        
        try? PreferencesExplorer.openUrl(PreferenceType.locationServices)
        
        let alertView = self.view.subviews.last
        alertView?.removeFromSuperview()
    }
}

extension VideoViewController : Location {
    
    func locationWithLatLong(latitude: Double, longitude: Double, location: String) {
        print(longitude)
        print(latitude)
        self.longitude = Float(longitude)
        self.latitude = Float(latitude)
        print(self.longitude)
        print(self.latitude)
    }
    
    @IBAction func locationStatusUpdate() {
        LocationManager.sharedLocation.locationStatus(delegate: self)
    }
}
