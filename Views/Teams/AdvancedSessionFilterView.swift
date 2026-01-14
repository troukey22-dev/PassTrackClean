//
//  AdvancedSessionFilterView.swift
//  PassTrackClean
//
//  Advanced filtering and search for sessions
//

import SwiftUI
import SwiftData

struct AdvancedSessionFilterView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Session.startTime, order: .reverse) private var allSessions: [Session]
    @Query(sort: \Team.createdAt, order: .reverse) private var teams: [Team]
    
    @State private var searchText = ""
    @State private var selectedTeam: Team?
    @State private var selectedPlayer: Player?
    @State private var minAverage: Double = 0.0
    @State private var maxAverage: Double = 3.0
    @State private var minPasses: Int = 0
    @State private var dateRange: DateRangeFilter = .allTime
    @State private var customStartDate = Date()
    @State private var customEndDate = Date()
    @State private var sortBy: SortOption = .dateNewest
    @State private var showingFilters = false
    
    enum DateRangeFilter: String, CaseIterable {
        case today = "Today"
        case last7Days = "Last 7 Days"
        case last30Days = "Last 30 Days"
        case last90Days = "Last 90 Days"
        case custom = "Custom Range"
        case allTime = "All Time"
    }
    
    enum SortOption: String, CaseIterable {
        case dateNewest = "Date (Newest)"
        case dateOldest = "Date (Oldest)"
        case averageHighest = "Average (Highest)"
        case averageLowest = "Average (Lowest)"
        case passesHighest = "Passes (Most)"
        case passesLowest = "Passes (Least)"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                
                // Active filters summary
                if hasActiveFilters {
                    activeFiltersSummary
                }
                
                // Session list
                sessionList
            }
            .navigationTitle("All Sessions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingFilters.toggle()
                    } label: {
                        Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundStyle(hasActiveFilters ? .blue : .primary)
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterSheet(
                    teams: teams,
                    selectedTeam: $selectedTeam,
                    selectedPlayer: $selectedPlayer,
                    minAverage: $minAverage,
                    maxAverage: $maxAverage,
                    minPasses: $minPasses,
                    dateRange: $dateRange,
                    customStartDate: $customStartDate,
                    customEndDate: $customEndDate,
                    sortBy: $sortBy,
                    onReset: resetFilters
                )
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Search sessions...", text: $searchText)
                .textFieldStyle(.plain)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
    }
    
    // MARK: - Active Filters Summary
    private var activeFiltersSummary: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let team = selectedTeam {
                    FilterChip(text: team.name) {
                        selectedTeam = nil
                    }
                }
                
                if let player = selectedPlayer {
                    FilterChip(text: player.name) {
                        selectedPlayer = nil
                    }
                }
                
                if minAverage > 0.0 || maxAverage < 3.0 {
                    FilterChip(text: "Avg: \(String(format: "%.1f", minAverage))-\(String(format: "%.1f", maxAverage))") {
                        minAverage = 0.0
                        maxAverage = 3.0
                    }
                }
                
                if minPasses > 0 {
                    FilterChip(text: "≥ \(minPasses) passes") {
                        minPasses = 0
                    }
                }
                
                if dateRange != .allTime {
                    FilterChip(text: dateRange.rawValue) {
                        dateRange = .allTime
                    }
                }
                
                if sortBy != .dateNewest {
                    FilterChip(text: "Sort: \(sortBy.rawValue)") {
                        sortBy = .dateNewest
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    // MARK: - Session List
    private var sessionList: some View {
        Group {
            if filteredSessions.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filteredSessions) { session in
                            NavigationLink {
                                SessionDetailView(session: session)
                            } label: {
                                EnhancedSessionRow(session: session)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Sessions Found")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Try adjusting your filters")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if hasActiveFilters {
                Button {
                    resetFilters()
                } label: {
                    Text("Clear All Filters")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
        .frame(maxHeight: .infinity)
    }
    
    // MARK: - Computed Properties
    
    private var filteredSessions: [Session] {
        var sessions = allSessions
        
        // Search filter
        if !searchText.isEmpty {
            sessions = sessions.filter { session in
                session.teamName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Team filter
        if let team = selectedTeam {
            sessions = sessions.filter { $0.teamId == team.id }
        }
        
        // Player filter
        if let player = selectedPlayer {
            sessions = sessions.filter { session in
                session.passerIds.contains(player.id)
            }
        }
        
        // Average filter
        sessions = sessions.filter { session in
            session.teamAverage >= minAverage && session.teamAverage <= maxAverage
        }
        
        // Minimum passes filter
        if minPasses > 0 {
            sessions = sessions.filter { $0.rallyCount >= minPasses }
        }
        
        // Date range filter
        sessions = sessions.filter { session in
            let startDate: Date
            let endDate = Date()
            
            switch dateRange {
            case .today:
                startDate = Calendar.current.startOfDay(for: Date())
            case .last7Days:
                startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            case .last30Days:
                startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            case .last90Days:
                startDate = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
            case .custom:
                startDate = customStartDate
                return session.startTime >= customStartDate && session.startTime <= customEndDate
            case .allTime:
                return true
            }
            
            return session.startTime >= startDate && session.startTime <= endDate
        }
        
        // Sort
        return sortedSessions(sessions)
    }
    
    private func sortedSessions(_ sessions: [Session]) -> [Session] {
        switch sortBy {
        case .dateNewest:
            return sessions.sorted { $0.startTime > $1.startTime }
        case .dateOldest:
            return sessions.sorted { $0.startTime < $1.startTime }
        case .averageHighest:
            return sessions.sorted { $0.teamAverage > $1.teamAverage }
        case .averageLowest:
            return sessions.sorted { $0.teamAverage < $1.teamAverage }
        case .passesHighest:
            return sessions.sorted { $0.rallyCount > $1.rallyCount }
        case .passesLowest:
            return sessions.sorted { $0.rallyCount < $1.rallyCount }
        }
    }
    
    private var hasActiveFilters: Bool {
        selectedTeam != nil ||
        selectedPlayer != nil ||
        minAverage > 0.0 ||
        maxAverage < 3.0 ||
        minPasses > 0 ||
        dateRange != .allTime ||
        sortBy != .dateNewest
    }
    
    private func resetFilters() {
        selectedTeam = nil
        selectedPlayer = nil
        minAverage = 0.0
        maxAverage = 3.0
        minPasses = 0
        dateRange = .allTime
        sortBy = .dateNewest
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue)
        .foregroundStyle(.white)
        .clipShape(Capsule())
    }
}

// MARK: - Enhanced Session Row

struct EnhancedSessionRow: View {
    let session: Session
    
    var body: some View {
        HStack(spacing: 16) {
            // Session icon with performance indicator
            ZStack {
                Circle()
                    .fill(performanceColor.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                VStack(spacing: 2) {
                    Image(systemName: "chart.bar.fill")
                        .font(.title3)
                        .foregroundStyle(performanceColor)
                    
                    Text(String(format: "%.1f", session.teamAverage))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(performanceColor)
                }
            }
            
            // Session info
            VStack(alignment: .leading, spacing: 4) {
                Text(session.teamName)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 4) {
                    Text(session.startTime, style: .date)
                    Text("•")
                    Text(session.startTime, style: .time)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                
                HStack(spacing: 12) {
                    Label("\(session.rallyCount)", systemImage: "arrow.up.circle")
                    Label(String(format: "%.0f%%", session.goodPassPercentage), systemImage: "checkmark.circle")
                    Label(session.durationFormatted, systemImage: "clock")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Performance trend indicator
            VStack(spacing: 4) {
                Image(systemName: performanceIcon)
                    .foregroundStyle(performanceColor)
                    .font(.title3)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var performanceColor: Color {
        let avg = session.teamAverage
        if avg >= 2.5 { return .green }
        if avg >= 2.0 { return .yellow }
        if avg >= 1.5 { return .orange }
        return .red
    }
    
    private var performanceIcon: String {
        let avg = session.teamAverage
        if avg >= 2.5 { return "star.fill" }
        if avg >= 2.0 { return "checkmark.circle.fill" }
        if avg >= 1.5 { return "exclamationmark.triangle.fill" }
        return "xmark.circle.fill"
    }
}

// MARK: - Filter Sheet

struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let teams: [Team]
    @Binding var selectedTeam: Team?
    @Binding var selectedPlayer: Player?
    @Binding var minAverage: Double
    @Binding var maxAverage: Double
    @Binding var minPasses: Int
    @Binding var dateRange: AdvancedSessionFilterView.DateRangeFilter
    @Binding var customStartDate: Date
    @Binding var customEndDate: Date
    @Binding var sortBy: AdvancedSessionFilterView.SortOption
    let onReset: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                // Team filter
                Section {
                    Picker("Team", selection: $selectedTeam) {
                        Text("All Teams").tag(nil as Team?)
                        ForEach(teams) { team in
                            Text(team.name).tag(team as Team?)
                        }
                    }
                    
                    if let team = selectedTeam {
                        Picker("Player", selection: $selectedPlayer) {
                            Text("All Players").tag(nil as Player?)
                            ForEach(team.players) { player in
                                Text("#\(player.number) \(player.name)").tag(player as Player?)
                            }
                        }
                    }
                } header: {
                    Text("Team & Player")
                }
                
                // Average filter
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Range: \(String(format: "%.1f", minAverage)) - \(String(format: "%.1f", maxAverage))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 16) {
                            Text("Min")
                                .frame(width: 40)
                            Slider(value: $minAverage, in: 0...3, step: 0.1)
                            Text(String(format: "%.1f", minAverage))
                                .frame(width: 40)
                        }
                        
                        HStack(spacing: 16) {
                            Text("Max")
                                .frame(width: 40)
                            Slider(value: $maxAverage, in: 0...3, step: 0.1)
                            Text(String(format: "%.1f", maxAverage))
                                .frame(width: 40)
                        }
                    }
                } header: {
                    Text("Average Rating")
                }
                
                // Pass count filter
                Section {
                    Stepper("Minimum: \(minPasses)", value: $minPasses, in: 0...100, step: 5)
                } header: {
                    Text("Pass Count")
                }
                
                // Date range filter
                Section {
                    Picker("Date Range", selection: $dateRange) {
                        ForEach(AdvancedSessionFilterView.DateRangeFilter.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    
                    if dateRange == .custom {
                        DatePicker("Start Date", selection: $customStartDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $customEndDate, displayedComponents: .date)
                    }
                } header: {
                    Text("Date Range")
                }
                
                // Sort options
                Section {
                    Picker("Sort By", selection: $sortBy) {
                        ForEach(AdvancedSessionFilterView.SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } header: {
                    Text("Sort")
                }
                
                // Reset button
                Section {
                    Button(role: .destructive) {
                        onReset()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Reset All Filters")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Filter Sessions")
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
