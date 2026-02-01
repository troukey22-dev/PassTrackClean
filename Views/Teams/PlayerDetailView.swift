//
//  PlayerDetailView.swift
//  PassTrackClean
//

import SwiftUI
import SwiftData
import Charts

struct PlayerDetailView: View {
    let player: Player
    let team: Team
    @Query private var allRallies: [Rally]
    @Query private var allSessions: [Session]
    
    private var teamSessions: [Session] {
        allSessions.filter { $0.teamId == team.id }.sorted { $0.startTime > $1.startTime }
    }
    
    private var playerRallies: [Rally] {
        let sessionIds = teamSessions.map { $0.id }
        return allRallies.filter { rally in
            if let rallySession = rally.session {
                return sessionIds.contains(rallySession.id) && rally.playerId == player.id
            }
            return false
        }
    }
    
    private var playerStats: PlayerOverallStats {
        guard !playerRallies.isEmpty else {
            return PlayerOverallStats(totalPasses: 0, average: 0.0, goodPassPercentage: 0.0, perfectPassPercentage: 0.0, sessionsPlayed: 0)
        }
        
        let totalScore = playerRallies.reduce(0) { $0 + $1.passScore }
        let average = Double(totalScore) / Double(playerRallies.count)
        let goodPasses = playerRallies.filter { $0.passScore >= 2 }.count
        let perfectPasses = playerRallies.filter { $0.passScore == 3 }.count
        let goodPassPercentage = (Double(goodPasses) / Double(playerRallies.count)) * 100
        let perfectPassPercentage = (Double(perfectPasses) / Double(playerRallies.count)) * 100
        
        let sessionsWithPasses = Set(playerRallies.compactMap { $0.session?.id }).count
        
        return PlayerOverallStats(
            totalPasses: playerRallies.count,
            average: average,
            goodPassPercentage: goodPassPercentage,
            perfectPassPercentage: perfectPassPercentage,
            sessionsPlayed: sessionsWithPasses
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Player Header Card
                playerHeaderCard
                
                // Overall Stats
                overallStatsSection
                
                // Performance Trend
                performanceTrendSection
                
                // Zone Analysis (aggregate)
                zoneAnalysisSection
                
                // Body Contact Heat Map (aggregate)
                bodyContactSection
                
                // Pass Quality Distribution
                passQualitySection
                
                // Recent Sessions
                recentSessionsSection
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(player.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Player Header Card
    private var playerHeaderCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Circle()
                    .fill(Color(hex: team.backgroundColor))
                    .frame(width: 70, height: 70)
                    .overlay {
                        Text(playerInitials)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let position = player.position {
                        Text("#\(player.number) · \(position)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("#\(player.number)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(team.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
        .padding(.horizontal)
    }
    
    private var playerInitials: String {
        let names = player.name.split(separator: " ")
        if names.count >= 2 {
            let first = names[0].prefix(1)
            let last = names[1].prefix(1)
            return "\(first)\(last)".uppercased()
        } else if let first = names.first {
            return String(first.prefix(2)).uppercased()
        }
        return "?"
    }
    
    // MARK: - Overall Stats Section
    private var overallStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CAREER STATS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                TeamPlayerStatCard(title: "Sessions", value: "\(playerStats.sessionsPlayed)", icon: "calendar", color: .purple)
                TeamPlayerStatCard(title: "Total Passes", value: "\(playerStats.totalPasses)", icon: "arrow.up.circle.fill", color: .blue)
                TeamPlayerStatCard(title: "Average", value: String(format: "%.2f", playerStats.average), icon: "chart.line.uptrend.xyaxis", color: .green)
                TeamPlayerStatCard(title: "Good Pass %", value: String(format: "%.0f%%", playerStats.goodPassPercentage), icon: "checkmark.circle.fill", color: .orange)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Performance Trend Section
    private var performanceTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PERFORMANCE TREND")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            if !sessionTrendData.isEmpty {
                VStack(spacing: 12) {
                    Chart(sessionTrendData) { dataPoint in
                        // Colored background bands
                        RectangleMark(
                            xStart: .value("Start", sessionTrendData.first?.date ?? Date()),
                            xEnd: .value("End", sessionTrendData.last?.date ?? Date()),
                            yStart: .value("Y Start", 2.5),
                            yEnd: .value("Y End", 3.0)
                        )
                        .foregroundStyle(Color.green.opacity(0.2))
                        
                        RectangleMark(
                            xStart: .value("Start", sessionTrendData.first?.date ?? Date()),
                            xEnd: .value("End", sessionTrendData.last?.date ?? Date()),
                            yStart: .value("Y Start", 2.0),
                            yEnd: .value("Y End", 2.5)
                        )
                        .foregroundStyle(Color.yellow.opacity(0.2))
                        
                        RectangleMark(
                            xStart: .value("Start", sessionTrendData.first?.date ?? Date()),
                            xEnd: .value("End", sessionTrendData.last?.date ?? Date()),
                            yStart: .value("Y Start", 1.5),
                            yEnd: .value("Y End", 2.0)
                        )
                        .foregroundStyle(Color.orange.opacity(0.2))
                        
                        RectangleMark(
                            xStart: .value("Start", sessionTrendData.first?.date ?? Date()),
                            xEnd: .value("End", sessionTrendData.last?.date ?? Date()),
                            yStart: .value("Y Start", 0.0),
                            yEnd: .value("Y End", 1.5)
                        )
                        .foregroundStyle(Color.red.opacity(0.2))
                        
                        LineMark(
                            x: .value("Session", dataPoint.date),
                            y: .value("Average", dataPoint.average)
                        )
                        .foregroundStyle(Color.appPurple)
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Session", dataPoint.date),
                            y: .value("Average", dataPoint.average)
                        )
                        .foregroundStyle(Color.appPurple)
                    }
                    .chartYScale(domain: 0...3)
                    .chartYAxis {
                        AxisMarks(position: .leading, values: [0.0, 1.0, 2.0, 3.0])
                    }
                    .frame(height: 200)
                    .padding()
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                .padding(.horizontal)
            } else {
                Text("No performance data available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
            }
        }
    }
    
    private var sessionTrendData: [SessionTrendPoint] {
        teamSessions.prefix(10).reversed().compactMap { session in
            let sessionRallies = playerRallies.filter { rally in
                rally.session?.id == session.id
            }
            guard !sessionRallies.isEmpty else { return nil }
            
            let totalScore = sessionRallies.reduce(0) { $0 + $1.passScore }
            let avg = Double(totalScore) / Double(sessionRallies.count)
            
            return SessionTrendPoint(id: session.id, date: session.startTime, average: avg)
        }
    }
    
    // MARK: - Zone Analysis Section
    private var zoneAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ZONE PERFORMANCE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(["1", "6", "5"], id: \.self) { zone in
                    let zoneRallies = playerRallies.filter { $0.zone == zone }
                    let stats = calculateZoneStats(for: zoneRallies)
                    ZoneCell(zone: zone, stats: stats)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Body Contact Section
    private var bodyContactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BODY CONTACT HEAT MAP")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                Text("Where contact was made on body")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
                
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
                                let positionRallies = playerRallies.filter { $0.contactLocation == "\(row)-\(position)" }
                                let stats = bodyContactStats(for: positionRallies)
                                BodyContactCell(position: "\(row)-\(position)", stats: stats)
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
                .padding(.top, 8)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            .padding(.horizontal)
        }
    }
    
    private func bodyContactStats(for positionRallies: [Rally]) -> BodyContactStats {
        guard !positionRallies.isEmpty else {
            return BodyContactStats(count: 0, average: 0.0)
        }
        
        let totalScore = positionRallies.reduce(0) { $0 + $1.passScore }
        let average = Double(totalScore) / Double(positionRallies.count)
        
        return BodyContactStats(count: positionRallies.count, average: average)
    }
    
    // MARK: - Pass Quality Section
    private var passQualitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PASS QUALITY DISTRIBUTION")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                TeamPassQualityRow(score: 3, count: playerRallies.filter { $0.passScore == 3 }.count, total: playerRallies.count)
                TeamPassQualityRow(score: 2, count: playerRallies.filter { $0.passScore == 2 }.count, total: playerRallies.count)
                TeamPassQualityRow(score: 1, count: playerRallies.filter { $0.passScore == 1 }.count, total: playerRallies.count)
                TeamPassQualityRow(score: 0, count: playerRallies.filter { $0.passScore == 0 }.count, total: playerRallies.count)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Recent Sessions Section
    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT SESSIONS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(teamSessions.prefix(5)) { session in
                    let sessionRallies = playerRallies.filter { rally in
                        rally.session?.id == session.id
                    }
                    if !sessionRallies.isEmpty {
                        PlayerSessionRow(session: session, rallies: sessionRallies)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Helper Functions
    private func calculateZoneStats(for zoneRallies: [Rally]) -> ZoneStats {
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

struct PlayerOverallStats {
    let totalPasses: Int
    let average: Double
    let goodPassPercentage: Double
    let perfectPassPercentage: Double
    let sessionsPlayed: Int
}

struct SessionTrendPoint: Identifiable {
    let id: UUID
    let date: Date
    let average: Double
}

struct PlayerSessionRow: View {
    let session: Session
    let rallies: [Rally]
    
    private var average: Double {
        guard !rallies.isEmpty else { return 0.0 }
        let totalScore = rallies.reduce(0) { $0 + $1.passScore }
        return Double(totalScore) / Double(rallies.count)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.startTime, style: .date)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(rallies.count) passes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.2f", average))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(averageColor)
                
                Text("avg")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
    
    private var averageColor: Color {
        if average >= 2.5 { return .green }
        if average >= 2.0 { return .blue }
        if average >= 1.5 { return .orange }
        return .red
    }
}

struct TeamPlayerStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

struct TeamPassQualityRow: View {
    let score: Int
    let count: Int
    let total: Int
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return (Double(count) / Double(total)) * 100
    }
    
    private var scoreLabel: String {
        switch score {
        case 3: return "Perfect (3)"
        case 2: return "Good (2)"
        case 1: return "Medium (1)"
        case 0: return "Poor (0)"
        default: return "\(score)"
        }
    }
    
    private var scoreColor: Color {
        switch score {
        case 3: return .green
        case 2: return .blue
        case 1: return .orange
        case 0: return .red
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(scoreColor)
                .frame(width: 12, height: 12)
            
            Text(scoreLabel)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 100, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(scoreColor)
                        .frame(width: geometry.size.width * (percentage / 100.0), height: 8)
                }
            }
            .frame(height: 8)
            
            Text("\(count)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(width: 30, alignment: .trailing)
            
            Text(String(format: "%.0f%%", percentage))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
    }
}
