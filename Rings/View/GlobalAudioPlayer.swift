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
    var currentURL: URL? = nil
    //set previous URL somewhere
    func loadAudioPlayer(url: URL){
        
        do{
            // Stop the currently playing audio if any
            if audioPlayer?.isPlaying == true {
                audioPlayer?.stop()
            }
            // Load and prepare new audio
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            
            audioPlayer!.prepareToPlay()
            audioPlayer!.volume = 1.0
            audioProgressDict[url] = 0.0
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
        self.currentURL  = url
        let tempURL = url.deletingLastPathComponent()
        
        if let started = songStartedByURL[url], started && self.prevURL == url{
            print("song resumed at \(url.lastPathComponent)")
            self.resetProgressForAllOtherFiles(in: tempURL, url: url)
            playbackHelper(url: url)
            
        }
        else {
            stopTimer()
            self.resetProgressForAllOtherFiles(in: tempURL, url: url)
            print("song playing for the first time at \(url.lastPathComponent)")
            loadAudioPlayer(url: url)
            playbackHelper(url: url)
            
        }
        
        // if we are playing something new or first time playing at all
        // load the AudioPlayer
        // else resume
        
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
                withAnimation{
                    self.audioProgressDict[url] = Float(currentTime)
                }
                // iDK if this is based off of setup or actually playing a song
                if self.audioPlayer?.isPlaying == false{
                    self.stopTimer()
                    withAnimation{
                        self.audioProgressDict[url] = 0
                        self.isPlayingDict[url] = false
                    }
                    self.resetProgress(for: url)
                }

            }
        }
    }
    
    func stopTimer() {
        print("stoping timer? ")
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    
    func resetProgress(for url: URL) {
        print("Resetting progressBySong of \(url.lastPathComponent)")
        stopTimer()
    
        withAnimation{
            audioProgressDict[url] = 0.0
            songStartedByURL[url] = false
        }
    }

    // Function to reset progress for all files within a given directory
    func resetProgressForAllOtherFiles(in directoryURL: URL, url: URL) {
        do {
            // Retrieve all file URLs within the directory
            let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            
            // Iterate over each file URL and reset progress
            for fileURL in fileURLs {
                if fileURL != url{
                    resetProgress(for: fileURL)
                    isPlayingDict[fileURL] = false
                }
                
            }
        } catch {
            print("Error fetching contents of directory: \(error)")
        }
    }
    
    func playSnippet(url: URL, startCut: CGFloat, endCut: CGFloat, snippetTime: Binding<CGFloat>){
        guard startCut.rounded() != endCut.rounded() else { return }
        loadAudioPlayer(url: url)
        audioProgressDict[url] = Float(startCut)
        print("startCut: \(startCut), endCut: \(endCut)")
        print("audioProgressDict: \(audioProgressDict[url]!)")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            audioProgressDict[url] = Float(startCut)
            audioPlayer!.currentTime = TimeInterval(startCut)
            
            
            audioPlayer?.play()
            songStartedByURL[url] = true
            isPlayingDict[url] = true
            
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: isPlayingDict[url]!) { _ in
                if let currentTime = self.audioPlayer?.currentTime {
                    snippetTime.wrappedValue = CGFloat(currentTime)
                    self.audioProgressDict[url] = Float(currentTime)
                    
                    // Audio hits end of the endCut value
                    if currentTime > TimeInterval(endCut){
                        
                        self.audioPlayer!.stop()
                        self.stopTimer()
                        
                        
                    }
                }
            }
            
        } catch {
            print("failed the splice play")
        }
        
        
        
    }
    
    
    
}
