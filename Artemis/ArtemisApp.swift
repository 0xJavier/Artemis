//
//  ArtemisApp.swift
//  Artemis
//
//  Created by Javier Munoz on 7/25/25.
//

import SwiftUI

@main
struct ArtemisApp: App {
    @State private var redditClient = RedditClient()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(redditClient)
        }
    }
}
