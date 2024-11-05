//
//  FilesChecker.swift
//  Rings
//
//  Created by Brody on 11/1/24.
//

import AVFoundation
import Combine
import Foundation


struct FileDetails: Hashable {
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
                if fileURL.pathExtension.lowercased() == "mp3" || fileURL.pathExtension.lowercased() == "mp4" {
                    let asset = AVURLAsset(url: fileURL)
                    fileLength = asset.duration.seconds
                }
                
                
                let fileSize = attributes.fileSize ?? 0
                let fileDetails = FileDetails(name: fileName, size: Int64(fileSize), length: fileLength, fileURL: fileURL)
//                print("\n\nFileDetails: \(fileDetails)\n\n")
                fileDetailsList.append(fileDetails)
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

}
