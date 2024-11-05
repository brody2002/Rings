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
    var progressBySong: [URL: Float] = [:]
    var songStartedByURL: [URL: Bool] = [:] // Track whether each song has started
    var songIsPlayingByURL: [URL: Bool] = [:]// Track whether each Song is in pause or play state
    
    func loadAudioPlayer(url: URL) {
        do {
            // Stop the currently playing audio if any
            if audioPlayer?.isPlaying == true {
                audioPlayer?.stop()
            }
            // Load and prepare new audio
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            self.prevURL = url
            resetProgress(for: self.prevURL)
            audioPlayer!.prepareToPlay()
            audioPlayer!.volume = 1.0
            audioProgress = 0.0
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }
    
    func play(url: URL) {
        if let started = songStartedByURL[url], started && url == self.prevURL{
            // Stop the currently playing audio, if any, to prevent overlap
            
                //Continue playing from resumed point
                print("resuming AudioPlayer")
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                    audioPlayer?.play()
                } catch {
                    // report for an error
                    print("error playing audio as a shardInstance")
                }
        } else {
            //Reload AudioPlayer
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                print("reloading AudioPlayer")
                loadAudioPlayer(url: url)
                
                audioPlayer?.play()
                songStartedByURL[url] = true
            } catch {
                // report for an error
                print("error playing audio as a shardInstance")
            }
            
        }
        songIsPlayingByURL[url] = true
        startTimer(url: url)
        
    }

    
    func pause(url: URL) {
        audioPlayer?.pause()
        songIsPlayingByURL[url] = false
    }
    
    func startTimer(url: URL) {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if let currentTime = self.audioPlayer?.currentTime {
                self.progressBySong[url] = Float(currentTime)
                if currentTime == 0.0 {
                    // reset values of the play button
                    self.stopTimer()
                    self.resetProgress(for: url)
                    //turn pause button to play button.
                }
            }
        }
    }
    
    func stopTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    // Resets the blue progress bar
    func resetProgress(for url: URL) {
        
        self.progressBySong[url] = 0
        print("changed progress of \n\(url) to \(self.progressBySong[url])")
        self.songStartedByURL[url] = false
    }
}

