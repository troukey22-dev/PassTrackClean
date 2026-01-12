//
//  Player.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/8/26.
//

import Foundation
import SwiftData

@Model
class Player {
    var id: UUID
    var name: String
    var number: Int
    var position: String?
    var isActive: Bool
    
    // Relationship to team
    var team: Team?
    
    // Session stats (reset each session, not persisted long-term)
    @Transient var passCount: Int = 0
    @Transient var totalScore: Int = 0
    
    init(
        id: UUID = UUID(),
        name: String,
        number: Int,
        position: String? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.number = number
        self.position = position
        self.isActive = isActive
    }
    
    // Calculate average on 0-3 scale
    var average: Double {
        guard passCount > 0 else { return 0.0 }
        return Double(totalScore) / Double(passCount)
    }
    
    func resetStats() {
        passCount = 0
        totalScore = 0
    }
}
