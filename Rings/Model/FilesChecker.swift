//
//  FilesChecker.swift
//  Rings
//
//  Created by Brody on 11/1/24.
//

import AVFoundation
import Combine
import Foundation


struct FileDetails: Hashable, Identifiable {
    var id = UUID()
    
    let name: String
    let size: Int64 // File size in bytes
    let length: TimeInterval? // File length in seconds, if applicable
    let fileURL: URL
}

extension Int64 {
    func toFileSizeString() -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB] // Customize units as needed
        formatter.countStyle = .file
        return formatter.string(fromByteCount: self)
    }
}

class FilesChecker: ObservableObject {
    
    @Published var fileList: [FileDetails] = []
    
    var folderPath: URL = URL(fileURLWithPath: "") {
        didSet {
            print("folderPath -> \(folderPath.path)")
            startMonitoringFolder()
            updateFileList() // Initial population of fileList
        }
    }
    
    private var folderMonitorSource: DispatchSourceFileSystemObject?
    
    init() {
        updateFileList() // Initial load
    }
    
    
    //Responsible for updating filesize, and song length, name, and pathURL
    func findFiles() -> [FileDetails] {
        
        let fileManager = FileManager.default
        var fileDetailsList: [FileDetails] = []
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: folderPath, includingPropertiesForKeys: [.fileSizeKey])
            print("\n\nFolderPath: \(folderPath)\n\nFileURLs: \(fileURLs)\n\n")
            for fileURL in fileURLs {
                let fileName = fileURL.lastPathComponent
                let attributes = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                
                // Extract file size in bytes
                
                
                // Check if the file is a media file and get its duration
                var fileLength: TimeInterval? = nil
                if fileURL.pathExtension.lowercased() == "m4a" || fileURL.pathExtension.lowercased() == "m4a" {
                    let asset = AVURLAsset(url: fileURL)
                    fileLength = asset.duration.seconds
                    let fileSize = attributes.fileSize ?? 0
                    let fileDetails = FileDetails(name: fileName, size: Int64(fileSize), length: fileLength, fileURL: fileURL)
                    print("\n\nFileDetails: \(fileDetails)\n\n")
                    fileDetailsList.append(fileDetails)
                }
                
                
                
            }
            
        } catch {
            print("Error accessing folder contents: \(error)")
        }
        
        return fileDetailsList
    }
    
    func updateFileList() {
        print("updating FILES")
        fileList = findFiles() // Update fileList with the current contents of the folder
    }
    
    func renameFile(currentFileName: String, newFileName: String) {
        
        print(currentFileName)
        print(newFileName)
        
        
        let currentFileURL = folderPath.appendingPathComponent(currentFileName)
        let newFileURL = folderPath.appendingPathComponent("\(newFileName).m4a")
        let fileManager = FileManager.default

        // Ensure the new file name doesn't already exist
        guard !fileManager.fileExists(atPath: newFileURL.path) else {
            print("A file with the name \(newFileName) already exists.")
            return
        }

        do {
            try fileManager.moveItem(at: currentFileURL, to: newFileURL)
            print("Renamed file from \(currentFileName) to \(newFileName)")
            updateFileList() // Refresh the file list after renaming
        } catch {
            print("Error renaming file \(currentFileName) to \(newFileName): \(error)")
        }
    }

    
    private func startMonitoringFolder() {
        stopMonitoringFolder() // Stop any existing monitor
        
        let fileDescriptor = open(folderPath.path, O_EVTONLY)
        guard fileDescriptor != -1 else {
            print("Could not open directory at \(folderPath.path)")
            return
        }
        
        folderMonitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: DispatchQueue.global())
        
        folderMonitorSource?.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                print("updating the fileList")
                self?.updateFileList() // Refresh fileList when there are changes
            }
        }
        
        folderMonitorSource?.setCancelHandler {
            close(fileDescriptor)
        }
        
        folderMonitorSource?.resume()
    }
    
    private func stopMonitoringFolder() {
        folderMonitorSource?.cancel()
        folderMonitorSource = nil
    }
    
    deinit {
        stopMonitoringFolder() // Clean up when the instance is deallocated
    }
    
    
    func deleteSongFile(fileName: String) {
        let fileURL = folderPath.appendingPathComponent(fileName)
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(at: fileURL)
            print("Deleted file: \(fileName)")
            updateFileList() // Refresh the file list after deletion
        } catch {
            print("Error deleting file \(fileName): \(error)")
        }
    }
    
   
    
    //code from stack overflow: https://stackoverflow.com/questions/35738133/ios-code-to-convert-m4a-to-wav
    
    func convertM4AToWAV(inputURL: URL, outputURL: URL) throws {
        // Define the destination file as "Audio.wav" within the outputURL
        let destinationURL = outputURL
        print("\ndestinationURL: \(destinationURL)\n")
        print("\nsourceURL: \(inputURL)\n")
        // Ensure the input file exists
        guard FileManager.default.fileExists(atPath: inputURL.path) else {
            throw NSError(domain: "FileError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Input file does not exist at \(inputURL.path)"])
        }
        
        do {
            // Copy the input file to the destination as "Audio.wav"
            try FileManager.default.copyItem(at: inputURL, to: destinationURL.deletingLastPathComponent().appendingPathComponent("Audio2.wav"))
            print("File successfully renamed and saved")
            
           
        } catch {
            print("Error during file operation: \(error.localizedDescription)")
            throw error
        }
    }


}
