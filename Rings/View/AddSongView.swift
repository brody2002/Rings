import SwiftUI

struct AddSongView: View {
    
    enum inputFocus: Int, Hashable {
        case youtubeLink, fileName
    }
    
    @State private var songName: String = ""
    @State private var songURL: String = ""
    @StateObject var server = ServerCommunicator()
    @State private var showError: Bool = false
    @State private var showConnectError: Bool = false
    @State private var loadingFile: Bool = false
    @Binding var navPath: NavigationPath
    @StateObject var fileChecker: FilesChecker
    @FocusState private var focusedField: inputFocus?
    @State private var tappedSaveSong: Bool = false
    @State private var errorMessage = ""
    @State private var isHoldingBack: Bool = false
    func setErrorMessage(errorMsg: String) {
        errorMessage = errorMsg
    }
    
    private var filledOut: Bool {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)){
            if !songName.isEmpty && URL(string: songURL) != nil {
                return true
            } else {
                return false
            }
        }
        
    }
    
    func validFileName(_ newValue: String) {
        let invalidCharacters = CharacterSet(charactersIn: "\\/:*?\"<>|").union(.newlines).union(.controlCharacters).subtracting(.whitespaces)
        let filtered = newValue
            .components(separatedBy: invalidCharacters).joined()
            .trimmingCharacters(in: .newlines)
            .trimmingCharacters(in: .init(charactersIn: ".\t\r"))
        songName = String(filtered.prefix(255))
    }
    
    var body: some View {
        // Loading View
        ZStack{
            
            ZStack(alignment: .top) {
                
                
                AppColors.secondary.ignoresSafeArea()
                
                
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
                    .opacity(server.isLoading ? 0.0 : 1.0)
                
                
                VStack(spacing: 20) {
                    // Title
                    Text("Add a Song")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppColors.white)
                        .padding(.top, 20)
                    
                    Spacer()
                        .frame(height: 20)
                    // TextField Inputs
                    VStack(spacing: 16) {
                        styledTextField(
                            placeholder: "Enter song name",
                            text: $songName,
                            focusedField: $focusedField,
                            field: .fileName
                        )
                        
                        .onChange(of: songName) { oldValue, newValue in
                            validFileName(newValue)
                        }
                        
                        Spacer()
                            .frame(height: 40)
                        
                        styledTextField(
                            placeholder: "Enter YouTube URL",
                            text: $songURL,
                            focusedField: $focusedField,
                            field: .youtubeLink
                        )
                        .autocapitalization(.none)
                    }
                    .padding(.horizontal)
                    .opacity(server.isLoading ? 0.0 : 1.0)
                    
                    // Save Song Button
                    Spacer()
                        .frame(height: 60)
                    Button(action: saveSongAction) {
                        Text("Save Song")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(filledOut ? AppColors.backgroundColor.opacity(0.2) : AppColors.backgroundColor.opacity(0.0))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .opacity(filledOut ? 1.0 : 0.0)
                    .disabled(!filledOut)
                    .opacity(server.isLoading ? 0 : 1)
                    .padding(.horizontal, UIScreen.main.bounds.width * 0.3)
                    
                    
                }
                .padding()
                .alert("Invalid YouTube URL", isPresented: $showError) {
                    Button("OK") {}
                } message: {
                    Text("\(errorMessage)")
                }
                .alert("Server Connectivity", isPresented: $showConnectError) {
                    Button("OK") {}
                } message: {
                    Text("\(errorMessage)")
                }
                .onAppear {
                    focusedField = nil
                }
            }
            .opacity(server.isLoading ? 0.0 : 1.0)
            .navigationBarBackButtonHidden(true)
            
            ZStack{
                AppColors.secondary.ignoresSafeArea()
                if server.isLoading {
                                    LoadingView(color: AppColors.white)
                                        .padding(.top, 20)
                                }
            }.opacity(server.isLoading ? 1.0 : 0.0)
        }
        
    }
    
    // Custom styled TextField
    private func styledTextField(
        placeholder: String,
        text: Binding<String>,
        focusedField: FocusState<inputFocus?>.Binding,
        field: inputFocus
    ) -> some View {
        VStack(alignment: .leading) {
            TextField(placeholder, text: text)
                .focused(focusedField, equals: field)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColors.white)
                )
                .foregroundColor(AppColors.third)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(focusedField.wrappedValue == field ? AppColors.secondary : AppColors.secondary, lineWidth: 1)
                )
        }
    }
    
    // Action handler for the save button
    private func saveSongAction() {
        print("Adding song...")
        focusedField = nil
        guard URL(string: songURL) != nil else {
            showError.toggle()
            setErrorMessage(errorMsg: "Please Enter a Valid YouTube URL")
            return
        }
        tappedSaveSong = true
        server.fileName = songName
        server.youtubeLink = songURL
        server.sendYouTubeLink(inputURL: fileChecker.folderPath) { fileURL in
            if let fileURL = fileURL {
                print("MP3 saved to: \(fileURL.path)")
                DispatchQueue.main.async {
                    fileChecker.updateFileList()
                }
                navPath.removeLast()
            } else {
                showConnectError.toggle()
                setErrorMessage(errorMsg: "Failed to Connect to Server")
            }
        }
    }
}

#Preview {
    @Previewable @State var testPath = NavigationPath()
    let fileChecker = FilesChecker()
    AddSongView(navPath: $testPath, fileChecker: fileChecker)
}

