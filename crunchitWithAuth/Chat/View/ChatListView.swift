//
//  ChatListView.swift
//  crunchitWithAuth
//
//  Created by Ibrohim Abdivokhidov on 25/07/23.
//

import SwiftUI

struct ChatListView: View {
    
    @StateObject var viewModel: ChatListViewModel
    
    @EnvironmentObject var store: Store
    
    init(user: User) {
        self._viewModel = StateObject(wrappedValue: ChatListViewModel(user: user))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent chats")
                .font(.title3)
                .padding()
            
            if !viewModel.chats.isEmpty {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.chats, id: \.id) {chat in
                            chatListView(chat: chat)
                        }
                    }
                }
                .refreshable {
                    Task { try await viewModel.fetchUserChats() }
                }
                .onAppear {
                    Task { try await viewModel.fetchUserChats() }
                }
            } else {
                Text("You have no chats yet.")
                    .font(.subheadline)
                    .padding()
                    .frame(height: 450)
            }
        }
        .padding()
    }
    
    func chatListView(chat: UserChats) -> some View {
        Button {
            Task {
                store.dispatch(.clearChat)
                
                store.dispatch(.isLoading(true))
                store.dispatch(.initRecentUserChat(chat))
                
                print("\n chat messages: \(store.appState.chatMessages)")
                
                store.dispatch(.isLoading(false))
                store.dispatch(.selectedTab(0))
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
                Text(chat.id)
                    .padding()
                    .background(.gray.opacity(0.1))
                    .cornerRadius(10)
            }
        }
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appState = AppState()
        let reducer = Reducer()
        let store = Store(appState: appState, reducer: reducer)
        
        @StateObject var viewModel = ContentViewModel()
        
        if let email = viewModel.userSession?.email, let id = viewModel.userSession?.uid {
            ChatListView(user: User(email: email, id: id)).environmentObject(store)
        }
    }
}
