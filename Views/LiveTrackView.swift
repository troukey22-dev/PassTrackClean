//
//  LiveTrackView.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/12/26.
//

import SwiftUI
import SwiftData

struct LiveTrackView: View {
    @Environment(DataStore.self) private var dataStore
    var body: some View {
        NavigationStack {
            if dataStore.currentSession != nil {
                // Show live session grid
                LiveSessionGridView()
            } else {
                // Show team quick start list
                TeamQuickStartView()
            }
        }
    }
}

// MARK: - Team Quick Start List
struct TeamQuickStartView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Team.createdAt, order: .reverse) private var teams: [Team]
    
    @State private var selectedTeam: Team?
    @State private var showingSelectPassers = false
    @State private var showingCreateTeam = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "volleyball.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    Text("Serve-Receive")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Text("Select a team to start live tracking")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGroupedBackground))
            
            // Team list
            if teams.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(teams) { team in
                            QuickStartTeamCard(team: team) {
                                selectedTeam = team
                                showingSelectPassers = true
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingCreateTeam = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingSelectPassers) {
            if let team = selectedTeam {
                SelectPassersView(team: team, isPresented: $showingSelectPassers)
            }
        }
        .sheet(isPresented: $showingCreateTeam) {
            CreateTeamSheet(isPresented: $showingCreateTeam)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "volleyball.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Teams Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Create your first team to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showingCreateTeam = true
            } label: {
                Text("Create Team")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
}

struct QuickStartTeamCard: View {
    let team: Team
    let onQuickStart: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Team icon
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: "person.3.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
            
            // Team info
            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("\(team.players.count) players")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Quick start button
            Button(action: onQuickStart) {
                Text("Quick Start")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

#Preview {
    LiveTrackView()
        .environment(DataStore())
        .modelContainer(for: [Team.self, Player.self, Session.self, Rally.self])
}
