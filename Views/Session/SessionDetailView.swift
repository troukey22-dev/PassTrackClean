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
                sessionSummarySection
                
                // Player Performance
                playerPerformanceSection
                
                // Pass Quality Distribution
                passQualityDistributionSection
                
                // Zone Analysis (if tracked)
                if session.trackZone {
                    zoneAnalysisSection
                }
                
                // Body Contact Heat Map (if tracked)
                if session.trackContactLocation {
                    bodyContactHeatMapSection
                }
                
                // Contact Type Analysis (if tracked)
                if session.trackContactType {
                    contactTypeAnalysisSection
                }
                
                // Serve Type Analysis (if tracked)
                if session.trackServeType {
                    serveTypeAnalysisSection
                }
            }
            .padding()
        }
        .navigationTitle(session.teamName)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            loadPlayerStats()
        }
    }
    
    // MARK: - Session Summary
    private var sessionSummarySection: some View {
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
                
                Text("\(session.startTime, style: .date) at \(session.startTime, style: .time)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
    }
    
    // MARK: - Player Performance
    private var playerPerformanceSection: some View {
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
    
    // MARK: - Pass Quality Distribution (NEW!)
    private var passQualityDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PASS QUALITY DISTRIBUTION")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                ForEach([3, 2, 1, 0], id: \.self) { score in
                    let count = session.rallies.filter { $0.passScore == score }.count
                    let percentage = session.rallyCount > 0 ? Double(count) / Double(session.rallyCount) : 0.0
                    
                    PassQualityBar(
                        score: score,
                        count: count,
                        percentage: percentage
                    )
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
    }
    
    // MARK: - Zone Analysis (NEW!)
    private var zoneAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ZONE ANALYSIS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            ZoneHeatMap(rallies: session.rallies)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
    }
    
    // MARK: - Body Contact Heat Map (NEW!)
    private var bodyContactHeatMapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BODY CONTACT HEAT MAP")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            BodyContactHeatMap(rallies: session.rallies)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
    }
    
    // MARK: - Contact Type Analysis (NEW!)
    private var contactTypeAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CONTACT TYPE ANALYSIS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            ContactTypeAnalysis(rallies: session.rallies)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
    }
    
    // MARK: - Serve Type Analysis (NEW!)
    private var serveTypeAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SERVE TYPE ANALYSIS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            ServeTypeAnalysis(rallies: session.rallies)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
    }
    
    // MARK: - Computed Properties
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

// MARK: - Supporting Data Models

struct PlayerSessionStat: Identifiable {
    let id = UUID()
    let playerId: UUID
    let playerName: String
    let playerNumber: Int
    let passCount: Int
    let average: Double
}

// MARK: - Visualization Components

struct PassQualityBar: View {
    let score: Int
    let count: Int
    let percentage: Double
    
    var body: some View {
        HStack(spacing: 12) {
            Text(scoreLabel)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 80, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                    
                    Rectangle()
                        .fill(scoreColor)
                        .frame(width: geometry.size.width * percentage)
                }
            }
            .frame(height: 24)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            
            Text("\(count)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 40, alignment: .trailing)
            
            Text(String(format: "%.0f%%", percentage * 100))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
    }
    
    private var scoreLabel: String {
        switch score {
        case 3: return "🟢 Perfect"
        case 2: return "🟡 Good"
        case 1: return "🟠 Poor"
        case 0: return "🔴 Ace"
        default: return "Unknown"
        }
    }
    
    private var scoreColor: Color {
        switch score {
        case 3: return .green
        case 2: return .yellow
        case 1: return .orange
        case 0: return .red
        default: return .gray
        }
    }
}

struct ZoneHeatMap: View {
    let rallies: [Rally]
    
    var body: some View {
        VStack(spacing: 16) {
            // Court representation
            VStack(spacing: 8) {
                Text("COURT VIEW")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 8) {
                    ZoneCell(zone: "5", stats: zoneStats("5"))
                    ZoneCell(zone: "6", stats: zoneStats("6"))
                    ZoneCell(zone: "1", stats: zoneStats("1"))
                }
                
                Text("← NET →")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            // Zone breakdown list
            VStack(spacing: 8) {
                ForEach(["6", "5", "1"], id: \.self) { zone in
                    ZoneDetailRow(zone: zone, stats: zoneStats(zone))
                }
            }
        }
    }
    
    private func zoneStats(_ zone: String) -> ZoneStats {
        let zoneRallies = rallies.filter { $0.zone == zone }
        guard !zoneRallies.isEmpty else {
            return ZoneStats(count: 0, average: 0.0, goodPassPercentage: 0.0)
        }
        
        let totalScore = zoneRallies.reduce(0) { $0 + $1.passScore }
        let average = Double(totalScore) / Double(zoneRallies.count)
        let goodPasses = zoneRallies.filter { $0.passScore >= 2 }.count
        let goodPassPercentage = (Double(goodPasses) / Double(zoneRallies.count)) * 100
        
        return ZoneStats(count: zoneRallies.count, average: average, goodPassPercentage: goodPassPercentage)
    }
}

struct ZoneStats {
    let count: Int
    let average: Double
    let goodPassPercentage: Double
}

struct ZoneCell: View {
    let zone: String
    let stats: ZoneStats
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Zone \(zone)")
                .font(.caption)
                .fontWeight(.semibold)
            
            if stats.count > 0 {
                Text(String(format: "%.1f", stats.average))
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(stats.count) passes")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("—")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                Text("No data")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(stats.count > 0 ? zoneColor.opacity(0.2) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(stats.count > 0 ? zoneColor : Color(.systemGray4), lineWidth: 2)
        )
    }
    
    private var zoneColor: Color {
        let avg = stats.average
        if avg >= 2.5 { return .green }
        if avg >= 2.0 { return .yellow }
        if avg >= 1.5 { return .orange }
        return .red
    }
}

struct ZoneDetailRow: View {
    let zone: String
    let stats: ZoneStats
    
    var body: some View {
        HStack {
            Text("Zone \(zone)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 60, alignment: .leading)
            
            if stats.count > 0 {
                Text(String(format: "%.2f avg", stats.average))
                    .font(.subheadline)
                    .frame(width: 80, alignment: .leading)
                
                Text("•")
                    .foregroundStyle(.secondary)
                
                Text("\(stats.count) passes")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(String(format: "%.0f%%", stats.goodPassPercentage))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(performanceColor(stats.average))
            } else {
                Text("No data")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func performanceColor(_ avg: Double) -> Color {
        if avg >= 2.5 { return .green }
        if avg >= 2.0 { return .orange }
        return .red
    }
}

struct BodyContactHeatMap: View {
    let rallies: [Rally]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Where contact was made on body")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            // 3x3 Grid
            VStack(spacing: 8) {
                ForEach(["High", "Waist", "Low"], id: \.self) { row in
                    HStack(spacing: 8) {
                        Text(row.uppercased())
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .frame(width: 50, alignment: .trailing)
                        
                        ForEach(["Left", "Mid", "Right"], id: \.self) { position in
                            BodyContactCell(
                                position: "\(row)-\(position)",
                                stats: bodyContactStats("\(row)-\(position)")
                            )
                        }
                    }
                }
            }
            
            // Legend
            HStack(spacing: 16) {
                LegendItem(color: .green, label: "2.5+")
                LegendItem(color: .yellow, label: "2.0-2.5")
                LegendItem(color: .orange, label: "1.5-2.0")
                LegendItem(color: .red, label: "<1.5")
            }
            .font(.caption2)
        }
    }
    
    private func bodyContactStats(_ position: String) -> BodyContactStats {
        let positionRallies = rallies.filter { $0.contactLocation == position }
        guard !positionRallies.isEmpty else {
            return BodyContactStats(count: 0, average: 0.0)
        }
        
        let totalScore = positionRallies.reduce(0) { $0 + $1.passScore }
        let average = Double(totalScore) / Double(positionRallies.count)
        
        return BodyContactStats(count: positionRallies.count, average: average)
    }
}

struct BodyContactStats {
    let count: Int
    let average: Double
}

struct BodyContactCell: View {
    let position: String
    let stats: BodyContactStats
    
    var body: some View {
        VStack(spacing: 4) {
            if stats.count > 0 {
                Text(String(format: "%.1f", stats.average))
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Text("\(stats.count)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("—")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(stats.count > 0 ? cellColor.opacity(0.3) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(stats.count > 0 ? cellColor : Color(.systemGray4), lineWidth: 2)
        )
    }
    
    private var cellColor: Color {
        let avg = stats.average
        if avg >= 2.5 { return .green }
        if avg >= 2.0 { return .yellow }
        if avg >= 1.5 { return .orange }
        return .red
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
        }
    }
}

struct ContactTypeAnalysis: View {
    let rallies: [Rally]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                ContactTypeCard(
                    type: "Platform",
                    stats: contactTypeStats("Platform")
                )
                
                ContactTypeCard(
                    type: "Hands",
                    stats: contactTypeStats("Hands")
                )
            }
        }
    }
    
    private func contactTypeStats(_ type: String) -> ContactTypeStats {
        let typeRallies = rallies.filter { $0.contactType == type }
        guard !typeRallies.isEmpty else {
            return ContactTypeStats(count: 0, average: 0.0, goodPassPercentage: 0.0)
        }
        
        let totalScore = typeRallies.reduce(0) { $0 + $1.passScore }
        let average = Double(totalScore) / Double(typeRallies.count)
        let goodPasses = typeRallies.filter { $0.passScore >= 2 }.count
        let goodPassPercentage = (Double(goodPasses) / Double(typeRallies.count)) * 100
        
        return ContactTypeStats(count: typeRallies.count, average: average, goodPassPercentage: goodPassPercentage)
    }
}

struct ContactTypeStats {
    let count: Int
    let average: Double
    let goodPassPercentage: Double
}

struct ContactTypeCard: View {
    let type: String
    let stats: ContactTypeStats
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: type == "Platform" ? "hand.raised.fill" : "hand.point.up.left.fill")
                .font(.title2)
                .foregroundStyle(.blue)
            
            Text(type)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            if stats.count > 0 {
                Text(String(format: "%.2f", stats.average))
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("\(stats.count) passes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(String(format: "%.0f%% good", stats.goodPassPercentage))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("No data")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ServeTypeAnalysis: View {
    let rallies: [Rally]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                ServeTypeCard(
                    type: "Float",
                    stats: serveTypeStats("Float")
                )
                
                ServeTypeCard(
                    type: "Spin",
                    stats: serveTypeStats("Spin")
                )
            }
        }
    }
    
    private func serveTypeStats(_ type: String) -> ServeTypeStats {
        let typeRallies = rallies.filter { $0.serveType == type }
        guard !typeRallies.isEmpty else {
            return ServeTypeStats(count: 0, average: 0.0, goodPassPercentage: 0.0)
        }
        
        let totalScore = typeRallies.reduce(0) { $0 + $1.passScore }
        let average = Double(totalScore) / Double(typeRallies.count)
        let goodPasses = typeRallies.filter { $0.passScore >= 2 }.count
        let goodPassPercentage = (Double(goodPasses) / Double(typeRallies.count)) * 100
        
        return ServeTypeStats(count: typeRallies.count, average: average, goodPassPercentage: goodPassPercentage)
    }
}

struct ServeTypeStats {
    let count: Int
    let average: Double
    let goodPassPercentage: Double
}

struct ServeTypeCard: View {
    let type: String
    let stats: ServeTypeStats
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: type == "Float" ? "arrow.up" : "arrow.up.forward")
                .font(.title2)
                .foregroundStyle(.blue)
            
            Text(type)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            if stats.count > 0 {
                Text(String(format: "%.2f", stats.average))
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("\(stats.count) passes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(String(format: "%.0f%% good", stats.goodPassPercentage))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("No data")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
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
