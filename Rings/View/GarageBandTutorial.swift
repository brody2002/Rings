//
//  GarageBandTutorial.swift
//  Rings
//
//  Created by Brody on 11/12/24.
//

import SwiftUI

struct GarageBandTutorial: View {
    
    @State var fileExporter = fileSaver()
    @State var fileURL: URL
    
    
    
    var body: some View {
        ZStack{
            AppColors.backgroundColor.ignoresSafeArea()
            ScrollView{
                Spacer()
                    .frame(height: 20)
                Text("Export Ringtones Through GarageBand")
                    .font(.system(size: 28))
                    .multilineTextAlignment(.center)
                    .bold()
                Spacer()
                    .frame(height: 50)
                ZStack{
                    Rectangle()
                        .frame(width: 140, height: 110)
                        .foregroundStyle(AppColors.secondary)
                        .cornerRadius(20)
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color.white)
                        .padding(.bottom, 10)
                }
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
                                                       
                                                       
                                                       do {
                                                           try FileManager.default.copyItem(at: fileURL, to: targetFileURL)
                                                           print("File copied successfully!")
                                                           
                                                           // Give the user the freedom to save this file to a desired location
                                                           fileExporter.saveToFilesApp(fileURL: temporaryURL)
                                                           
                                                           // TODO: Implement a save file view to allow the user to choose a location
                                                       } catch {
                                                           print("File copy failed: \(error.localizedDescription)")
                                                           print("Error details: \(error)") // This provides a more detailed error object for debugging.
                                                       }

                                           
                                                   }
                                                   
               //                                    clearTemporaryDirectory()
                                                   
                                               } catch {
                                                   print("Temp Copy failed: \(error.localizedDescription)")
                                               }
                                           } else {
                                               print("Could not find .band file in the bundle.")
                                           }
                                               

                                           
                                       } .onTapGesture{
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
                                                       
                                                       
                                                       do {
                                                           try FileManager.default.copyItem(at: fileURL, to: targetFileURL)
                                                           print("File copied successfully!")
                                                           
                                                           // Give the user the freedom to save this file to a desired location
                                                           fileExporter.saveToFilesApp(fileURL: temporaryURL)
                                                           
                                                           // TODO: Implement a save file view to allow the user to choose a location
                                                       } catch {
                                                           print("File copy failed: \(error.localizedDescription)")
                                                           print("Error details: \(error)") // This provides a more detailed error object for debugging.
                                                       }

                                           
                                                   }
                                                   
               //                                    clearTemporaryDirectory()
                                                   
                                               } catch {
                                                   print("Temp Copy failed: \(error.localizedDescription)")
                                               }
                                           } else {
                                               print("Could not find .band file in the bundle.")
                                           }
                                               

                                           
                                       }
                Spacer()
                    .frame(height: 50)
               
                
                VStack(alignment: .leading){
                    VStack{
                        
                        Text("1: ")
                        + Text("Save")
                            .bold()
                            .foregroundStyle(AppColors.secondary)
                        + Text(" the ")
                        + Text("GarageBand")
                        + Text(" file in the desired location by ")
                        + Text("Tapping ")
                            .bold()
                            .foregroundStyle(AppColors.secondary)
                        + Text("the shared button above")
                    }
                    Spacer()
                        .frame(height: 20)
                    VStack{
                        Text("2:")
                        + Text(" Long Press")
                            .bold()
                            .foregroundColor(AppColors.secondary)
                        + Text(" the project file found in the desired location and")
                        + Text(" Press Share")
                            .bold()
                            .foregroundColor(AppColors.secondary)
                    }
                    Spacer()
                        .frame(height: 20)
                    VStack{
                        Text("3: ")
                        + Text("Press")
                        + Text(" RingTones")
                            .bold()
                            .foregroundColor(AppColors.secondary)
                    }
                    Spacer()
                        .frame(height: 20)
                    VStack{
                        Text("4: ")
                        + Text("Click ")
                        + Text("Export")
                            .bold()
                            .foregroundColor(AppColors.secondary)
                        + Text(" to successfuly complete the ringtone! Now you can use the ringtone found in ")
                        + Text("Settings -> Sounds & Haptics -> Ringtones")
                            .bold()
                            .foregroundColor(AppColors.secondary)
                    }
                }
            }
            
        }
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
}

#Preview {
    GarageBandTutorial(fileURL: URL(fileURLWithPath: ""))
}
