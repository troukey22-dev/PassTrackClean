//
//  Team.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/8/26.
//

import Foundation
import SwiftData

@Model
class Team {
    var id: UUID
    var name: String
    var createdAt: Date
    
    // Relationship to players
    @Relationship(deleteRule: .cascade, inverse: \Player.team)
    var players: [Player] = []
    
    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }
    
    var activePlayers: [Player] {
        players.filter { $0.isActive }
    }
    
    var playerCount: Int {
        players.count
    }
}
