import SwiftUI
import AVFoundation

struct AudioAssetTimelineBackground: View {
    @State private var audioFile: AVAudioFile?
    @State private var waveform: [Float]?
    @State private var fadeInWave: Bool = false // Controls visibility of the waveform
    
    @Binding var isWaveFormShowing: Bool
    var audioUrl: URL? // Make this a stored property
    
    private enum Constants {
        static let samplesPerPixel: CGFloat = 3
    }

    init(audioUrl: URL?, isWaveFormShowing: Binding<Bool>) {
        self.audioUrl = audioUrl
        self._isWaveFormShowing = isWaveFormShowing
    }

    class Reader {
        private let reader: AVAssetReader
        init(asset: AVAsset) {
            reader = try! AVAssetReader(asset: asset)
        }
    }

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                Canvas { context, size in
                    
                    if fadeInWave {
                        guard let waveform else { return }
                        
                        let minValue = waveform.min() ?? 0.0
                        let maxValue = waveform.max() ?? 1.0
                        let range = maxValue - minValue

                        for (index, value) in waveform.enumerated() {
                            
                            
                            
                            // Normalize and scale the waveform values
                            let normalizedValue = (value - minValue) / range
                            let differentiatedValue = pow(normalizedValue, 2.5)
                            let scaledValue = differentiatedValue * 0.5
                            let adjustedValue = min(max(scaledValue, 0), 0.5)
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
                                with: .color(AppColors.white)
                            )
                        }
                    }
                }
                .opacity(fadeInWave ? 1 : 0)
                .animation(.default, value: fadeInWave)
                .scaleEffect(fadeInWave ? 1.0 : 1.2)
                .animation(
                    Animation.spring(response: 0.3, dampingFraction: 0.3, blendDuration: 0.2)
                        .repeatCount(1, autoreverses: true)
                        .delay(0.2),
                    value: fadeInWave
                )
                .transition(.scale)
                .task {
                    if let audioUrl = audioUrl {
                        do {
                            audioFile = try AVAudioFile(forReading: audioUrl)
                            waveform = (try? await audioFile?.loadWaveform(width: Int(proxy.size.width / Constants.samplesPerPixel))) ?? []
                            if waveform != nil {
                                fadeInWave = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                    withAnimation {
                                        isWaveFormShowing = true
                                    }
                                }
                            }
                        } catch {
                            print("Error loading audio file: \(error.localizedDescription)")
                        }
                    } else {
                        print("Audio URL is nil.")
                    }
                }
            }
        }
        .frame(height: 400)
    }
}

#Preview {
    let mainURL = Bundle.main.url(forResource: "505", withExtension: "mp3")
    AudioAssetTimelineBackground(audioUrl: mainURL, isWaveFormShowing: .constant(false))
}

