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
                        .padding(.trailing, 10)
                        .onTapGesture{
                            changeNameAlert = true
                            fileDirectoryURL = fileURL
                        }
                    
                    Spacer()
                        .frame(height:20)
                    

                    AddRingtoneView()
                        .frame(width:20 ,height: 20)
                        .padding(.trailing, 10)
                        .onTapGesture{
                            
                            func clearTemporaryDirectory() {
                                    let tempDirectory = FileManager.default.temporaryDirectory
                                    do {
                                        let tempFiles = try FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil, options: [])
                                        for file in tempFiles {
                                            try FileManager.default.removeItem(at: file)
                                        }
                                        print("Temporary directory cleared successfully.")
                                    } catch {
                                        print("Failed to clear temporary directory: \(error.localizedDescription)")
                                    }
                                }
                            // edit and create a .band file
                            if let bandURL = Bundle.main.url(forResource: "garageband", withExtension: "band") {
                                print("Found .band file at: \(bandURL)")
                                
                                // Define the destination URL in the temporary directory
                                let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent("garageband.band")
                                    print("\ntempURL: \(temporaryURL)\n")
                                do {
                                    // Copy the .band file to the temporary URL
                                    try FileManager.default.copyItem(at: bandURL, to: temporaryURL)
                                    print("Successful copy found at: \(temporaryURL.path)")
                                    
                                    let targetFileURL = temporaryURL.appendingPathComponent("/Media/Audio Files/Audio.wav")
                                    if FileManager.default.fileExists(atPath: fileURL.path) {
                                        print("audio file found at :\(targetFileURL)\n")
                                        print("fileURL: \(fileURL)\n")
                                        
                                        //TODO: Check why this fails
                                        do {try FileManager.default.copyItem(at: fileURL, to: targetFileURL)
                                            print("ez money")}
                                        catch {print("m4a to wav copy failed")}
                            
                                    }
                                    
                                    
                                    clearTemporaryDirectory()
                                } catch {
                                    print("Temp Copy failed: \(error.localizedDescription)")
                                }
                            } else {
                                print("Could not find .band file in the bundle.")
                            }
                                /* TODO: Save to temporary directory and then write the .bundle file there.
                                    then ask user to save the file.
                                    delete the file afterwords...
                                */

                            
                        }
                    
                    Spacer()
                        .frame(height:10)
                        
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
