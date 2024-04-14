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
        .background(Image("Background Image").resizable().scaledToFill().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    ContentView()
}
