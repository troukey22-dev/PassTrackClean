//
//  PlayerComparisonView.swift
//  PassTrackClean
//
//  Compare multiple players side-by-side
//

import SwiftUI
import SwiftData

struct PlayerComparisonView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Session.startTime, order: .reverse) private var allSessions: [Session]
    
    let team: Team
    @State private var selectedPlayers: Set<UUID> = []
    @State private var dateFilter: DateFilter = .last30Days
    @State private var showingPlayerPicker = false
    
    enum DateFilter: String, CaseIterable {
        case last7Days = "Last 7 Days"
        case last30Days = "Last 30 Days"
        case allTime = "All Time"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Player Selection
                    playerSelectionSection
                    
                    if selectedPlayers.count >= 2 {
                        // Date Filter
                        dateFilterPicker
                        
                        // Stats Comparison Cards
                        statsComparisonSection
                        
                        // Multi-line Performance Chart
                        performanceComparisonChart
                        
                        // Pass Quality Comparison
                        passQualityComparisonSection
                        
                        // Zone Comparison
                        if hasZoneData {
                            zoneComparisonSection
                        }
                        
                        // Contact Type Comparison
                        if hasContactTypeData {
                            contactTypeComparisonSection
                        }
                        
                        // Head-to-Head Stats Table
                        headToHeadStatsTable
                    } else {
                        emptyState
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Compare Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showingPlayerPicker) {
                PlayerPickerSheet(
                    team: team,
                    selectedPlayers: $selectedPlayers
                )
            }
        }
    }
    
    // MARK: - Player Selection Section
    private var playerSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SELECTED PLAYERS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            if selectedPlayers.isEmpty {
                Button {
                    showingPlayerPicker = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Select Players to Compare")
                            .font(.headline)
                    }
                    .foregroundStyle(Color.appPurple)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                }
                .padding(.horizontal)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(selectedPlayerObjects), id: \.id) { player in
                        SelectedPlayerRow(player: player) {
                            selectedPlayers.remove(player.id)
                        }
                    }
                    
                    if selectedPlayers.count < 4 {
                        Button {
                            showingPlayerPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Add Another Player")
                                    .font(.subheadline)
                            }
                            .foregroundStyle(Color.appPurple)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
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
    
    // MARK: - Stats Comparison Section
    private var statsComparisonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("STATS COMPARISON")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                ComparisonMetricCard(
                    title: "Average Rating",
                    icon: "chart.line.uptrend.xyaxis",
                    playerStats: selectedPlayerObjects.map { player in
                        (player, playerStats(for: player).average)
                    }
                )
                
                ComparisonMetricCard(
                    title: "Total Passes",
                    icon: "arrow.up.circle",
                    playerStats: selectedPlayerObjects.map { player in
                        (player, Double(playerStats(for: player).totalPasses))
                    }
                )
                
                ComparisonMetricCard(
                    title: "Good Pass %",
                    icon: "checkmark.circle",
                    playerStats: selectedPlayerObjects.map { player in
                        (player, playerStats(for: player).goodPassPercentage)
                    }
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Performance Comparison Chart
    private var performanceComparisonChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PERFORMANCE TREND")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            MultiPlayerComparisonChart(
                playerData: selectedPlayerObjects.map { player in
                    (player, playerSessionStats(for: player))
                }
            )
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Pass Quality Comparison
    private var passQualityComparisonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PASS QUALITY DISTRIBUTION")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            PassQualityComparisonGrid(
                playerData: selectedPlayerObjects.map { player in
                    let stats = playerStats(for: player)
                    return (player, stats.perfect, stats.good, stats.poor, stats.ace)
                }
            )
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Zone Comparison
    private var zoneComparisonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ZONE PERFORMANCE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            ZoneComparisonGrid(
                playerData: selectedPlayerObjects.map { player in
                    (player, playerRallies(for: player))
                }
            )
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Contact Type Comparison
    private var contactTypeComparisonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CONTACT TYPE PERFORMANCE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            ContactTypeComparisonGrid(
                playerData: selectedPlayerObjects.map { player in
                    (player, playerRallies(for: player))
                }
            )
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Head-to-Head Stats Table
    private var headToHeadStatsTable: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("HEAD-TO-HEAD STATS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                // Header row
                HStack {
                    Text("Metric")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(Array(selectedPlayerObjects.prefix(4)), id: \.id) { player in
                        Text(player.name)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: 60)
                            .lineLimit(1)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                Divider()
                
                // Data rows
                ForEach(comparisonMetrics, id: \.title) { metric in
                    HStack {
                        Text(metric.title)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(Array(selectedPlayerObjects.prefix(4)), id: \.id) { player in
                            Text(metric.valueForPlayer(player))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(metric.colorForPlayer(player))
                                .frame(width: 60)
                        }
                    }
                    .padding()
                    
                    if metric.title != comparisonMetrics.last?.title {
                        Divider()
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image("idea")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
            
            Text("Select 2-4 Players")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Compare performance, trends, and stats side-by-side")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.vertical, 60)
    }
    
    // MARK: - Computed Properties
    
    private var selectedPlayerObjects: [Player] {
        team.players.filter { selectedPlayers.contains($0.id) }
    }
    
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
    
    private var hasZoneData: Bool {
        filteredSessions.contains { $0.trackZone }
    }
    
    private var hasContactTypeData: Bool {
        filteredSessions.contains { $0.trackContactType }
    }
    
    private func playerRallies(for player: Player) -> [Rally] {
        filteredSessions.flatMap { $0.rallies.filter { $0.playerId == player.id } }
    }
    
    private func playerStats(for player: Player) -> PlayerComparisonStats {
        let rallies = playerRallies(for: player)
        
        guard !rallies.isEmpty else {
            return PlayerComparisonStats(
                totalPasses: 0,
                average: 0.0,
                goodPassPercentage: 0.0,
                perfect: 0,
                good: 0,
                poor: 0,
                ace: 0
            )
        }
        
        let totalScore = rallies.reduce(0) { $0 + $1.passScore }
        let average = Double(totalScore) / Double(rallies.count)
        let goodPasses = rallies.filter { $0.passScore >= 2 }.count
        let goodPassPercentage = (Double(goodPasses) / Double(rallies.count)) * 100
        
        let perfect = rallies.filter { $0.passScore == 3 }.count
        let good = rallies.filter { $0.passScore == 2 }.count
        let poor = rallies.filter { $0.passScore == 1 }.count
        let ace = rallies.filter { $0.passScore == 0 }.count
        
        return PlayerComparisonStats(
            totalPasses: rallies.count,
            average: average,
            goodPassPercentage: goodPassPercentage,
            perfect: perfect,
            good: good,
            poor: poor,
            ace: ace
        )
    }
    
    private func playerSessionStats(for player: Player) -> [PlayerComparisonSessionStat] {
        var stats: [PlayerComparisonSessionStat] = []
        
        for session in filteredSessions {
            let playerRallies = session.rallies.filter { $0.playerId == player.id }
            if !playerRallies.isEmpty {
                let totalScore = playerRallies.reduce(0) { $0 + $1.passScore }
                let average = Double(totalScore) / Double(playerRallies.count)
                
                stats.append(PlayerComparisonSessionStat(
                    sessionDate: session.startTime,
                    average: average,
                    passCount: playerRallies.count
                ))
            }
        }
        
        return stats.sorted { $0.sessionDate < $1.sessionDate }
    }
    
    private var comparisonMetrics: [ComparisonMetric] {
        [
            ComparisonMetric(
                title: "Avg Rating",
                valueForPlayer: { player in
                    String(format: "%.2f", playerStats(for: player).average)
                },
                colorForPlayer: { player in
                    let avg = playerStats(for: player).average
                    if avg >= 2.5 { return .green }
                    if avg >= 2.0 { return .yellow }
                    if avg >= 1.5 { return .orange }
                    return .red
                }
            ),
            ComparisonMetric(
                title: "Total Passes",
                valueForPlayer: { player in
                    "\(playerStats(for: player).totalPasses)"
                },
                colorForPlayer: { _ in .primary }
            ),
            ComparisonMetric(
                title: "Good %",
                valueForPlayer: { player in
                    String(format: "%.0f%%", playerStats(for: player).goodPassPercentage)
                },
                colorForPlayer: { _ in .primary }
            ),
            ComparisonMetric(
                title: "Perfect (3)",
                valueForPlayer: { player in
                    "\(playerStats(for: player).perfect)"
                },
                colorForPlayer: { _ in .green }
            ),
            ComparisonMetric(
                title: "Good (2)",
                valueForPlayer: { player in
                    "\(playerStats(for: player).good)"
                },
                colorForPlayer: { _ in .yellow }
            ),
            ComparisonMetric(
                title: "Poor (1)",
                valueForPlayer: { player in
                    "\(playerStats(for: player).poor)"
                },
                colorForPlayer: { _ in .orange }
            ),
            ComparisonMetric(
                title: "Ace (0)",
                valueForPlayer: { player in
                    "\(playerStats(for: player).ace)"
                },
                colorForPlayer: { _ in .red }
            )
        ]
    }
}

// MARK: - Supporting Data Models

struct PlayerComparisonStats {
    let totalPasses: Int
    let average: Double
    let goodPassPercentage: Double
    let perfect: Int
    let good: Int
    let poor: Int
    let ace: Int
}

struct PlayerComparisonSessionStat {
    let sessionDate: Date
    let average: Double
    let passCount: Int
}

struct ComparisonMetric {
    let title: String
    let valueForPlayer: (Player) -> String
    let colorForPlayer: (Player) -> Color
}

// MARK: - Selected Player Row

struct SelectedPlayerRow: View {
    let player: Player
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.appPurple.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay {
                    Text("#\(player.number)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appPurple)
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if let position = player.position {
                    Text(position)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Player Picker Sheet

struct PlayerPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let team: Team
    @Binding var selectedPlayers: Set<UUID>
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(team.players) { player in
                    Button {
                        if selectedPlayers.contains(player.id) {
                            selectedPlayers.remove(player.id)
                        } else if selectedPlayers.count < 4 {
                            selectedPlayers.insert(player.id)
                        }
                    } label: {
                        HStack {
                            Text("#\(player.number)")
                                .fontWeight(.bold)
                                .frame(width: 40)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(player.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                if let position = player.position {
                                    Text(position)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if selectedPlayers.contains(player.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.appPurple)
                            } else if selectedPlayers.count >= 4 {
                                Image(systemName: "circle")
                                    .foregroundStyle(.gray)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundStyle(Color.appPurple)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedPlayers.count >= 4 && !selectedPlayers.contains(player.id))
                }
            }
            .navigationTitle("Select Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Comparison Metric Card

struct ComparisonMetricCard: View {
    let title: String
    let icon: String
    let playerStats: [(Player, Double)]
    
    private var maxValue: Double {
        playerStats.map { $0.1 }.max() ?? 0
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color.appPurple)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            ForEach(playerStats, id: \.0.id) { player, value in
                HStack(spacing: 12) {
                    Text(player.name)
                        .font(.caption)
                        .frame(width: 60, alignment: .leading)
                        .lineLimit(1)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.systemGray5))
                            
                            Rectangle()
                                .fill(Color.appPurple)
                                .frame(width: maxValue > 0 ? geometry.size.width * (value / maxValue) : 0)
                        }
                    }
                    .frame(height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    Text(String(format: "%.1f", value))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Multi-Player Comparison Chart

struct MultiPlayerComparisonChart: View {
    let playerData: [(Player, [PlayerComparisonSessionStat])]
    
    private let colors: [Color] = [Color.appPurple, .green, .orange, .purple]
    
    var body: some View {
        VStack(spacing: 16) {
            if playerData.allSatisfy({ $0.1.isEmpty }) {
                Text("No data available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                // Legend
                HStack(spacing: 12) {
                    ForEach(Array(playerData.enumerated()), id: \.element.0.id) { index, data in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(colors[index % colors.count])
                                .frame(width: 8, height: 8)
                            Text(data.0.name)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                    }
                }
                
                HStack(spacing: 8) {
                    // Y-axis labels
                    VStack(spacing: 0) {
                        ForEach([3.0, 2.0, 1.0, 0.0], id: \.self) { value in
                            Text(String(format: "%.1f", value))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .frame(width: 30, alignment: .trailing)
                                .frame(maxHeight: .infinity)
                        }
                    }
                    
                    // Chart area
                    GeometryReader { geometry in
                        ZStack {
                            // Grid lines
                            gridLines(geometry: geometry)
                            
                            // Multiple player lines
                            ForEach(Array(playerData.enumerated()), id: \.element.0.id) { index, data in
                                playerLine(geometry: geometry, stats: data.1)
                                    .stroke(colors[index % colors.count], style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                            }
                        }
                    }
                }
                .frame(height: 150)
            }
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
    
    private func playerLine(geometry: GeometryProxy, stats: [PlayerComparisonSessionStat]) -> Path {
        Path { path in
            guard !stats.isEmpty else { return }
            
            let width = geometry.size.width
            let height = geometry.size.height
            let count = stats.count
            let spacing = width / CGFloat(count - 1 > 0 ? count - 1 : 1)
            
            for (index, stat) in stats.enumerated() {
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
}

// MARK: - Pass Quality Comparison Grid

struct PassQualityComparisonGrid: View {
    let playerData: [(Player, Int, Int, Int, Int)] // (player, perfect, good, poor, ace)
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(playerData, id: \.0.id) { player, perfect, good, poor, ace in
                VStack(spacing: 8) {
                    Text(player.name)
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 8) {
                        QualityBar(count: perfect, color: .green, label: "3")
                        QualityBar(count: good, color: .yellow, label: "2")
                        QualityBar(count: poor, color: .orange, label: "1")
                        QualityBar(count: ace, color: .red, label: "0")
                    }
                }
            }
        }
    }
}

struct QualityBar: View {
    let count: Int
    let color: Color
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.caption)
                .fontWeight(.bold)
            
            Rectangle()
                .fill(color)
                .frame(height: 60)
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Zone Comparison Grid

struct ZoneComparisonGrid: View {
    let playerData: [(Player, [Rally])]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(playerData, id: \.0.id) { player, rallies in
                VStack(spacing: 8) {
                    Text(player.name)
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 8) {
                        ForEach(["5", "6", "1"], id: \.self) { zone in
                            ZoneComparisonCell(zone: zone, rallies: rallies)
                        }
                    }
                }
            }
        }
    }
}

struct ZoneComparisonCell: View {
    let zone: String
    let rallies: [Rally]
    
    private var zoneRallies: [Rally] {
        rallies.filter { $0.zone == zone }
    }
    
    private var average: Double {
        guard !zoneRallies.isEmpty else { return 0.0 }
        let total = zoneRallies.reduce(0) { $0 + $1.passScore }
        return Double(total) / Double(zoneRallies.count)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Zone \(zone)")
                .font(.caption2)
            
            if !zoneRallies.isEmpty {
                Text(String(format: "%.1f", average))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(averageColor)
                
                Text("\(zoneRallies.count)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("—")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var averageColor: Color {
        if average >= 2.5 { return .green }
        if average >= 2.0 { return .yellow }
        if average >= 1.5 { return .orange }
        return .red
    }
}

// MARK: - Contact Type Comparison Grid

struct ContactTypeComparisonGrid: View {
    let playerData: [(Player, [Rally])]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(playerData, id: \.0.id) { player, rallies in
                VStack(spacing: 8) {
                    Text(player.name)
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 8) {
                        ContactTypeComparisonCell(type: "Platform", rallies: rallies)
                        ContactTypeComparisonCell(type: "Hands", rallies: rallies)
                    }
                }
            }
        }
    }
}

struct ContactTypeComparisonCell: View {
    let type: String
    let rallies: [Rally]
    
    private var typeRallies: [Rally] {
        rallies.filter { $0.contactType == type }
    }
    
    private var average: Double {
        guard !typeRallies.isEmpty else { return 0.0 }
        let total = typeRallies.reduce(0) { $0 + $1.passScore }
        return Double(total) / Double(typeRallies.count)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(type)
                .font(.caption2)
            
            if !typeRallies.isEmpty {
                Text(String(format: "%.1f", average))
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("\(typeRallies.count)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("—")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
