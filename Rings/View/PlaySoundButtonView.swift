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
    @State private var buttonColor: Color = AppColors.third
    @State var fileURL: URL
    @State private var documentInteractionController: UIDocumentInteractionController?
    @State private var documentDelegate = DocumentInteractionControllerDelegate()
    
    @StateObject var GAP: GlobalAudioPlayer
    
    @State private var buttonHold: Bool = false
    
    


    var fileLength: CGFloat
    
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 3)
                    .foregroundStyle(AppColors.backgroundColor)
                    .frame(width: 40, height: 40)
                
                
                //TODO: fix the audioProgress view:
                // Issue 1: before even running there is still blue present Blue also moves along all songs.
                // Issue 2: playing another song doesn't pause the others by default
                // Issue 3: Time Length Units incorrect
                
                
                // Remeber the previous URL and clear ther audioProgress value to 0
                // set the ui play button = to false because it's not paused.
                
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(GAP.audioProgressDict[fileURL] ?? 0.0) / fileLength)
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(AppColors.secondary)
//                    .onChange(of: GAP.audioProgressDict[fileURL]) { value in
//                        print("\(fileURL.lastPathComponent) is being changed")
//                    }
                    

                Image(systemName: (GAP.isPlayingDict[fileURL] ?? false) ? "pause" : "play")
                                    .foregroundStyle(buttonColor)
            }
            .frame(width: 40, height: 40)
            
            .onTapGesture {
                if GAP.isPlayingDict[fileURL] == nil{
                    // fileURL isnt in dictionary from moving files in the directory
                    GAP.isPlayingDict[fileURL] = false
                    
                    GAP.play(url: fileURL)
                    
                }
                else if GAP.isPlayingDict[fileURL] == true {
                    print("\n\npausing")
                    GAP.pause(url: fileURL)
                } else {
                    print("\n\nresume")
                    
                    GAP.play(url: fileURL)
                }
            }
            .onLongPressGesture(
                minimumDuration: 1.0, // Duration in seconds
                pressing: { isPressing in
                    // Optional: Use this for visual feedback or debugging, but avoid critical logic here.
                    if isPressing {
//                        print("Pressing started (but not long enough yet).")
                    } else {
//                        print("Pressing ended before long press was completed.")
                    }
                },
                perform: {
                    // This is only called after the 1.0-second threshold is met.
                    print("Long press gesture successfully performed.")
                    triggerHapticFeedback()
                    GAP.resetProgress(for: fileURL)
                }
            )
        }
        
    }
//    private func playFileThroughFilesApp() {
//            documentInteractionController = UIDocumentInteractionController(url: fileURL)
//            documentInteractionController?.delegate = documentDelegate
//            
//            // Use presentPreview to open the file
//            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//                documentInteractionController?.presentPreview(animated: true)
//            }
//    }
    
    func triggerHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred() // Perform the feedback
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
