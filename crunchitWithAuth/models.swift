//
//  models.swift
//  crunchitWithAuth
//
//  Created by Ibrohim Abdivokhidov on 24/07/23.
//


import Foundation


// User with Chats model
struct UserChats: Identifiable, Codable {
    let id: String
    var uid: String
    let chatMessages: [ChatMessage]
    let fileData: FileData
}

// User model
struct User: Identifiable, Hashable, Codable {
    let email: String
    let id: String
}

// Chat model
struct ChatMessage: Identifiable, Codable {
    let id: String
    let content: String
    let dateCreated: Date
    let sender: MessageSender
}

enum MessageSender: String, Codable {
    case user
    case agent
}


// Alert model
struct AlertMessage {
    let customMessage: String?
    let message: AppError?
    let type: AlertType
}

enum AppError {
    case fileUploadSuccess
    case fileUploadFailed
    case processingFile
    case fileProcessSuccess
    case fileProcessFailed
    case somethingWentWrong
    case signUpSuccess
    case signInSuccess
    case feedbackSuccess
}

extension AppError {
    var typeString: String {
        switch self {
        case .fileUploadSuccess:
            return "File uploaded successfully!"
        case .fileUploadFailed:
            return "File upload failed!"
        case .processingFile:
            return "Processing file..."
        case .fileProcessSuccess:
            return "File processed successfully!"
        case .fileProcessFailed:
            return "File process failed!"
        case .somethingWentWrong:
            return "Something went wrong!"
        case .signInSuccess:
            return "Signed In successfully!"
        case .signUpSuccess:
            return "Signed Up successfully!"
        case .feedbackSuccess:
            return "Feedback sent successfully!"
        }
    }
}

enum AlertType {
    case error
    case success
    case info
}

extension AlertType {
    var typeString: String {
        switch self {
        case .error:
            return "Error"
        case .success:
            return "Success"
        case .info:
            return "Info"
        }
    }
}


// File model
struct FileData: Identifiable, Codable {
    let id: String?
    let url: String?
}

// Feedback model
struct Feedback: Identifiable, Codable {
    let id: String
    let message: String
    let user: User
    let dateCreated: Date
}
