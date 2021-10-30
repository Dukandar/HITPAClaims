//
//  AudioPlayerViewController.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 12/09/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayerViewController: UIViewController {
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playDuration: UILabel!
    
    var audioName : String? = nil
    var webRefNumber : String?
    var audioPlayer: AVAudioPlayer?

    
    convenience init( audioName : String,webRefNumber : String)
    {
        self.init()
        self.audioName = audioName
        self.webRefNumber = webRefNumber
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        createPlayer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createPlayer() {
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docDir = dirPath[0] as NSString
        let soundFilePath = docDir.appendingPathComponent(self.audioName!)
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        
        print(soundFileURL)
        
        do{
            audioPlayer = try AVAudioPlayer.init(contentsOf: soundFileURL as URL)
        }catch {
            print(error)
        }
        
        audioPlayer?.delegate = self
    }
    
    @IBAction func dismissScreen(_ sender: UIButton) {
        
        audioPlayer?.stop()
        
        self.dismiss(animated: true, completion: nil)
        
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
    
    @IBAction func playPauseAudio(_ sender: UIButton) {
        
        if !(self.audioPlayer?.isPlaying)!
        {
            print("Playing")
            self.audioPlayer?.play()
            self.playBtn.setBackgroundImage(UIImage(named : "icon_playerBtnPause"), for: UIControlState.normal)
            self.watcher()
            
        }else
        {
            print("Not playing")
            self.audioPlayer?.pause()
            self.playBtn.setBackgroundImage(UIImage(named : "icon_playerBtnPlay"), for: UIControlState.normal)
        }
        
    }
    
    @IBAction func watcher()
    {
        if !(self.audioPlayer?.isPlaying)!
        {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(watcher), object: nil)
        }else
        {
            let currentTime = self.audioPlayer?.currentTime
            self.playDuration.text = self.timeFormat(seconds: Float(currentTime!))
            self.perform(#selector(watcher), with: nil, afterDelay: 0.5)
            self.slider.value = Float(currentTime! / (self.audioPlayer?.duration)!)
        }
    }
    
}

extension AudioPlayerViewController : AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        audioPlayer?.stop()
        
    }
    
    private func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: Error!) {
        print("Audio Play Decode Error")
    }
}
