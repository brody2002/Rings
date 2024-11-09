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
    @State var changeNameAlert: Bool = false

    let maxCharacters = 27
    @State var truncatedFileName: String? = ""
    @State var newFileName: String = ""
    @StateObject var fileChecker: FilesChecker
    
    @State var directoryURL: URL?
    
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
                Image(systemName: "pencil.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.gray.opacity(0.8))
                    .padding()
                    .onTapGesture{
                        changeNameAlert = true
                    }
                    .alert("Change Name", isPresented: $changeNameAlert) {
                        TextField("FileName", text: $newFileName)
                            .textInputAutocapitalization(.never)
                        Button("OK", action: {
                            
                            // fetch fileURL:
                            // make a new fileURL
                            // delete old fileURL
                            
                            fileChecker.renameFile(currentFileName: fileName, newFileName: newFileName)
                            GAP.resetProgress(for: directoryURL!.appendingPathComponent(newFileName))
                           
                            
                        })
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Please enter a new userName")
                    }
                    
                Spacer()
                    
            }
        }
        .onAppear{
            directoryURL = fileURL.deletingLastPathComponent()
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
        MainRowView(fileName: "505 CoastContra_slice3.m4a", fileSize: "2.7Mb", fileLength: 221.0, fileURL: URL(fileURLWithPath: ""), GAP: GlobalAudioPlayer(),navPath: .constant(NavigationPath()), fileChecker: fileChecker)
    }
   
}
