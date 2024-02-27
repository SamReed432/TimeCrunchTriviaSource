//
//  ContentView.swift
//  Trivia App
//
//  Created by Sam Reed on 12/25/23.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

struct ContentView: View {

    var body: some View {
        
        VStack {
            GeometryReader { g in
                HomeView(
                    store: Store(initialState: HomeViewModel.State()) {
                        HomeViewModel()
                    }
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
