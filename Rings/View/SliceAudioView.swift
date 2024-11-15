//
//  SliceAudioView.swift
//  Rings
//
//  Created by Brody on 11/4/24.
//
import Foundation
import AVFoundation
import SwiftUI



struct SliceAudioView: View {
    
    let fileURL: URL
    let fileName: String
    let fileLength: CGFloat
    
    // View Checks
    @State var isWaveFormShowing: Bool = false
    @State var isHoldingBack: Bool = false
    @State var isPlayingAudio: Bool = false
    @State var cutAudioAlert: Bool = false
    @State var showBlackBar: Bool = false
    
    
    // Slider Values
    @State var capsuleStartRatio: CGFloat = 0.00
    @State var capsuleEndRatio: CGFloat = 1.0
    
    // Audio Timeline
    @State var startCut: CGFloat = 0
    @State var endCut: CGFloat = 0
    @State var snippetTime: CGFloat = 0
    
    // App Objects
    @StateObject var GAP: GlobalAudioPlayer
    @Binding var navPath: NavigationPath
    
    
    var body: some View {
        GeometryReader{ metrics in
            ZStack {
                AppColors.secondary.ignoresSafeArea()
                AudioAssetTimelineBackground(audioUrl: fileURL, isWaveFormShowing: $isWaveFormShowing)
                    .overlay(
                        
                        isWaveFormShowing ? ZStack(alignment: .leading) {
                            // Orange rectangle that reflects capsuleStartRatio and capsuleEndRatio
                            GeometryReader { overlayMetrics in
                                let totalWidth = overlayMetrics.size.width
                                let rectStart = capsuleStartRatio * totalWidth
                                let rectWidth = (capsuleEndRatio - capsuleStartRatio) * totalWidth
                                
                                Rectangle()
                                    .fill(AppColors.backgroundColor.opacity(0.7))
                                    .frame(width: rectWidth)
                                    .cornerRadius(20)
                                    .offset(x: rectStart)
                                    .animation(.easeInOut, value: capsuleStartRatio)
                                    .animation(.easeInOut, value: capsuleEndRatio)
                                
                                
                                
                                if showBlackBar{
                                    VStack{
                                        Rectangle()
                                            .fill(AppColors.third)
                                        
                                    }
                                    .frame(width: 2, height: overlayMetrics.size.height)
                                    .scaleEffect(y: 0.92, anchor: .center)
                                    
                                    // need length of the song to convert to the ratios values.
                                    .offset(x: snippetTime / fileLength * totalWidth)
                                }
                                
                            }
                        } : nil
                    )
                    .padding()
                    .padding(.bottom, metrics.size.height * 2/10)
                
                VStack {
                    HStack{
                        Spacer()
                            .frame(width: 20)
                        Image(systemName: "arrowshape.turn.up.backward.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(self.isHoldingBack ? AppColors.white.opacity(0.6) : AppColors.white)
                            .onLongPressGesture(minimumDuration: 0.05, pressing: { pressing in
                                isHoldingBack = pressing
                            }, perform: {
                                if isHoldingBack{
                                    // remove from navpath
                                    
                                    if GAP.audioPlayer?.isPlaying == true {
                                        GAP.audioPlayer?.stop()
                                    }
                                
                                    GAP.resetProgress(for: fileURL)
                                    navPath.removeLast()
                                    
                                }
                            })
                        Spacer()
                        
                        Text("Slice Audio")
                            .font(.system(size: 26))
                            .bold()
                            .foregroundColor(AppColors.white)
                            .padding(.top, 20)
                        Spacer()
                        Spacer()
                    }
                    HStack{
                        ZStack(alignment: .leading){
                            if isPlayingAudio{
                                Text("\(HandyFunctions.convertLengthSnippet(snippetTime))")
                                    .font(Font.system(size: 20, design: .monospaced).weight(.light))
                                    .foregroundColor(AppColors.white)
                            }
                        }
                        
                        
                    }
                    .frame(width: 100,height: 20)
                    
                    
                    Spacer()
                        .frame(height: metrics.size.height * 5.75/10)
                    HStack{
                        Spacer()
                        HStack(spacing: 0) {
                            Text("Start: ")
                                .font(.system(size: 20, weight: .regular)) // Regular font for "End"
                                .foregroundStyle(AppColors.white)
                            
                            Text("\(HandyFunctions.convertLengthSnippet(startCut))")
                                .font(Font.system(size: 20, design: .monospaced).weight(.light)) // Monospaced font for the converted length
                                .foregroundStyle(AppColors.white)
                        }
                        .onChange(of: startCut) {
                            showBlackBar = false
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)){
                                isPlayingAudio = false
                            }
                            if GAP.audioPlayer?.isPlaying == true {
                                GAP.audioPlayer?.stop()
                            }
                            GAP.stopTimer()
                            GAP.resetProgress(for: fileURL)
                        }
                        Spacer()
                        HStack(spacing: 0) {
                            Text("End: ")
                                .font(.system(size: 20, weight: .regular)) // Regular font for "End"
                                .foregroundStyle(AppColors.white)
                            
                            Text("\(HandyFunctions.convertLengthSnippet(endCut))")
                                .font(Font.system(size: 20, design: .monospaced).weight(.light)) // Monospaced font for the converted length
                                .foregroundStyle(AppColors.white)
                        }
                        .onChange(of: endCut) {
                            showBlackBar = false
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)){
                                isPlayingAudio = false
                            }
                            if GAP.audioPlayer?.isPlaying == true {
                                GAP.audioPlayer?.stop()
                            }
                            GAP.stopTimer()
                            GAP.resetProgress(for: fileURL)
                        }
                        Spacer()
                    }
                    
                    CustomSlider(fileLength: fileLength, capsuleStartRatio: $capsuleStartRatio, capsuleEndRatio: $capsuleEndRatio, startCut: $startCut, endCut: $endCut)
                        .padding()
                    Spacer()
                    HStack{
                        Spacer()
                        ZStack {
                            
                            ZStack{
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(lineWidth: 4)
                                    .frame(width: 90, height: 90)
                                    .foregroundColor(AppColors.white)
                                Image(systemName: isPlayingAudio ? "pause.fill" : "play.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(AppColors.white)
                            }
                            .onTapGesture {
                                if !isPlayingAudio {
                                    GAP.playSnippet(url: fileURL, startCut: startCut, endCut: endCut, snippetTime: $snippetTime)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05){
                                        showBlackBar = true
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)){
                                            isPlayingAudio = true
                                        }
                                    }
                                }
                                else{
                                    // pause state
                                    
                                    GAP.audioPlayer?.stop()
                                    GAP.stopTimer()
                                    GAP.resetProgress(for: fileURL)
                                    showBlackBar = false
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)){
                                        isPlayingAudio = false
                                    }
                                }
                            }
                            
                            
                        }
                        Spacer()
                        ZStack{
                            
                            ZStack{
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(lineWidth: 4)
                                    .frame(width: 90, height: 90)
                                    .foregroundStyle(AppColors.white)
                                Image(systemName: "scissors")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(AppColors.white)
                            }
                            .onTapGesture {
                                cutAudioAlert = true
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                    Spacer()
                    
                }
            }
        }.navigationBarBackButtonHidden(true)
            .alert("Slice or Overwrite", isPresented: $cutAudioAlert) {
                Button("Slice") {
                    // Action for creating a new .mp3 file
                    print("slice")
                    
                    //
                    Task {
                        await overWriteAudio(fileURL: fileURL, startCut: startCut, endCut: endCut, isOverWriting: false)
                    }
                }
                Button("Overwrite") {
                    // Action for overwriting the existing file
                    print("overwrite")
                    Task {
                        await overWriteAudio(fileURL: fileURL, startCut: startCut, endCut: endCut, isOverWriting: true)
                    }
                    
                }
                Button("Cancel", role: .cancel) {
                    // Optional: Dismiss the alert without action
                    print("cancel")
                }
            } message: {
                Text("Choose to create a new .mp3 or to overwrite the existing file")
            }
    }
    
    func overWriteAudio(fileURL: URL, startCut: CGFloat, endCut: CGFloat, isOverWriting: Bool, fileManager: FileManager = .default) async {
        let asset = AVURLAsset(url: fileURL)
        var outputURL: URL

        // Define start and end time in CMTime
        let startTime = CMTime(seconds: Double(startCut), preferredTimescale: asset.duration.timescale)
        let endTime = CMTime(seconds: Double(endCut), preferredTimescale: asset.duration.timescale)
        let timeRange = CMTimeRange(start: startTime, end: endTime)

        let directory = fileURL.deletingLastPathComponent()
        var baseName = fileURL.deletingPathExtension().lastPathComponent
        let fileExtension = fileURL.pathExtension

        if isOverWriting {
            outputURL = fileURL
        } else {
            // Check if the base name already includes a "_sliceX" suffix
            if let range = baseName.range(of: " slice\\d+$", options: .regularExpression) {
                baseName.removeSubrange(range)
            }

            // Find a unique suffix for the output file
            var suffix = 1
            repeat {
                let newFileName = "\(baseName) slice\(suffix).\(fileExtension)"
                outputURL = directory.appendingPathComponent(newFileName)

                // If we find a gap (e.g., _slice1 missing), stop checking
                if !fileManager.fileExists(atPath: outputURL.path) {
                    break
                }
                suffix += 1
            } while true
        }

        // Remove the existing file if it exists
        if fileManager.fileExists(atPath: outputURL.path) {
            do {
                try fileManager.removeItem(at: outputURL)
            } catch {
                print("Error removing existing file: \(error.localizedDescription)")
                return
            }
        }

        // Prepare export session
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            print("Failed to create export session.")
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a
        exportSession.timeRange = timeRange

        do {
            try await exportSession.export(to: outputURL, as: .m4a)
            print("Audio successfully sliced and saved at \(outputURL)")

            // Clean up temporary file if applicable
            if fileURL.path.contains(NSTemporaryDirectory()) {
                try? fileManager.removeItem(at: fileURL)
                print("Temporary file deleted: \(fileURL)")
            }
        } catch {
            print("Export failed: \(error.localizedDescription)")
        }
    }





        
}


extension FileManager {
    func temporaryFileURL(fileName: String = UUID().uuidString) -> URL? {
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(fileName)
    }
}

#Preview {
    @Previewable @State var navPath = NavigationPath()
    @Previewable @StateObject var GAP = GlobalAudioPlayer()
    if let testURL = Bundle.main.url(forResource: "505", withExtension: "m4a") {
        SliceAudioView(fileURL: testURL, fileName: "505", fileLength: 60.0, GAP: GAP, navPath: $navPath)
            .onAppear{
                print("TEST URL: \n\(testURL)")
            }
    } else {
        Text("Audio file not found")
    }
}

