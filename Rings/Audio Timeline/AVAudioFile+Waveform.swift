//
//  AVAsset+Waveform.swift
//  Timeline
//
//  Created by Zac White on 2/23/24.
//

import Foundation
import AVFoundation
import Accelerate

extension AVAudioFile {

    func loadWaveform(width: Int) async throws -> [Float] {
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat, frameCapacity: AVAudioFrameCount(length)) else { return [] }

        try read(into: audioBuffer)

        guard let floatChannelData = audioBuffer.floatChannelData?[0] else { return [] }

        let rawFloatData = Array(UnsafeBufferPointer(start: floatChannelData, count: Int(audioBuffer.frameLength)))
        var resultVector = [Float](repeating: 0.0, count: rawFloatData.count)

        let sampleCount = vDSP_Length(audioBuffer.frameLength)

        // take the absolute values to get amplitude
        vDSP_vabs(rawFloatData, 1, &resultVector, 1, sampleCount)

        // convert do dB
        var zero: Float = 32767.0;
        vDSP_vdbcon(resultVector, 1, &zero, &resultVector, 1, sampleCount, 1)

        // clip to [noiseFloor, 0]
        var ceil: Float = 0.0
        var noiseFloor: Float = -200
        vDSP_vclip(resultVector, 1, &noiseFloor, &ceil, &resultVector, 1, sampleCount)

        // downsample and average
        var downSampledData = [Float](repeating: 0.0, count: width)
        let samplesPerPixel = resultVector.count / width
        let filter = [Float](repeating: 1.0 / Float(samplesPerPixel), count: samplesPerPixel)

        vDSP_desamp(resultVector,
                    vDSP_Stride(samplesPerPixel),
                    filter,
                    &downSampledData,
                    vDSP_Length(width),
                    vDSP_Length(samplesPerPixel))
        
        
        vDSP_vsmsa(downSampledData, 1, [1 / Float(-200)], [-1], &downSampledData, 1, vDSP_Length(downSampledData.count))
        vDSP_vabs(downSampledData, 1, &downSampledData, 1, vDSP_Length(downSampledData.count))

        return downSampledData
    }
}
