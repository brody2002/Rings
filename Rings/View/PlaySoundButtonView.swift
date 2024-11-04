//
//  PlaySoundButtonView.swift
//  Rings
//
//  Created by Brody on 11/4/24.
//
import SwiftUI
import AVFoundation
import UIKit





struct PlaySoundButtonView: View {
    @State var isPlaying: Bool = false
    @State var songStarted: Bool = false
    
    
    
    @State private var buttonColor: Color = Color.black
    @State var fileURL: URL
    @State private var documentInteractionController: UIDocumentInteractionController?
    @State private var documentDelegate = DocumentInteractionControllerDelegate()
    
    @StateObject var GAP: GlobalAudioPlayer
    
    


    var fileLength: CGFloat
    

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 3)
                    .foregroundStyle(buttonColor)
                    .frame(width: 40, height: 40)
                
                
                //TODO: fix the audioProgress view:
                Circle()
                    .trim(from: 0.0, to: CGFloat(GAP.audioProgress) / fileLength)
                    .stroke(style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(AppColors.secondary)
                
                Image(systemName: isPlaying ? "pause" : "play")
                    .foregroundStyle(buttonColor)
            }
            .frame(width: 40, height: 40)
            .onTapGesture {
                isPlaying.toggle()
                if isPlaying == true {
                    if songStarted == false{
                        // start song for the first time
                        GAP.loadAudioPlayer(url: fileURL)
                        print("starting song")
                        songStarted = true
                    }
                    GAP.play(url: fileURL)
                    GAP.startTimer()
                    
                } else {
                    print("pausing audio")
                    GAP.pause(url:fileURL)
                    GAP.stopTimer()
                }
                
            }
        }
        
    }
    private func playFileThroughFilesApp() {
            documentInteractionController = UIDocumentInteractionController(url: fileURL)
            documentInteractionController?.delegate = documentDelegate
            
            // Use presentPreview to open the file
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                documentInteractionController?.presentPreview(animated: true)
            }
    }
    
}

// Delegate for handling UIDocumentInteractionController behavior
class DocumentInteractionControllerDelegate: NSObject, UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            fatalError("Root view controller not found.")
        }
        return rootViewController
    }
}

#Preview {
    @Previewable @State var currentTime: CGFloat = 0.3
    PlaySoundButtonView(fileURL: URL(fileURLWithPath: ""), GAP: GlobalAudioPlayer(), fileLength: 0.0)
}
