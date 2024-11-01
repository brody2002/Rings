//
//  RingsApp.swift
//  Rings
//
//  Created by Brody on 11/1/24.
//

import SwiftUI
import SwiftData

@main
struct RingsApp: App {
    @State var folderURL: URL = URL(fileURLWithPath: "")
    @StateObject var fileCheck = FilesChecker()
    var body: some Scene {
        WindowGroup {
            mainView(fileChecker: fileCheck)
                .onAppear{
                    createCustomFolder(named: "AddedSongs")
                    fileCheck.folderPath = folderURL
                    fileCheck.fileList = fileCheck.findFiles()
                    
                    
                }
                
        }.modelContainer(for: Song.self)
    }
    func createCustomFolder(named folderName: String) {
        let fileManager = FileManager.default

        // Get the Documents directory URL for your app
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to access Documents directory")
            return
        }

        // Create the full folder path
        folderURL = documentsURL.appendingPathComponent(folderName)

        // Check if the folder already exists
        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                // Create the folder
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                print("Folder created at: \(folderURL)")
            } catch {
                print("Error creating folder: \(error)")
            }
        } else {
            print("Folder already exists at: \(folderURL)")
        }
    }
}




