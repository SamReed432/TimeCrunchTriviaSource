//
//  Trivia_AppApp.swift
//  Trivia App
//
//  Created by Sam Reed on 12/25/23.
//

import SwiftUI
import ComposableArchitecture
import GoogleMobileAds

@main
struct Trivia_AppApp: App {
    
    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
