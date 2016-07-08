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
    @IBOutlet var playPauseButtonIcon: UIButton!
    @IBOutlet var musicVolumeSlider: UISlider!
    @IBOutlet var musicTimeSlider: UISlider!
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

    @IBAction func adjustMusicVolume(_ sender: UISlider) {
        player.volume = musicVolumeSlider.value
        if musicVolumeSlider.value == 0.0 {
            volumeIcon.image = #imageLiteral(resourceName: "white mute")
        } else {
            volumeIcon.image = #imageLiteral(resourceName: "white sound")
        }
    }
    
    @IBAction func musicTime(_ sender: UISlider) {
        player.currentTime = TimeInterval (musicTimeSlider.value)
    }
    
    func updateMusicTimeSlider() {
        musicTimeSlider.value = Float (player.currentTime)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let audioPath = Bundle.main().pathForResource("Tyga - Hijack", ofType: "mp3")!
        
        do {
            try player = AVAudioPlayer(contentsOf: URL (fileURLWithPath: audioPath))
            
            musicTitleLabel.text = "Tyga - Hijjack"
            
            musicTimeSlider.maximumValue = Float(player.duration)
            musicTimeSlider.value = 0.0
            
            musicVolumeSlider.value = player.volume
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

