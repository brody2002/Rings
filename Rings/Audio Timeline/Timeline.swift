//
//  Timeline.swift
//  Timeline
//
//  Created by Zac White on 3/21/23.
//

import SwiftUI
import AVFoundation

struct Timeline<Background: View>: View {

    @Binding var progress: Double
    var background: () -> Background

    init(progress: Binding<Double>, background: @escaping () -> Background) {
        self._progress = progress
        self.background = background
    }

    @State private var previousProgress: Double?
    @State private var offsetX: CGFloat = 0
    @State private var startPosition: CGFloat = 0
    @State private var isDragging: Bool = false

    @State private var impactGenerator = UIImpactFeedbackGenerator(style: .medium)

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if !isDragging {
                    startPosition = offsetX
                    isDragging = true
                }

                offsetX = startPosition + value.translation.width
            }
            .onEnded { value in
                offsetX = max(min(startPosition + (value.translation.width + (value.predictedEndTranslation.width - value.translation.width) / 4), 0), -timelineWidth)

                // delay the isDragging flag so we get the offsetX onChange handler called first
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    isDragging = false
                }
            }
    }

    var timelineWidth: CGFloat {
        1000
    }

    var overscrollScaleX: CGFloat {
        if offsetX > -timelineWidth && offsetX < 0 {
            return 1
        } else if offsetX <= -timelineWidth {
            return 1 + (abs(offsetX) - timelineWidth) / 500
        } else if offsetX >= 0 {
            return 1 + abs(offsetX) / 500
        }

        return 1
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(Color(.secondarySystemFill))
                .frame(height: 48)
                .overlay {
                    GeometryReader { proxy in
                        background()
                            .frame(width: timelineWidth)
                            .scaleEffect(x: overscrollScaleX, anchor: offsetX <= -timelineWidth ? .trailing : .leading)
                            .padding(.horizontal, proxy.size.width / 2)
                            .offset(x: max(min(offsetX, 0), -timelineWidth))
                            .animation(.interpolatingSpring(stiffness: 500, damping: 100), value: offsetX)
                            .contentShape(Rectangle())
                            .gesture(dragGesture)
                            .onChange(of: offsetX) { _, newValue in
                                guard isDragging else { return }
                                progress = min(1, abs(min(0, newValue)) / timelineWidth)

                                if previousProgress == nil {
                                    previousProgress = progress
                                }

                                if let previous = previousProgress {
                                    if Swift.abs(previous - progress) >= 0.05 {
                                        impactGenerator.impactOccurred(intensity: 0.5)
                                        previousProgress = progress
                                    }
                                }
                            }
                            .onChange(of: progress) { _, newValue in
                                guard !isDragging else { return }
                                withAnimation(.linear(duration: 0.1)) {
                                    offsetX = -timelineWidth * newValue
                                }
                            }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Capsule()
                .foregroundColor(Color(.label))
                .frame(width: 4, height: 56)
        }
    }
}

struct Timeline_Previews: PreviewProvider {
    static var previews: some View {
        Timeline(
            progress: .constant(0)
        ) {
            Color.red
        }
    }
}
