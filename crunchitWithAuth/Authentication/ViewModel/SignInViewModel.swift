//
//  SignInViewModel.swift
//  crunchitWithAuth
//
//  Created by Ibrohim Abdivokhidov on 24/07/23.
//

import Foundation

class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func signIn() async throws {
        try await AuthService.shared.signIn(withEmail: email, password: password)
    }
}

