import SwiftUI

struct GarageBandTutorial: View {
    @State var fileExporter = FileSaver()
    @State var fileURL: URL

    @State var isHoldingBack: Bool = false
    @Binding var navPath: NavigationPath
    var body: some View {
        ZStack(alignment: .top){
            AppColors.secondary.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 20)
                Text("Export Ringtones Through GarageBand")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(Color.white)
                Spacer()
                    .frame(height: 20)
                
                TabView {
                    tutorialStepView(
                        stepNumber: "1",
                        text: "Save the GarageBand file to the desired location by tapping the share button above in our App.",
                        imageName: "Step1"
                    )
                    tutorialStepView(
                        stepNumber: "2",
                        text: "Long-press the project file in the desired location and press Share.",
                        imageName: "Step2"
                    )
                    tutorialStepView(
                        stepNumber: "3",
                        text: "Open GarageBand, select your project, and open it.",
                        imageName: "Step3"
                    )
                    tutorialStepView(
                        stepNumber: "4",
                        text: "Navigate to \"My Songs\".",
                        imageName: "Step4"
                    )
                    tutorialStepView(
                        stepNumber: "5",
                        text: "Click the Ringtone Button to export the Audio File as a Ringtone.",
                        imageName: "Step5"
                    )
                    tutorialStepView(
                        stepNumber: "6",
                        text: "Now you can use it via Settings → Sounds & Haptics → Ringtones.",
                        imageName: "Step6"
                    )
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 20)
                
            }
            .padding(.top, 20)
            
            
            Image(systemName: "square.and.arrow.up")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(.white)
                .padding(.leading, UIScreen.main.bounds.width * 0.8)
                .padding(.top, UIScreen.main.bounds.width * 0.1)
                .ignoresSafeArea()
                .onTapGesture {
                    handleExport()
                }
            
            
            Image(systemName: "arrowshape.turn.up.backward.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(self.isHoldingBack ? .white.opacity(0.6) : .white)
                .onLongPressGesture(minimumDuration: 0.05, pressing: { pressing in
                    isHoldingBack = pressing
                }, perform: {
                    navPath.removeLast()
                })
                .padding(.trailing, UIScreen.main.bounds.width * 0.8)
                .padding(.top, UIScreen.main.bounds.width * 0.1)
                .ignoresSafeArea()
            
            
            
            
        }.navigationBarBackButtonHidden(true)
    }

    // Tutorial step view
    private func tutorialStepView(stepNumber: String, text: String, imageName: String) -> some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                Text("\(stepNumber):")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text(text)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .lineSpacing(4)
                    .bold()
            }
            .padding(.horizontal)
            if imageName == "Step4" || imageName == "Step5"{
                Image(imageName)
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.height * 0.2)
                    .cornerRadius(20)
            }
            else if imageName == "Step1" || imageName == "Step6"{
                Image(imageName)
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width * 0.6, height: UIScreen.main.bounds.height * 0.475)
                    .cornerRadius(20)
            }
            else{
                Image(imageName)
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width * 0.6, height: UIScreen.main.bounds.height * 0.5)
                    .cornerRadius(20)
            }
            Spacer()
            
        }
    }

    // Action handler for export button
    private func handleExport() {
        clearTemporaryDirectory()
        createAndExportBandFile()
    }

    // Clear temporary directory
    private func clearTemporaryDirectory() {
        let tempDirectory = FileManager.default.temporaryDirectory
        do {
            let tempFiles = try FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil, options: [])
            for file in tempFiles {
                try FileManager.default.removeItem(at: file)
            }
            print("Temporary directory cleared successfully.")
        } catch {
            print("Failed to clear temporary directory: \(error.localizedDescription)")
        }
    }

    // Create and export .band file
    private func createAndExportBandFile() {
        guard let bandURL = Bundle.main.url(forResource: "AudioFile", withExtension: "band") else {
            print("Could not find .band file in the bundle.")
            return
        }

        let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent("AudioFile.band")
        do {
            try FileManager.default.copyItem(at: bandURL, to: temporaryURL)
            print("Successful copy found at: \(temporaryURL.path)")

            let targetFileURL = temporaryURL.appendingPathComponent("/Media/Ringtone.wav")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.copyItem(at: fileURL, to: targetFileURL)
                    print("File copied successfully!")
                    fileExporter.saveToFilesApp(fileURL: temporaryURL)
                } catch {
                    print("File copy failed: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Temp Copy failed: \(error.localizedDescription)")
        }
    }

    // Ui Screen class for exporting file
    class FileSaver: NSObject, UIDocumentPickerDelegate {
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Document picker was cancelled.")
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print("Document saved to Files app at: \(urls.first?.absoluteString ?? "unknown location")")
        }

        func saveToFilesApp(fileURL: URL) {
            let documentPicker = UIDocumentPickerViewController(forExporting: [fileURL])
            documentPicker.modalPresentationStyle = .formSheet
            documentPicker.delegate = self

            if let topController = UIApplication.shared.windows.first?.rootViewController {
                topController.present(documentPicker, animated: true, completion: nil)
            }
        }
    }
}

#Preview {
    @Previewable @State var navPath = NavigationPath()
    GarageBandTutorial(fileURL: URL(fileURLWithPath: ""), navPath: $navPath)
}

