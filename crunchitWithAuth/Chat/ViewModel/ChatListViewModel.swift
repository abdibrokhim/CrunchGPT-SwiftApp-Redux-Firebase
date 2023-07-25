//
//  ChatListViewModel.swift
//  crunchitWithAuth
//
//  Created by Ibrohim Abdivokhidov on 25/07/23.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift


class ChatListViewModel: ObservableObject {
    private let user: User
    @Published var chats = [UserChats]()
    @Published var chatMessages = [ChatMessage]()
    
    init(user: User) {
        self.user = user
        
        Task { try await fetchUserChats() }
    }
    
    @MainActor
    func fetchUserChats() async throws {
        self.chats = try await ChatService().fetchUserChats(uid: user.id)
        
        for i in 0 ..< chats.count {
            chats[i].uid = self.user.id
        }
    }
}
