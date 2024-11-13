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
    
    // Writing to .band
    @State private var fileToSave: URL? = nil
    @State private var showingFileSaver = false

    @State var fileExporter = fileSaver()
   
    
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
                            clearTemporaryDirectory()
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
                            if let bandURL = Bundle.main.url(forResource: "AudioFile", withExtension: "band") {
                                print("Found .band file at: \(bandURL)")
                                
                                // Define the destination URL in the temporary directory
                                let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent("AudioFile.band")
                                    print("\ntempURL: \(temporaryURL)\n")
                                do {
                                    // Copy the .band file to the temporary URL
                                    try FileManager.default.copyItem(at: bandURL, to: temporaryURL)
                                    print("Successful copy found at: \(temporaryURL.path)")
                                    
                                    let targetFileURL = temporaryURL.appendingPathComponent("/Media/Ringtone.wav")
                                    if FileManager.default.fileExists(atPath: fileURL.path) {
                                        print("audio file found at :\(targetFileURL)\n")
                                        print("fileURL: \(fileURL)\n")
                                        
                                        
                                        do {try FileManager.default.copyItem(at: fileURL, to: targetFileURL)
                                            print("ez money")
                                            fileExporter.saveToFilesApp(fileURL: temporaryURL)
                                            
                                        }
                                        catch {print("m4a to wav copy failed")}
                            
                                    }
                                    
                                    clearTemporaryDirectory()
                                    
                                } catch {
                                    print("Temp Copy failed: \(error.localizedDescription)")
                                }
                            } else {
                                print("Could not find .band file in the bundle.")
                            }
                                

                            
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
    
    // Document picker delegate method (if needed)
       
}

class fileSaver: NSObject, UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("Document saved to Files app at: \(urls.first?.absoluteString ?? "unknown location")")
    }

    func saveToFilesApp(fileURL: URL) {
            let documentPicker = UIDocumentPickerViewController(forExporting: [fileURL])
            documentPicker.modalPresentationStyle = .formSheet
            documentPicker.delegate = self

            if let topController = UIApplication.shared.windows.first?.rootViewController {
                topController.present(documentPicker, animated: true, completion: nil)
            }
        }
}




#Preview {
    @Previewable @StateObject var fileChecker = FilesChecker()
    
    ZStack{
        Color.green.ignoresSafeArea()
        MainRowView(fileName: "505 CoastContra_slice3.m4a", fileSize: "2.7Mb", fileLength: 221.0, fileURL: URL(fileURLWithPath: ""), GAP: GlobalAudioPlayer(),navPath: .constant(NavigationPath()), fileChecker: fileChecker, changeNameAlert: .constant(false), newFileName: .constant(""), fileDirectoryURL: .constant(URL(fileURLWithPath: "")))
    }
   
}
