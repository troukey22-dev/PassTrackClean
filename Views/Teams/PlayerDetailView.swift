//
//  PlayerDetailView.swift
//  PassTrackClean
//
//  Individual Player Analytics View
//

import SwiftUI
import SwiftData

struct PlayerDetailView: View {
    @Environment(DataStore.self) private var dataStore
    @Query(sort: \Session.startTime, order: .reverse) private var allSessions: [Session]
    
    let player: Player
    let team: Team
    
    @State private var dateFilter: DateFilter = .last30Days
    
    enum DateFilter: String, CaseIterable {
        case last7Days = "Last 7 Days"
        case last30Days = "Last 30 Days"
        case allTime = "All Time"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Player Overview Card
                playerOverviewCard
                
                // Date Filter
                dateFilterPicker
                
                // Player Stats Cards
                playerStatsCards
                
                // Performance Comparison Chart (Player vs Team)
                if filteredSessions.count >= 2 {
                    performanceComparisonChart
                }
                
                // Pass Quality Distribution (Player's stacked bars)
                if !filteredSessions.isEmpty {
                    passQualityDistributionChart
                }
                
                // Zone Analysis
                if hasZoneData {
                    zoneAnalysisSection
                }
                
                // Body Contact Heat Map
                if hasContactLocationData {
                    bodyContactHeatMapSection
                }
                
                // Contact Type Analysis
                if hasContactTypeData {
                    contactTypeAnalysisSection
                }
                
                // Session History
                sessionHistorySection
            }
            .padding(.vertical)
        }
        .navigationTitle(player.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Player Overview Card
    private var playerOverviewCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Text("#\(player.number)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let position = player.position {
                        Text(position)
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
    
    // MARK: - Date Filter Picker
    private var dateFilterPicker: some View {
        Picker("Filter", selection: $dateFilter) {
            ForEach(DateFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    // MARK: - Player Stats Cards
    private var playerStatsCards: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PLAYER STATS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "Sessions",
                    value: "\(playerSessionCount)",
                    icon: "calendar",
                    color: .blue
                )
                
                StatCard(
                    title: "Average",
                    value: String(format: "%.2f", playerAverage),
                    icon: "chart.line.uptrend.xyaxis",
                    color: averageColor(playerAverage)
                )
                
                StatCard(
                    title: "Total Passes",
                    value: "\(playerTotalPasses)",
                    icon: "arrow.up.circle",
                    color: .orange
                )
                
                StatCard(
                    title: "Good Pass %",
                    value: String(format: "%.0f%%", playerGoodPassPercentage),
                    icon: "checkmark.circle",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Performance Comparison Chart
    private var performanceComparisonChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("PERFORMANCE COMPARISON")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                // Legend
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                        Text("Player")
                            .font(.caption2)
                    }
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 8, height: 8)
                        Text("Team")
                            .font(.caption2)
                    }
                }
            }
            .padding(.horizontal)
            
            PlayerVsTeamComparisonChart(
                playerSessions: playerSessionStats,
                teamSessions: filteredSessions
            )
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Pass Quality Distribution Chart
    private var passQualityDistributionChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PASS QUALITY BREAKDOWN")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            PlayerStackedPassDistributionChart(
                sessions: filteredSessions,
                playerId: player.id
            )
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Zone Analysis Section
    private var zoneAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ZONE ANALYSIS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            PlayerZoneHeatMap(rallies: playerRallies)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Body Contact Heat Map Section
    private var bodyContactHeatMapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BODY CONTACT HEAT MAP")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            PlayerBodyContactHeatMap(rallies: playerRallies)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Contact Type Analysis Section
    private var contactTypeAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CONTACT TYPE ANALYSIS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            PlayerContactTypeAnalysis(rallies: playerRallies)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Session History Section
    private var sessionHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SESSION HISTORY")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            if playerSessionStats.isEmpty {
                Text("No sessions yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
            } else {
                ForEach(playerSessionStats.prefix(5)) { stat in
                    NavigationLink {
                        SessionDetailView(session: stat.session)
                    } label: {
                        PlayerSessionRow(stat: stat)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredSessions: [Session] {
        let teamSessions = allSessions.filter { $0.teamId == team.id }
        
        switch dateFilter {
        case .last7Days:
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return teamSessions.filter { $0.startTime >= cutoffDate }
        case .last30Days:
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            return teamSessions.filter { $0.startTime >= cutoffDate }
        case .allTime:
            return teamSessions
        }
    }
    
    private var playerSessionStats: [PlayerSessionStats] {
        var stats: [PlayerSessionStats] = []
        
        for session in filteredSessions {
            let playerRallies = session.rallies.filter { $0.playerId == player.id }
            if !playerRallies.isEmpty {
                let totalScore = playerRallies.reduce(0) { $0 + $1.passScore }
                let average = Double(totalScore) / Double(playerRallies.count)
                let goodPasses = playerRallies.filter { $0.passScore >= 2 }.count
                let goodPassPercentage = (Double(goodPasses) / Double(playerRallies.count)) * 100
                
                stats.append(PlayerSessionStats(
                    session: session,
                    passCount: playerRallies.count,
                    average: average,
                    goodPassPercentage: goodPassPercentage
                ))
            }
        }
        
        return stats.sorted { $0.session.startTime < $1.session.startTime }
    }
    
    private var playerRallies: [Rally] {
        filteredSessions.flatMap { $0.rallies.filter { $0.playerId == player.id } }
    }
    
    private var playerSessionCount: Int {
        playerSessionStats.count
    }
    
    private var playerAverage: Double {
        guard !playerRallies.isEmpty else { return 0.0 }
        let totalScore = playerRallies.reduce(0) { $0 + $1.passScore }
        return Double(totalScore) / Double(playerRallies.count)
    }
    
    private var playerTotalPasses: Int {
        playerRallies.count
    }
    
    private var playerGoodPassPercentage: Double {
        guard !playerRallies.isEmpty else { return 0.0 }
        let goodPasses = playerRallies.filter { $0.passScore >= 2 }.count
        return (Double(goodPasses) / Double(playerRallies.count)) * 100
    }
    
    private var hasZoneData: Bool {
        playerRallies.contains { $0.zone != nil }
    }
    
    private var hasContactLocationData: Bool {
        playerRallies.contains { $0.contactLocation != nil }
    }
    
    private var hasContactTypeData: Bool {
        playerRallies.contains { $0.contactType != nil }
    }
    
    private func averageColor(_ avg: Double) -> Color {
        if avg >= 2.5 { return .green }
        if avg >= 2.0 { return .yellow }
        if avg >= 1.5 { return .orange }
        return .red
    }
}

// MARK: - Supporting Data Models

struct PlayerSessionStats: Identifiable {
    let id = UUID()
    let session: Session
    let passCount: Int
    let average: Double
    let goodPassPercentage: Double
}

// MARK: - Player vs Team Comparison Chart

struct PlayerVsTeamComparisonChart: View {
    let playerSessions: [PlayerSessionStats]
    let teamSessions: [Session]
    
    private var sortedPlayerSessions: [PlayerSessionStats] {
        playerSessions.sorted { $0.session.startTime < $1.session.startTime }
    }
    
    private var sortedTeamSessions: [Session] {
        teamSessions.sorted { $0.startTime < $1.startTime }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if sortedPlayerSessions.isEmpty {
                Text("No data available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 8) {
                    // Y-axis labels
                    yAxisLabels
                    
                    // Chart area
                    GeometryReader { geometry in
                        ZStack {
                            // Colored zones
                            coloredZones(geometry: geometry)
                            
                            // Grid lines
                            gridLines(geometry: geometry)
                            
                            // Team average line (gray)
                            teamAverageLine(geometry: geometry)
                                .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [5, 3]))
                            
                            // Player line (blue)
                            playerLine(geometry: geometry)
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                            
                            // Player data points
                            playerDataPoints(geometry: geometry)
                        }
                    }
                }
                .frame(height: 180)
                
                // X-axis labels
                xAxisLabels
            }
        }
    }
    
    private var yAxisLabels: some View {
        VStack(spacing: 0) {
            ForEach([3.0, 2.0, 1.0, 0.0], id: \.self) { value in
                Text(String(format: "%.1f", value))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(width: 30, alignment: .trailing)
                    .frame(maxHeight: .infinity)
            }
        }
    }
    
    private func coloredZones(geometry: GeometryProxy) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.green.opacity(0.1))
                .frame(height: geometry.size.height * (0.5 / 3.0))
                .position(x: geometry.size.width / 2, y: geometry.size.height * (0.25 / 3.0))
            
            Rectangle()
                .fill(Color.yellow.opacity(0.1))
                .frame(height: geometry.size.height * (0.5 / 3.0))
                .position(x: geometry.size.width / 2, y: geometry.size.height * (0.75 / 3.0))
            
            Rectangle()
                .fill(Color.orange.opacity(0.1))
                .frame(height: geometry.size.height * (0.5 / 3.0))
                .position(x: geometry.size.width / 2, y: geometry.size.height * (1.25 / 3.0))
            
            Rectangle()
                .fill(Color.red.opacity(0.1))
                .frame(height: geometry.size.height * (1.5 / 3.0))
                .position(x: geometry.size.width / 2, y: geometry.size.height * (2.25 / 3.0))
        }
    }
    
    private func gridLines(geometry: GeometryProxy) -> some View {
        Path { path in
            for i in 0...3 {
                let y = geometry.size.height * (1 - CGFloat(i) / 3.0)
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: geometry.size.width, y: y))
            }
        }
        .stroke(Color(.systemGray4), lineWidth: 1)
    }
    
    private func teamAverageLine(geometry: GeometryProxy) -> Path {
        Path { path in
            guard !sortedTeamSessions.isEmpty else { return }
            
            let width = geometry.size.width
            let height = geometry.size.height
            let count = sortedTeamSessions.count
            let spacing = width / CGFloat(count - 1 > 0 ? count - 1 : 1)
            
            for (index, session) in sortedTeamSessions.enumerated() {
                let x = CGFloat(index) * spacing
                let normalizedValue = session.teamAverage / 3.0
                let y = height * (1 - normalizedValue)
                
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
    }
    
    private func playerLine(geometry: GeometryProxy) -> Path {
        Path { path in
            guard !sortedPlayerSessions.isEmpty else { return }
            
            let width = geometry.size.width
            let height = geometry.size.height
            let count = sortedPlayerSessions.count
            let spacing = width / CGFloat(count - 1 > 0 ? count - 1 : 1)
            
            for (index, stat) in sortedPlayerSessions.enumerated() {
                let x = CGFloat(index) * spacing
                let normalizedValue = stat.average / 3.0
                let y = height * (1 - normalizedValue)
                
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
    }
    
    private func playerDataPoints(geometry: GeometryProxy) -> some View {
        ForEach(Array(sortedPlayerSessions.enumerated()), id: \.element.id) { index, stat in
            let width = geometry.size.width
            let height = geometry.size.height
            let count = sortedPlayerSessions.count
            let spacing = width / CGFloat(count - 1 > 0 ? count - 1 : 1)
            
            let x = CGFloat(index) * spacing
            let normalizedValue = stat.average / 3.0
            let y = height * (1 - normalizedValue)
            
            Circle()
                .fill(Color.blue)
                .frame(width: 8, height: 8)
                .position(x: x, y: y)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                )
        }
    }
    
    private var xAxisLabels: some View {
        HStack {
            Spacer()
                .frame(width: 38)
            
            HStack {
                if sortedPlayerSessions.count >= 2 {
                    Text(sortedPlayerSessions.first!.session.startTime, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(sortedPlayerSessions.last!.session.startTime, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Player Stacked Pass Distribution Chart

struct PlayerStackedPassDistributionChart: View {
    let sessions: [Session]
    let playerId: UUID
    
    private var sortedSessions: [Session] {
        sessions.sorted { $0.startTime < $1.startTime }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if sortedSessions.isEmpty {
                Text("No data available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(sortedSessions.prefix(5)) { session in
                        PlayerStackedBar(session: session, playerId: playerId)
                    }
                }
                .frame(height: 150)
                
                legend
            }
        }
    }
    
    private var legend: some View {
        HStack(spacing: 16) {
            PlayerChartLegendItem(color: .green, label: "Perfect (3)")
            PlayerChartLegendItem(color: .yellow, label: "Good (2)")
            PlayerChartLegendItem(color: .orange, label: "Poor (1)")
            PlayerChartLegendItem(color: .red, label: "Ace (0)")
        }
        .font(.caption2)
    }
}

struct PlayerStackedBar: View {
    let session: Session
    let playerId: UUID
    
    private var playerRallies: [Rally] {
        session.rallies.filter { $0.playerId == playerId }
    }
    
    private var distribution: [(score: Int, count: Int, color: Color)] {
        let perfect = playerRallies.filter { $0.passScore == 3 }.count
        let good = playerRallies.filter { $0.passScore == 2 }.count
        let poor = playerRallies.filter { $0.passScore == 1 }.count
        let ace = playerRallies.filter { $0.passScore == 0 }.count
        
        return [
            (3, perfect, .green),
            (2, good, .yellow),
            (1, poor, .orange),
            (0, ace, .red)
        ]
    }
    
    private var total: Int {
        playerRallies.count
    }
    
    var body: some View {
        VStack(spacing: 4) {
            if total > 0 {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        ForEach(distribution, id: \.score) { item in
                            if item.count > 0 {
                                Rectangle()
                                    .fill(item.color)
                                    .frame(height: geometry.size.height * (CGFloat(item.count) / CGFloat(total)))
                                    .overlay(
                                        Text("\(item.count)")
                                            .font(.caption2)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.white)
                                            .shadow(color: .black.opacity(0.3), radius: 1)
                                    )
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            } else {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        Text("No passes")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    )
            }
            
            Text(session.startTime, format: .dateTime.month().day())
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

struct PlayerChartLegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
        }
    }
}

// MARK: - Player Zone Heat Map

struct PlayerZoneHeatMap: View {
    let rallies: [Rally]
    
    var body: some View {
        VStack(spacing: 16) {
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

// MARK: - Player Body Contact Heat Map

struct PlayerBodyContactHeatMap: View {
    let rallies: [Rally]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Where contact was made on body")
                .font(.caption)
                .foregroundStyle(.secondary)
            
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
            
            HStack(spacing: 16) {
                PlayerBodyLegendItem(color: .green, label: "2.5+")
                PlayerBodyLegendItem(color: .yellow, label: "2.0-2.5")
                PlayerBodyLegendItem(color: .orange, label: "1.5-2.0")
                PlayerBodyLegendItem(color: .red, label: "<1.5")
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

struct PlayerBodyLegendItem: View {
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

// MARK: - Player Contact Type Analysis

struct PlayerContactTypeAnalysis: View {
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

// MARK: - Player Session Row

struct PlayerSessionRow: View {
    let stat: PlayerSessionStats
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: "chart.bar.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(stat.session.startTime, style: .date)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("\(stat.passCount) passes • \(String(format: "%.1f", stat.average)) avg")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}
