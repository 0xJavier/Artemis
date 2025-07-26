//
//  RedditPostView.swift
//  Artemis
//
//  Created by Javier Munoz on 7/25/25.
//

import SwiftUI

struct RedditPostView: View {
    let post: RedditPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Subreddit and author info
            HStack {
                Text("r/\(post.subreddit)")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .fontWeight(.medium)
                
                Text("•")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("u/\(post.author)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(timeAgoString(from: post.created))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Title
            Text(post.title)
                .font(.headline)
                .lineLimit(3)
                .foregroundColor(.primary)
            
            // Media content (images/videos)
            if post.hasImage || post.hasVideo {
                RedditMediaView(post: post)
            }
            
            // Score and comments
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("\(post.score)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "bubble.left")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("\(post.numComments)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func timeAgoString(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        let minutes = Int(timeInterval / 60)
        let hours = Int(timeInterval / 3600)
        let days = Int(timeInterval / 86400)
        
        if days > 0 {
            return "\(days)d"
        } else if hours > 0 {
            return "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "now"
        }
    }
}

#Preview {
    RedditPostView(post: RedditPost(
        id: "1",
        title: "This is a sample Reddit post title that might be longer than one line",
        author: "sample_user",
        subreddit: "swift",
        score: 1234,
        numComments: 56,
        created: Date().timeIntervalSince1970 - 3600,
        url: "https://example.com",
        permalink: "/r/swift/comments/1",
        thumbnail: nil,
        isVideo: false,
        isSelf: false,
        selftext: nil,
        preview: RedditPreview(images: [
            RedditPreviewImage(
                source: RedditPreviewSource(url: "https://picsum.photos/400/300", width: 400, height: 300),
                resolutions: []
            )
        ]),
        media: nil,
        secureMedia: nil,
        postHint: "image"
    ))
    .padding()
} 
