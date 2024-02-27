//
//  StoredData.swift
//  Trivia App
//
//  Created by Sam Reed on 1/19/24.
//

import Foundation
import SwiftData

@available(iOS 17, *)

@Model
class storedData {
    var hasPlayedDaily: Bool
    var lastPlayedDaily: Date
    
    init(hasPlayedDaily: Bool = false, lastPlayedDaily: Date = .now) {
        self.hasPlayedDaily = hasPlayedDaily
        self.lastPlayedDaily = lastPlayedDaily
    }
}
