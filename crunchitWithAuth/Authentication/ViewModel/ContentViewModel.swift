//
//  ContentViewModel.swift
//  crunchitWithAuth
//
//  Created by Ibrohim Abdivokhidov on 24/07/23.
//

import Foundation
import Combine
import Firebase

class ContentViewModel: ObservableObject {
    private let service = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var userSession: FirebaseAuth.User?
    
    init() {
        setupSubscribers()
    }
    
    func setupSubscribers() {
        service.$userSession
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userSesson in
                self?.userSession = userSesson
            }
            .store(in: &cancellables)
    }
}
