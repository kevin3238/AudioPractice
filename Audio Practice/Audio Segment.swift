//
//  AudioSegment.swift
//  Audio Practice
//
//  Created by Taehyung Kim on 7/25/16.
//  Copyright © 2016 Taehyung Kim. All rights reserved.
//

import AVFoundation

class AudioSegment {
    var audioFile: AVAudioFile!
    var startFrame: AVAudioFramePosition!
    var frameCount: AVAudioFrameCount!
    
    init(file:AVAudioFile, startPercentage:Float32, lengthPercentage:Float32) {
        audioFile = file
        
        let length = file.length
        startFrame = Int64(Float32(length) * startPercentage)
        frameCount = UInt32(Float32(length) * lengthPercentage)
        // println("length: \(length), \(startPercentage) -> \(lengthPercentage): \(startFrame) -> \(frameCount)")
    }
}
