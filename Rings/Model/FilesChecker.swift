//
//  FilesChecker.swift
//  Rings
//
//  Created by Brody on 11/1/24.
//

import Foundation
import Combine

class FilesChecker: ObservableObject {
    
    @Published var fileList: [String] = []
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
    
    func findFiles() -> [String] {
        let fileManager = FileManager.default
        var fileNames: [String] = []
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: folderPath, includingPropertiesForKeys: nil)
            
            // Extract file names and add them to the array
            fileNames = fileURLs.map { $0.lastPathComponent }
            
        } catch {
            print("Error accessing folder contents: \(error)")
        }
        
        return fileNames
    }
    
    private func updateFileList() {
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
}
