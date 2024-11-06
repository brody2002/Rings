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
    
    
    


    var body: some View {
        GeometryReader{ metrics in
            ZStack {
                AppColors.backgroundColor.ignoresSafeArea()
                AudioAssetTimelineBackground(audioUrl: fileURL)
                    .padding()
                    .padding(.bottom, metrics.size.height * 1/10)
                    
                VStack {
                    Text("Slice Audio")
                        .font(.system(size: 26))
                        .bold()
                        .foregroundColor(AppColors.secondary)
                        .padding(.top, 20)
                    Spacer()
                        .frame(height: metrics.size.height * 6/10)
                    
                        
                    
                    CustomSlider(fileLength: fileLength)
                    Spacer()
                    Spacer()
                        
                }
            }
        }
        
    }
}


#Preview {
    if let testURL = Bundle.main.url(forResource: "Kendrick Lamar - Not Like Us", withExtension: "mp3") {
        
        SliceAudioView(fileURL: testURL, fileName: "NOT LIKE US", fileLength: 60.0)
            .onAppear{
                print("TEST URL: \n\(testURL)")
            }
    } else {
        Text("Audio file not found")
    }
}

