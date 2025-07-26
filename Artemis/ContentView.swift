//
//  ContentView.swift
//  Artemis
//
//  Created by Javier Munoz on 7/25/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(RedditClient.self) private var redditClient
    @State private var selectedSection: String? = "popular"
    @State private var viewModel: RedditViewModel?
    
    var body: some View {
        NavigationSplitView {
            // Sidebar for iPad/Mac
            List(selection: $selectedSection) {
                Section("Reddit") {
                    NavigationLink("Popular", value: "popular")
                }
            }
            .navigationTitle("Artemis")
        } detail: {
            // Detail view
            Group {
                if let viewModel = viewModel {
                    if viewModel.isLoading && viewModel.posts.isEmpty {
                        loadingView
                    } else if let errorMessage = viewModel.errorMessage {
                        errorView(message: errorMessage)
                    } else {
                        postsList(viewModel: viewModel)
                    }
                } else {
                    loadingView
                }
            }
            .navigationTitle("r/popular")
            .navigationBarTitleDisplayMode(.large)
        }
        .onChange(of: selectedSection) { _, newSection in
            if newSection == "popular" {
                Task {
                    // Initialize view model with the environment RedditClient
                    viewModel = RedditViewModel(redditClient: redditClient)
                    await viewModel?.fetchPopularPosts()
                }
            }
        }
        .task {
            // Initialize with popular posts on first load
            if selectedSection == "popular" {
                viewModel = RedditViewModel(redditClient: redditClient)
                await viewModel?.fetchPopularPosts()
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading posts...")
                .foregroundColor(.secondary)
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                Task {
                    await viewModel?.fetchPopularPosts()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func postsList(viewModel: RedditViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.posts) { post in
                    RedditPostView(post: post)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await viewModel.refreshPosts()
        }
    }
}

#Preview {
    ContentView()
        .environment(RedditClient())
}
