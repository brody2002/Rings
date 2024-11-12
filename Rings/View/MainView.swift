import SwiftData
import SwiftUI
import AVFoundation

enum Destination: Hashable{
    case addSongView
    case sliceAudioView(fileURL: URL, fileName: String, fileLength: CGFloat)
}

struct mainView: View {
    
    @State private var showAddSongSheet: Bool = false
    @State private var mainColor = AppColors.backgroundColor
    @StateObject var fileChecker: FilesChecker
    @State var navPath = NavigationPath()
    @StateObject var GAP = GlobalAudioPlayer()
    
    // Rename File Vars
    @State var changeNameAlert: Bool = false
    @State var newFileName: String = ""
    
    @State var fileDirectoryURL: URL?
    

    
    var body: some View {
        NavigationStack(path: $navPath){
            ZStack {
                mainColor.ignoresSafeArea()
                VStack {
                    HStack {
                        Text("Song List")
                            .foregroundStyle(AppColors.secondary)
                            .font(.system(size: 30))
                            .bold()
                            .padding(.top, 30)
                    }
                    Spacer()
                    Form {
                        List {
                            ForEach(fileChecker.fileList.sorted(by: { $0.name < $1.name })) { file in
                                MainRowView(fileName: file.name, fileSize: file.size.toFileSizeString(), fileLength: file.length ?? 0.0, fileURL: file.fileURL, GAP: GAP, navPath: $navPath, fileChecker: fileChecker, changeNameAlert: $changeNameAlert, newFileName: $newFileName, fileDirectoryURL: $fileDirectoryURL)
                                    .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                                
                                    
                            }
                            .onDelete { indexSet in
                                    indexSet.forEach { index in
                                        let file = fileChecker.fileList[index]
                                        fileChecker.deleteSongFile(fileName: file.name)
                                    }
                            }
                            
                        }
                        
                    }
//                    .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.7)
                    .scrollContentBackground(.hidden)
                    .background(mainColor)
                    

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
                                .foregroundStyle(mainColor)
                        }
                    }
                        .opacity(changeNameAlert ? 0.0: 1.0)
                }
            }
            .onAppear{
                
                fileChecker.fileList = fileChecker.findFiles()
                for file in fileChecker.fileList {
                    GAP.isPlayingDict[file.fileURL] = false
                }
            }
            // Use navigationDestination to map Destination cases to views if needed for other cases
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .addSongView:
                    AddSongView(navPath: $navPath, fileChecker: fileChecker)
                case .sliceAudioView(let fileURL, let fileName, let fileLength):
                    SliceAudioView(fileURL: fileURL, fileName: fileName, fileLength: fileLength, GAP:GAP, navPath: $navPath)
                }
    
            }
           
        } .alert("Change Name", isPresented: $changeNameAlert) {
            TextField("FileName", text: $newFileName)
                .textInputAutocapitalization(.never)
            Button("OK", action: {
                
                // fetch fileURL:
                // make a new fileURL
                // delete old fileURL
            
                // fileDirectoryURL passes in the whole path including the file!
                
                
                
                fileChecker.renameFile(currentFileName: fileDirectoryURL!.lastPathComponent, newFileName: newFileName)
                GAP.resetProgress(for: fileDirectoryURL!.appendingPathComponent(newFileName))
                newFileName = ""
               
                
            })
            Button("Cancel", role: .cancel) {newFileName = ""}
        } message: {
            Text("Please enter a new file name")
        }
    }
    
}


#Preview {
    do {
        let sampleFileChecker = FilesChecker()
        sampleFileChecker.folderPath = URL(fileURLWithPath: "/sample/path/to/folder")
        
        return mainView(fileChecker: sampleFileChecker, GAP: GlobalAudioPlayer())
    }
    catch{
        print("cant outputview")
    }
        
            
    
}

