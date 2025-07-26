//
//  RedditViewModel.swift
//  Artemis
//
//  Created by Javier Munoz on 7/25/25.
//

import Foundation
import SwiftUI
import Observation

@Observable
class RedditViewModel {
    var posts: [RedditPost] = []
    var isLoading = false
    var errorMessage: String?
    
    private let redditClient: RedditClient
    
    init(redditClient: RedditClient) {
        self.redditClient = redditClient
    }
    
    func fetchPopularPosts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            posts = try await redditClient.fetchPopularPosts(limit: 30)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refreshPosts() async {
        await fetchPopularPosts()
    }
} 