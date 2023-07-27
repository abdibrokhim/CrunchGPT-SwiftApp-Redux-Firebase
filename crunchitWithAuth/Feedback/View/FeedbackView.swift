//
//  FeedbackView.swift
//  crunchitWithAuth
//
//  Created by Ibrohim Abdivokhidov on 28/07/23.
//

import SwiftUI

struct FeedbackView: View {
    
    @StateObject var viewModel: FeedbackViewModel
    
    @EnvironmentObject var store: Store
    
    init(user: User) {
        self._viewModel = StateObject(wrappedValue: FeedbackViewModel(user: user))
    }
    
    var body: some View {
        HStack {
            TextField("Enter your feedback", text: $viewModel.message)
                .padding()
                .background(.gray.opacity(0.1))
                .cornerRadius(10)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            
            Spacer()
            
            Button {
                Task {
                    store.dispatch(.isLoading(true))
                    
                    try await viewModel.createFeedback()
                    viewModel.clearMessage()
                    
                    store.dispatch(.isLoading(false))
                    
                    store.dispatch(.addAlertMessage(AlertMessage(customMessage: nil, message: .feedbackSuccess, type: .success)))
                    store.dispatch(.isShowingAlert(true))
                }
            } label: {
                if (store.appState.isLoading == true) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .padding()
                        .scaleEffect(1)
                        .background(.black)
                        .cornerRadius(10)
                } else {
                    Text("Send")
                        .foregroundColor(.white)
                        .padding()
                        .background(.black)
                        .cornerRadius(10)
                }
            }
            
            Spacer()
        }
        .padding()
        .alert(isPresented: $store.appState.alert) {
            Alert(
                title: Text(store.appState.alertMessage!.type.typeString),
                message: Text(store.appState.alertMessage!.message!.typeString),
                dismissButton:
                        .default(Text("Dismiss"))
            )
        }
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appState = AppState()
        let reducer = Reducer()
        let store = Store(appState: appState, reducer: reducer)
        
        @StateObject var viewModel = ContentViewModel()
        
        if let email = viewModel.userSession?.email, let id = viewModel.userSession?.uid {
            FeedbackView(user: User(email: email, id: id)).environmentObject(store)
        }
    }
}
