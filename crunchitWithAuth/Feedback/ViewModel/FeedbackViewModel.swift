//
//  FeedbackViewModel.swift
//  crunchitWithAuth
//
//  Created by Ibrohim Abdivokhidov on 28/07/23.
//

import Foundation

class FeedbackViewModel: ObservableObject {
    private let user: User
    @Published var message = ""
    
    init(user: User) {
        self.user = user
    }
    
    func clearMessage() {
        self.message = ""
    }
    
    func createFeedback() async throws {
        let feedback = Feedback(id: UUID().uuidString, message: message, user: user, dateCreated: Date())
        
        try await FeedbackService.shared.createFeedback(feedback: feedback)
    }
}
