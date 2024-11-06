import SwiftUI

struct Bar: View {
    @State private var capsuleStartRatio: CGFloat = 0.00
    @State private var capsuleEndRatio: CGFloat = 0.9778368523780335
    var capsuleWidth: CGFloat = 26.0
    var fileLength: CGFloat
    
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
                                .offset(x: capsuleEndRatio * totalWidth - capsuleWidth)
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
    var body: some View {
        Bar(fileLength: fileLength)
            .frame(height: 10)
    }
}

#Preview {
    
    Bar(fileLength: 200.0)
    
    
}

