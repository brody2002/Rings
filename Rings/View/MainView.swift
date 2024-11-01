import SwiftData
import SwiftUI



@Model
class Song{
    var id = UUID()
    var name: String
    var url: String
    init(name: String, url: String){
        self.name = name
        self.url = url
    }
}

struct mainView: View{
    @Query var songList: [Song]
    @Environment(\.modelContext) var mainContext
    @State private var showAddSongSheet: Bool = false
    @State private var mainColor = Color(red: 242 / 255, green: 242 / 255, blue: 247 / 255)
    @State var navPath = NavigationPath()
    @StateObject var fileChecker: FilesChecker
    
    var body: some View{
        NavigationStack{
            ZStack{
                mainColor.ignoresSafeArea()
                VStack{
                    HStack{
                        Text("Songs: ")
                            .foregroundStyle(Color.blue)
                            .font(.system(size: 30))
                            .bold()
                    }
                    Form {
                        List {
                            ForEach(fileChecker.fileList, id: \.self){fileName in
                                Text(fileName)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(mainColor)
                    
                    Spacer()
                    
                    NavigationLink(
                        destination: AddSongView(navPath: $navPath, fileChecker: fileChecker), label: {
                            ZStack{
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 60, height: 60)
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(mainColor)
                            }
                        
                    })
                    
                }
                
            }
            
            
        }
        
        
        
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Song.self, configurations: config)
        
        // Create a sample FilesChecker instance for the preview
        let sampleFileChecker = FilesChecker()
        sampleFileChecker.folderPath = URL(fileURLWithPath: "/sample/path/to/folder")
        
        return mainView(fileChecker: sampleFileChecker)
            .modelContainer(container)
    } catch {
        return Text("Failed to create container: \(error.localizedDescription)")
    }
}

