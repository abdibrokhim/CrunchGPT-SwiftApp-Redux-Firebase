//
//  ChatView.swift
//  crunchitWithAuth
//
//  Created by Ibrohim Abdivokhidov on 24/07/23.
//

import SwiftUI
import MobileCoreServices
import Firebase
import FirebaseStorage

struct ChatView: View {
    @State private var message: String = ""
    @State private var showDocumentPicker: Bool = false
    @State private var showModal = false
    
    @EnvironmentObject var store: Store
    @StateObject var viewModel = ChatViewModel()
    @StateObject var contentViewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            Text("Cruncher")
                .font(.title)
            
            Spacer()
            
            ScrollView {
                LazyVStack {
                    ForEach(store.appState.chatMessages, id: \.id) {message in
                        messageView(message: message)
                    }
                }
            }
            
            HStack {
                Button {
                    self.showDocumentPicker.toggle()
                } label: {
                    if store.appState.isUploading || store.appState.isProcessing || store.appState.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .padding()
                            .scaleEffect(1)
                    } else {
                        Image(systemName: "paperclip")
                            .imageScale(.large)
                            .padding()
                            .foregroundColor(.black)
                    }
                }
                .sheet(isPresented: $showDocumentPicker) {
                    DocumentPicker()
                }
                .disabled(
                    store.appState.isUploading)
                
                TextField("Send a message", text: $message)
                    .padding()
                    .background(.gray.opacity(0.2))
                    .cornerRadius(10)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .disabled(
                        !store.appState.isProcessed)
                
                Button {
                    sendMessage()
                } label: {
                    if store.appState.isUploading || store.appState.isProcessing || store.appState.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .padding()
                            .scaleEffect(1)
                            .background(.black)
                            .cornerRadius(10)
                    } else {
                        Text("Send")
                            .foregroundColor(.white)
                            .padding()
                            .background(.black)
                            .cornerRadius(10)
                    }
                }
                .disabled(
                    message.isEmpty ||
                    store.appState.isUploading ||
                    store.appState.isProcessing ||
                    store.appState.isLoading ||
                    !store.appState.isProcessed)
                .gesture(
                    LongPressGesture()
                        .onEnded { _ in
                            showAlertToClearConversation()
                        }
                )
            }
        }
        .padding()
        .alert(isPresented: $store.appState.alert) {
            Alert(
                title: Text(store.appState.alertMessage!.type.typeString),
                message: Text(store.appState.alertMessage!.message == nil ? "" : store.appState.alertMessage!.message!.typeString),
                dismissButton:
                        .default(Text("Dismiss"))
            )
        }
    }
    
    func showAlertToClearConversation() {
        let alert = UIAlertController(
            title: "Clear Conversation",
            message: "Are you sure you want to clear the conversation?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            store.dispatch(.clearChat)
        })

        // Present the alert
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    
    func messageView(message: ChatMessage) -> some View {
        HStack {
            if message.sender == .user { Spacer() }

            VStack(alignment: message.sender == .user ? .trailing : .leading) {
                Spacer()
                
                HStack(
                    alignment: .top
                ) {
                    Text(message.content)
                        .foregroundColor(.black)
                        .padding()
                        .background(message.sender == .user ? Color.gray.opacity(0.4) : Color.gray.opacity(0.1))
                        .cornerRadius(10)

                    if message.sender == .agent {
                        Button(action: {
                            UIPasteboard.general.string = message.content
                        }) {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.black)
                        }
                    }
                }
                
                Spacer()
            }

            if message.sender == .agent { Spacer() }
        }
    }
    
    
    func sendMessage() {
        store.dispatch(.isLoading(true))
        
        let userMessage = ChatMessage(id: UUID().uuidString, content: message, dateCreated: Date(), sender: .user)
        store.dispatch(.addChatMessage(userMessage))
        
        if let uid = contentViewModel.userSession?.uid {
            if store.appState.documentId == "" {
                let documentId = UUID().uuidString
                store.dispatch(.documentId(documentId))
                
                let userChat = UserChats(id: documentId, uid: uid, chatMessages: [userMessage], fileData: store.appState.fileData ?? FileData(id: "", url: ""))
                Task { try await viewModel.createChat(chat: userChat) }
            } else {
                print("resuming conversation. document id: \(store.appState.documentId)")
                Task { try await viewModel.updateChat(chat: userMessage, documentId: store.appState.documentId) }
            }
        }

        let messageQueryParam = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let fileIDQueryParam = store.appState.fileData!.url!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        // Construct the URL components
        var urlComponents = URLComponents(string: "http://127.0.0.1:8000/chat/cohere/")!

        // Add the query and file_id parameters to the URL
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: messageQueryParam),
            URLQueryItem(name: "file_id", value: fileIDQueryParam)
        ]

        // Create the final URL
        let url = urlComponents.url!
        
        print("full url: \(url)")
        
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    let clearedResponse = responseString.trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: "\"")))
                    let agentMessage = ChatMessage(id: UUID().uuidString, content: clearedResponse, dateCreated: Date(), sender: .agent)
                    store.dispatch(.addChatMessage(agentMessage))
                    
                    Task { try await viewModel.updateChat(chat: agentMessage, documentId: store.appState.documentId) }
                }
            }
        }
        
        task.resume()
        
        message = ""
        
        store.dispatch(.isLoading(false))
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        let reducer = Reducer()
        let store = Store(appState: appState, reducer: reducer)
        
        ChatView().environmentObject(store)
    }
}




struct DocumentPicker: UIViewControllerRepresentable {
    
    @EnvironmentObject var store: Store
    @StateObject var viewModel = ChatViewModel()
    
    func makeCoordinator() -> Coordinator {
        return DocumentPicker.Coordinator(parent: self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        
        let picker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .open)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        
        var parent: DocumentPicker
        
        init(parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            let fileId = UUID().uuidString
            
            self.parent.store.dispatch(.addFileData(FileData(id: fileId, url: nil)))
            
            let storageRef = Storage.storage(url: "gs://swift-5b45e.appspot.com").reference()
            
            let fileRef = storageRef.child(fileId)
            
            self.parent.store.dispatch(.isUploading(true))
            self.parent.store.dispatch(.clearChat)
            self.parent.store.dispatch(.documentId(""))
            
            print("fileRef: \(fileRef)")
            print("storageRef: \(storageRef)")
            
            fileRef.putFile(from: urls.first!, metadata: nil) {
                (_, err) in
                
                if err != nil {
                    print("Error on putFile: \((err?.localizedDescription)!)")
                    
                    self.parent.store.dispatch(.isUploading(false))
                    
                    self.parent.store.dispatch(.addAlertMessage(AlertMessage(customMessage: nil, message: .fileUploadFailed, type: .error)))
                    self.parent.store.dispatch(.isShowingAlert(true))
                    
                    return
                }
                
                self.parent.store.dispatch(.isUploading(false))
                
                self.parent.store.dispatch(.addAlertMessage(AlertMessage(customMessage: nil, message: .fileUploadSuccess, type: .success)))
                self.parent.store.dispatch(.isShowingAlert(true))
            }
            
            print("waiting for 5 seconds before processing")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.parent.store.dispatch(.isProcessing(true))
                
                self.parent.store.dispatch(.addAlertMessage(AlertMessage(customMessage: nil, message: .processingFile, type: .info)))
                self.parent.store.dispatch(.isShowingAlert(true))
                
                
                print("waiting for 10 seconds to process file")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.parent.store.dispatch(.isProcessing(false))
                    
                    fileRef.downloadURL { url, error in
                        if let error = error {
                            print("Error fetching download URL: \(error.localizedDescription)")
                            
                            self.parent.store.dispatch(.addAlertMessage(AlertMessage(customMessage: nil, message: .fileProcessFailed, type: .error)))
                            self.parent.store.dispatch(.isShowingAlert(true))
                        
                            return
                        } else {
                            if let downloadURL = url {
                                self.parent.store.dispatch(.addFileData(FileData(id: fileId, url: downloadURL.absoluteString)))
                                print("Download URL: \(downloadURL.absoluteString)")
                            } else {
                                print("Error: Download URL is nil.")
                            }
                        }
                        
                        self.parent.store.dispatch(.addAlertMessage(AlertMessage(customMessage: nil, message: .fileProcessSuccess, type: .success)))
                        self.parent.store.dispatch(.isShowingAlert(true))
                        self.parent.store.dispatch(.isProcessed(true))
                        
                        print("processing file data: \(self.parent.store.appState.fileData!)")
                        
                        print("completed")
                    }
                }
            }
        }
    }
}
