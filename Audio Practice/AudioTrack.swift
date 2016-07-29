//
//  AudioTrack.swift
//  Audio Practice
//
//  Created by Taehyung Kim on 7/25/16.
//  Copyright © 2016 Taehyung Kim. All rights reserved.
//

import AVFoundation

class AudioTrack {
    private var segments = Array<AudioSegment>()
    private var currentPlayingSegment: Int!
    var player: AVAudioPlayerNode!
    var playing = false
    
    init(player: AVAudioPlayerNode) {
        self.player = player
    }
    
    func play() {
        player.play()
        if segments.count > 0 {
            currentPlayingSegment = 0
            scheduleSegment(segment: segments[currentPlayingSegment])
        }
        playing = true
    }
    
    func stop() {
        player.stop()
        currentPlayingSegment = nil
        playing = false
    }
    
    func reset() {
        if player.isPlaying {
            player.stop()
        }
        segments = []
        currentPlayingSegment = nil
        playing = false
    }
    
    private func scheduleSegment(segment:AudioSegment) {
        // println("schedule \(currentPlayingSegment)")
        player.scheduleSegment(segment.audioFile, startingFrame: segment.startFrame, frameCount: segment.frameCount, at: nil, completionHandler: scheduleNext)
    }
    
    private func scheduleNext() {
        if currentPlayingSegment == nil {
            return
        }
        if currentPlayingSegment! == segments.count - 1 {
            currentPlayingSegment = 0
            scheduleSegment(segment: segments[currentPlayingSegment])
            return
        }
        
        currentPlayingSegment! += 1
        scheduleSegment(segment: segments[currentPlayingSegment])
    }
    
    func addSegment(segment:AudioSegment) {
        segments.append(segment)
    }
    
    func insertSegment(segment:AudioSegment, atIndex index:Int) {
        segments.insert(segment, at: index)
        // adjust the current playing index if needed
        
        if currentPlayingSegment! >= index {
            currentPlayingSegment! += 1
        }
    }
}
