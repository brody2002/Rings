//
//  LoadingView.swift
//  Rings
//
//  Created by Brody on 11/1/24.
//

import Foundation
import SwiftUI

struct LoadingView: View {
    
    // State variable to control the animation
    @State var isAnimating: Bool = false
    
    @State var color: Color
    
    // Constants to configure the dots
    private let height: CGFloat = 40
    
    // Initializer to set the dot color
    init(color: Color) {
        self.color = color
    }
    
    var body: some View {
        ZStack {
            // Circles forming a triangular pattern
            Circle()
                .fill(color)
                .offset(x: 0, y: isAnimating ? -height : 0)
            
            Circle()
                .fill(color)
                .offset(x: isAnimating ? -height : 0, y: isAnimating ? height : 0)
            
            Circle()
                .fill(color)
                .offset(x: isAnimating ? height : 0, y: isAnimating ? height : 0)
        }
        .frame(height: height)
        // Animation for the triangular movement
        .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: UUID())
        // Rotation animation for an overall spinning effect
        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
        .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: false), value: UUID())
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview{
    LoadingView(color: Color.orange)
}
