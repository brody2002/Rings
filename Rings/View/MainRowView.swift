//
//  MainRowView.swift
//  Rings
//
//  Created by Brody on 11/4/24.
//

import SwiftUI

struct MainRowView: View {
    @State var fileName: String
    @State var fileSize: String
    @State var fileLength: CGFloat
    @State var fileURL: URL
    @StateObject var GAP: GlobalAudioPlayer
    @State private var holdingRow: Bool = false
    @Binding var navPath: NavigationPath
    
    var convertLength: (CGFloat) -> String = { length in
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
    
    
    var body: some View {
        ZStack{
            Color.white
            HStack{
                Spacer()
                    .frame(width: 15)
                PlaySoundButtonView(fileURL: fileURL, GAP:GAP, fileLength: fileLength)
                Spacer()
                    .frame(width:20)
                VStack{
                    Text("\(fileName)")
    
                }
                Spacer()
                Spacer()
                HStack{
                    Text("\(fileSize)")
                        .font(.system(size: 10))
                    Text("\(convertLength(fileLength))")
                        .font(.system(size: 10))
                }
                Spacer()
                    
            }
        }
        .frame(height: 80)
        .onTapGesture {
            //Slice Audio View
            print("ROW TAP")
            navPath.append(Destination.sliceAudioView(fileURL: fileURL, fileName: fileName, fileLength: fileLength))
            GAP.stopTimer()
            
        }
        .onLongPressGesture(minimumDuration: 0.05, pressing: { pressing in
            withAnimation{ holdingRow = pressing }
        },perform: {})
        .opacity(holdingRow ? 0.4 : 1.0)
    }
}

#Preview {
    
    
    ZStack{
        Color.green.ignoresSafeArea()
        MainRowView(fileName: "OnePieceOP.mp3", fileSize: "8Mb", fileLength: 221.0, fileURL: URL(fileURLWithPath: ""), GAP: GlobalAudioPlayer(),navPath: .constant(NavigationPath()))
    }
   
}
