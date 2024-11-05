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
    var prevURL: URL = URL(fileURLWithPath: "")
    
    // file info
    var audioProgressDict: [URL: Float] = [:] // Blue progress bar
    var isPlayingDict: [URL:Bool] = [:] // Track play/pause state for view
    var songStartedByURL: [URL: Bool] = [:] // Track whether each song has started
    
    //set previous URL somewhere
    func loadAudioPlayer(url: URL){
        let currentURL = url
        do{
            // Stop the currently playing audio if any
            if audioPlayer?.isPlaying == true {
                audioPlayer?.stop()
            }
            // Load and prepare new audio
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            
            audioPlayer!.prepareToPlay()
            audioPlayer!.volume = 1.0
            audioProgressDict[currentURL] = 0.0
        }
        catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }
    func playbackHelper(url: URL){
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            audioPlayer?.play()
            songStartedByURL[url] = true
            isPlayingDict[url] = true
            startTimer(url: url)
            
        }
        catch {
            print("error playing audio as a shared Instance")
        }
    }
    
    func play(url:URL){
        if let started = songStartedByURL[url], started && self.prevURL == url{
            print("song resumed at \(url.lastPathComponent)")
            playbackHelper(url: url)
            
        }
        else {
            stopTimer()
            self.resetProgress(for: url)
            print("song playing for the first time at \(url.lastPathComponent)")
            loadAudioPlayer(url: url)
            playbackHelper(url: url)
            
        }
    }
    
    func pause(url: URL) {
        print("pausing song at \(url.lastPathComponent)")
        audioPlayer?.pause()
        isPlayingDict[url] = false
        self.prevURL = url
    }
    
    func startTimer(url: URL) {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: isPlayingDict[url]!) { _ in
            if let currentTime = self.audioPlayer?.currentTime {
                self.audioProgressDict[url] = Float(currentTime)

            }
        }
    }
    
    func stopTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    
    // Resets the blue progress bar
    func resetProgress(for url: URL) {
        print("reseting progressBySong of \(url.lastPathComponent)")
        self.audioProgressDict[url] = 0.0
            songStartedByURL[url] = false
    }
}

