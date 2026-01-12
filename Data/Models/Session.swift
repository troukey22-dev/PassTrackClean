//
//  Session.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/8/26.
//

import Foundation
import SwiftData

@Model
class Session {
    var id: UUID
    var teamId: UUID  // Store team ID instead of direct reference
    var teamName: String  // Cache team name for easy display
    var passerIds: [UUID]  // Store player IDs
    var startTime: Date
    var endTime: Date?
    
    // Relationship to rallies
    @Relationship(deleteRule: .cascade, inverse: \Rally.session)
    var rallies: [Rally] = []
    
    // Settings snapshot
    var trackZone: Bool
    var trackContactType: Bool
    var trackContactLocation: Bool
    var trackServeType: Bool
    
    init(
        id: UUID = UUID(),
        teamId: UUID,
        teamName: String,
        passerIds: [UUID],
        trackZone: Bool = false,
        trackContactType: Bool = false,
        trackContactLocation: Bool = false,
        trackServeType: Bool = false
    ) {
        self.id = id
        self.teamId = teamId
        self.teamName = teamName
        self.passerIds = passerIds
        self.startTime = Date()
        self.trackZone = trackZone
        self.trackContactType = trackContactType
        self.trackContactLocation = trackContactLocation
        self.trackServeType = trackServeType
    }
    
    var rallyCount: Int {
        rallies.count
    }
    
    var teamAverage: Double {
        guard !rallies.isEmpty else { return 0.0 }
        let total = rallies.reduce(0) { $0 + $1.passScore }
        return Double(total) / Double(rallies.count)
    }
    
    // Good pass = score 2 or 3 (on 0-3 scale)
    var goodPassPercentage: Double {
        guard !rallies.isEmpty else { return 0.0 }
        let goodPasses = rallies.filter { $0.passScore >= 2 }.count
        return (Double(goodPasses) / Double(rallies.count)) * 100
    }
    
    var duration: TimeInterval {
        if let end = endTime {
            return end.timeIntervalSince(startTime)
        } else {
            return Date().timeIntervalSince(startTime)
        }
    }
    
    var durationFormatted: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func complete() {
        endTime = Date()
    }
}
