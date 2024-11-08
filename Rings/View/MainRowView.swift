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

    
    
    var body: some View {
        ZStack{
            Color.white
            HStack{
                Spacer()
                    .frame(width: 50)
                PlaySoundButtonView(fileURL: fileURL, GAP:GAP, fileLength: fileLength)
                Spacer()
                    .frame(width:30)
                VStack(alignment: .leading) {
                    Text("\(fileName)")
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 20))
                        .bold()
                    Spacer()
                        .frame(height: 10)
                    HStack{
                        Text(HandyFunctions.convertLength(fileLength))
                            .font(.system(size: 10))
                            .foregroundColor(Color.gray)
                        Text(fileSize)
                            .font(.system(size: 10))
                            .foregroundColor(Color.gray)
                        Spacer()
                    }
                }
                .frame(width: 300)
                Spacer()
                    
            }
        }
        .frame(height: 80)
        .onTapGesture {
            //Slice Audio View
            print("ROW TAP")
            navPath.append(Destination.sliceAudioView(fileURL: fileURL, fileName: fileName, fileLength: fileLength))
            if GAP.audioPlayer?.isPlaying == true {
                GAP.audioPlayer?.stop()
            }
            GAP.resetProgress(for: fileURL)
            GAP.resetProgressForAllOtherFiles(in: fileURL.deletingLastPathComponent(), url: fileURL)
            
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
        MainRowView(fileName: "505 CoastContra.m4a", fileSize: "2.7Mb", fileLength: 221.0, fileURL: URL(fileURLWithPath: ""), GAP: GlobalAudioPlayer(),navPath: .constant(NavigationPath()))
    }
   
}
