import SwiftUI

struct Bar: View {
    
    var capsuleWidth: CGFloat = 26.0
    var rectangleHeight: CGFloat = 6
    var fileLength: CGFloat
    @Binding var capsuleStartRatio: CGFloat
    @Binding var capsuleEndRatio: CGFloat
    @State var isHoldingStartButton: Bool = false
    @State var isHoldingEndButton: Bool = false
    
    
    @Binding var startCut: CGFloat
    @Binding var endCut: CGFloat
    
    var body: some View {
        ZStack{
            GeometryReader { geometry in
                
                let totalWidth = geometry.size.width - capsuleWidth
                
                VStack {
                    ZStack(alignment: .leading) {
                        
                        
                        Rectangle()
                            .fill(AppColors.third.opacity(0.2))
                            .frame(height: rectangleHeight)
                  
                        
                        Rectangle()
                            .fill(AppColors.third)
                            .frame(
                                width: (capsuleEndRatio - capsuleStartRatio) * totalWidth + capsuleWidth,
                                height: rectangleHeight
                            )
                            .offset(x: capsuleStartRatio * totalWidth)
                        
                        
                        HStack {
                            
                            Capsule()
                                .frame(width: capsuleWidth, height: isHoldingStartButton ? 54 : 38)
                                .offset(x: capsuleStartRatio * totalWidth)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let newRatio = max(0, min(1, value.location.x / totalWidth))
                                            if newRatio < capsuleEndRatio { // Prevent overlap
                                                self.capsuleStartRatio = newRatio
                                                self.startCut = fileLength * capsuleStartRatio
                                            }
                                        }
                                )
                                .onLongPressGesture(minimumDuration: 0.05, pressing: { pressing in
                                    withAnimation { isHoldingStartButton = pressing }
                                        
                                },perform: {})
                            
                            
                            Capsule()
                                .frame(width: capsuleWidth, height: isHoldingEndButton ? 54 : 38)
                                .offset(x: capsuleEndRatio * totalWidth - (capsuleWidth * 1.31))
                                
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let newRatio = max(0, min(1, value.location.x / totalWidth))
                                            if newRatio > capsuleStartRatio {
                                                self.capsuleEndRatio = newRatio
                                                self.capsuleEndRatio = newRatio
                                                self.endCut = fileLength * capsuleEndRatio
                                            }
                                        }
                                )
                                .onLongPressGesture(minimumDuration: 0.05, pressing: { pressing in
                                    withAnimation { isHoldingEndButton = pressing }
                                        
                                },perform: {})
                        }
                    }
                }
                .frame(height: 54)
                
            }
            .onAppear{
                print("fileLength: \(fileLength)")
                startCut = fileLength * capsuleStartRatio
                endCut = fileLength * capsuleEndRatio
            }
        }
        .frame(height: 60)
        
    }
}

struct CustomSlider: View {
    var fileLength: CGFloat
    
    //Slider Movement
    @Binding var capsuleStartRatio: CGFloat
    @Binding var capsuleEndRatio: CGFloat
    
    //Slider music cut vaules for timeline
    @Binding var startCut: CGFloat
    @Binding var endCut: CGFloat
    
    var body: some View {
        Bar(fileLength: fileLength, capsuleStartRatio: $capsuleStartRatio, capsuleEndRatio: $capsuleEndRatio, startCut: $startCut, endCut: $endCut)
            .frame(height: 10)
    }
}

#Preview {
    @Previewable @State var start: CGFloat = 0.0
    @Previewable @State var end: CGFloat = 1.0
    @Previewable @State var startCut: CGFloat = 0.0
    @Previewable @State var endCut: CGFloat = 0.0
    Bar(fileLength: 200.0, capsuleStartRatio: $start, capsuleEndRatio: $end, startCut: $startCut, endCut: $endCut)
    
    
}

