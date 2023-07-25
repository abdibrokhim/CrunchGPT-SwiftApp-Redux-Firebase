//
//  ProfileViewModel.swift
//  crunchitWithAuth
//
//  Created by Ibrohim Abdivokhidov on 24/07/23.
//

import Foundation

class ProfileViewModel: ObservableObject {
    func signOut() async throws {
        AuthService.shared.signOut()
    }
}
