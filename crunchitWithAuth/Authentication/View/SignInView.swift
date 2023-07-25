//
//  SignInView.swift
//  crunchitWithAuth
//
//  Created by Ibrohim Abdivokhidov on 24/07/23.
//

import SwiftUI

struct SignInView: View {
    
    @EnvironmentObject var store: Store
    @StateObject var viewModel = SignInViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                
//                Spacer()
                
                VStack(spacing: 20.0) {
                    Text("Sign In")
                        .font(.title)
                        .padding()
                    
                    TextField("Enter your email", text: $viewModel.email)
                        .padding()
                        .background(.gray.opacity(0.2))
                        .cornerRadius(10)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    
                    SecureField("Enter your password", text: $viewModel.password)
                        .padding()
                        .background(.gray.opacity(0.2))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Button {
                        Task {
                            store.dispatch(.isLoading(true))
                            
                            try await viewModel.signIn()
                            
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
                            Text("Sign In")
                                .foregroundColor(.white)
                                .padding()
                                .background(.black)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(
                        viewModel.email.isEmpty ||
                        viewModel.password.isEmpty ||
                        (store.appState.isLoading == true))
                    
                    Text("or")
                        .foregroundColor(.black)
                    
                    NavigationLink(destination: SignUpView()) {
                        Text("Sign Up")
                            .foregroundColor(.black)
                            .underline()
                    }
                    
//                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .alert(isPresented: $store.appState.alert) {
                Alert(
                    title: Text(store.appState.alertMessage!.type.typeString),
                    message: Text(store.appState.alertMessage!.customMessage == nil ? store.appState.alertMessage!.message!.typeString : store.appState.alertMessage!.customMessage!),
                    dismissButton:
                            .default(Text("Dismiss"))
                )
            }
        }
        .navigationTitle("Sign In")
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
