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
    var teamId: UUID
    var teamName: String
    var passerIds: [UUID]
    var startTime: Date
    var endTime: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \Rally.session)
    var rallies: [Rally] = []
    
    var trackZone: Bool
    var trackContactType: Bool
    var trackContactLocation: Bool
    var trackServeType: Bool
    var goodPassThreshold: Double  // ← NEW!
    
    init(
        id: UUID = UUID(),
        teamId: UUID,
        teamName: String,
        passerIds: [UUID],
        trackZone: Bool = false,
        trackContactType: Bool = false,
        trackContactLocation: Bool = false,
        trackServeType: Bool = false,
        goodPassThreshold: Double = 2.0  // ← NEW!
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
        self.goodPassThreshold = goodPassThreshold
    }
    
    var rallyCount: Int {
        rallies.count
    }
    
    var teamAverage: Double {
        guard !rallies.isEmpty else { return 0.0 }
        let total = rallies.reduce(0) { $0 + $1.passScore }
        return Double(total) / Double(rallies.count)
    }
    
    // ← UPDATE THIS! Use stored threshold
    var goodPassPercentage: Double {
        guard !rallies.isEmpty else { return 0.0 }
        let goodPasses = rallies.filter { Double($0.passScore) >= goodPassThreshold }.count
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
