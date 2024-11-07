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
    
    @State var capsuleStartRatio: CGFloat = 0.00
    @State var capsuleEndRatio: CGFloat = 1.0
    
    @State var startCut: CGFloat = 0
    @State var endCut: CGFloat = 0
    
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
                                        .fill(Color.orange.opacity(0.7))
                                        .frame(width: rectWidth)
                                        .cornerRadius(20)
                                        .offset(x: rectStart)
                                        .animation(.easeInOut, value: capsuleStartRatio)
                                        .animation(.easeInOut, value: capsuleEndRatio)
                                }
                            } : nil
                        
                        
                    )
                    .padding()
                    .padding(.bottom, metrics.size.height * 1/10)
                        
                
                
                
                
                    
                    
                VStack {
                    HStack{
                        Spacer()
                            .frame(width: 20)
                        Image(systemName: "arrowshape.turn.up.backward.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(self.isHoldingBack ? Color.black.opacity(0.6) : Color.black)
                            .onLongPressGesture(minimumDuration: 0.05, pressing: { pressing in
                                isHoldingBack = pressing
                            }, perform: {
                                if isHoldingBack{
                                    // remove from navpath
                                    navPath.removeLast()
                                }
                            })
                        Spacer()
                            
                        Text("Slice Audio")
                            .font(.system(size: 26))
                            .bold()
                            .foregroundColor(Color.black)
                            .padding(.top, 20)
                        Spacer()
                        Spacer()
                    }
                    
                    Spacer()
                        .frame(height: metrics.size.height * 7/10)
                    HStack{
                        Spacer()
                        Text("Start: \(HandyFunctions.convertLength(startCut))")
                        Spacer()
                        Text("End: \(HandyFunctions.convertLength(endCut))")
                        Spacer()
                    }
                    
                        
                    
                    CustomSlider(fileLength: fileLength, capsuleStartRatio: $capsuleStartRatio, capsuleEndRatio: $capsuleEndRatio, startCut: $startCut, endCut: $endCut)
                        .padding()
                    Spacer()
                    Spacer()
                    HStack{
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                    .stroke(lineWidth: 4)
                                    .frame(width: 90, height: 90)
                            Image(systemName: "play.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                
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
                        
                }
            }
        }.navigationBarBackButtonHidden(true)
        
    }
}


#Preview {
    @Previewable @State var navPath = NavigationPath()
    if let testURL = Bundle.main.url(forResource: "Kendrick Lamar - Not Like Us", withExtension: "mp3") {
        SliceAudioView(fileURL: testURL, fileName: "NOT LIKE US", fileLength: 60.0, navPath: $navPath)
            .onAppear{
                print("TEST URL: \n\(testURL)")
            }
    } else {
        Text("Audio file not found")
    }
}

