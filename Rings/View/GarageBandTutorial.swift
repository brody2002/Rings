//
//  GarageBandTutorial.swift
//  Rings
//
//  Created by Brody on 11/12/24.
//

import SwiftUI

struct GarageBandTutorial: View {
    @State var fileExporter = FileSaver()
    @State var fileURL: URL

    var body: some View {
        ZStack {
            AppColors.backgroundColor.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 30) {
                    // Title
                    Text("Export Ringtones Through GarageBand")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(AppColors.third)

                    // Export Button
                    Button(action: handleExport) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(AppColors.secondary)
                                .frame(width: 150, height: 120)
                            Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 20)

                    // Steps
                    VStack(alignment: .leading, spacing: 25) {
                        Spacer()
                            .frame(height: 20)
                        tutorialStep(number: "1", text: "Save the GarageBand file to the desired location by tapping the share button above.")
                        tutorialStep(number: "2", text: "Long-press the project file in the desired location and press Share.")
                        tutorialStep(number: "3", text: "Pr")
                        tutorialStep(number: "3", text: "Press Ringtones and confirm your selection.")
                        tutorialStep(number: "4", text: "Click Export to complete the ringtone. Now you can use it via Settings → Sounds & Haptics → Ringtones.")
                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(.horizontal, 20)
                    .background(AppColors.secondary)
                    .cornerRadius(20)
                    .padding()
                }
                .padding(.top, 20)
            }
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

    // Step view
    private func tutorialStep(number: String, text: String) -> some View {
        HStack(alignment: .top) {
            Text("\(number):")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            Text(text)
                .font(.system(size: 18))
                .foregroundColor(Color.white)
                .lineSpacing(4)
        }
    }

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
    GarageBandTutorial(fileURL: URL(fileURLWithPath: ""))
}

