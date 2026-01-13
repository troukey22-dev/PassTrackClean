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
        .sheet(item: $selectedTeam) { team in
            SessionConfigurationFlow(team: team, isPresented: $showingSelectPassers)
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
                .foregroundStyle(.blue)
            
            Text("No Teams Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Create your first team to start tracking serve-receive performance")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Add players with names and numbers", systemImage: "person.badge.plus")
                Label("Track passes in real-time", systemImage: "chart.line.uptrend.xyaxis")
                Label("Review performance after practice", systemImage: "sparkles")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 40)
            
            Button {
                showingCreateTeam = true
            } label: {
                Text("Create Your First Team")
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

// MARK: - Combined Configuration Flow
struct SessionConfigurationFlow: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(\.dismiss) private var dismiss
    @Bindable var team: Team
    @Binding var isPresented: Bool
    
    @State private var currentStep: ConfigStep = .selectPassers
    @State private var enabledFields: Set<String> = ["zone", "contactType"]
    
    enum ConfigStep {
        case selectPassers
        case configureFields
    }
    
    var body: some View {
        let _ = print("🔍 SessionConfigurationFlow rendering")
        let _ = print("🔍 Team: \(team.name)")
        let _ = print("🔍 Players count: \(team.players.count)")
        let _ = print("🔍 Active players: \(team.activePlayers.count)")

        NavigationStack {
            Group {
                if currentStep == .selectPassers {
                    selectPassersView
                } else {
                    configureFieldsView
                }
            }
        }
    }
    
    // MARK: - Select Passers View
    private var selectPassersView: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Select Active Passers")
                    .font(.headline)
                Text("Tap players to enable/disable for this session")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGroupedBackground))
            
            // Player list
            List {
                ForEach(team.players) { player in
                    PlayerToggleRow(player: player)
                }
            }
            
            // Bottom bar
            VStack(spacing: 12) {
                HStack {
                    Text("Selected: \(team.activePlayers.count) players")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button("Select All") {
                        team.players.forEach { $0.isActive = true }
                    }
                    .font(.subheadline)
                }
                
                Button {
                    withAnimation {
                        currentStep = .configureFields
                    }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(team.activePlayers.isEmpty ? Color.gray : Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(team.activePlayers.isEmpty)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle(team.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    isPresented = false
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Configure Fields View
    private var configureFieldsView: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Data Fields")
                    .font(.headline)
                Text("Select which data to track for each pass")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGroupedBackground))
            
            // Fields list
            List {
                Section {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text("Pass Score")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("Always tracked")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Required")
                }
                
                Section {
                    ForEach(availableFields, id: \.0) { field in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                if enabledFields.contains(field.0) {
                                    enabledFields.remove(field.0)
                                } else {
                                    enabledFields.insert(field.0)
                                }
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(field.1)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                    Text(field.2)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: enabledFields.contains(field.0) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(enabledFields.contains(field.0) ? .blue : .secondary)
                                    .font(.title3)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Optional Fields")
                } footer: {
                    Text("Estimated: \(estimatedTaps) taps per log")
                        .font(.caption)
                }
            }
            
            // Bottom bar
            VStack(spacing: 12) {
                Button {
                    startSession()
                } label: {
                    Text("Start Session")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle("Configure")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Back") {
                    withAnimation {
                        currentStep = .selectPassers
                    }
                }
            }
        }
    }
    
    private let availableFields = [
        ("zone", "Zone", "Court position (5, 6, 1)"),
        ("contactType", "Contact Type", "Platform or Hands"),
        ("contactLocation", "Contact Location", "Where on court contact was made"),
        ("serveType", "Serve Type", "Type of serve received")
    ]
    
    private var estimatedTaps: Int {
        return 1 + enabledFields.count + 1
    }
    
    private func startSession() {
        dataStore.startSession(
            team: team,
            passers: team.activePlayers,
            enabledFields: [
                "zone": enabledFields.contains("zone"),
                "contactType": enabledFields.contains("contactType"),
                "contactLocation": enabledFields.contains("contactLocation"),
                "serveType": enabledFields.contains("serveType")
            ]
        )
        isPresented = false
        dismiss()
    }
}

// MARK: - Player Toggle Row
struct PlayerToggleRow: View {
    @Bindable var player: Player
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                player.isActive.toggle()
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name)
                        .font(.body)
                        .fontWeight(.semibold)
                    Text("#\(player.number) • \(player.position ?? "Player")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: player.isActive ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(player.isActive ? .green : .secondary)
                    .font(.title3)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
                Text("Start Session")
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
