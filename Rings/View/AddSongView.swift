//
//  AddSongView.swift
//  Rings
//
//  Created by Brody on 11/1/24.
//

import Foundation
import SwiftUI

struct AddSongView: View{
    
    @State private var songName: String = ""
    @State private var songURL: String = ""
    @StateObject var server = ServerCommunicator()
    @State private var showError: Bool = false
    
    @State private var loadingFile: Bool = false
    @Binding var navPath: NavigationPath
    @StateObject var fileChecker: FilesChecker
    private let invalidCharacters = CharacterSet(charactersIn: "\\/:*?\"<>|")
    
    private var filledOut: Bool {
        if !songName.isEmpty && URL(string: songURL) != nil{
            return true
        } else { return false}
    }
    
    func checkIfURLExists(_ urlString: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(false) // Invalid URL format
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Use GET instead of HEAD for broader compatibility

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                completion(true) // URL exists and server responded with success
            } else {
                completion(false) // URL does not exist or some error occurred
            }
        }.resume()
    }

    
    func validFileName(_ newValue: String){
        let filtered = newValue
            .components(separatedBy: invalidCharacters).joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .init(charactersIn: "."))

        
        let finalValue = String(filtered.prefix(255))
        if finalValue != songName {
            songName = finalValue
        }
    }
    
    var body: some View{
        NavigationStack{
            ZStack{
                VStack{
                    Form{
                        Section{
                            TextField("Name", text: $songName)
                                .onChange(of: songName){ newValue in
                                    validFileName(newValue)
                                }
                        }
                        
                        Section{
                            TextField("YouTube URL", text: $songURL)
                                .autocapitalization(.none)
                        }
                        
                        Section{
                            Button(
                                action:{
                                    print("adding Song")
                                    checkIfURLExists(songURL){ check in
                                        if check == false{
                                            showError.toggle()
                                        }
                                    }
                                    server.fileName = songName
                                    server.youtubeLink = songURL
                                    server.sendYouTubeLink(){ fileURL in
                                    if let fileURL = fileURL {
                                        print("MP3 saved to: \(fileURL.path)")
                                        // Use the file URL as needed, e.g., play the audio or move it to another directory
                                    } else {
                                        print("Failed to download and save the MP3 file.")
                                    }
                                }
                                    
                                },
                                label:{
                                    Text("Save Song")
                                }
                            ).disabled(!filledOut)
                        }
                    }
                    
                }
                if server.isLoading{
                    HStack{
                        LoadingView(color: Color.blue)
                    }
                }
                
                
                
                
            }
            .navigationTitle("Add Song")
            .alert("Invalid YouTube URL", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text("Please Enter a Valid YouTube URL")
            }
        }
        
    }
}

#Preview {
    
    @Previewable @State var testPath = NavigationPath()
    let fileChecker = FilesChecker()
    AddSongView(navPath: $testPath, fileChecker: fileChecker)
}
