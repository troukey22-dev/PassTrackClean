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
                        .foregroundStyle(Color.appPurple)
                    Text("PerfectPass")
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
                .background(Color(.systemGroupedBackground))
            }
        }
        .background(Color(.systemGroupedBackground))
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
        ScrollView {
            VStack(spacing: 24) {
                // Spacer for top padding
                Spacer()
                    .frame(height: 60)
                
                // Mascot
                Image("sitting")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                // Title
                Text("No Teams Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Description
                Text("Create your first team to start tracking serve-receive performance")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Features card
                VStack(alignment: .leading, spacing: 12) {
                    Label("Add players with names and numbers", systemImage: "person.badge.plus")
                    Label("Track passes in real-time", systemImage: "chart.line.uptrend.xyaxis")
                    Label("Review performance after practice", systemImage: "sparkles")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                .padding(.horizontal)
                
                // CTA Button
                Button {
                    showingCreateTeam = true
                } label: {
                    Text("Create Your First Team")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.545, green: 0.361, blue: 0.965))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Spacer()
            }
        }
        .background(Color(.systemGroupedBackground))
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
            let _ = print("Ã°Å¸â€Â SessionConfigurationFlow rendering")
            let _ = print("Ã°Å¸â€Â Team: \(team.name)")
            let _ = print("Ã°Å¸â€Â Players count: \(team.players.count)")
            let _ = print("Ã°Å¸â€Â Active players: \(team.activePlayers.count)")
            
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
                // Mascot "message" header
                HStack(alignment: .top, spacing: 16) {
                    // Mascot in circle (using new circular icon)
                    Image("circleclipboard1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                    
                    // Speech bubble with question
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Who's passing today?")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("Tap players to select them for this session")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(
                        SpeechBubble(tailPosition: .left)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    )
                    .padding(.leading, 8) // Space for the tail to point left
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Player cards
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(team.players) { player in
                            PlayerSelectionCard(player: player)
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
                
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
                        .foregroundStyle(Color.appPurple)
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
                            .background(team.activePlayers.isEmpty ? Color.gray : Color.appPurple)
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
                // Mascot "message" header
                HStack(alignment: .top, spacing: 16) {
                    // Mascot in circle
                    Image("circleclipboard2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                    
                    // Speech bubble with question
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What do you want to track?")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("Pass score is always tracked. Select optional fields below:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(
                        SpeechBubble(tailPosition: .left)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    )
                    .padding(.leading, 8)
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Optional fields
                ScrollView {
                    VStack(spacing: 12) {
                        FieldSelectionCard(
                            title: "Zone",
                            description: zoneDescription,
                            icon: "square.grid.3x3",
                            isSelected: enabledFields.contains("zone")
                        ) {
                            toggleField("zone")
                        }
                        
                        FieldSelectionCard(
                            title: "Contact Type",
                            description: "Platform or Hands",
                            icon: "hand.raised.fill",
                            isSelected: enabledFields.contains("contactType")
                        ) {
                            toggleField("contactType")
                        }
                        
                        FieldSelectionCard(
                            title: "Contact Location",
                            description: "Where on body contact was made",
                            icon: "figure.stand",
                            isSelected: enabledFields.contains("contactLocation")
                        ) {
                            toggleField("contactLocation")
                        }
                        
                        FieldSelectionCard(
                            title: "Serve Type",
                            description: "Float or Spin serve",
                            icon: "arrow.up.circle",
                            isSelected: enabledFields.contains("serveType")
                        ) {
                            toggleField("serveType")
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
                
                // Bottom bar
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                        Text("More fields = more taps per pass")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    
                    Button {
                        startSession()
                    } label: {
                        Text("Start Session")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.545, green: 0.361, blue: 0.965))
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
        
        private func toggleField(_ field: String) {
            withAnimation(.spring(response: 0.3)) {
                if enabledFields.contains(field) {
                    enabledFields.remove(field)
                } else {
                    enabledFields.insert(field)
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
        
        private var zoneDescription: String {
            switch team.zoneType {
            case .indoor:
                return "Court position (5, 6, 1)"
            case .beach:
                return "Beach position (Left, Right)"
            }
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
                        Text("#\(player.number) Ã¢â‚¬Â¢ \(player.position ?? "Player")")
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
                // Team icon with custom colors
                Circle()
                    .fill(Color(hex: team.backgroundColor))
                    .frame(width: 56, height: 56)
                    .overlay {
                        Image("headband-\(team.mascotColor)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 46, height: 46)
                            .offset(y: 2)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                
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
                        .background(Color.appPurple)
                        .clipShape(Capsule())
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
    }
    // MARK: - Player Selection Card
    struct PlayerSelectionCard: View {
        @Bindable var player: Player
        
        var body: some View {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    player.isActive.toggle()
                }
            } label: {
                HStack(spacing: 16) {
                    // Player info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(player.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(player.isActive ? .white : .primary)
                        
                        if let position = player.position {
                            Text(position)
                                .font(.subheadline)
                                .foregroundStyle(player.isActive ? .white.opacity(0.85) : .secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Checkmark circle
                    ZStack {
                        Circle()
                            .fill(player.isActive ? Color.white : Color(.systemGray5))
                            .frame(width: 28, height: 28)
                        
                        if player.isActive {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.appPurple)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(player.isActive ? .appPurple : Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(player.isActive ? Color.clear : Color(.systemGray4), lineWidth: 2)
                )
                .shadow(color: player.isActive ? .appPurple.opacity(0.3) : Color.black.opacity(0.05), radius: player.isActive ? 8 : 2, y: 2)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Field Selection Card
    struct FieldSelectionCard: View {
        let title: String
        let description: String
        let icon: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 16) {
                    // Icon
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(isSelected ? .white : Color.appPurple)
                        .frame(width: 30)
                    
                    // Text
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(isSelected ? .white : .primary)
                        
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(isSelected ? .white.opacity(0.85) : .secondary)
                    }
                    
                    Spacer()
                    
                    // Checkmark circle
                    ZStack {
                        Circle()
                            .fill(isSelected ? Color.white : Color(.systemGray5))
                            .frame(width: 28, height: 28)
                        
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.appPurple)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(isSelected ? .appPurple : Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 2)
                )
                .shadow(color: isSelected ? .appPurple.opacity(0.3) : Color.black.opacity(0.05), radius: isSelected ? 8 : 2, y: 2)
            }
            .buttonStyle(.plain)
        }
    }
    
    #Preview {
        LiveTrackView()
            .environment(DataStore())
            .modelContainer(for: [Team.self, Player.self, Session.self, Rally.self])
    }
}
