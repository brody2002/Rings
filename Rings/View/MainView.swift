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
    
    
    //TODO:
    // * entering the chop view I need to kill the GAP and refresh the blue progress bars
    // * I need to implement the audio chop. Give two options:
    //   1. Overwrite file, 2. Make copy.
    
    
    
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
                            ForEach(fileChecker.fileList, id: \.self) { file in
                                MainRowView(fileName: file.name, fileSize: file.size.toFileSizeString(), fileLength: file.length ?? 0.0, fileURL: file.fileURL, GAP: GAP, navPath: $navPath)
                                    
                            }
                            .onDelete { indexSet in
                                    indexSet.forEach { index in
                                        let file = fileChecker.fileList[index]
                                        fileChecker.deleteSongFile(fileName: file.name)
                                    }
                            }
                            
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.7)
                    .scrollContentBackground(.hidden)
                    .background(mainColor)
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
                                .foregroundStyle(mainColor)
                        }
                    }.padding(.bottom , 20)
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

