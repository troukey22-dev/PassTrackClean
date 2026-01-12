//
//  SessionDetailView.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/12/26.
//

import SwiftUI
import SwiftData

struct SessionDetailView: View {
    @Environment(DataStore.self) private var dataStore
    let session: Session
    @State private var passers: [Player] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Session Summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("SESSION SUMMARY")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Passes")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("\(session.rallyCount)")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Team Average")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(String(format: "%.2f", session.teamAverage))
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Duration")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(session.durationFormatted)
                                    .font(.headline)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Good Pass %")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(String(format: "%.0f%%", session.goodPassPercentage))
                                    .font(.headline)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Player Performance
                VStack(alignment: .leading, spacing: 12) {
                    Text("PLAYER PERFORMANCE")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    ForEach(playerStats.sorted(by: { $0.average > $1.average })) { stat in
                        PlayerPerformanceRow(stat: stat)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(session.teamName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPlayerStats()
        }
    }
    
    private var playerStats: [PlayerSessionStat] {
        var stats: [PlayerSessionStat] = []
        
        for playerId in session.passerIds {
            let playerRallies = session.rallies.filter { $0.playerId == playerId }
            if !playerRallies.isEmpty {
                let totalScore = playerRallies.reduce(0) { $0 + $1.passScore }
                let average = Double(totalScore) / Double(playerRallies.count)
                
                // Get player name from team
                if let team = dataStore.fetchTeam(byId: session.teamId),
                   let player = team.players.first(where: { $0.id == playerId }) {
                    stats.append(PlayerSessionStat(
                        playerId: playerId,
                        playerName: player.name,
                        playerNumber: player.number,
                        passCount: playerRallies.count,
                        average: average
                    ))
                }
            }
        }
        
        return stats
    }
    
    private func loadPlayerStats() {
        passers = dataStore.getPassers(for: session)
    }
}

struct PlayerSessionStat: Identifiable {
    let id = UUID()
    let playerId: UUID
    let playerName: String
    let playerNumber: Int
    let passCount: Int
    let average: Double
}

struct PlayerPerformanceRow: View {
    let stat: PlayerSessionStat
    
    var body: some View {
        HStack {
            Text("#\(stat.playerNumber)")
                .font(.headline)
                .foregroundStyle(.blue)
                .frame(width: 40, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(stat.playerName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(stat.passCount) passes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(String(format: "%.2f", stat.average))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(averageColor(stat.average))
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func averageColor(_ avg: Double) -> Color {
        if avg >= 2.5 { return .green }
        if avg >= 2.0 { return .orange }
        if avg >= 1.5 { return .red }
        return .secondary
    }
}
