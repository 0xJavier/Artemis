//
//  RedditMediaView.swift
//  Artemis
//
//  Created by Javier Munoz on 7/25/25.
//

import SwiftUI
import AVKit

struct RedditMediaView: View {
    let post: RedditPost
    
    var body: some View {
        Group {
            if post.hasVideo {
                videoView
            } else if post.hasImage {
                imageView
            } else {
                EmptyView()
            }
        }
    }
    
    private var imageView: some View {
        Group {
            if let imageURL = post.imageURL {
                let processedURL = processImageURL(imageURL)
                
                AsyncImage(url: processedURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .clipped()
                    case .failure:
                        VStack {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("Failed to load image")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 200)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private func processImageURL(_ urlString: String) -> URL? {
        // Handle common Reddit image URL issues
        var processedURL = urlString
        
        // Fix common Reddit image URL patterns
        if processedURL.contains("&amp;") {
            processedURL = processedURL.replacingOccurrences(of: "&amp;", with: "&")
        }
        
        // Handle relative URLs
        if processedURL.hasPrefix("//") {
            processedURL = "https:" + processedURL
        }
        
        // URL encode if needed
        if let encodedURL = processedURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            processedURL = encodedURL
        }
        
        return URL(string: processedURL)
    }
    
    private var videoView: some View {
        Group {
            if let videoURL = post.videoURL, let url = URL(string: videoURL) {
                RedditVideoPlayer(url: url)
                    .frame(height: 300)
                    .clipped()
                    .cornerRadius(8)
            } else {
                VStack {
                    Image(systemName: "video")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Video not available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
            }
        }
    }
}

#Preview {
    RedditMediaView(post: RedditPost(
        id: "1",
        title: "Sample post",
        author: "user",
        subreddit: "swift",
        score: 100,
        numComments: 10,
        created: Date().timeIntervalSince1970,
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
