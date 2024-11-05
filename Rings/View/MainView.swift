import SwiftData
import SwiftUI
import AVFoundation

enum Destination: Hashable {
    case addSongView
    case sliceAudioView
}

struct mainView: View {
    
    @State private var showAddSongSheet: Bool = false
    @State private var mainColor = AppColors.backgroundColor
    @StateObject var fileChecker: FilesChecker
    @State var navPath = NavigationPath()
    @StateObject var GAP: GlobalAudioPlayer
    
    
    
    var body: some View {
        NavigationStack(path: $navPath){
            ZStack {
                mainColor.ignoresSafeArea()
                VStack {
                    HStack {
                        Text("Songs: ")
                            .foregroundStyle(AppColors.secondary)
                            .font(.system(size: 30))
                            .bold()
                    }
                    Form {
                        List {
                            ForEach(fileChecker.fileList, id: \.self) { file in
                                MainRowView(fileName: file.name, fileSize: file.size.toFileSizeString(), fileLength: file.length ?? 0.0, fileURL: file.fileURL, GAP: GAP)
                            }
                            .onDelete { indexSet in
                                    indexSet.forEach { index in
                                        let file = fileChecker.fileList[index]
                                        fileChecker.deleteSongFile(fileName: file.name)
                                    }
                            }
                            .onTapGesture {
                                //Slice Audio View
                                navPath.append(Destination.sliceAudioView)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(mainColor)
                    
                    Spacer()
                    
                    // Use NavigationLink directly to navigate to AddSongView
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
                }
            }
            // Use navigationDestination to map Destination cases to views if needed for other cases
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .addSongView:
                    AddSongView(navPath: $navPath, fileChecker: fileChecker)
                case .sliceAudioView:
                    SliceAudioView()
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

