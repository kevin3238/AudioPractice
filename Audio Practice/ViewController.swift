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
    
    @IBOutlet var musicVolumeSlider: UISlider!
    
    @IBAction func playMusicButton(_ sender: UIButton) {
        player.play()
    }
    
    @IBAction func pauseMusicButton(_ sender: UIButton) {
        player.pause()
    }
    
    @IBAction func adjustMusicVolume(_ sender: UISlider) {
        player.volume = musicVolumeSlider.value
    }
    
    var player: AVAudioPlayer = AVAudioPlayer() //controls music
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let audioPath = Bundle.main().pathForResource("Tyga - Hijack", ofType: "mp3")!
        
        do {
            try player = AVAudioPlayer(contentsOf: URL (fileURLWithPath: audioPath))
            player.play()
        } catch {
            print ("process error here")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

