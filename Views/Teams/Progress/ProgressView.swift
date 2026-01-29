//
//  ProgressView.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/8/26.
//

import SwiftUI
import SwiftData

struct ProgressView: View {
    @Environment(DataStore.self) private var dataStore
    @Query(sort: \Team.createdAt, order: .reverse) private var teams: [Team]
    @Query(sort: \Session.startTime, order: .reverse) private var allSessions: [Session]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if allSessions.isEmpty && dataStore.currentSession == nil {
                    emptyState
                } else {
                    VStack(spacing: 24) {
                        // Current Session (if active)
                        if let session = dataStore.currentSession {
                            currentSessionCard(session: session)
                        }
                        
                        // Teams Section
                        if !teams.isEmpty {
                            teamsSection
                        }
                        
                        // Recent Sessions Section
                        if !allSessions.isEmpty {
                            recentSessionsSection
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Team Stats")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: - Current Session Card
    private func currentSessionCard(session: Session) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                Text("CURRENT SESSION")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            NavigationLink {
                // Navigate to live track (session is already active)
                EmptyView()
            } label: {
                HStack(spacing: 16) {
                    Circle()
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 56, height: 56)
                        .overlay {
                            Image(systemName: "record.circle")
                                .font(.title3)
                                .foregroundStyle(.red)
                        }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.teamName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        HStack(spacing: 12) {
                            Text("\(session.rallyCount) passes")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            if session.rallyCount > 0 {
                                Text("â€¢")
                                    .foregroundStyle(.secondary)
                                Text(String(format: "%.2f avg", session.teamAverage))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Text(session.durationFormatted + " elapsed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("LIVE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Capsule())
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Teams Section
    private var teamsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TEAMS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            // Show first 3 teams
            ForEach(teams.prefix(3)) { team in
                NavigationLink {
                    TeamDetailView(team: team)
                } label: {
                    TeamCard(team: team, sessions: sessionsForTeam(team))
                }
                .buttonStyle(.plain)
            }
            
            // "View All Teams" button if more than 3
            if teams.count > 3 {
                NavigationLink {
                    AllTeamsView()
                } label: {
                    HStack {
                        Text("View All Teams (\(teams.count))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appPurple)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
            }
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
            
            // Show first 5 sessions
            ForEach(allSessions.prefix(5)) { session in
                NavigationLink {
                    SessionDetailView(session: session)
                } label: {
                    SessionRow(session: session)
                }
                .buttonStyle(.plain)
            }
            
            // "View All Sessions" button if more than 5, this was removced so filter always shows
                NavigationLink {
                    AdvancedSessionFilterView()
                } label: {
                    HStack {
                        Text("View All Sessions (\(allSessions.count))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appPurple)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image("graph")  // Change to "question" or "graph" potentially
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            
            Text("No Sessions Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Start tracking a practice session to see detailed stats and player performance")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Real-time pass tracking", systemImage: "clock.fill")
                Label("Individual player stats", systemImage: "person.fill")
                Label("Team performance trends", systemImage: "chart.line.uptrend.xyaxis")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Helper Functions
    private func sessionsForTeam(_ team: Team) -> [Session] {
        allSessions.filter { $0.teamId == team.id }
    }
}

// MARK: - Team Card Component
struct TeamCard: View {
    let team: Team
    let sessions: [Session]
    
    var body: some View {
        HStack(spacing: 16) {
            // Team icon with custom colors
            Circle()
                .fill(Color(hex: team.backgroundColor))
                .frame(width: 56, height: 56)
                .overlay {
                    Image("headband-\(team.mascotColor)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 46, height: 46)
                }
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            
            // Team info
            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                if !sessions.isEmpty {
                    HStack(spacing: 8) {
                        Text("\(sessions.count) sessions")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("•")
                            .foregroundStyle(.secondary)
                        
                        Text(String(format: "%.1f avg", teamAverage))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("No sessions yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if let lastSession = sessions.first {
                    Text("Last: \(lastSession.startTime, style: .relative) ago")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .padding(.horizontal)
    }
    
    private var teamAverage: Double {
        guard !sessions.isEmpty else { return 0.0 }
        let totalAvg = sessions.reduce(0.0) { $0 + $1.teamAverage }
        return totalAvg / Double(sessions.count)
    }
}

// MARK: - Session Row Component
struct SessionRow: View {
    let session: Session
    
    var body: some View {
        HStack(spacing: 16) {
            // Session icon
            Circle()
                .fill(Color.appPurple.opacity(0.1))
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: "chart.bar.fill")
                        .font(.title3)
                        .foregroundStyle(Color.appPurple)
                }
            
            // Session info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(session.teamName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text("â€¢")
                        .foregroundStyle(.secondary)
                    
                    Text(session.startTime, style: .date)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 8) {
                    Text("\(session.rallyCount) passes")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("â€¢")
                        .foregroundStyle(.secondary)
                    
                    Text(String(format: "%.1f avg", session.teamAverage))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - All Teams View (Placeholder)
struct AllTeamsView: View {
    @Query(sort: \Team.createdAt, order: .reverse) private var teams: [Team]
    @Query(sort: \Session.startTime, order: .reverse) private var allSessions: [Session]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(teams) { team in
                    let teamSessions = allSessions.filter { $0.teamId == team.id }
                    NavigationLink {
                        TeamDetailView(team: team)
                    } label: {
                        TeamCard(team: team, sessions: teamSessions)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("All Teams")
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - All Sessions View (Placeholder)
struct AllSessionsView: View {
    @Query(sort: \Session.startTime, order: .reverse) private var allSessions: [Session]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(allSessions) { session in
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



#Preview {
    ProgressView()
        .environment(DataStore())
        .modelContainer(for: [Team.self, Player.self, Session.self, Rally.self])
}
