import SwiftUI

struct Bar: View {
    
    var capsuleWidth: CGFloat = 26.0
    var fileLength: CGFloat
    @Binding var capsuleStartRatio: CGFloat
    @Binding var capsuleEndRatio: CGFloat
    
    var body: some View {
        ZStack{
            GeometryReader { geometry in
                
                let totalWidth = geometry.size.width - capsuleWidth
                
                VStack {
                    ZStack(alignment: .leading) {
                        
                        Rectangle()
                            .fill(Color.black.opacity(0.2))
                            .frame(height: 6)
                        
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(
                                width: (capsuleEndRatio - capsuleStartRatio) * totalWidth + capsuleWidth,
                                height: 6
                            )
                            .offset(x: capsuleStartRatio * totalWidth)
                        
                        
                        HStack {
                            
                            Capsule()
                                .frame(width: capsuleWidth, height: 38)
                                .offset(x: capsuleStartRatio * totalWidth)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let newRatio = max(0, min(1, value.location.x / totalWidth))
                                            if newRatio < capsuleEndRatio { // Prevent overlap
                                                self.capsuleStartRatio = newRatio
                                            }
                                        }
                                )
                            
                            
                            Capsule()
                                .frame(width: capsuleWidth, height: 38)
                                .offset(x: capsuleEndRatio * totalWidth - (capsuleWidth))
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let newRatio = max(0, min(1, value.location.x / totalWidth))
                                            if newRatio > capsuleStartRatio {
                                                self.capsuleEndRatio = newRatio
                                                print(newRatio)
                                            }
                                        }
                                )
                        }
                    }
                }
                
            }
            .frame(height: 50)
            .onAppear{
                print("fileLength: \(fileLength)")
            }
        }
        
    }
}

struct CustomSlider: View {
    var fileLength: CGFloat
    @Binding var capsuleStartRatio: CGFloat
    @Binding var capsuleEndRatio: CGFloat
    var body: some View {
        Bar(fileLength: fileLength, capsuleStartRatio: $capsuleStartRatio, capsuleEndRatio: $capsuleEndRatio)
            .frame(height: 10)
    }
}

#Preview {
    @Previewable @State var start: CGFloat = 0.0
    @Previewable @State var end: CGFloat = 1.0
    Bar(fileLength: 200.0, capsuleStartRatio: $start, capsuleEndRatio: $end)
    
    
}

