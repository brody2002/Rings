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
                    Text("\(fileLength)")
                        .font(.system(size: 10))
                }
                Spacer()
                    
            }
        }
        .frame(height: 80)
    }
}

#Preview {
    ZStack{
        Color.green.ignoresSafeArea()
        MainRowView(fileName: "OnePieceOP.mp3", fileSize: "8Mb", fileLength: 221.0, fileURL: URL(fileURLWithPath: ""), GAP: GlobalAudioPlayer())
    }
   
}
