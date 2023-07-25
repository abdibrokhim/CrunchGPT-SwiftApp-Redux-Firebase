//
//  ChatService.swift
//  crunchitWithAuth
//
//  Created by Ibrohim Abdivokhidov on 25/07/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift


class ChatService {
    
    func createChat(chat: UserChats) async throws {
        
        let chatRef = Firestore.firestore().collection("chats").document(chat.id)
        
        guard let encodedChat = try? Firestore.Encoder().encode(chat) else { return }
        
        try await chatRef.setData(encodedChat)
    }
    
    func updateChat(chat: ChatMessage, documentId: String) async throws {
        
        print("Document Id: \(documentId)")
        
        let chatRef = Firestore.firestore().collection("chats").document(documentId)
        
        guard let encodedChat = try? Firestore.Encoder().encode(chat) else { return }
        
        try await chatRef.updateData(["chatMessages": FieldValue.arrayUnion([encodedChat])])
    }
    
    func fetchUserChats(uid: String) async throws -> [UserChats] {
        
        let snapshot = try await Firestore.firestore().collection("chats").whereField("uid", isEqualTo: uid).getDocuments()
        
        return try snapshot.documents.compactMap({ try $0.data(as: UserChats.self) })
    }
}
