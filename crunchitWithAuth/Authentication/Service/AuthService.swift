//
//  AuthService.swift
//  crunchitWithAuth
//
//  Created by Ibrohim Abdivokhidov on 24/07/23.
//


import Foundation
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore


class AuthService {
    
    @Published var userSession: FirebaseAuth.User?
    
    static let shared = AuthService()
    
    init() {
        Task { try await laodUserData() }
    }
    
    @MainActor
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            print("User Session: \(self.userSession!)")
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func signUp(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            await uploadUserData(uid: result.user.uid, email: email)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        self.userSession = nil
    }
    
    func laodUserData() async throws {
        self.userSession = Auth.auth().currentUser
        
        guard let currentUserUid = userSession?.uid else { return }
        let snapshot = try await Firestore.firestore().collection("users").document(currentUserUid).getDocument()
        
        if let data = snapshot.data() {
            print("Data: \(data)")
        }
    }
    
    private func uploadUserData(uid: String, email: String) async {
        let user = User(email: email, id: uid)
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
        try? await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
    }
}
