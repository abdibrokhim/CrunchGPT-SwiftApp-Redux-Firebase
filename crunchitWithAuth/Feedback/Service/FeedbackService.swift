//
//  FeedbackService.swift
//  crunchitWithAuth
//
//  Created by Ibrohim Abdivokhidov on 28/07/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore


class FeedbackService {
    
    static let shared = FeedbackService()
    
    func createFeedback(feedback: Feedback) async throws {
        
        let feedbackRef = Firestore.firestore().collection("feedbacks").document(feedback.id)
        
        guard let encodedFeedback = try? Firestore.Encoder().encode(feedback) else { return }
        
        try await feedbackRef.setData(encodedFeedback)
    }
}
