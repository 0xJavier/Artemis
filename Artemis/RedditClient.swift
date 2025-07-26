//
//  RedditClient.swift
//  Artemis
//
//  Created by Javier Munoz on 7/25/25.
//

import Foundation
import Observation

// MARK: - Models

struct RedditPost: Codable, Identifiable {
    let id: String
    let title: String
    let author: String
    let subreddit: String
    let score: Int
    let numComments: Int
    let created: TimeInterval
    let url: String
    let permalink: String
    let thumbnail: String?
    let isVideo: Bool
    let isSelf: Bool
    let selftext: String?
    let preview: RedditPreview?
    let media: RedditMedia?
    let secureMedia: RedditMedia?
    let postHint: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case author
        case subreddit
        case score
        case numComments = "num_comments"
        case created
        case url
        case permalink
        case thumbnail
        case isVideo = "is_video"
        case isSelf = "is_self"
        case selftext
        case preview
        case media
        case secureMedia = "secure_media"
        case postHint = "post_hint"
    }
    
    // Computed properties for easier access to media
    var hasImage: Bool {
        if let preview = preview, !preview.images.isEmpty {
            return true
        }
        if let postHint = postHint, postHint == "image" {
            return true
        }
        return false
    }
    
    var hasVideo: Bool {
        return isVideo || media?.redditVideo != nil || secureMedia?.redditVideo != nil
    }
    
    var imageURL: String? {
        if let preview = preview, let firstImage = preview.images.first {
            return firstImage.source.url
        }
        if let postHint = postHint, postHint == "image" {
            return url
        }
        return nil
    }
    
    var videoURL: String? {
        if let media = media, let video = media.redditVideo {
            return video.fallbackURL
        }
        if let secureMedia = secureMedia, let video = secureMedia.redditVideo {
            return video.fallbackURL
        }
        return nil
    }
}

struct RedditPreview: Codable {
    let images: [RedditPreviewImage]
}

struct RedditPreviewImage: Codable {
    let source: RedditPreviewSource
    let resolutions: [RedditPreviewSource]
}

struct RedditPreviewSource: Codable {
    let url: String
    let width: Int
    let height: Int
}

struct RedditMedia: Codable {
    let redditVideo: RedditVideo?
    
    enum CodingKeys: String, CodingKey {
        case redditVideo = "reddit_video"
    }
}

struct RedditVideo: Codable {
    let fallbackURL: String
    let height: Int
    let width: Int
    let duration: Int
    let isGif: Bool
    
    enum CodingKeys: String, CodingKey {
        case fallbackURL = "fallback_url"
        case height
        case width
        case duration
        case isGif = "is_gif"
    }
}

struct RedditListing: Codable {
    let data: RedditListingData
}

struct RedditListingData: Codable {
    let children: [RedditPostWrapper]
    let after: String?
    let before: String?
}

struct RedditPostWrapper: Codable {
    let data: RedditPost
}

struct RedditResponse: Codable {
    let data: RedditListingData
}

// MARK: - RedditClient

@Observable
class RedditClient {
    private let baseURL = "https://www.reddit.com"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchPopularPosts(limit: Int = 30) async throws -> [RedditPost] {
        let urlString = "\(baseURL)/r/popular.json?limit=\(limit)"
        
        guard let url = URL(string: urlString) else {
            throw RedditError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw RedditError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw RedditError.httpError(statusCode: httpResponse.statusCode)
            }
            
            let redditResponse = try JSONDecoder().decode(RedditResponse.self, from: data)
            return redditResponse.data.children.map { $0.data }
            
        } catch let decodingError as DecodingError {
            throw RedditError.decodingError(decodingError)
        } catch {
            throw RedditError.networkError(error)
        }
    }
}

// MARK: - Errors

enum RedditError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(DecodingError)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
} 