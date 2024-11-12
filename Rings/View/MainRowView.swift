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
    @StateObject var fileChecker: FilesChecker

    let maxCharacters = 27
    @State var truncatedFileName: String? = ""
    
    @Binding var changeNameAlert: Bool
    @Binding var newFileName: String
    
    @Binding var fileDirectoryURL: URL?
    

    
    
    private func fontSize(for characterCount: Int) -> CGFloat {
        switch characterCount {
        case 0...10:
            return 20
        case 11...20:
            return 18
        case 21...maxCharacters:
            return 16
        default:
            return 14
        }
    }
    
    var body: some View {
        
        ZStack{
            Color.white
            HStack{
                Spacer()
                    
                PlaySoundButtonView(fileURL: fileURL, GAP:GAP, fileLength: fileLength)
                    .padding()
                Spacer()
                    
                VStack(alignment: .leading) {
                    Spacer()
                    ZStack{
                        Text(truncatedFileName!)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: fontSize(for: fileName.count)))
                            .bold()
                    }
                    
                    
                    Spacer()
                        
                    HStack{
                        Text(HandyFunctions.convertLength(fileLength))
                            .font(.system(size: 10))
                            .foregroundColor(Color.gray)
                        Text(fileSize)
                            .font(.system(size: 10))
                            .foregroundColor(Color.gray)
                        Spacer()
                    }
                    Spacer()
                }
                VStack{
                    Spacer()
                        .frame(height: 10)
                    Image(systemName: "pencil.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.gray.opacity(0.8))
                        .padding()
                        .onTapGesture{
                            changeNameAlert = true
                            fileDirectoryURL = fileURL
                        }
                    

                    AddRingtoneView()
                        .frame(width:20 ,height: 20)
                        .padding()
                        .onTapGesture{
                            var lengthCheck: Bool = {
                                return fileLength < 39.99
                            }()
                            // check for length of file and approve it
                            // if true -> take to  expot .band view.
                            print("Checking Audio")
                            
                            if lengthCheck{
                                print("we can go to to view")
                                // create a copy garageband.band instance and edit the Audio.wav file
                                // behind it
                            }
                            
                            
                        }
                    Spacer()
                        .frame(height: 10)
                        
                }
                

                    
                Spacer()
                    
            }
        }
        .onAppear{
            
            self.truncatedFileName = fileName.count > maxCharacters ? "\(fileName.prefix(maxCharacters))…" : fileName
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
        .onLongPressGesture(minimumDuration: 0.03, pressing: { pressing in
            withAnimation{ holdingRow = pressing }
        },perform: {})
        .opacity(holdingRow ? 0.4 : 1.0)
    }
}

#Preview {
    @Previewable @StateObject var fileChecker = FilesChecker()
    
    ZStack{
        Color.green.ignoresSafeArea()
        MainRowView(fileName: "505 CoastContra_slice3.m4a", fileSize: "2.7Mb", fileLength: 221.0, fileURL: URL(fileURLWithPath: ""), GAP: GlobalAudioPlayer(),navPath: .constant(NavigationPath()), fileChecker: fileChecker, changeNameAlert: .constant(false), newFileName: .constant(""), fileDirectoryURL: .constant(URL(fileURLWithPath: "")))
    }
   
}
