//
//  VideoPlayerViewController.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 03/09/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

struct PlayerDefinedDuration {
    static let kSrart   = 0
    static let kEnd     = 186
}

class VideoPlayerViewController: UIViewController {
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playDuration: UILabel!
    var player = MPMoviePlayerController()
    var videoName : String? = nil
    var webRefNumber : String?
    var videoDetails : [String:Any]?

    
    convenience init( videoName : String,webRefNumber : String)
    {
        self.init()
        self.videoName = videoName
        self.webRefNumber = webRefNumber
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackDidFinish(_:)), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: self.player)
        
        createPlayer()
        // Do any additional setup after loading the view.
    }
    @IBAction func stopVideo(_ sender: UIButton) {
        
        self.player.stop()
        
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func createPlayer()
    {
        let videoUrl = DocumentDirectory.shareDocumentDirectory.directoryPath().appendingPathComponent("\(self.videoName!).m4v")

        self.player = MPMoviePlayerController(contentURL:videoUrl)
        self.player.view.frame = self.playerView.bounds
        self.player.controlStyle = .none
        self.player.movieSourceType = .file
        self.player.scalingMode = .fill
        self.player.prepareToPlay()
        self.player.shouldAutoplay = false
        self.playerView.addSubview(self.player.view)
    }
    
    @IBAction func moviePlayBackDidFinish(_ notification : NSNotification)
    {
        print("finish playing")
        let error = notification.userInfo!["error"]
        if (error != nil)
        {
            print("Did finish with error: \(String(describing: error))")
        }else
        {
            self.playBtn.setBackgroundImage(UIImage(named:"icon_playerBtnPlay"), for: UIControlState.normal)
            self.slider.value = 0
        }
        
    }
    @IBAction func watcher()
    {
        if self.player.playbackState == MPMoviePlaybackState.paused
        {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(watcher), object: nil)
        }else
        {
            let currentTime = self.player.currentPlaybackTime
            self.playDuration.text = self.timeFormat(seconds: Float(currentTime))
            self.perform(#selector(watcher), with: nil, afterDelay: 0.5)
            self.slider.value = Float(currentTime / self.player.duration)
        }
    }
    
    @IBAction func onTimeSliderChange(sender : UISlider)
    {
        self.player.currentPlaybackTime = TimeInterval(slider.value)
        let currentTime = self.player.currentPlaybackTime
        self.playDuration.text =  self.timeFormat(seconds: Float(currentTime))
    }
    
    func timeFormat(seconds : Float)-> String
    {
        if !(seconds.isNaN) {
            let minutes = Int(seconds / 60)
            let second = (Int(seconds) % 60)
            
            if second < 10 {
                return "\(minutes):0\(second)"
            }else {
                return "\(minutes):\(second)"
            }
        }else {
            return ""
        }
    }
    
    @IBAction func playBtnTapped(_ sender: Any) {
        
        if self.player.playbackState == MPMoviePlaybackState.playing
        {
            print("Playing")
            self.playBtn.setBackgroundImage(UIImage(named : "icon_playerBtnPlay"), for: UIControlState.normal)
            self.player.pause()
            
        }else
        {
            print("Not playing")
            self.player.play()
            self.playBtn.setBackgroundImage(UIImage(named : "icon_playerBtnPause"), for: UIControlState.normal)
            self.watcher()
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func showVideoDetailView(_ sender: UIButton) {
        
        self.player.stop()
        
        let vctr = VideoInfoViewController()
        vctr.infoDictionary = self.videoDetails!
        
        vctr.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        vctr.modalPresentationStyle = .overFullScreen
        
        self.present(vctr, animated: true, completion: nil)
        
    }
    
}
