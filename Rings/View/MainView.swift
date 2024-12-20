import SwiftData
import SwiftUI
import AVFoundation

enum Destination: Hashable{
    case addSongView
    case sliceAudioView(fileURL: URL, fileName: String, fileLength: CGFloat)
    case garageBandTutorial(fileURL: URL)
}

struct mainView: View {
    
    @State private var showAddSongSheet: Bool = false
    @StateObject var fileChecker: FilesChecker
    @State var navPath = NavigationPath()
    @StateObject var GAP = GlobalAudioPlayer()
    
    // Rename File Vars
    @State var changeNameAlert: Bool = false
    @State var newFileName: String = ""
    
    @State var fileDirectoryURL: URL?
    
    func customSort(_ lhs: String, _ rhs: String) -> Bool {
        // Check if one string is a prefix of the other
        if lhs.hasPrefix(rhs) || rhs.hasPrefix(lhs) {
            return lhs.count > rhs.count // Longer string goes first
        }
        
        // Fall back to natural sorting for non-prefix strings
        return lhs.localizedStandardCompare(rhs) == .orderedAscending
    }
    
    


    
    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack {
                AppColors.secondary.ignoresSafeArea()
                VStack {
                    HStack {
                        Text("Audio List")
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .foregroundColor(AppColors.white)
                            .padding(.top, 20)
                    }
                    
                    Spacer()
                    VStack{
                        // Limit the scrollable area to the List
                        List {
                            ForEach(fileChecker.fileList.sorted(by: { customSort($0.name, $1.name) })) { file in
                                MainRowView(
                                    fileName: file.name,
                                    fileSize: file.size.toFileSizeString(),
                                    fileLength: file.length ?? 0.0,
                                    fileURL: file.fileURL,
                                    GAP: GAP,
                                    navPath: $navPath,
                                    fileChecker: fileChecker,
                                    changeNameAlert: $changeNameAlert,
                                    newFileName: $newFileName,
                                    fileDirectoryURL: $fileDirectoryURL
                                )
                                .listSectionSpacing(20)
                                .listRowInsets(EdgeInsets(top: 30, leading: 0, bottom: 30, trailing: 0))
                                .cornerRadius(20)
                            }
                            .onDelete { indexSet in
                                let sortedFileList = fileChecker.fileList.sorted(by: { customSort($0.name, $1.name) })
                                indexSet.map { sortedFileList[$0] }.forEach { file in
                                    fileChecker.deleteSongFile(fileName: file.name)
                                }
                                fileChecker.updateFileList()
                            }
                        }

                        
                        .scrollContentBackground(.hidden) // Ensure background matches
                        .background(AppColors.secondary)
                        .frame(maxHeight: UIScreen.main.bounds.height * 0.7) // Restrict List height
                        
                    }
                    .cornerRadius(20)
                    .clipShape(RoundedRectangle(cornerRadius: 40))
                    .padding()
                    
                    
                    
                    // Clip explicitly to ensure the radius is enforced
                    Spacer()
                    
                    Button(action: {
                        navPath.append(Destination.addSongView)
                    }) {
                        ZStack {
                            Circle()
                                .fill(AppColors.secondary)
                                .frame(width: 60, height: 60)
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundStyle(AppColors.white)
                        }
                    }
                    .opacity(changeNameAlert ? 0.0 : 1.0)
                }
            }
            .onAppear {
                fileChecker.fileList = fileChecker.findFiles()
                for file in fileChecker.fileList {
                    GAP.isPlayingDict[file.fileURL] = false
                }
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .addSongView:
                    AddSongView(navPath: $navPath, fileChecker: fileChecker)
                case .sliceAudioView(let fileURL, let fileName, let fileLength):
                    SliceAudioView(fileURL: fileURL, fileName: fileName, fileLength: fileLength, GAP: GAP, navPath: $navPath)
                case .garageBandTutorial(let fileURL):
                    GarageBandTutorial(fileURL: fileURL, navPath: $navPath)
                }
            }
            .alert("Change Name", isPresented: $changeNameAlert) {
                TextField("FileName", text: $newFileName)
                    .textInputAutocapitalization(.never)
                Button("OK") {
                    guard let directoryURL = fileDirectoryURL else { return }
                    fileChecker.renameFile(currentFileName: directoryURL.lastPathComponent, newFileName: newFileName)
                    GAP.resetProgress(for: directoryURL.appendingPathComponent(newFileName))
                    newFileName = ""
                }
                Button("Cancel", role: .cancel) {
                    newFileName = ""
                }
            } message: {
                Text("Please enter a new file name")
            }
        }
    }

}


#Preview {
    
        let sampleFileChecker = FilesChecker()
        sampleFileChecker.folderPath = URL(fileURLWithPath: "/sample/path/to/folder")
        
        return mainView(fileChecker: sampleFileChecker, GAP: GlobalAudioPlayer())
    
        
            
    
}

