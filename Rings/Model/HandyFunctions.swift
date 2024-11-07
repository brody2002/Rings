//
//  HandyFunctions.swift
//  Rings
//
//  Created by Brody on 11/7/24.
//

import Foundation


struct HandyFunctions{
    static var convertLength: (CGFloat) -> String = { length in
        let totalSeconds = Int(length)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds) // HH:MM:SS
        } else {
            return String(format: "%d:%02d", minutes, seconds) // MM:SS
        }
    }
    
    static var convertLengthSnippet: (CGFloat) -> String = { length in
        let totalSeconds = Int(length)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        let milliseconds = Int((length - floor(length)) * 1000) / 10 

        if hours > 0 {
            return String(format: "%d:%02d:%02d.%02d", hours, minutes, seconds, milliseconds) // HH:MM:SS
        } else {
            return String(format: "%d:%02d.%02d", minutes, seconds, milliseconds) // MM:SS
        }
    }
}
