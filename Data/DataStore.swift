//
//  DataStore.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/8/26.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class DataStore {
    var currentSession: Session?
    var currentSessionPassers: [Player] = []
    var refreshTrigger: Int = 0
    var settings = AppSettings()
    
    // Reference to SwiftData context
    private var modelContext: ModelContext?
    
    init() {
        // Empty init - context will be injected
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Team Management
    
    func createTeam(name: String, players: [Player] = []) {
        guard let context = modelContext else { return }
        
        let team = Team(name: name)
        context.insert(team)
        
        // Add players to team
        for player in players {
            player.team = team
            context.insert(player)
        }
        
        saveContext()
    }
    
    func deleteTeam(_ team: Team) {
            guard let context = modelContext else { return }
            
            // Delete all players in the team (cascade should handle this, but let's be explicit)
            for player in team.players {
                context.delete(player)
            }
            
            // Delete the team
            context.delete(team)
            saveContext()
        }
    
    func addPlayer(to team: Team, player: Player) {
        guard let context = modelContext else { return }
        player.team = team
        context.insert(player)
        saveContext()
    }
    
    func removePlayer(from team: Team, player: Player) {
        guard let context = modelContext else { return }
        context.delete(player)
        saveContext()
    }
    
    // MARK: - Session Management
    
    func startSession(team: Team, passers: [Player], enabledFields: [String: Bool]) {
            guard let _ = modelContext else {
                print("❌ ERROR: No modelContext")
                return
            }
            
            print("🎯 Starting session for team: \(team.name)")
            print("🎯 Passers count: \(passers.count)")
            print("🎯 Passer names: \(passers.map { $0.name })")
            
            // End any existing session first
                if currentSession != nil {
                completeSession()
            }
            
            // Create new session
            let session = Session(
                teamId: team.id,
                teamName: team.name,
                passerIds: passers.map { $0.id },
                trackZone: enabledFields["zone"] ?? false,
                trackContactType: enabledFields["contactType"] ?? false,
                trackContactLocation: enabledFields["contactLocation"] ?? false,
                trackServeType: enabledFields["serveType"] ?? false
            )
            
            currentSession = session
            print("✅ Session created: \(session.teamName)")
            
            // Reset stats for all passers
            passers.forEach { $0.resetStats() }
            
            // IMPORTANT: Store the EXACT same player instances
            currentSessionPassers = passers
            print("✅ Stored \(currentSessionPassers.count) passers in currentSessionPassers")
        }
    
    func logPass(
        player: Player,
        score: Int,
        zone: String? = nil,
        contactType: String? = nil,
        contactLocation: String? = nil,
        serveType: String? = nil
    ) {
        guard let context = modelContext else { return }
        guard (0...3).contains(score) else { return }
        guard let session = currentSession else { return }
        
        let rally = Rally(
            playerId: player.id,
            rallyNumber: session.rallies.count + 1,
            passScore: score,
            zone: zone,
            contactType: contactType,
            contactLocation: contactLocation,
            serveType: serveType
        )
        
        rally.session = session
        context.insert(rally)
        
        // Update player stats (in-memory, not persisted)
        player.passCount += 1
        player.totalScore += score
        refreshTrigger += 1
    }
    
    func undoLastLog() {
            guard let context = modelContext else { return }
            guard let session = currentSession else { return }
            guard let lastRally = session.rallies.last else { return }
            
            // Find the player in currentSessionPassers (the SAME instances used in the UI)
            if let player = currentSessionPassers.first(where: { $0.id == lastRally.playerId }) {
                player.passCount -= 1
                player.totalScore -= lastRally.passScore
                refreshTrigger += 1
            }
            
            // Remove the rally
            context.delete(lastRally)
        }
    
    func completeSession() {
        guard let context = modelContext else { return }
        guard let session = currentSession else { return }
        
        // Mark session as complete
        session.complete()
        
        // Save session to SwiftData
        context.insert(session)
        saveContext()
        
        // Clear current session
                currentSession = nil
                currentSessionPassers = []
            }
    
    // MARK: - Fetch Methods
    
    func fetchAllTeams() -> [Team] {
        guard let context = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<Team>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch teams: \(error)")
            return []
        }
    }
    
    func fetchTeam(byId id: UUID) -> Team? {
        guard let context = modelContext else { return nil }
        
        let descriptor = FetchDescriptor<Team>(
            predicate: #Predicate { $0.id == id }
        )
        
        do {
            return try context.fetch(descriptor).first
        } catch {
            print("Failed to fetch team: \(error)")
            return nil
        }
    }
    
    func fetchAllSessions() -> [Session] {
        guard let context = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<Session>(
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch sessions: \(error)")
            return []
        }
    }
    
    func fetchSessions(forTeamId teamId: UUID) -> [Session] {
        guard let context = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<Session>(
            predicate: #Predicate { $0.teamId == teamId },
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch sessions: \(error)")
            return []
        }
    }
    
    func getPassers(for session: Session) -> [Player] {
            guard let context = modelContext else { return [] }
            guard let team = fetchTeam(byId: session.teamId) else { return [] }
            
            return team.players.filter { player in
                session.passerIds.contains(player.id)
            }
        }
    
    // MARK: - Demo Data
            
        func loadDemoData() {
            guard let context = modelContext else { return }
            
            // Check if demo team already exists
            let existingTeams = fetchAllTeams()
            if !existingTeams.isEmpty {
                return  // Demo data already loaded
            }
            
            let demoTeam = Team(name: "Demo Varsity Team")
            context.insert(demoTeam)
            
            let players = [
                Player(name: "Tyler", number: 4, position: "Libero"),
                Player(name: "Sam", number: 2, position: "OH"),
                Player(name: "Max", number: 10, position: "DS"),
                Player(name: "Tymo", number: 7, position: "OH"),
                Player(name: "Rat", number: 5, position: "MB", isActive: false),
                Player(name: "Jon", number: 8, position: "MB", isActive: false)
            ]
            
            for player in players {
                player.team = demoTeam
                demoTeam.players.append(player)
                context.insert(player)
            }
            
            saveContext()
        }
    // MARK: - Private Helpers
    
    private func saveContext() {
        guard let context = modelContext else { return }
        
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
