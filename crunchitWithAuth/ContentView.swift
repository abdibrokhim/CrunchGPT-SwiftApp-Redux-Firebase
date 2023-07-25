//
//  ContentView.swift
//  crunchitWithAuth
//
//  Created by Ibrohim Abdivokhidov on 24/07/23.
//

import SwiftUI


struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    @StateObject var signUpViewModel = SignUpViewModel()
    @EnvironmentObject var store: Store

    var body: some View {
        TabView(selection: $store.appState.selectedTab) {
            ChatView()
                .tabItem {
                    Image(systemName: "ellipsis.message")
                    Text("Chat")
                }
                .tag(0)

            AuthBridge()
                .tabItem {
                    Image(systemName: "person")
                    Text("Account")
                }
                .tag(1)
        }
        .accentColor(.black)
    }
}

struct AuthBridge: View {
    
    @StateObject var viewModel = ContentViewModel()
    @StateObject var signUpViewModel = SignUpViewModel()

    var body: some View {
        if (viewModel.userSession == nil) {
            SignInView()
        } else {
            if let email = viewModel.userSession?.email, let id = viewModel.userSession?.uid {
                ProfileView(user: User(email: email, id: id))
            }
        }
    }
}

// Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appState = AppState()
        let reducer = Reducer()
        let store = Store(appState: appState, reducer: reducer)
        
        ContentView().environmentObject(store)
    }
}
