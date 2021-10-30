//
//  ImageControlViewController.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 10/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit
import AVFoundation

protocol ImageControlViewProtocol {
    func cameraControlWithImage(image : UIImage, imageDetail: [String: AnyObject])
}

class ImageControlViewController: UIViewController {
    
    var viewSaveDiscard: UIView? = nil
    var viewRecording: UIView? = nil
    var recordTimerLabel: UILabel? = nil
    var viewRecordTimer: UIView? = nil
    var audioControlView: UIView? = nil
    var viewRecorder: UIView? = nil
    var delegate: ImageControlViewProtocol? = nil
    
    var tableViewMedia:UITableView?
    var mediaArray: [AnyObject]?
    var fieldID: Int? = nil
    var mediaType: String = ""
    var mediaNameString: String? = nil
    
    var viewVideoControl: UIView? = nil
    var mediaViewTable: UIView?  = nil
    var latitude: Double = 0
    var longitude: Double = 0
    var btnRecording: UIButton!
    var btnPlayAudio: UIButton!
    var btnStopAudio: UIButton!
    var playAudio: UIImageView!
    var recording: UIImageView!
    var stopAudio: UIImageView!
    
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    var timer = Timer()
    @objc var currentTime : Int = 0
    var currentPlayTime : Int = 0

    var audioName : String = ""
    var webRefNumber : String? = nil
    
    let _y:Float = 0
    
    var heightConstant:CGFloat = 50.0
    var _totalHeight:CGFloat = 0
    var _viewCount:Int = 1
    
    var recLabel:Bool = false
    var countDown:Bool = false
    var OkView:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        mediaArray?.removeAll()
        
        mediaArray = DataModel.share.getMediaDetailsForFieldID(fieldID: fieldID!, webRefNumber: webRefNumber!)
        
        createImageControlView()
        
        if (mediaArray?.count)! > 0 {
            // reload Tableview
            tableViewMedia?.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createImageControlView() {
        
        let frame = Configuration.sharedConfiguration.bounds()
        
        var xPos: CGFloat = 0.0
        var yPos: CGFloat = 0.0
        var width: CGFloat = frame.size.width
        var height: CGFloat = frame.size.height
        
        viewVideoControl = UIView(frame:CGRect(x: xPos, y: yPos, width: width, height: height))
        viewVideoControl?.backgroundColor = UIColor.clear
        self.view.addSubview(viewVideoControl!)
        
        xPos = DeviceType.IPAD ? 30.0 : 20.0
        height = DeviceType.IPAD ? 200.0 : 150.0
        yPos = ((viewVideoControl?.frame.size.height)! - height)/3
        width = (viewVideoControl?.frame.size.width)! - 2 * xPos
        
        let imageControlView = UIView(frame:CGRect(x: xPos, y: yPos, width: width, height: height))
        imageControlView.backgroundColor = UIColor.white
        viewVideoControl?.addSubview(imageControlView)
        
        yPos = imageControlView.frame.origin.y + imageControlView.frame.size.height
        height = ((mediaArray!.count) > 0) ? (DeviceType.IPAD ? 250 : 200) : 70.0
        
        mediaViewTable = UIView(frame:CGRect(x: xPos, y: yPos, width: width, height: height))
        mediaViewTable!.backgroundColor = UIColor.white
        mediaViewTable?.isHidden = ((mediaArray!.count) > 0) ? false : true
        viewVideoControl?.addSubview(mediaViewTable!)
        
        xPos = 0.0
        yPos = 0.0
        height = 60.0
        width = imageControlView.frame.size.width
        
        let headerView = UIView(frame:CGRect(x: xPos, y: yPos, width: width, height: height))
        headerView.backgroundColor = ColorConstant.kThemeColor
        imageControlView.addSubview(headerView)
        
        // Header label
        xPos = 20.0
        height = 40.0
        yPos = (headerView.frame.size.height - height)/2
        width = headerView.frame.size.width - 2 * xPos
        let headerLabel = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        headerLabel.text = "Choose Action"
        headerLabel.textColor = UIColor.white
        headerLabel.numberOfLines = 1
        headerLabel.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 22.0) : UIFont.systemFont(ofSize: 20.0)
        headerLabel.textAlignment = .left
        headerView.addSubview(headerLabel)
        
        // close button image
        xPos = headerView.frame.size.width - 50.0

        let closeImage = UIImageView(frame: CGRect(x: xPos, y: yPos, width: 40.0, height: 40.0))
        closeImage.image = #imageLiteral(resourceName: "ic_close")
        closeImage.contentMode = UIViewContentMode.scaleAspectFit
        headerView.addSubview(closeImage)
        
        xPos = closeImage.frame.origin.x - 10.0
        height = headerView.frame.size.height
        yPos = 0.0
        width = closeImage.frame.size.width + 20.0
        
        // close button
        let btnClose = UIButton(type: UIButtonType.custom)
        btnClose.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        btnClose.backgroundColor = UIColor.clear
        btnClose.addTarget(self, action: #selector(hideMediaControls(_:)), for: UIControlEvents.touchUpInside)
        headerView.addSubview(btnClose)
        
        xPos = 0.0
        yPos = headerView.frame.origin.y + headerView.frame.size.height
        width = imageControlView.frame.size.width
        height = imageControlView.frame.size.height - yPos
        let viewBottom = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        viewBottom.backgroundColor = UIColor.white
        imageControlView.addSubview(viewBottom)
        
        // camera view
        xPos = 0.0
        yPos = 0.0
        width = viewBottom.frame.size.width/3.0
        height = viewBottom.frame.size.height
        
        let viewCamera = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        viewCamera.backgroundColor = UIColor.clear
        viewBottom.addSubview(viewCamera)
        
        width = 10.0
        xPos = 0.0
        yPos = 5.0
        height = 10.0
        
        let mandatoryImageCamera = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        mandatoryImageCamera.image = #imageLiteral(resourceName: "icon_mandatory")
        viewCamera.addSubview(mandatoryImageCamera)
        
        width = DeviceType.IPAD ? 44.0 : 34.0
        height = DeviceType.IPAD ? 44.0 : 34.0
        xPos = (viewCamera.frame.size.width - width)/2
        yPos = (viewCamera.frame.size.height - height - 30.0)/2
        
        let cameraImage = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        cameraImage.image = #imageLiteral(resourceName: "ic_camera_alt_black")
        cameraImage.contentMode = UIViewContentMode.scaleAspectFit
        viewCamera.addSubview(cameraImage)
        
        xPos = (viewCamera.frame.size.width - (viewCamera.frame.size.width/2 + 10.0))/2
        height = 30.0
        yPos = (cameraImage.frame.origin.y + cameraImage.frame.size.height)
        width = viewCamera.frame.size.width/2 + 10.0
        
        let cameraLabel = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        cameraLabel.text = "Camera"
        cameraLabel.textColor = UIColor.black
        cameraLabel.numberOfLines = 1
        cameraLabel.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 22.0) : UIFont.systemFont(ofSize: 18.0)
        cameraLabel.adjustsFontSizeToFitWidth = true
        cameraLabel.textAlignment = .center
        viewCamera.addSubview(cameraLabel)
        
        
        // camera button
        let btnCamera = UIButton(type: UIButtonType.custom)
        btnCamera.frame = viewCamera.frame
        btnCamera.backgroundColor = UIColor.clear
        btnCamera.addTarget(self, action: #selector(btnCameraTapped(_:)), for: UIControlEvents.touchUpInside)
        viewCamera.addSubview(btnCamera)
        
        
        // Audio view
        xPos = viewBottom.frame.size.width/3.0
        yPos = 0.0
        width = viewBottom.frame.size.width/3.0
        height = viewBottom.frame.size.height
        let viewAudio = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        viewAudio.backgroundColor = UIColor.clear
        viewBottom.addSubview(viewAudio)
        
        width = 10.0
        xPos = 0.0
        yPos = 5.0
        height = 10.0
        let mandatoryImageAudio = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        mandatoryImageAudio.image = #imageLiteral(resourceName: "icon_mandatory")
        viewAudio.addSubview(mandatoryImageAudio)
        
        width = DeviceType.IPAD ? 44.0 : 34.0
        height = DeviceType.IPAD ? 44.0 : 34.0
        xPos = (viewAudio.frame.size.width - width)/2
        yPos = (viewAudio.frame.size.height - height - 30.0)/2
        let audioImage = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        audioImage.image = #imageLiteral(resourceName: "ic_mic_black")
        audioImage.contentMode = UIViewContentMode.scaleAspectFit
        viewAudio.addSubview(audioImage)
        
        
        xPos = (viewAudio.frame.size.width - (viewAudio.frame.size.width/2 + 10.0))/2
        height = 30.0
        yPos = (audioImage.frame.origin.y + audioImage.frame.size.height)
        width = viewAudio.frame.size.width/2 + 10.0
        let audioLabel = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        audioLabel.text = "Audio"
        audioLabel.textColor = UIColor.black
        audioLabel.numberOfLines = 1
        audioLabel.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 22.0) : UIFont.systemFont(ofSize: 18.0)
        audioLabel.adjustsFontSizeToFitWidth = true
        audioLabel.textAlignment = .center
        viewAudio.addSubview(audioLabel)
        
        
        // camera button
        let btnAudio = UIButton(type: UIButtonType.custom)
        btnAudio.frame = CGRect(x: 0.0, y: 0.0, width: viewAudio.frame.size.width, height: viewAudio.frame.size.height)
        btnAudio.backgroundColor = UIColor.clear
        btnAudio.addTarget(self, action: #selector(btnAudioTapped(_:)), for: UIControlEvents.touchUpInside)
        viewAudio.addSubview(btnAudio)
        
        // Video view
        xPos = viewBottom.frame.size.width/3.0 * 2.0
        yPos = 0.0
        width = viewBottom.frame.size.width/3.0
        height = viewBottom.frame.size.height
        let viewVideo = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        viewVideo.backgroundColor = UIColor.clear
        viewBottom.addSubview(viewVideo)
        
        width = 10.0
        xPos = 0.0
        yPos = 5.0
        height = 10.0
        let mandatoryImageVideo = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        mandatoryImageVideo.image = #imageLiteral(resourceName: "icon_mandatory")
        viewVideo.addSubview(mandatoryImageVideo)
        
        width = DeviceType.IPAD ? 44.0 : 34.0
        height = DeviceType.IPAD ? 44.0 : 34.0
        xPos = (viewVideo.frame.size.width - width)/2
        yPos = (viewVideo.frame.size.height - height - 30.0)/2 
        let videoImage = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        videoImage.image = #imageLiteral(resourceName: "ic_videocam_black")
        videoImage.contentMode = UIViewContentMode.scaleAspectFit
        viewVideo.addSubview(videoImage)
        
        
        xPos = (viewVideo.frame.size.width - (viewVideo.frame.size.width/2 + 10.0))/2
        height = 30.0
        yPos = (videoImage.frame.origin.y + videoImage.frame.size.height)
        width = viewVideo.frame.size.width/2 + 10.0
        
        let videoLabel = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        
        videoLabel.text = "Video"
        videoLabel.textColor = UIColor.black
        videoLabel.numberOfLines = 1
        videoLabel.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 22.0) : UIFont.systemFont(ofSize: 18.0)
        videoLabel.adjustsFontSizeToFitWidth = true
        videoLabel.textAlignment = .center
        viewVideo.addSubview(videoLabel)
        
        
        // camera button
        let btnVideo = UIButton(type: UIButtonType.custom)
        btnVideo.frame = CGRect(x: 0.0, y: 0.0, width: viewVideo.frame.size.width, height: viewVideo.frame.size.height)
        btnVideo.backgroundColor = UIColor.clear
        btnVideo.addTarget(self, action: #selector(btnVideoTapped(_:)), for: UIControlEvents.touchUpInside)
        viewVideo.addSubview(btnVideo)
        
        
        // list view
        xPos = 0.0
        yPos = 0.0
        width = mediaViewTable!.frame.size.width
        height = mediaViewTable!.frame.size.height
        
        tableViewMedia = UITableView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        tableViewMedia!.delegate = self
        tableViewMedia!.dataSource = self
        tableViewMedia!.tableFooterView = UIView()
        tableViewMedia!.separatorStyle = .singleLineEtched
        mediaViewTable?.addSubview(tableViewMedia!)
        
    }
    
    func showAudioControls() {
        
        let frame = Configuration.sharedConfiguration.bounds()
        
        var xPos: CGFloat = 0.0
        var yPos: CGFloat = 0.0
        var width: CGFloat = frame.size.width
        var height: CGFloat = frame.size.height
        
        xPos = DeviceType.IPAD ? 30.0 : 20.0
//        height = heightConstant
        height = DeviceType.IPAD ? 200.0 : 150.0
        yPos = (frame.size.height - height)/3
        width = frame.size.width - 2 * xPos
        
        audioControlView = UIView(frame:CGRect(x: xPos, y: yPos, width: width, height: height))
        audioControlView?.backgroundColor = UIColor.white
        self.view.addSubview(audioControlView!)
        
        xPos = 0.0
        yPos = 0.0
        height = 60.0 //heightConstant
        width = (audioControlView?.frame.size.width)!
        
        let headerView = UIView(frame:CGRect(x: xPos, y: yPos, width: width, height: height))
        headerView.backgroundColor = ColorConstant.kThemeColor
        audioControlView?.addSubview(headerView)
        
        xPos = headerView.frame.size.width - 50.0
        height = 40.0
        yPos = (headerView.frame.size.height - height)/2
        width = 40.0
        
        // close button image
        let closeImage = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        closeImage.image = #imageLiteral(resourceName: "ic_close")
        closeImage.contentMode = UIViewContentMode.scaleAspectFit
        headerView.addSubview(closeImage)
        
        xPos = closeImage.frame.origin.x - 10.0
        height = headerView.frame.size.height
        yPos = 0.0
        width = closeImage.frame.size.width + 20.0
        
        // close button
        let btnClose = UIButton(type: UIButtonType.custom)
        btnClose.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        btnClose.backgroundColor = UIColor.clear
        btnClose.addTarget(self, action: #selector(btnHideAudioControlsTapped(_:)), for: UIControlEvents.touchUpInside)
        headerView.addSubview(btnClose)
        
        // Header label
        xPos = 20.0
        height = 40.0
        yPos = (headerView.frame.size.height - height)/2
        width = headerView.frame.size.width - 2 * xPos
        
        let headerLabel = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        headerLabel.text = "Audio Recorder"
        headerLabel.textColor = UIColor.white
        headerLabel.numberOfLines = 1
        headerLabel.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 22.0) : UIFont.systemFont(ofSize: 18.0)
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.textAlignment = .left
        headerView.addSubview(headerLabel)
        
        heightConstant += 20
        
        height = heightConstant
        yPos = heightConstant
        xPos = 0.0
        width = (audioControlView?.frame.size.width)!
        
        viewRecording = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        viewRecording?.backgroundColor = UIColor.clear
        audioControlView?.addSubview(viewRecording!)
        
        height = 40.0
        yPos = 10.0
        width = (viewRecording?.frame.size.width)! - 40.0
        xPos = ((viewRecording?.frame.size.width)! - width)/2
        
        let lblRecording = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        lblRecording.text = "Recording..."
        lblRecording.textColor = UIColor.lightGray
        lblRecording.numberOfLines = 1
        lblRecording.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 22.0) : UIFont.systemFont(ofSize: 18.0)
        lblRecording.adjustsFontSizeToFitWidth = true
        lblRecording.textAlignment = .center
        viewRecording?.addSubview(lblRecording)

        
        xPos = (audioControlView?.frame.size.width)!/3.0
        yPos = (heightConstant * 2)
        width = ((audioControlView?.frame.size.width)! - 20)/3.0
        height = 50.0
        
        viewRecordTimer = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        viewRecordTimer?.backgroundColor = ColorConstant.kThemeColor
        audioControlView?.addSubview(viewRecordTimer!)
        
        height = 40.0
        xPos = 10.0
        yPos = ((viewRecordTimer?.frame.size.height)! - height) / 2
        width = ((viewRecordTimer?.frame.size.width)! - 2 * xPos)
        
        recordTimerLabel = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        recordTimerLabel?.text = "00:00"
        recordTimerLabel?.textColor = UIColor.white
        recordTimerLabel?.numberOfLines = 1
        recordTimerLabel?.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 22.0) : UIFont.systemFont(ofSize: 18.0)
        recordTimerLabel?.textAlignment = .center
        viewRecordTimer!.addSubview(recordTimerLabel!)
 
        xPos = 20.0
        yPos = (heightConstant * 3)
        width = ((audioControlView?.frame.size.width)! - 2 * xPos)
        height = heightConstant
        
        viewRecorder = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        viewRecorder?.backgroundColor = UIColor.clear
        audioControlView?.addSubview((viewRecorder)!)
        
        // Mic view
        xPos = 0.0
        yPos = 0.0
        width = (viewRecorder?.frame.size.width)!/3.0
        height = heightConstant
        
        let viewMic = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        viewMic.backgroundColor = UIColor.clear
        viewRecorder?.addSubview(viewMic)
        
        width = DeviceType.IPAD ? 44.0 : 34.0
        height = DeviceType.IPAD ? 44.0 : 34.0
        xPos = (viewMic.frame.size.width - width)/2
        yPos = (viewMic.frame.size.height - height)/2
        
        recording = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        recording.image = #imageLiteral(resourceName: "ic_mic_black")
        recording.contentMode = UIViewContentMode.scaleAspectFit
        viewMic.addSubview(recording)
        
        // Recording button
        btnRecording = UIButton(type: UIButtonType.custom)
        btnRecording.frame = CGRect(x: 0.0, y: 0.0, width: viewMic.frame.size.width, height: viewMic.frame.size.height)
        btnRecording.backgroundColor = UIColor.clear
        btnRecording.isEnabled = true
        btnRecording.addTarget(self, action: #selector(btnRecordingTapped(_:)), for: UIControlEvents.touchUpInside)
        viewMic.addSubview(btnRecording)
        
        // Audio Play view
        xPos = viewMic.frame.size.width + viewMic.frame.origin.x
        yPos = viewMic.frame.origin.y
        width = viewMic.frame.size.width
        height = viewMic.frame.size.height
        
        let viewPlayAudio = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        viewPlayAudio.backgroundColor = UIColor.clear
        viewRecorder?.addSubview(viewPlayAudio)
        
        width = DeviceType.IPAD ? 44.0 : 34.0
        height = DeviceType.IPAD ? 44.0 : 34.0
        xPos = (viewPlayAudio.frame.size.width - width)/2
        yPos = (viewPlayAudio.frame.size.height - height)/2
        
        playAudio = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        playAudio.image = #imageLiteral(resourceName: "ic_ic_play_arrow_gray")
        playAudio.contentMode = UIViewContentMode.scaleAspectFit
        viewPlayAudio.addSubview(playAudio)
        
        // play button
        btnPlayAudio = UIButton(type: UIButtonType.custom)
        btnPlayAudio.frame = CGRect(x: 0.0, y: 0.0, width: viewPlayAudio.frame.size.width, height: viewPlayAudio.frame.size.height)
        btnPlayAudio.isEnabled = false
        btnPlayAudio.backgroundColor = UIColor.clear
        btnPlayAudio.addTarget(self, action: #selector(btnPlayAudioTapped(_:)), for: UIControlEvents.touchUpInside)
        viewPlayAudio.addSubview(btnPlayAudio)
        
        // Stop Audio view
        xPos = viewPlayAudio.frame.size.width + viewPlayAudio.frame.origin.x
        yPos = viewPlayAudio.frame.origin.y
        width = viewPlayAudio.frame.size.width
        height = viewPlayAudio.frame.size.height
        
        let viewStopRecording = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        viewStopRecording.backgroundColor = UIColor.clear
        viewRecorder?.addSubview(viewStopRecording)
        
        width = DeviceType.IPAD ? 44.0 : 34.0
        height = DeviceType.IPAD ? 44.0 : 34.0
        xPos = (viewStopRecording.frame.size.width - width)/2
        yPos = (viewStopRecording.frame.size.height - height)/2
        
        stopAudio = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        stopAudio.image = #imageLiteral(resourceName: "ic_ic_stop_gray")
        stopAudio.contentMode = UIViewContentMode.scaleAspectFit
        viewStopRecording.addSubview(stopAudio)
        
        // camera button
        btnStopAudio = UIButton(type: UIButtonType.custom)
        btnStopAudio.frame = CGRect(x: 0.0, y: 0.0, width: viewStopRecording.frame.size.width, height: viewStopRecording.frame.size.height)
        btnStopAudio.isEnabled = false
        btnStopAudio.backgroundColor = UIColor.clear
        btnStopAudio.addTarget(self, action: #selector(btnStopRecordingTapped(_:)), for: UIControlEvents.touchUpInside)
        viewStopRecording.addSubview(btnStopAudio)
        
        // OK/Discard  view
        xPos = 20.0
        yPos = (heightConstant * 4)
        width = ((audioControlView?.frame.size.width)! - 2 * xPos)
        height = heightConstant
        viewSaveDiscard = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        viewSaveDiscard?.backgroundColor = UIColor.clear
        audioControlView?.addSubview(viewSaveDiscard!)
        
        // Save Recording button
        xPos = 20.0
        yPos = 5.0
        width = ((viewSaveDiscard?.frame.size.width)! - 2 * xPos)/2
        height = ((viewSaveDiscard?.frame.size.height)! - 2 * yPos)
        
        let btnSaveAudio = UIButton(type: UIButtonType.custom)
        btnSaveAudio.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        btnSaveAudio.backgroundColor = UIColor.clear
        btnSaveAudio.setTitle("OK", for: .normal)
        btnSaveAudio.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        btnSaveAudio.setTitleColor(ColorConstant.kThemeColor, for: .normal)
        btnSaveAudio.addTarget(self, action: #selector(btnSaveAudioTapped(_:)), for: UIControlEvents.touchUpInside)
        viewSaveDiscard?.addSubview(btnSaveAudio)
        
        // Discard Recording button
        xPos = btnSaveAudio.frame.origin.x + btnSaveAudio.frame.size.width + 10.0
        yPos = btnSaveAudio.frame.origin.y
        width = (btnSaveAudio.frame.size.width)
        height = (btnSaveAudio.frame.size.height)
        
        let btnDiscardAudio = UIButton(type: UIButtonType.custom)
        btnDiscardAudio.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        btnDiscardAudio.backgroundColor = UIColor.clear
        btnDiscardAudio.setTitle("DISCARD", for: .normal)
        btnDiscardAudio.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        btnDiscardAudio.setTitleColor(ColorConstant.kThemeColor, for: .normal)
        btnDiscardAudio.addTarget(self, action: #selector(btnDiscardAudioTapped(_:)), for: UIControlEvents.touchUpInside)
        viewSaveDiscard?.addSubview(btnDiscardAudio)
 
        self.changeViewHeight(_totalHeight: heightConstant * 2)
        
        self.discardSelected()
    }
    
    func changeViewHeight(_totalHeight: CGFloat) {
        audioControlView?.frame.size.height = _totalHeight
    }
    
    func discardSelected() {
        
        viewRecording?.isHidden = true
        viewSaveDiscard?.isHidden = true
        viewRecordTimer?.isHidden = true
        
        viewRecorder?.frame.origin.y = heightConstant
    }
    
    func addView(isRecOn:Bool,isPlaySelected:Bool) {
        
        viewRecording?.isHidden = isPlaySelected
        viewSaveDiscard?.isHidden = isRecOn
        viewRecording?.frame.origin.y = heightConstant
        viewSaveDiscard?.frame.origin.y = (heightConstant * 3)
        
        viewRecordTimer?.isHidden = isRecOn ? !isRecOn : isRecOn
        viewRecordTimer?.frame.origin.y = recLabel ? (heightConstant * 2) : heightConstant
        
        changeViewHeight(_totalHeight: heightConstant * 4)
        
        self.addRecorderView()
    }
    
    func addRecorderView() {
        viewRecorder?.isHidden = false
        viewRecorder?.frame.origin.y = ((countDown || OkView) ? (recLabel ? (heightConstant * 3) : (heightConstant * 2)) : heightConstant)
    }
    
    @IBAction func hideMediaControls(_ sender : UIButton) {
        
        // dismiss controls here
        
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func btnHideAudioControlsTapped(_ sender : UIButton) {
        
        // dismiss controls here
        
//        if self.navigationController != nil {
//            self.navigationController?.popViewController(animated: true)
//        }else {
//            self.dismiss(animated: true, completion: nil)
//        }
        audioControlView?.removeFromSuperview()
    }
    
    @IBAction func btnDiscardAudioTapped(_ sender : UIButton) {
        
        // discard recording
        
        discardSelected()
        
        changeViewHeight(_totalHeight: heightConstant * 2)

        self.timer.invalidate()
        
        playAudio.image = #imageLiteral(resourceName: "ic_ic_play_arrow_gray")
        btnPlayAudio.isEnabled = false
        
        stopAudio.image = #imageLiteral(resourceName: "ic_ic_stop_gray")
        btnStopAudio.isEnabled = false
        
        recording.image = #imageLiteral(resourceName: "ic_mic_black")
        btnRecording.isEnabled = true
        
        if (DocumentDirectory.shareDocumentDirectory.deleteAudioFromDirectory(name: audioName, webRefNumber: webRefNumber!)) {
            print("audio file deleted")
            
            self.audioRecorder?.stop()
            self.currentTime = 0
            self.recordTimerLabel?.text = "00:00"
        }
    }
    
    @IBAction func btnSaveAudioTapped(_ sender : UIButton) {
        
        // use recording further
        
        discardSelected()
        
        changeViewHeight(_totalHeight: heightConstant * 2)
        
        self.timer.invalidate()
        self.audioRecorder?.stop()
//        self.recordTimerLabel?.text = "00:00"
        
        if self.currentTime > 0 {
            
            var audioDetails = ["mediaName": mediaNameString!, "mediaType" : MediaControlType.kAudioControl,"fieldID" : fieldID!,"webRefNumber":webRefNumber!] as [String : AnyObject]
            
            audioDetails["tag"] = audioName as AnyObject
            
            if DataModel.share.insertMediaDetailsForFieldID(fieldID: fieldID!, webRefNumber: webRefNumber!, response: [audioDetails]) {
                
                mediaArray?.removeAll()
                
                mediaArray = DataModel.share.getMediaDetailsForFieldID(fieldID: fieldID!, webRefNumber: webRefNumber!)
                
                if (mediaViewTable?.isHidden)! {
                    mediaViewTable?.isHidden = false
                }
                
                if (mediaViewTable?.frame.size.height)! < 250.0 {
                    mediaViewTable?.frame.size.height = (mediaViewTable?.frame.size.height)! + 60.0
                    mediaViewTable?.layoutIfNeeded()
                }
                
                let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Audio saved successfully", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                self.view.addSubview(alertView)
            }
        }
    }
    
    // stop recording
    @IBAction func btnStopRecordingTapped(_ sender : UIButton) {
        
        recLabel  = false
        countDown = true
        OkView = true
        
        addView(isRecOn: false, isPlaySelected: true)
        
        stopAudio.image = #imageLiteral(resourceName: "ic_ic_stop_gray")
        btnStopAudio.isEnabled = false
        
        playAudio.image = #imageLiteral(resourceName: "ic_play_arrow_black")
        btnPlayAudio.isEnabled = true
        
        recording.image = #imageLiteral(resourceName: "ic_ic_mic_gray")
        btnRecording.isEnabled = false
        
        self.timer.invalidate()

        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
        }else {
            audioPlayer?.stop()
        }
    }
    
    // play recording
    @IBAction func btnPlayAudioTapped(_ sender : UIButton) {
        
        recLabel  = false
        countDown = true
        OkView = true
        
        addView(isRecOn: false, isPlaySelected: true)
        
        if audioRecorder?.isRecording == false {
            
            self.timer.invalidate()
    
            stopAudio.image = #imageLiteral(resourceName: "ic_stop_black")
            btnStopAudio.isEnabled = true
            
            recording.image = #imageLiteral(resourceName: "ic_ic_mic_gray")
            btnRecording.isEnabled = false
            
            playAudio.image = #imageLiteral(resourceName: "ic_ic_play_arrow_gray")
            sender.isEnabled = false
            
            let error : NSError? = nil
            
            print((audioRecorder?.url)!)
            
            do{
                audioPlayer = try AVAudioPlayer.init(contentsOf: (audioRecorder?.url)!)
            }catch {
                print(error)
            }
            
            audioPlayer?.delegate = self
            
            if let err = error{
                print("audioPlayer error: \(err.localizedDescription)")
            }else{
                audioPlayer?.play()
                
                currentPlayTime = currentTime
                
                Timer.cancelPreviousPerformRequests(withTarget: self, selector: #selector(currentTimeForPlaying(_:)), object: nil)
                
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(currentTimeForPlaying(_:)), userInfo: nil, repeats: true)
            }
        }
    }
    
    // record audio
    @IBAction func btnRecordingTapped(_ sender : UIButton) {
        
        recLabel  = true
        countDown = true
        OkView = false
        
        addView(isRecOn: true, isPlaySelected: false)
        
        if audioRecorder?.isRecording == false {
            
            playAudio.image = #imageLiteral(resourceName: "ic_ic_play_arrow_gray")
            btnPlayAudio.isEnabled = false
            
            recording.image = #imageLiteral(resourceName: "ic_ic_mic_gray")
            sender.isEnabled = false
            
            stopAudio.image = #imageLiteral(resourceName: "ic_stop_black")
            btnStopAudio.isEnabled = true
            
            audioRecorder?.record()
            
            Timer.cancelPreviousPerformRequests(withTarget: self, selector: #selector(currentTime(_:)), object: nil)
            
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(currentTime(_:)), userInfo: nil, repeats: true)
            
        }else {
            self.timer.invalidate()
            self.audioRecorder?.stop()
            self.currentTime = 0
            self.recordTimerLabel?.text = "00:00"
        }
    }
    
    // open camera
    @IBAction func btnCameraTapped(_ sender : UIButton) {
        
        let cameraVctr = CameraViewController(nibName: "CameraViewController", bundle: nil)
        cameraVctr.delegate = self
        cameraVctr.refNumber = webRefNumber!
        self.present(cameraVctr, animated: true, completion: nil)
    }
    
    // show Audio Controls
    @IBAction func btnAudioTapped(_ sender : UIButton) {
        
        recLabel  = false
        countDown = false
        OkView = false
        
        viewVideoControl?.isHidden = false
        
        self.setUpRecorder()
        
        heightConstant = 50.0
        
        self.showAudioControls()
    }
    
    // open Video
    @IBAction func btnVideoTapped(_ sender : UIButton) {
        
        let videoVctr = VideoViewController(nibName: "VideoViewController", bundle: nil)
        videoVctr.delegate = self
        videoVctr.webRefNumber = webRefNumber!
        self.present(videoVctr, animated: true, completion: nil)
    }
    
    @IBAction func currentTime(_ sender : Timer)
    {
        currentTime += 1
        if currentTime > 600 {
            self.timer.invalidate()
            self.audioRecorder?.stop()
            self.currentTime = 0
            self.recordTimerLabel!.text = "00:00"
        }
        if currentTime <= 60 && currentTime >= 10{
            self.recordTimerLabel!.text = "00:\(currentTime)"
        }else if currentTime < 10 {
            self.recordTimerLabel!.text = "00:0\(currentTime)"
        }
        else if currentTime > 60 {
            self.recordTimerLabel!.text = "\(currentTime / 60):\(currentTime % 60)"
        }
    }
    
    @IBAction func currentTimeForPlaying(_ sender: UIButton) {
        
        currentPlayTime -= 1
        
        if currentPlayTime == 0 {
            self.timer.invalidate()
            self.audioPlayer?.stop()
            self.currentPlayTime = 0
            self.recordTimerLabel!.text = "00:00"
        }else if(currentPlayTime > 0) {
            if currentPlayTime > 60 {
                self.recordTimerLabel!.text = "\(currentPlayTime / 60):\(currentPlayTime % 60)"
            }
            else if currentPlayTime <= 60 && currentPlayTime >= 10{
                self.recordTimerLabel!.text = "00:\(currentPlayTime)"
            }
            else  {
                self.recordTimerLabel!.text = "00:0\(currentPlayTime)"
            }
        }
    }
    
    func setUpRecorder() {
    
        let timeInt = Int(Utility.sharedUtility.getMillisecondsFromDateTime(Date()))!
        
        self.audioName = "\(timeInt).caf"
        
        // getting URL path for audio
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docDir = dirPath[0] as NSString
        let soundFilePath = docDir.appendingPathComponent(self.audioName)
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        print(soundFileURL)
        
        let recordSetting = [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
                             AVEncoderBitRateKey: 16,
                             AVNumberOfChannelsKey : 2,
                             AVSampleRateKey: 44100.0] as [String : Any]
        
        let error : NSError? = nil
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            print(error)
        }
        if let err = error {
            print("audioSession error: \(err.localizedDescription)")
        }
        
        do {
            audioRecorder = try AVAudioRecorder.init(url: soundFileURL as URL, settings: recordSetting as [String: Any])
            
        } catch  {
            print(error)
        }
        
        if let err = error {
            print("audioSession error: \(err.localizedDescription)")
        }else{
            audioRecorder?.prepareToRecord()
        }
    }
}


extension ImageControlViewController : VideoProtocol,CameraProtocol
{
    func videoWithImageTag(_ image: UIImage,nameTag: String, infoDict: [String:AnyObject]) {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "hh:mm:ss:SSS"
        let timeString = dateFormatter.string(from: date)
        
        var videoDetails = ["mediaName": mediaNameString!, "latitude":infoDict["latitude"] as Any, "longitude":infoDict["longitude"] as Any, "lastModifiedTime":timeString, "lastModifiedDate":dateString,"size":"\(infoDict["size"]! as Any) Bytes","mediaType" : MediaControlType.kVideoControl,"fieldID" : fieldID!,"webRefNumber":webRefNumber!] as [String : AnyObject]
        
        videoDetails["tag"] = nameTag as AnyObject
        
        if DataModel.share.insertMediaDetailsForFieldID(fieldID: fieldID!, webRefNumber: webRefNumber!, response: [videoDetails]) {
            
            mediaArray?.removeAll()
            
            // reload Tableview
            mediaArray = DataModel.share.getMediaDetailsForFieldID(fieldID: fieldID!, webRefNumber: webRefNumber!)
            
            if (mediaViewTable?.isHidden)! {
                mediaViewTable?.isHidden = false
            }
            
            if (mediaViewTable?.frame.size.height)! < 250.0 {
                
                mediaViewTable?.frame.size.height = (mediaViewTable?.frame.size.height)! + 60.0
                
                tableViewMedia?.frame.size.height = (mediaViewTable?.frame.size.height)! - 5.0

                mediaViewTable?.layoutIfNeeded()
            }

            tableViewMedia?.reloadData()
        }
        
    }
    
    
    func cameraWithImage(image: UIImage,imageTag: String)
    {
        if self.delegate != nil
        {
            let imageData = NSData.init(data:  UIImageJPEGRepresentation(image, 1)!)
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateString = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "hh:mm:ss:SSS"
            let timeString = dateFormatter.string(from: date)
            
            var imageDetails = ["mediaName": mediaNameString!, "latitude":latitude, "longitude":longitude, "lastModifiedTime":timeString, "lastModifiedDate":dateString,"size":"\(imageData.length) Bytes","mediaType" : MediaControlType.kImageControl,"fieldID" : fieldID!,"webRefNumber":webRefNumber!] as [String : AnyObject]
            
            imageDetails["tag"] = imageTag as AnyObject

            if DataModel.share.insertMediaDetailsForFieldID(fieldID: fieldID!, webRefNumber: webRefNumber!, response: [imageDetails]) {
                
                mediaArray?.removeAll()
                
                // reload Tableview
                mediaArray = DataModel.share.getMediaDetailsForFieldID(fieldID: fieldID!, webRefNumber: webRefNumber!)
                
                if (mediaViewTable?.isHidden)! {
                    mediaViewTable?.isHidden = false
                }
                
                if (mediaViewTable?.frame.size.height)! < 250.0 {
                    
                    mediaViewTable?.frame.size.height = (mediaViewTable?.frame.size.height)! + 60.0
                    tableViewMedia?.frame.size.height = (mediaViewTable?.frame.size.height)! - 5.0
                    
                    mediaViewTable?.layoutIfNeeded()
                }
                
                tableViewMedia?.reloadData()
            }
        }

    }
}

extension ImageControlViewController: AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        if btnRecording != nil {
            btnRecording.isEnabled = true
            btnStopAudio.isEnabled = false
        }
    }
    
    private func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: Error!) {
        print("Audio Play Decode Error")
    }
    
    private func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
    }
    
    private func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
        print("Audio Record Encode Error")
    }
}
extension ImageControlViewController : Location {
    
    func locationWithLatLong(latitude: Double, longitude: Double, location: String) {
        print(longitude)
        print(latitude)
        self.longitude = longitude
        self.latitude = latitude
    }
    
    func locationDisabled(){
        
        let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Please enable the location", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
        self.view.addSubview(alertView)        
    }
    
    @IBAction func locationStatusUpdate() {
        LocationManager.sharedLocation.locationStatus(delegate: self)
    }
}

extension ImageControlViewController : UtilityProtocol
{
    func dismissAlert() {
        let alertView = self.view.subviews.last
        alertView?.removeFromSuperview()
        
        tableViewMedia?.reloadData()

    }
    
    func pushToViewController()
    {
    }
    
    func pushToNextViewController() {
        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.openURL(settingsURL as URL)
        }
    }
}

extension ImageControlViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (mediaArray?.count)! > 0 {
            return mediaArray!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "cell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        for (_,view) in ((cell?.contentView.subviews)?.enumerated())! {
            
            if view.isKind(of: UIView.self) {
                view.removeFromSuperview()
            }
        }
        
        let item = (mediaArray as! [MediaInfo])[indexPath.row]
        
        let tempDict = ["date":item.lastModifiedDate! as Any,"time":item.lastModifiedTime! as Any,"size":item.size! as Any,"latitude":item.latitude as Any,"longitude":item.longitude as Any]
                
        if item.mediaType == MediaControlType.kImageControl {
            
            let imageControl = ImageControl(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 60.0), placeHolderText: item.mediaName!, responseValue : item.tag!, refNumber: self.webRefNumber!, isMandatory: false,imageDetails:tempDict ,delegate: self,isReadOnly: false, isDependent: false)
            
            cell?.contentView.addSubview(imageControl)
            
        }else if (item.mediaType == MediaControlType.kAudioControl) {
            
            let audioControl = AudioControl(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 60.0), placeHolderText: item.mediaName!, responseValue : item.tag!,  webRefNumber: self.webRefNumber!, isMandatory: false,delegate: self)
            
            cell?.contentView.addSubview(audioControl)
            
        }else {
            
            let videoControl = VideoControl(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 60.0), placeHolderText: item.mediaName!, responseValue : item.tag!,  webRefNumber: self.webRefNumber!, isMandatory: false,videoDetails:tempDict,delegate: self)
            
            cell?.contentView.addSubview(videoControl)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
}

extension ImageControlViewController : ImageControlProtocol,VideoControlProtocol,AudioControlProtocol {
    
    func playAudioWithTagAndName(tag: Int, name: String) {
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docDir = dirPath[0] as NSString
        let soundFilePath = docDir.appendingPathComponent(name)
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        
        let error : NSError? = nil
        
        print(soundFileURL)
        
        do{
            audioPlayer = try AVAudioPlayer.init(contentsOf: soundFileURL as URL)
        }catch {
            print(error)
        }
        
        audioPlayer?.delegate = self
        
        if let err = error{
            print("audioPlayer error: \(err.localizedDescription)")
        }else{
            audioPlayer?.play()
        }
    }
    
    func audioControlWithSuperview(superView: UIView, name: String, audioDetails: [String : AnyObject]) {
        
    }
    
    func removeAudioWithTag(tag: String) {
        
        if DataModel.share.deleteMediaDetails(fieldID: Int64(fieldID!), webRefNumber: webRefNumber!, itemTag: tag) {
            
            mediaArray?.removeAll()
            
            mediaArray = DataModel.share.getMediaDetailsForFieldID(fieldID: fieldID!, webRefNumber: webRefNumber!)
            
            if (mediaViewTable?.frame.size.height)! > 70.0 {
                
                mediaViewTable?.frame.size.height = (mediaViewTable?.frame.size.height)! - 60.0
                
                tableViewMedia?.frame.size.height = (mediaViewTable?.frame.size.height)! - 5.0
                
                mediaViewTable?.layoutIfNeeded()
            }
            
            if (mediaArray?.count)! == 0 {
                mediaViewTable?.isHidden = true
            }
            tableViewMedia?.reloadData()
        }
    }
    
    func videoControlWithSuperview(_ superView: UIView, _ name: String) {
        
    }
    
    func removeVideoWithTag(tag: String) {
        
        if DataModel.share.deleteMediaDetails(fieldID: Int64(fieldID!), webRefNumber: webRefNumber!, itemTag: tag) {
            
            mediaArray?.removeAll()
            
            mediaArray = DataModel.share.getMediaDetailsForFieldID(fieldID: fieldID!, webRefNumber: webRefNumber!)
            
            if (mediaViewTable?.frame.size.height)! > 70.0 {
                
                mediaViewTable?.frame.size.height = (mediaViewTable?.frame.size.height)! - 60.0
                
                tableViewMedia?.frame.size.height = (mediaViewTable?.frame.size.height)! - 5.0
                
                mediaViewTable?.layoutIfNeeded()
            }
            
            if (mediaArray?.count)! == 0 {
                mediaViewTable?.isHidden = true
            }
            tableViewMedia?.reloadData()
        }
    }
    
    
    func imageControlWithSuperview(_ superView: UIView, _ name: String, _ imageDetails: [String : AnyObject]) {
        
    }
    
    func removeImageWithTag(tag: String) {
        
        if DataModel.share.deleteMediaDetails(fieldID: Int64(fieldID!), webRefNumber: webRefNumber!, itemTag: tag) {
            
            mediaArray?.removeAll()
            
            mediaArray = DataModel.share.getMediaDetailsForFieldID(fieldID: fieldID!, webRefNumber: webRefNumber!)
            
            if (mediaViewTable?.frame.size.height)! > 70.0 {
                
                mediaViewTable?.frame.size.height = (mediaViewTable?.frame.size.height)! - 60.0
                
                tableViewMedia?.frame.size.height = (mediaViewTable?.frame.size.height)! - 5.0
                
                mediaViewTable?.layoutIfNeeded()
            }
            
            if (mediaArray?.count)! == 0 {
                mediaViewTable?.isHidden = true
            }
            tableViewMedia?.reloadData()
        }
    }
}




