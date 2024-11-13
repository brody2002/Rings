//
//  MainRowView.swift
//  Rings
//
//  Created by Brody on 11/4/24.
//

import SwiftUI
import UIKit

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
                            // edit and create a .band file
                            if let bandURL = Bundle.main.url(forResource: "garageband", withExtension: "band") {
                                    print("Found .band file")
                                    
                                    // Traverse the contents of the .band file
                                    let fileManager = FileManager.default
                                    let enumerator = fileManager.enumerator(at: bandURL, includingPropertiesForKeys: nil)
                                    
                                // Find Audio.wav in .band package
                                    while let file = enumerator?.nextObject() as? URL {
                                        if file.pathExtension == "wav" {
                                            print("Found WAV file: \(file.lastPathComponent)")
                                            
                                        //TODO: find m4a file of the row, convert it to wav and replace this Audio.wav and make it a saveable ringtone with UIPicker or delegate i forgot
                                            
                                            let outputWAVFileURL = file
                                            
                                            fileChecker.convertM4AToWAV(inputURL: self.fileURL, outputURL: outputWAVFileURL) { result in
                                                                switch result {
                                                                case .success(let outputURL):
                                                                    print("Conversion successful! WAV file saved at: \(outputURL)")
                                                                case .failure(let error):
                                                                    print("Conversion failed: \(error.localizedDescription)")
                                                                }
                                                            }
                                            return
                                        }
                                    }
                                    
                                    print("No WAV files found in the .band file.")
                                } else {
                                    print("Cannot find the .band file.")
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
            
            
            //Preparing for audio slice view
            print("ROW TAP")
            navPath.append(Destination.sliceAudioView(fileURL: fileURL, fileName: fileName, fileLength: fileLength))
            if GAP.audioPlayer?.isPlaying == true {
                GAP.audioPlayer?.stop()
            }
            print("preparing for the slice view")
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
