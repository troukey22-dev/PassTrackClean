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
    var zoneType: ZoneType
    var goodPassThreshold: Double
    var mascotColor: String = "purple"
    var backgroundColor: String = "#8B5CF6"
    
    // Relationship to players
    @Relationship(deleteRule: .cascade, inverse: \Player.team)
    var players: [Player] = []
    
    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        zoneType: ZoneType = .indoor,
        goodPassThreshold: Double = 2.0,
        mascotColor: String = "purple",
        backgroundColor: String = "#8B5CF6"
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.zoneType = zoneType
        self.goodPassThreshold = goodPassThreshold
        self.mascotColor = mascotColor
        self.backgroundColor = backgroundColor
    }
    
    var activePlayers: [Player] {
        players.filter { $0.isActive }
    }
    
    var playerCount: Int {
        players.count
    }
}

// Zone type
enum ZoneType: String, Codable {
    case indoor = "Indoor (5-6-1)"
    case beach = "Beach (Left-Right)"
    
    var zones: [String] {
        switch self {
        case .indoor:
            return ["5", "6", "1"]
        case .beach:
            return ["Left", "Right"]
        }
    }
}
