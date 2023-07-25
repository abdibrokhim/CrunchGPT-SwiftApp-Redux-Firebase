//
//  store.swift
//  crunchitWithAuth
//
//  Created by Ibrohim Abdivokhidov on 24/07/23.
//


import Foundation


struct AppState {
    var isUploading: Bool = false
    var isProcessing: Bool = false
    var alert: Bool = false
    var chatMessages: [ChatMessage] = []
    var fileData: FileData?
    var alertMessage: AlertMessage?
    var isProcessed: Bool = false
    var isLoading: Bool = false
    var selectedTab: Int = 0
    var documentId: String = ""
}

enum Action {
    case isUploading(Bool)
    case isProcessing(Bool)
    case isShowingAlert(Bool)
    case addFileData(FileData)
    case addAlertMessage(AlertMessage)
    case isProcessed(Bool)
    case addChatMessage(ChatMessage)
    case clearChat
    case isLoading(Bool)
    case selectedTab(Int)
    case documentId(String)
    case initialize
    case initRecentUserChat(UserChats)
}

class Reducer {
    func update(_ appState: inout AppState, _ action: Action) {
        switch (action) {
        case let .isUploading(isUploading):
            appState.isUploading = isUploading
        case let .isProcessing(isProcessing):
            appState.isProcessing = isProcessing
        case let .isShowingAlert(isShowingAlert):
            appState.alert = isShowingAlert
        case let .addFileData(fileData):
            appState.fileData = fileData
        case let .addAlertMessage(alertMessage):
            appState.alertMessage = alertMessage
        case let .isProcessed(isProcessed):
            appState.isProcessed = isProcessed
        case let .addChatMessage(ChatMessage):
            appState.chatMessages.append(ChatMessage)
        case .clearChat:
            appState.chatMessages = []
        case let .isLoading(isLoading):
            appState.isLoading = isLoading
        case let .selectedTab(selectedTab):
            appState.selectedTab = selectedTab
        case let .documentId(documentId):
            appState.documentId = documentId
        case .initialize:
            appState = AppState(selectedTab: 1)
        case let .initRecentUserChat(UserChats):
            appState.documentId = UserChats.id
            appState.chatMessages = UserChats.chatMessages
            appState.fileData = UserChats.fileData
            appState.isProcessed = true
        }
    }
}


class Store: ObservableObject {
    
    var reducer: Reducer
    @Published var appState: AppState
    
    init(appState: AppState, reducer: Reducer) {
        self.appState = appState
        self.reducer = reducer
    }
    
    func dispatch(_ action: Action) {
        DispatchQueue.main.async {
            self.reducer.update(&self.appState, action)
        }
    }
}


