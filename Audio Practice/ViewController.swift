//
//  ViewController.swift
//  Audio Practice
//
//  Created by Taehyung Kim on 7/8/16.
//  Copyright © 2016 Taehyung Kim. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var player: AVAudioPlayer = AVAudioPlayer() //controls music
    
    @IBOutlet var musicTitleLabel: UILabel!
    @IBOutlet var musicRateLabel: UILabel!
    
    @IBOutlet var musicCurrentTime: UILabel!
    @IBOutlet var musicEndTime: UILabel!
    
    @IBOutlet var playPauseButtonIcon: UIButton!
    
    @IBOutlet var musicVolumeSlider: UISlider!
    @IBOutlet var musicTimeSlider: UISlider!
    @IBOutlet var musicRateSlider: UISlider!
    
    @IBOutlet var volumeIcon: UIImageView!
    
    @IBAction func playPauseButton(_ sender: UIButton) {
        if player.isPlaying {
            player.pause()
            playPauseButtonIcon.setImage(#imageLiteral(resourceName: "white play"), for: [])
        } else {
            player.play()
            playPauseButtonIcon.setImage(#imageLiteral(resourceName: "white pause"), for: [])
        }
    }

    //manual control of volume
    // *** need to change so that it's consistent with the device. max value should be max value of device and change with device sound changes.
    @IBAction func adjustMusicVolume(_ sender: UISlider) {
        player.volume = musicVolumeSlider.value
        if musicVolumeSlider.value == 0.0 {
            volumeIcon.image = #imageLiteral(resourceName: "white mute")
        } else {
            volumeIcon.image = #imageLiteral(resourceName: "white sound")
        }
    }
    
    //manual control of music rate
    // *** need to change string to only display 2 numbers past decimal
    @IBAction func adjustMusicRate(_ sender: UISlider) {
        player.rate = musicRateSlider.value
        musicRateLabel.text = String(musicRateSlider.value)
    }
    
    //manual control of music time
    // *** need to display 2 decimals past seconds
    @IBAction func musicTime(_ sender: UISlider) {
        player.currentTime = TimeInterval (musicTimeSlider.value)
        
        let currentTimeMin:Int = Int(player.currentTime)/60
        let currentTimeSec:Int = Int(player.currentTime) % 60
        
        if currentTimeMin < 10 {
            if currentTimeSec < 10 {
                musicCurrentTime.text = "0\(currentTimeMin):0\(currentTimeSec)"
            } else {
                musicCurrentTime.text = "0\(currentTimeMin):\(currentTimeSec)"
            }
        } else {
            if currentTimeSec < 10 {
                musicCurrentTime.text = "\(currentTimeMin):0\(currentTimeSec)"
            } else {
                musicCurrentTime.text = "\(currentTimeMin):\(currentTimeSec)"
            }
        }
    }
    
    // slider updates as the music progresses
    func updateMusicTimeSlider() {
        musicTimeSlider.value = Float (player.currentTime)
        
        let currentTimeMin:Int = Int(player.currentTime)/60
        let currentTimeSec:Int = Int(player.currentTime) % 60
        
        if currentTimeMin < 10 {
            if currentTimeSec < 10 {
                musicCurrentTime.text = "0\(currentTimeMin):0\(currentTimeSec)"
            } else {
                musicCurrentTime.text = "0\(currentTimeMin):\(currentTimeSec)"
            }
        } else {
            if currentTimeSec < 10 {
                musicCurrentTime.text = "\(currentTimeMin):0\(currentTimeSec)"
            } else {
                musicCurrentTime.text = "\(currentTimeMin):\(currentTimeSec)"
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let audioPath = Bundle.main().pathForResource("Tyga - Hijack", ofType: "mp3")!
        
        do {
            try player = AVAudioPlayer(contentsOf: URL (fileURLWithPath: audioPath))
            
            player.enableRate = true
            
            musicTitleLabel.text = "Tyga ft. 2 Chainz - Hijack"
            
            musicCurrentTime.text = "00:00"
            
            let endTimeMin:Int = Int(player.duration)/60
            let endTimeSec:Int = Int(player.duration) % 60
            if (endTimeMin < 10) {
                musicEndTime.text = "0\(endTimeMin):\(endTimeSec)"
            } else {
                musicEndTime.text = "\(endTimeMin):\(endTimeSec)"
            }
            
            musicTimeSlider.maximumValue = Float(player.duration)
            musicTimeSlider.value = 0.0
            
            musicVolumeSlider.value = player.volume
            
            musicRateSlider.value = player.rate
            musicRateSlider.minimumValue = 0.5
            musicRateSlider.maximumValue = 1.5
            musicRateLabel.text = String(player.rate)
            
        } catch {
            print ("Music could not be loaded")
        }
        
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateMusicTimeSlider), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

