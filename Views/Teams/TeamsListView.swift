//
//  TeamsListView.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/8/26.
//

import SwiftUI
import SwiftData

struct TeamsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(DataStore.self) private var dataStore
    @Query(sort: \Team.createdAt, order: .reverse) private var teams: [Team]
    @State private var showingCreateTeam = false
    
    var body: some View {
            Group {
                if teams.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(teams) { team in
                            NavigationLink {
                                TeamDetailView(team: team)
                            } label: {
                                TeamRow(team: team)
                            }
                        }
                        .onDelete(perform: deleteTeams)
                    }
                    .navigationTitle("Teams")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                showingCreateTeam = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarLeading) {
                            EditButton()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCreateTeam) {
                CreateTeamSheet(isPresented: $showingCreateTeam)
            }
        }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text("No Teams Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Create your first team to get started with tracking")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingCreateTeam = true
            } label: {
                Label("Create Team", systemImage: "plus")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }
    
    private func deleteTeams(at offsets: IndexSet) {
        for index in offsets {
            let team = teams[index]
            dataStore.deleteTeam(team)
        }
    }
}

struct TeamRow: View {
    var team: Team
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(team.name)
                .font(.headline)
            
            Text("\(team.playerCount) players")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Enhanced Team Detail View

struct TeamDetailView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Session.startTime, order: .reverse) private var allSessions: [Session]
    @Bindable var team: Team
    
    @State private var showingAddPlayer = false
    @State private var showingDeleteConfirmation = false
    @State private var dateFilter: DateFilter = .last30Days
    
    enum DateFilter: String, CaseIterable {
        case last7Days = "Last 7 Days"
        case last30Days = "Last 30 Days"
        case allTime = "All Time"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Team Overview Card
                teamOverviewCard
                
                // Date Filter
                dateFilterPicker
                
                // Team Stats Cards
                teamStatsCards
                
                // Performance Trend Chart
                if filteredSessions.count >= 2 {
                    performanceTrendChart
                }
                
                // Roster Performance
                rosterPerformanceSection
                
                // Session History
                sessionHistorySection
                
                // Quick Actions
                quickActionsSection
            }
            .padding(.vertical)
        }
        .navigationTitle(team.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingAddPlayer = true
                    } label: {
                        Label("Add Player", systemImage: "person.badge.plus")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete Team", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingAddPlayer) {
            AddPlayerSheet(isPresented: $showingAddPlayer) { name, number, position in
                let newPlayer = Player(name: name, number: number, position: position)
                dataStore.addPlayer(to: team, player: newPlayer)
            }
        }
        .alert("Delete Team?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataStore.deleteTeam(team)
                dismiss()
            }
        } message: {
            Text("This will permanently delete \(team.name) and all associated data.")
        }
    }
    
    // MARK: - Team Overview Card
    private var teamOverviewCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "person.3.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(team.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(team.players.count) players")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("Created \(team.createdAt, style: .date)")
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
    
    // MARK: - Team Stats Cards
    private var teamStatsCards: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TEAM STATS")
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
                    value: "\(filteredSessions.count)",
                    icon: "calendar",
                    color: .blue
                )
                
                StatCard(
                    title: "Team Avg",
                    value: String(format: "%.2f", teamAverage),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
                
                StatCard(
                    title: "Total Passes",
                    value: "\(totalPasses)",
                    icon: "arrow.up.circle",
                    color: .orange
                )
                
                StatCard(
                    title: "Good Pass %",
                    value: String(format: "%.0f%%", goodPassPercentage),
                    icon: "checkmark.circle",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Performance Trend Chart
    private var performanceTrendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Line Chart
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("PERFORMANCE TREND")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    // Trend indicator
                    if let trend = performanceTrend {
                        HStack(spacing: 4) {
                            Image(systemName: trend > 0 ? "arrow.up.right" : trend < 0 ? "arrow.down.right" : "arrow.right")
                                .font(.caption2)
                            Text(String(format: "%+.2f", trend))
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(trend > 0 ? .green : trend < 0 ? .red : .secondary)
                    }
                }
                .padding(.horizontal)
                
                PerformanceTrendLineChart(sessions: filteredSessions)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    .padding(.horizontal)
            }
            
            // Stacked Bar Chart
            VStack(alignment: .leading, spacing: 12) {
                Text("PASS QUALITY BREAKDOWN")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                StackedPassDistributionChart(sessions: filteredSessions)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Roster Performance Section
    private var rosterPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ROSTER PERFORMANCE")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                NavigationLink {
                    FullRosterView(team: team, sessions: filteredSessions)
                } label: {
                    Text("View All (\(team.players.count))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(topPerformers.prefix(5)) { stat in
                    PlayerStatRow(stat: stat)
                }
                
                if team.players.isEmpty {
                    Text("No players in roster")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Session History Section
    private var sessionHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("SESSION HISTORY")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if filteredSessions.count > 5 {
                    NavigationLink {
                        TeamSessionsListView(team: team, sessions: filteredSessions)
                    } label: {
                        Text("View All (\(filteredSessions.count))")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .padding(.horizontal)
            
            if filteredSessions.isEmpty {
                Text("No sessions yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
            } else {
                ForEach(filteredSessions.prefix(5)) { session in
                    NavigationLink {
                        SessionDetailView(session: session)
                    } label: {
                        SessionRow(session: session)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            NavigationLink {
                PlayerComparisonView(team: team)
            } label: {
                QuickActionButton(
                    title: "Compare Players",
                    icon: "person.2.fill",
                    color: .purple
                )
            }
            
            NavigationLink {
                FullRosterView(team: team, sessions: filteredSessions)
            } label: {
                QuickActionButton(
                    title: "Manage Roster",
                    icon: "person.3.fill",
                    color: .blue
                )
            }
            
            Button {
                // Export functionality (placeholder)
            } label: {
                QuickActionButton(
                    title: "Export Report",
                    icon: "square.and.arrow.up",
                    color: .green
                )
            }
        }
        .padding(.horizontal)
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
    
    private var teamAverage: Double {
        guard !filteredSessions.isEmpty else { return 0.0 }
        let total = filteredSessions.reduce(0.0) { $0 + $1.teamAverage }
        return total / Double(filteredSessions.count)
    }
    
    private var totalPasses: Int {
        filteredSessions.reduce(0) { $0 + $1.rallyCount }
    }
    
    private var goodPassPercentage: Double {
        guard !filteredSessions.isEmpty else { return 0.0 }
        let totalGoodPasses = filteredSessions.reduce(0.0) { $0 + $1.goodPassPercentage }
        return totalGoodPasses / Double(filteredSessions.count)
    }
    
    private var performanceTrend: Double? {
        guard filteredSessions.count >= 2 else { return nil }
        let sortedSessions = filteredSessions.sorted { $0.startTime < $1.startTime }
        let recentAvg = sortedSessions.suffix(3).reduce(0.0) { $0 + $1.teamAverage } / Double(min(3, sortedSessions.count))
        let earlyAvg = sortedSessions.prefix(3).reduce(0.0) { $0 + $1.teamAverage } / Double(min(3, sortedSessions.count))
        return recentAvg - earlyAvg
    }
    
    private var topPerformers: [PlayerAggregateStats] {
        var playerStats: [UUID: (name: String, number: Int, totalScore: Int, passCount: Int)] = [:]
        
        for session in filteredSessions {
            for rally in session.rallies {
                if var stats = playerStats[rally.playerId] {
                    stats.totalScore += rally.passScore
                    stats.passCount += 1
                    playerStats[rally.playerId] = stats
                } else {
                    if let player = team.players.first(where: { $0.id == rally.playerId }) {
                        playerStats[rally.playerId] = (
                            name: player.name,
                            number: player.number,
                            totalScore: rally.passScore,
                            passCount: 1
                        )
                    }
                }
            }
        }
        
        return playerStats.map { id, stats in
            PlayerAggregateStats(
                playerId: id,
                playerName: stats.name,
                playerNumber: stats.number,
                passCount: stats.passCount,
                average: Double(stats.totalScore) / Double(stats.passCount)
            )
        }.sorted { $0.average > $1.average }
    }
}

// MARK: - Performance Trend Line Chart (Enhanced)

struct PerformanceTrendLineChart: View {
    let sessions: [Session]
    
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
                HStack(spacing: 8) {
                    // Y-axis labels
                    yAxisLabels
                    
                    // Chart area
                    GeometryReader { geometry in
                        ZStack {
                            // Colored background zones
                            coloredZones(geometry: geometry)
                            
                            // Grid lines
                            gridLines(geometry: geometry)
                            
                            // Line path
                            linePath(geometry: geometry)
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                            
                            // Data points
                            dataPoints(geometry: geometry)
                        }
                    }
                }
                .frame(height: 180)
                
                // X-axis labels
                xAxisLabels
            }
        }
    }
    
    // MARK: - Y-Axis Labels
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
    
    // MARK: - Colored Background Zones
    private func coloredZones(geometry: GeometryProxy) -> some View {
        ZStack {
            // Green zone (2.5 - 3.0)
            Rectangle()
                .fill(Color.green.opacity(0.1))
                .frame(height: geometry.size.height * (0.5 / 3.0))
                .position(x: geometry.size.width / 2, y: geometry.size.height * (0.25 / 3.0))
            
            // Yellow zone (2.0 - 2.5)
            Rectangle()
                .fill(Color.yellow.opacity(0.1))
                .frame(height: geometry.size.height * (0.5 / 3.0))
                .position(x: geometry.size.width / 2, y: geometry.size.height * (0.75 / 3.0))
            
            // Orange zone (1.5 - 2.0)
            Rectangle()
                .fill(Color.orange.opacity(0.1))
                .frame(height: geometry.size.height * (0.5 / 3.0))
                .position(x: geometry.size.width / 2, y: geometry.size.height * (1.25 / 3.0))
            
            // Red zone (0.0 - 1.5)
            Rectangle()
                .fill(Color.red.opacity(0.1))
                .frame(height: geometry.size.height * (1.5 / 3.0))
                .position(x: geometry.size.width / 2, y: geometry.size.height * (2.25 / 3.0))
        }
    }
    
    // MARK: - Grid Lines
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
    
    // MARK: - Line Path
    private func linePath(geometry: GeometryProxy) -> Path {
        Path { path in
            guard !sortedSessions.isEmpty else { return }
            
            let width = geometry.size.width
            let height = geometry.size.height
            let count = sortedSessions.count
            let spacing = width / CGFloat(count - 1 > 0 ? count - 1 : 1)
            
            for (index, session) in sortedSessions.enumerated() {
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
    
    // MARK: - Data Points
    private func dataPoints(geometry: GeometryProxy) -> some View {
        ForEach(Array(sortedSessions.enumerated()), id: \.element.id) { index, session in
            let width = geometry.size.width
            let height = geometry.size.height
            let count = sortedSessions.count
            let spacing = width / CGFloat(count - 1 > 0 ? count - 1 : 1)
            
            let x = CGFloat(index) * spacing
            let normalizedValue = session.teamAverage / 3.0
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
    
    // MARK: - X-Axis Labels
    private var xAxisLabels: some View {
        HStack {
            Spacer()
                .frame(width: 38) // Offset for Y-axis labels
            
            HStack {
                if sortedSessions.count >= 2 {
                    Text(sortedSessions.first!.startTime, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(sortedSessions.last!.startTime, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Stacked Pass Distribution Chart (NEW!)

struct StackedPassDistributionChart: View {
    let sessions: [Session]
    
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
                // Stacked bars
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(sortedSessions.prefix(5)) { session in
                        StackedBar(session: session)
                    }
                }
                .frame(height: 150)
                
                // Legend
                legend
            }
        }
    }
    
    private var legend: some View {
        HStack(spacing: 16) {
            ChartLegendItem(color: .green, label: "Perfect (3)")
            ChartLegendItem(color: .yellow, label: "Good (2)")
            ChartLegendItem(color: .orange, label: "Poor (1)")
            ChartLegendItem(color: .red, label: "Ace (0)")
        }
        .font(.caption2)
    }
}

struct StackedBar: View {
    let session: Session
    
    private var distribution: [(score: Int, count: Int, color: Color)] {
        let perfect = session.rallies.filter { $0.passScore == 3 }.count
        let good = session.rallies.filter { $0.passScore == 2 }.count
        let poor = session.rallies.filter { $0.passScore == 1 }.count
        let ace = session.rallies.filter { $0.passScore == 0 }.count
        
        return [
            (3, perfect, .green),
            (2, good, .yellow),
            (1, poor, .orange),
            (0, ace, .red)
        ]
    }
    
    private var total: Int {
        session.rallyCount
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Stacked bar
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
            
            // Date label
            Text(session.startTime, format: .dateTime.month().day())
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

struct ChartLegendItem: View {
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

// MARK: - Supporting Components

struct StatCard: View {
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
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

struct PlayerAggregateStats: Identifiable {
    let id = UUID()
    let playerId: UUID
    let playerName: String
    let playerNumber: Int
    let passCount: Int
    let average: Double
}

struct PlayerStatRow: View {
    let stat: PlayerAggregateStats
    
    var body: some View {
        HStack {
            Text("#\(stat.playerNumber)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.blue)
                .frame(width: 40, alignment: .leading)
            
            Text(stat.playerName)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Text("\(stat.passCount) passes")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(String(format: "%.2f", stat.average))
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(averageColor(stat.average))
                .frame(width: 50, alignment: .trailing)
        }
        .padding(.horizontal)
    }
    
    private func averageColor(_ avg: Double) -> Color {
        if avg >= 2.5 { return .green }
        if avg >= 2.0 { return .orange }
        if avg >= 1.5 { return .red }
        return .secondary
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 40)
            
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Placeholder Views

struct FullRosterView: View {
    @Bindable var team: Team
    let sessions: [Session]
    
    var body: some View {
        List {
            ForEach(team.players) { player in
                HStack {
                    Text("#\(player.number)")
                        .fontWeight(.bold)
                    Text(player.name)
                    Spacer()
                    if let position = player.position {
                        Text(position)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Full Roster")
    }
}

struct TeamSessionsListView: View {
    let team: Team
    let sessions: [Session]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(sessions) { session in
                    NavigationLink {
                        SessionDetailView(session: session)
                    } label: {
                        SessionRow(session: session)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("All Sessions")
        .background(Color(.systemGroupedBackground))
    }
}
