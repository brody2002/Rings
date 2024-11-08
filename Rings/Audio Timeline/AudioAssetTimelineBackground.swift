//
//  AudioAssetTimelineBackground.swift
//  Timeline
//
//  Created by Zac White on 2/23/24.
//

import SwiftUI
import AVFoundation

struct AudioAssetTimelineBackground: View {
    @State private var audioFile: AVAudioFile
    @State private var waveform: [Float]?
    @State private var fadeInWave: Bool = false // Controls visibility of the waveform
    
    @Binding var isWaveFormShowing: Bool
    
    private enum Constants {
        static let samplesPerPixel: CGFloat = 3
    }

    init(audioUrl: URL, isWaveFormShowing: Binding<Bool>) {
        _audioFile = State(initialValue: { try! AVAudioFile(forReading: audioUrl) }())
        self._isWaveFormShowing = isWaveFormShowing
    }

    class Reader {
        private let reader: AVAssetReader
        init(asset: AVAsset) {
            reader = try! AVAssetReader(asset: asset)
        }
    }

    var body: some View {
        ZStack{
            GeometryReader { proxy in
                Canvas { context, size in
                    
                    if fadeInWave {
                        guard let waveform else { return }
                        
                        let minValue = waveform.min() ?? 0.0
                            let maxValue = waveform.max() ?? 1.0
                            let range = maxValue - minValue

                            for (index, value) in waveform.enumerated() {
                                
                                // Normalize the value to [0, 1]
                                let normalizedValue = (value - minValue) / range

                                // Apply nonlinear scaling for differentiation
                                let differentiatedValue = pow(normalizedValue, 2.5) // Exponential scaling

                                // Scale to fit within [0, 0.5]
                                let scaledValue = differentiatedValue * 0.5

                                // Clamp the scaled value to ensure it fits within the range
                                let adjustedValue = min(max(scaledValue, 0), 0.5)
                                
                                // Calculate the height based on the adjusted value
                                let height = size.height * CGFloat(adjustedValue) * 1.2
                                
                                context.fill(
                                    Path(
                                        roundedRect: CGRect(
                                            x: CGFloat(index) * Constants.samplesPerPixel,
                                            y: (size.height - height) / 2,
                                            width: 2,
                                            height: height
                                        ),
                                        cornerRadius: 1
                                    ),
                                    with: .color(AppColors.secondary)
                                )
                            }
                    }
                }
                
                .opacity(fadeInWave ? 1 : 0)
                .animation(.default, value: fadeInWave)
                .scaleEffect(fadeInWave ? 1.0 : 1.2) // Starts with a slight bubble up
                .animation(
                    Animation.spring(response: 0.3, dampingFraction: 0.3, blendDuration: 0.2)
                        .repeatCount(1, autoreverses: true) // Springy bubbling animation
                        .delay(0.2), // Optional delay to coordinate with opacity
                    value: fadeInWave
                )
                .transition(.scale)
                .task {
                    waveform = (try? await audioFile.loadWaveform(width: Int(proxy.size.width / Constants.samplesPerPixel))) ?? []
                    if waveform != nil {
                        fadeInWave = true // Trigger the animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7){
                            withAnimation{
                                isWaveFormShowing = true
                            }
                        }
                        
                        
                    }
                }
            }
        }
        .frame(height: 400)
        
    }
}

#Preview {
    let mainURL = Bundle.main.url(forResource: "505", withExtension: "mp3")
    AudioAssetTimelineBackground(audioUrl: mainURL!, isWaveFormShowing: .constant(false))
}

