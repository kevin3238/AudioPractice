//
//  ViewController.swift
//  Audio Practice
//
//  Created by Taehyung Kim on 7/8/16.
//  Copyright © 2016 Taehyung Kim. All rights reserved.
//

// make icons buttons, and when clicked go to default


import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController, AVAudioRecorderDelegate, MPMediaPickerControllerDelegate {
    
    var player: AVAudioPlayerNode!
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    var changeAudio:AVAudioUnitTimePitch!
    
    var nodeTime:AVAudioTime!
    var playerTime:AVAudioTime!
    var currentTimeMusic:Float!
    var endTimeMusic:Float!
    
    var isRecording:Bool = false
    var isRepeat:Bool = false
    var isBeginning:Bool = true
    var isMuted:Bool = false
    var lastVolume:Float!
    var numberLoops: Int = 100000
    
    @IBOutlet var musicTitleLabel: UILabel!
    @IBOutlet var musicArtistLabel: UILabel!
    @IBOutlet var musicPitchLabel: UILabel!
    @IBOutlet var musicRateLabel: UILabel!
    @IBOutlet var musicVolumeLabel: UILabel!
    
    @IBOutlet var musicCurrentTime: UILabel!
    @IBOutlet var musicEndTime: UILabel!
    
    @IBOutlet var playPauseButtonIcon: UIButton!
    @IBOutlet var muteVolumeButtonIcon: UIButton!
    @IBOutlet var resetMusicRateButtonIcon: UIButton!
    @IBOutlet var loopMusicButtonIcon: UIButton!
    @IBOutlet var recordButtonIcon: UIButton!
    @IBOutlet var rewindButtonIcon: UIButton!
    
    @IBOutlet var musicVolumeSlider: UISlider!
    @IBOutlet var musicTimeSlider: UISlider!
    @IBOutlet var musicRateSlider: UISlider!
    @IBOutlet var musicPitchSlider: UISlider!
    
//    @IBOutlet var musicImageView: UIImageView!
    @IBOutlet var musicImageView: UIImageView!
    @IBOutlet var smallMusicImageView: UIImageView!
    
    //MediaPicker vars
//    var mediaPicker: MPMediaPickerController?
//    var myMusicPlayer: MPMusicPlayerController?
//    let masterVolumeSlider: MPVolumeView = MPVolumeView()

    //func mediaPicker(mediaPicker:)
    
    @IBAction func playPauseButton(_ sender: UIButton) {
        if player.isPlaying {
            player.pause()
            playPauseButtonIcon.setImage(#imageLiteral(resourceName: "white play"), for: [])
        } else {
            player.play()
            playPauseButtonIcon.setImage(#imageLiteral(resourceName: "white pause 2"), for: [])
        }
    }

    @IBAction func muteVolumeButton(_ sender: UIButton) {
        if (isMuted) {
            musicVolumeLabel.text = String(Int(Float(lastVolume)*100))
            musicVolumeLabel.text?.append(" %")
            musicVolumeSlider.value = Float(Float(lastVolume)*100)
            player.volume = lastVolume
            muteVolumeButtonIcon.setImage(#imageLiteral(resourceName: "white sound"), for: [])
            isMuted = false
        } else {
            musicVolumeLabel.text = "0"
            musicVolumeSlider.value = 0
            lastVolume = player.volume
            player.volume = 0
            muteVolumeButtonIcon.setImage(#imageLiteral(resourceName: "white mute"), for: [])
            isMuted = true
        }
    }
    
    @IBAction func resetMusicRateButton(_ sender: UIButton) {
        musicRateLabel.text = "1.0x"
        musicRateSlider.value = 1.0
        changeAudio.rate = 1.0
    }
   
//    @IBAction func loopMusicButton(_ sender: UIButton) {
//        if isRepeat {
//            loopMusicButtonIcon.setImage(#imageLiteral(resourceName: "white infinity"), for: [])
//            player.numberOfLoops = 0
//            isRepeat = false
//        } else {
//            loopMusicButtonIcon.setImage(#imageLiteral(resourceName: "green infinity"), for: [])
//            player.numberOfLoops = numberLoops
//            isRepeat = true
//        }
//    }
    
    @IBAction func rewindMusicButton(_ sender: UIButton) {
        var nodetime: AVAudioTime  = player.lastRenderTime!
        let playerTime: AVAudioTime = player.playerTime(forNodeTime: nodetime)!
        var sampleRate = playerTime.sampleRate
        
        var newsampletime = AVAudioFramePosition(sampleRate * Double(musicTimeSlider.value))
        
        var length = Float(endTimeMusic!)
        var framestoplay = AVAudioFrameCount(Float(playerTime.sampleRate) * length)
        
        player.stop()
        
        if framestoplay > 100 {
            player.scheduleSegment(audioFile, startingFrame: newsampletime, frameCount: framestoplay, at: nil,completionHandler: nil)
        }
        
        player.play()
        
        
    }
    
//    @IBAction func recordMusicButton(_ sender: UIButton) {
//        print ("hello")
//        if !(isRecording) {
//            do {
//                let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//                let recordingName = "my_audio.wav"
//                let pathArray = [dirPath, recordingName]
//                let filePath = URL.fileURL(withPathComponents: pathArray)
//                let session = AVAudioSession.sharedInstance()
//                try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
//                try audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
//                try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
//                audioRecorder.prepareToRecord()
//                audioRecorder.record()
//            } catch {
//                print ("cannot record")
//            }
//        } else {
//            do {
//                audioRecorder.stop()
//                let audioSession = AVAudioSession.sharedInstance()
//                try audioSession.setActive(false)
//            } catch {
//                print ("doesnt work here")
//            }
//        }
//    }
    
    //manual control of volume
    // *** need to change so that it's consistent with the device. max value should be max value of device and change with device sound changes.
    @IBAction func adjustMusicVolume(_ sender: UISlider) {
        player.volume = Float(musicVolumeSlider.value / 100.0)
        musicVolumeLabel.text = String(Int(musicVolumeSlider.value))
        musicVolumeLabel.text?.append(" %")
        if musicVolumeSlider.value == 0.0 {
            muteVolumeButtonIcon.setImage(#imageLiteral(resourceName: "white mute"), for: [])
        } else {
            muteVolumeButtonIcon.setImage(#imageLiteral(resourceName: "white sound"), for: [])
        }
    }
   
    @IBAction func adjustMusicPitch(_ sender: UISlider) {
        changeAudio.pitch = musicPitchSlider.value
        let musicPitchRaw: String = String(musicPitchSlider.value)
        
        var count = 0;
        print (musicPitchRaw)
        for char in musicPitchRaw.characters {
            if char == "." {
                let musicPitchIndex = musicPitchRaw.index(musicPitchRaw.startIndex, offsetBy: count)
                let musicPitch:String = musicPitchRaw.substring(to: musicPitchIndex)
                musicPitchLabel.text = musicPitch
            } else {
                count+=1
            }
        }
//        print(count)
//
//        if (musicPitchRaw.characters.count < 5) {
//            musicPitchLabel.text = musicPitchRaw
//        }
//        else if (musicPitchRaw.characters.count >= 5) {
//            let musicPitchIndex = musicPitchRaw.index(musicPitchRaw.startIndex, offsetBy: 4)
//            let musicPitch:String = musicPitchRaw.substring(to: musicPitchIndex)
//            musicPitchLabel.text = musicPitch
//        }
        musicPitchLabel.text?.append(" c")
        
    }
    
    //manual control of music rate
    // *** need to change string to only display 2 numbers past decimal
    @IBAction func adjustMusicRate(_ sender: UISlider) {
        changeAudio.rate = musicRateSlider.value
        var musicRateRaw: String = String(musicRateSlider.value)
        if (musicRateRaw.characters.count < 5) {
            musicRateLabel.text = musicRateRaw
        }
        else if (musicRateRaw.characters.count >= 5) {
            let musicRateIndex = musicRateRaw.index(musicRateRaw.startIndex, offsetBy: 4)
            let musicRate:String = musicRateRaw.substring(to: musicRateIndex)
            musicRateLabel.text = musicRate
        }
        musicRateLabel.text?.append(" x")
    }
    
    //manual control of music time
    @IBAction func musicTime(_ sender: UISlider) {
        
        let newsampletime = AVAudioFramePosition(playerTime.sampleRate * Double(musicTimeSlider.value))
        let length = Float(endTimeMusic!) - musicTimeSlider.value
        let framestoplay = AVAudioFrameCount(Float(playerTime.sampleRate) * length)
        currentTimeMusic = Float(Double(newsampletime) / playerTime.sampleRate)
        player.stop()
        
        if framestoplay > 100 {
            player.scheduleSegment(audioFile, startingFrame: newsampletime, frameCount: framestoplay, at: nil,completionHandler: nil)
        }
        
        player.play()
        print(currentTimeMusic)
//        musicTimeSlider.value = currentTimeMusic
        
        print(player.lastRenderTime)
        
        let currentTimeMin:Int = Int(currentTimeMusic)/60
        let currentTimeSec:Int = Int(currentTimeMusic) % 60
        
        let ms = currentTimeMusic.truncatingRemainder(dividingBy: 1.0) * 1000
        
        var currentTimeMil: String = String(ms)
        if (currentTimeMil.characters.count > 3) {
            let idx2 = currentTimeMil.index(currentTimeMil.startIndex, offsetBy: 2)
            currentTimeMil = currentTimeMil.substring (to: idx2)
        }
        
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
        musicCurrentTime.text?.append(".")
        musicCurrentTime.text?.append(currentTimeMil)
    }
    
    
    // slider updates as the music progresses
    func updateMusicTimeSlider() {
        if (player.isPlaying) {
            playPauseButtonIcon.setImage(#imageLiteral(resourceName: "white pause 2"), for: [])
            nodeTime = self.player.lastRenderTime
            playerTime = player.playerTime(forNodeTime: nodeTime)
            currentTimeMusic = Float(Double(playerTime.sampleTime) / playerTime.sampleRate)
        } else {
            playPauseButtonIcon.setImage(#imageLiteral(resourceName: "white play"), for: [])
        }
        musicTimeSlider.value = Float (currentTimeMusic)
        
        let currentTimeMin:Int = Int(currentTimeMusic)/60
        let currentTimeSec:Int = Int(currentTimeMusic) % 60
        
        let ms = currentTimeMusic.truncatingRemainder(dividingBy: 1.0) * 1000
        
        var currentTimeMil: String = String(ms)
        if (currentTimeMil.characters.count > 3) {
            let idx2 = currentTimeMil.index(currentTimeMil.startIndex, offsetBy: 2)
            currentTimeMil = currentTimeMil.substring (to: idx2)
        }
        
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
        musicCurrentTime.text?.append(".")
        musicCurrentTime.text?.append(currentTimeMil)
    }
    
    
    //figure out how to load music from library
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioEngine = AVAudioEngine()
        player = AVAudioPlayerNode()
        player.volume = 1.0
        
        let audioPath = Bundle.main().pathForResource("aca fall 2014", ofType: "mp3")!
        let url = NSURL.fileURL(withPath: audioPath)
        
        audioFile = try? AVAudioFile(forReading: url)
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile!.processingFormat, frameCapacity: AVAudioFrameCount(audioFile!.length))
        do {
            try audioFile!.read(into: buffer)
        } catch _ {
        }
        
        changeAudio = AVAudioUnitTimePitch()

        audioEngine.attach(player)
        audioEngine.attach(changeAudio)
        audioEngine.connect(player, to: changeAudio, format: buffer.format)
        audioEngine.connect(changeAudio, to: audioEngine.mainMixerNode, format: buffer.format)
        
        player.scheduleBuffer(buffer, at: nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch _ {
        }
        
        player.play()
        
        nodeTime = self.player.lastRenderTime
        playerTime = player.playerTime(forNodeTime: nodeTime)
        currentTimeMusic = Float(Double(playerTime.sampleTime) / playerTime.sampleRate)
        print (currentTimeMusic)
        
        endTimeMusic = Float (Float(audioFile.length) / Float(playerTime.sampleRate))
        
//        player.pause()
        
        musicTitleLabel.text = "ACA Bridge Fall 2014"
        musicArtistLabel.text = "TungFuHustle"
        
        
        musicCurrentTime.text = "00:00.00"
        
        let endTimeMin:Int = Int(endTimeMusic)/60
        let endTimeSec = Int((endTimeMusic).truncatingRemainder(dividingBy: 60))
        let endTimeMs = endTimeMusic.truncatingRemainder(dividingBy: 1.0) * 1000
        
        var endTimeMil: String = String(endTimeMs)
        if (endTimeMil.characters.count > 3) {
            let idx2 = endTimeMil.index(endTimeMil.startIndex, offsetBy: 2)
            endTimeMil = endTimeMil.substring (to: idx2)
        }
        
        if (endTimeMin < 10) {
            if endTimeSec < 10 {
                musicEndTime.text = "0\(endTimeMin):0\(endTimeSec)"
            } else {
                musicEndTime.text = "0\(endTimeMin):\(endTimeSec)"
            }

        } else {
            if endTimeSec < 10 {
                musicEndTime.text = "\(endTimeMin):0\(endTimeSec)"
            } else {
                musicEndTime.text = "\(endTimeMin):\(endTimeSec)"
            }
        }
        
        musicEndTime.text?.append(".")
        musicEndTime.text?.append(endTimeMil)
        
        //setting music time
        musicTimeSlider.maximumValue = Float(endTimeMusic)
        musicTimeSlider.value = 0.0
    
        //setting volume
        player.volume = 0.5
        musicVolumeSlider.minimumValue = 0
        musicVolumeSlider.maximumValue = 100
        musicVolumeSlider.value = (player.volume * 100.0)
        musicVolumeLabel.text = String(Int(musicVolumeSlider.value))
        musicVolumeLabel.text?.append(" %")
        
        //setting pitch
        changeAudio.pitch = 1.0
        musicPitchSlider.value = changeAudio.pitch
        musicPitchSlider.minimumValue = -1200
        musicPitchSlider.maximumValue = 2400
        musicPitchLabel.text = "1 c"
        
        //setting rate
        changeAudio.rate = 1.0
        musicRateSlider.value = changeAudio.rate
        musicRateSlider.minimumValue = 0.5
        musicRateSlider.maximumValue = 2.0
        musicRateLabel.text = String(changeAudio.rate)
        musicRateLabel.text?.append(" x")
        
        //applying blur to musicImageView
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.95
        blurEffectView.frame = musicImageView.bounds
        musicImageView.addSubview(blurEffectView)
        
        //cropping circular image of smallMusicImageView
        smallMusicImageView.layer.borderWidth = 1
        smallMusicImageView.layer.masksToBounds = false
        smallMusicImageView.layer.borderColor = UIColor.white().cgColor
        smallMusicImageView.layer.cornerRadius = smallMusicImageView.frame.height/2
        smallMusicImageView.clipsToBounds = true
        
        //timer to update musicTimeSlider
        _ = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.updateMusicTimeSlider), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

