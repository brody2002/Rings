//
//  Server.swift
//  Rings
//
//  Created by Brody on 11/1/24.
//

import Foundation
import UIKit
import SwiftUI


@Observable
class ServerCommunicator: NSObject, UIDocumentPickerDelegate, ObservableObject{
    var fileName: String
    var youtubeLink: String
    var isLoading: Bool = false
    private let serverLink: String = "http://192.168.0.209:5002/convert"
    
    init(fileName: String = "", youtubeLink: String = "") {
        self.fileName = fileName
        self.youtubeLink = youtubeLink
    
    }
    
    func saveToFilesApp(fileURL: URL) {
        let documentPicker = UIDocumentPickerViewController(forExporting: [fileURL])
        documentPicker.modalPresentationStyle = .formSheet
        documentPicker.delegate = self
        
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(documentPicker, animated: true, completion: nil)
        }
    }
    
    func sendYouTubeLink(inputURL: URL, completion: @escaping (URL?) -> Void) {
        guard let requestUrl = URL(string: serverLink) else { return }
        let requestBody: [String: Any] = ["url": youtubeLink]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        print("sending request")
        
        withAnimation{
            self.isLoading = true
        }
        
        
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                self.isLoading = false
                completion(nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Server returned an error")
                self.isLoading = false
                completion(nil)
                return
            }
            
           
            if let data = data {
                withAnimation{
                    self.isLoading = false
                }
                // Save temporarily in app's cache directory
                let tempDirectoryURL = FileManager.default.temporaryDirectory
                
                //URL INPUT HERE
                let fileURL = tempDirectoryURL.appendingPathComponent("\(self.fileName).mp3")
                let outputURL = inputURL.appendingPathComponent("\(self.fileName).mp3")
                print("fileURL: \(fileURL)")
                print("outputURL: \(outputURL)")
                
                do {
                    try data.write(to: outputURL)
                    // Present document picker for user to save in Files app
                    completion(outputURL)
                } catch {
                    print("File saving error: \(error)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}
