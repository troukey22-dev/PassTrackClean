//
//  Rally.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/8/26.
//

import Foundation
import SwiftData

@Model
class Rally {
    var id: UUID
    var playerId: UUID  // Track which player made this pass
    var rallyNumber: Int  // Track order of passes
    var passScore: Int
    var zone: String?
    var contactType: String?
    var contactLocation: String?
    var serveType: String?
    var timestamp: Date
    
    // Relationship to session
    var session: Session?
    
    init(
        id: UUID = UUID(),
        playerId: UUID,
        rallyNumber: Int,
        passScore: Int,
        zone: String? = nil,
        contactType: String? = nil,
        contactLocation: String? = nil,
        serveType: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.playerId = playerId
        self.rallyNumber = rallyNumber
        self.passScore = passScore
        self.zone = zone
        self.contactType = contactType
        self.contactLocation = contactLocation
        self.serveType = serveType
        self.timestamp = timestamp
    }
}
