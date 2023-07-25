//
//  ChatViewModel.swift
//  crunchitWithAuth
//
//  Created by Ibrohim Abdivokhidov on 24/07/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift


class ChatViewModel: ObservableObject {    
    func createChat(chat: UserChats) async throws {
        try await ChatService().createChat(chat: chat)
    }
    
    func updateChat(chat: ChatMessage, documentId: String) async throws {
        try await ChatService().updateChat(chat: chat, documentId: documentId)
    }
}

