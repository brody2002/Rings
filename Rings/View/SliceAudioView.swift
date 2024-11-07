//
//  SliceAudioView.swift
//  Rings
//
//  Created by Brody on 11/4/24.
//

import AVFoundation
import SwiftUI


struct SliceAudioView: View {
    
    let fileURL: URL
    let fileName: String
    let fileLength: CGFloat
    
    @State var isWaveFormShowing: Bool = false
    @State var isHoldingBack: Bool = false
    @State var isPlayingAudio: Bool = false
    
    @State var capsuleStartRatio: CGFloat = 0.00
    @State var capsuleEndRatio: CGFloat = 1.0
    
    @State var startCut: CGFloat = 0
    @State var endCut: CGFloat = 0
    
    @State var snippetTime: CGFloat = 0
    
    @StateObject var GAP: GlobalAudioPlayer
    
    @Binding var navPath: NavigationPath


    var body: some View {
        GeometryReader{ metrics in
            ZStack {
                AppColors.backgroundColor.ignoresSafeArea()
                AudioAssetTimelineBackground(audioUrl: fileURL, isWaveFormShowing: $isWaveFormShowing)
                    .overlay(
                        
                            isWaveFormShowing ? ZStack(alignment: .leading) {
                                    // Orange rectangle that reflects capsuleStartRatio and capsuleEndRatio
                                    GeometryReader { overlayMetrics in
                                        let totalWidth = overlayMetrics.size.width
                                        let rectStart = capsuleStartRatio * totalWidth
                                        let rectWidth = (capsuleEndRatio - capsuleStartRatio) * totalWidth
                                        
                                        Rectangle()
                                            .fill(AppColors.slice.opacity(0.7))
                                            .frame(width: rectWidth)
                                            .cornerRadius(20)
                                            .offset(x: rectStart)
                                            .animation(.easeInOut, value: capsuleStartRatio)
                                            .animation(.easeInOut, value: capsuleEndRatio)
                                        
                                        
                                        
                                        if isPlayingAudio{
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
                            .foregroundColor(self.isHoldingBack ? AppColors.third.opacity(0.6) : AppColors.third)
                            .onLongPressGesture(minimumDuration: 0.05, pressing: { pressing in
                                isHoldingBack = pressing
                            }, perform: {
                                if isHoldingBack{
                                    // remove from navpath
                                    navPath.removeLast()
                                    if GAP.audioPlayer?.isPlaying == true {
                                        GAP.audioPlayer?.stop()
                                    }
                                    GAP.resetProgress(for: fileURL)
                                }
                            })
                        Spacer()
                            
                        Text("Slice Audio")
                            .font(.system(size: 26))
                            .bold()
                            .foregroundColor(AppColors.third)
                            .padding(.top, 20)
                        Spacer()
                        Spacer()
                    }
                    HStack{
                        ZStack(alignment: .leading){
                            if isPlayingAudio{
                                Text("\(HandyFunctions.convertLengthSnippet(snippetTime))")
                            }
                        }
                        
                        
                    }
                    .frame(width: 100,height: 20)
                   
                    
                    Spacer()
                        .frame(height: metrics.size.height * 5.75/10)
                    HStack{
                        Spacer()
                        Text("Start: \(HandyFunctions.convertLengthSnippet(startCut))")
                            .onChange(of: startCut){
                                isPlayingAudio = false
                                if GAP.audioPlayer?.isPlaying == true {
                                    GAP.audioPlayer?.stop()
                                }
                                GAP.stopTimer()
                                GAP.resetProgress(for: fileURL)
                            }
                        Spacer()
                        Text("End: \(HandyFunctions.convertLengthSnippet(endCut))")
                            .onChange(of: endCut){
                                isPlayingAudio = false
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
                            Button(action:{
                                print("tapped")
                                GAP.playSnippet(url: fileURL, startCut: startCut, endCut: endCut, snippetTime: $snippetTime)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05){
                                    isPlayingAudio = true
                                }
                                
                            },
                                label:{
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(lineWidth: 4)
                                            .frame(width: 90, height: 90)
                                            .foregroundColor(AppColors.third)
                                        Image(systemName: "play.fill")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(AppColors.third)
                                        }
                                    }
                            )
                        }
                        Spacer()
                        ZStack{
                            RoundedRectangle(cornerRadius: 4)
                                    .stroke(lineWidth: 4)
                                    .frame(width: 90, height: 90)
                            Image(systemName: "scissors")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        Spacer()
                    }
                    Spacer()
                    Spacer()
                        
                }
            }
        }.navigationBarBackButtonHidden(true)
        
    }
}


#Preview {
    @Previewable @State var navPath = NavigationPath()
    @Previewable @StateObject var GAP = GlobalAudioPlayer()
    if let testURL = Bundle.main.url(forResource: "Kendrick Lamar - Not Like Us", withExtension: "mp3") {
        SliceAudioView(fileURL: testURL, fileName: "NOT LIKE US", fileLength: 60.0, GAP: GAP, navPath: $navPath)
            .onAppear{
                print("TEST URL: \n\(testURL)")
            }
    } else {
        Text("Audio file not found")
    }
}

