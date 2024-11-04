//
//  GlobalAudioPlayer.swift
//  Rings
//
//  Created by Brody on 11/4/24.
//
import AVFoundation
import Foundation
import SwiftUI

@Observable
class GlobalAudioPlayer: ObservableObject {
    var audioPlayer: AVAudioPlayer?
    var playbackTimer: Timer?
    var audioProgress: Float = 0.0
    var prevURL: URL = URL(fileURLWithPath: "")
    
    func loadAudioPlayer(url: URL) {
        do {
            // Stop the currently playing audio if any
            if audioPlayer?.isPlaying == true {
                audioPlayer?.stop()
            }
            // Load and prepare new audio
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            self.prevURL = url
            audioPlayer!.prepareToPlay()
            audioPlayer!.volume = 1.0
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }
    
    func play(url: URL) {
        // Stop the currently playing audio, if any, to prevent overlap
        if url == self.prevURL{
//            if audioPlayer?.isPlaying == true {
//                audioPlayer?.stop()
//            }
            
            
            //Continue playing from resumed point
            print("resuming AudioPlayer")
            audioPlayer?.play()
        } else {
            //Reload AudioPlayer
            print("reloading AudioPlayer")
            loadAudioPlayer(url: url)
            audioPlayer?.play()
        }
        
    }
    
    func pause(url: URL) { audioPlayer?.pause() }
    
    func startTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if let currentTime = self.audioPlayer?.currentTime {
                self.audioProgress = Float(currentTime)
                if currentTime == 0.0 {
                    self.stopTimer()
                }
            }
        }
    }
    
    func stopTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
}

