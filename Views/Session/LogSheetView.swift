//
//  LogSheetView.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/8/26.
//

import SwiftUI
import SwiftData

struct LogSheetView: View {
    @Environment(DataStore.self) private var dataStore
    @Bindable var player: Player
    @Binding var isPresented: Bool
    
    @State private var selectedScore: Int? = nil
    @State private var selectedZone: String? = nil
    @State private var selectedContactType: String? = nil
    @State private var selectedContactLocation: String? = nil
    @State private var selectedServeType: String? = nil
    
    var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Player header
                        playerHeader
                        
                        // Pass Score (Required)
                        passScoreSection
                        
                        // Optional fields (if enabled in current session)
                        if let session = dataStore.currentSession {
                            if session.trackZone {
                                zoneSection
                            }
                            
                            if session.trackContactType {
                                contactTypeSection
                            }
                            
                            if session.trackContactLocation {
                                contactLocationSection
                            }
                            
                            if session.trackServeType {
                                serveTypeSection
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Log Pass")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isPresented = false
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Log") {
                            logPass()
                        }
                        .fontWeight(.semibold)
                        .disabled(selectedScore == nil)
                    }
                }
            }
        }
    
    // MARK: - Player Header
    private var playerHeader: some View {
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
                    .font(.title3)
                    .fontWeight(.bold)
                
                if let position = player.position {
                    Text(position)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Pass Score Section
    private var passScoreSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pass Score")
                .font(.headline)
            
            // 2x2 grid of score buttons
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                PassScoreButtons.scoreButton(score: 3, isSelected: selectedScore == 3) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedScore = 3
                    }
                }
                
                PassScoreButtons.scoreButton(score: 2, isSelected: selectedScore == 2) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedScore = 2
                    }
                }
                
                PassScoreButtons.scoreButton(score: 1, isSelected: selectedScore == 1) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedScore = 1
                    }
                }
                
                PassScoreButtons.scoreButton(score: 0, isSelected: selectedScore == 0) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedScore = 0
                    }
                }
            }
        }
    }
    
    // MARK: - Zone Section
    private var zoneSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Zone")
                .font(.headline)
            
            HStack(spacing: 12) {
                ForEach(["5", "6", "1"], id: \.self) { zone in
                    zoneButton(zone: zone)
                }
            }
        }
    }
    
    private func zoneButton(zone: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedZone = zone
            }
        } label: {
            Text(zone)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(selectedZone == zone ? .white : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(selectedZone == zone ? Color.blue : Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selectedZone == zone ? Color.blue : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Contact Type Section
    private var contactTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact Type")
                .font(.headline)
            
            HStack(spacing: 12) {
                contactTypeButton(type: "Platform")
                contactTypeButton(type: "Hands")
            }
        }
    }
    
    private func contactTypeButton(type: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedContactType = type
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: type == "Platform" ? "hand.raised.fill" : "hand.point.up.left.fill")
                    .font(.title2)
                Text(type)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundStyle(selectedContactType == type ? .white : .primary)
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(selectedContactType == type ? Color.blue : Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Contact Location Section
    private var contactLocationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact Location")
                .font(.headline)
            
            // 3x3 grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(1...9, id: \.self) { position in
                    contactLocationButton(position: position)
                }
            }
        }
    }
    
    private func contactLocationButton(position: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedContactLocation = "\(position)"
            }
        } label: {
            Text("\(position)")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(selectedContactLocation == "\(position)" ? .white : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(selectedContactLocation == "\(position)" ? Color.blue : Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Serve Type Section
    private var serveTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Serve Type")
                .font(.headline)
            
            VStack(spacing: 12) {
                serveTypeButton(type: "Float")
                serveTypeButton(type: "Jump")
                serveTypeButton(type: "Jump Spin")
            }
        }
    }
    
    private func serveTypeButton(type: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedServeType = type
            }
        } label: {
            Text(type)
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(selectedServeType == type ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedServeType == type ? Color.blue : Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Actions
    private func logPass() {
        guard let score = selectedScore else { return }
        
        dataStore.logPass(
            player: player,
            score: score,
            zone: selectedZone,
            contactType: selectedContactType,
            contactLocation: selectedContactLocation,
            serveType: selectedServeType
        )
        
        isPresented = false
    }
}

#Preview {
    @Previewable @State var isPresented = true
    let player = Player(name: "Smith", number: 4, position: "Libero")
    
    return LogSheetView(
        player: player,
        isPresented: $isPresented
    )
    .environment(DataStore())
    .modelContainer(for: [Team.self, Player.self, Session.self, Rally.self])
}
