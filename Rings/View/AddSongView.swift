//
//  AddSongView.swift
//  Rings
//
//  Created by Brody on 11/1/24.
//

import Foundation
import SwiftUI

struct AddSongView: View {
    
    enum inputFocus: Int, Hashable{
        case youtubeLink, fileName
    }
    
    @State private var songName: String = ""
    @State private var songURL: String = ""
    @StateObject var server = ServerCommunicator()
    @State private var showError: Bool = false
    @State private var  showConnectError: Bool = false
    @State private var loadingFile: Bool = false
    @Binding var navPath: NavigationPath
    @StateObject var fileChecker: FilesChecker
    @FocusState private var focusedField: inputFocus?
    @State private var tappedSaveSong: Bool = false
    @State private var errorMessage = ""
    
    
    func setErrorMessage(errorMsg: String) {
        errorMessage = errorMsg
        
    }
    
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
    
    var body: some View {
            ZStack{
                AppColors.backgroundColor.ignoresSafeArea()
                
                    Form{
                        Section{
                            TextField("Name", text: $songName)
                                .onChange(of: songName){ newValue in
                                    validFileName(newValue)
                                }
                                .focused($focusedField, equals: .fileName)
                        }
                        
                        Section{
                            TextField("YouTube URL", text: $songURL)
                                .autocapitalization(.none)
                                .focused($focusedField, equals: .youtubeLink)
                                
                        }
                        
                        Section{
                            Button(
                                action:{
                                    print("adding Song")
                                    //remove keyboard from view
                                    focusedField = nil
                                    checkIfURLExists(songURL){ check in
                                        if check == false{
                                            showError.toggle()
                                            setErrorMessage(errorMsg: "Please Enter a Valid YouTube URL")
                                        }
                                        else{
                                            tappedSaveSong = true
                                            server.fileName = songName
                                            server.youtubeLink = songURL
                                            server.sendYouTubeLink(inputURL: fileChecker.folderPath){ fileURL in
                                            if let fileURL = fileURL {
                                                print("MP3 saved to: \(fileURL.path)")
                                                
                                                
                                                //Dismiss the Navigation Path back to the root view
                                                
                                                DispatchQueue.main.async {
                                                    fileChecker.updateFileList()
                                                }

                                                navPath.removeLast()
                                                
                                            } else {
                                                
                                                // Show error for failed mp3 download
                                                showConnectError.toggle()
                                                setErrorMessage(errorMsg: "Failed to Connect to Server")
                                                
                                            }
                                        }
                                    }
                        
                                }
                                    
                                },
                                label:{
                                    Text("Save Song")
                                }
                            )
                            .disabled(!filledOut)
                            .opacity(server.isLoading ? 0 : 1)
                        }
                    }
                    .opacity(server.isLoading ? 0 : 1)
                    
                
                if server.isLoading{
                    ZStack{
                        
                        HStack{
                            LoadingView(color: AppColors.secondary)
                        }
                    }
                    
                }
                
                
                
                
            }
            .onAppear{
                focusedField = nil
            }
            .navigationTitle("Add Song")
            .alert("Invalid YouTube URL", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text("\(errorMessage)")
            }
            .alert("Server Connectivity", isPresented: $showConnectError) {
                Button("OK") {}
            } message: {
                Text("\(errorMessage)")
            }
            .navigationBarBackButtonHidden(server.isLoading)
        
        
    }
}

#Preview {
    
    @Previewable @State var testPath = NavigationPath()
    let fileChecker = FilesChecker()
    AddSongView(navPath: $testPath, fileChecker: fileChecker)
}
