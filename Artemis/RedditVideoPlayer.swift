//
//  RedditVideoPlayer.swift
//  Artemis
//
//  Created by Javier Munoz on 7/25/25.
//

import SwiftUI
import AVKit

struct RedditVideoPlayer: View {
    let url: URL
    @State private var player: AVPlayer?
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .clipped()
            } else {
                ProgressView()
                    .frame(height: 300)
            }
        }
        .frame(height: 300)
        .onAppear {
            setupPlayer()
            isVisible = true
        }
        .onDisappear {
            isVisible = false
            pausePlayer()
        }
    }
    
    private func setupPlayer() {
        // Create player with the video URL
        let newPlayer = AVPlayer(url: url)
        
        // Configure player for auto-play
        newPlayer.automaticallyWaitsToMinimizeStalling = false
        
        // Set up looping
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: newPlayer.currentItem,
            queue: .main
        ) { _ in
            newPlayer.seek(to: .zero)
            newPlayer.play()
        }
        
        self.player = newPlayer
        
        // Start playing when player is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if isVisible {
                newPlayer.play()
            }
        }
    }
    
    private func pausePlayer() {
        player?.pause()
    }
}

#Preview {
    RedditVideoPlayer(url: URL(string: "https://example.com/video.mp4")!)
} 