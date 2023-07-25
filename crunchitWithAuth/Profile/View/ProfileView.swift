//
//  ProfileView.swift
//  crunchitWithAuth
//
//  Created by Ibrohim Abdivokhidov on 24/07/23.
//

import SwiftUI
import FirebaseFirestore

struct ProfileView: View {
    let user: User
    
    @StateObject var viewModel = ProfileViewModel()
    
    @EnvironmentObject var store: Store
    
    var body: some View {
        VStack {
            Text("Profile")
                .font(.title)
                .padding()
            
            VStack {
                    
                HStack {
                    Text(user.email)
                        .padding()
                        .background(.gray.opacity(0.2))
                        .cornerRadius(10)
                    
                    Button {
                        Task {
                            store.dispatch(.isLoading(true))
                            
                            try await viewModel.signOut()
                            
                            store.dispatch(.initialize)
                            store.dispatch(.isLoading(false))
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
                            Text("Sign Out")
                                .foregroundColor(.white)
                                .padding()
                                .background(.black)
                                .cornerRadius(10)
                        }
                    }
                }
                
                ChatListView(user: user)
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var viewModel = ContentViewModel()
        
        if let email = viewModel.userSession?.email, let id = viewModel.userSession?.uid {
            ProfileView(user: User(email: email, id: id))
        }
    }
}
