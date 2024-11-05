//
//  SliceAudioView.swift
//  Rings
//
//  Created by Brody on 11/4/24.
//

import AVFoundation
import SwiftUI


// Utility struct to contain audio processing functions
struct AudioUtils {
    static func getFloatBuffers(from url: URL) throws -> [Float] {
        let file = try AVAudioFile(forReading: url)
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)!
        
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))!
        try file.read(into: buf)
        
        let floatArray = Array(UnsafeBufferPointer(start: buf.floatChannelData![0], count: Int(buf.frameLength)))
        return floatArray
    }
    
    static func downsample(_ floatArray: [Float], samplingFactor: CGFloat) -> [Float] {
        let samplingFactor = 512
        let newSize = ceil(Double(floatArray.count) / Double(samplingFactor))
        var downsampled = [Float](repeating: 0, count: Int(newSize))
        var bin: [Float] = []
        
        floatArray.enumerated().forEach { value in
            if value.offset % samplingFactor == 0 {
                downsampled[value.offset / samplingFactor] = bin.max() ?? value.element
                bin.removeAll()
            } else {
                bin.append(value.element)
            }
        }
        return downsampled
    }
}

struct SliceAudioView: View {
    let fileURL: URL
    
    @State private var values: [CGFloat] = []
    @State private var original: [CGFloat] = []

    var body: some View {
        VStack {
            Text("Slice AUDIO VIEW")
            
            // Display waveform if available
            if !values.isEmpty{
                WaveformView(data: $values)
                    .frame(width: 300, height: 100) // Adjust as needed
                    .foregroundColor(.blue)
            } else {
                LoadingView(color: .blue)
            }
        }
        .onAppear {
            loadWaveformData()
        }
    }
    
    private func loadWaveformData() {
        Task {
            do {
                let floatArray = try AudioUtils.getFloatBuffers(from: fileURL)
                print("finish make floatArray")
                let downsampled = AudioUtils.downsample(floatArray, samplingFactor: 2048)
                print("finished downsampled")
                
                DispatchQueue.main.async {
                    self.values = downsampled.map(CGFloat.init)

                }
            } catch {
                print("Failed to load waveform data: \(error)")
            }
        }
    }

}
#Preview {
    if let testURL = Bundle.main.url(forResource: "Kendrick Lamar - Not Like Us", withExtension: "mp3") {
        
        SliceAudioView(fileURL: testURL)
            .onAppear{
                print("TEST URL: \n\(testURL)")
            }
    } else {
        Text("Audio file not found")
    }
}

