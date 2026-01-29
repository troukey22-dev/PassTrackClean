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
            }
            .safeAreaInset(edge: .bottom) {
                // Big LOG button
                Button {
                    logPass()
                } label: {
                    Text("LOG PASS FOR #\(player.number) \(player.name.uppercased())")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(selectedScore == nil ? Color.gray : Color(red: 0.545, green: 0.361, blue: 0.965))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(selectedScore == nil)
                .padding()
                .background(Color(.systemBackground))
            }
        }
    }
    
    // MARK: - Pass Score Section
    private var passScoreSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pass Score")
                .font(.headline)
            
            HStack(spacing: 12) {
                PassScoreButtons.tallScoreButton(score: 3, isSelected: selectedScore == 3) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedScore = 3
                    }
                }
                
                PassScoreButtons.tallScoreButton(score: 2, isSelected: selectedScore == 2) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedScore = 2
                    }
                }
                
                PassScoreButtons.tallScoreButton(score: 1, isSelected: selectedScore == 1) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedScore = 1
                    }
                }
                
                PassScoreButtons.tallScoreButton(score: 0, isSelected: selectedScore == 0) {
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
            
            // Get team's zone type
            if let session = dataStore.currentSession,
               let team = dataStore.fetchTeam(byId: session.teamId) {
                HStack(spacing: 12) {
                    ForEach(team.zoneType.zones, id: \.self) { zone in
                        zoneButton(zone: zone)
                    }
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
                .background(selectedZone == zone ? Color(red: 0.545, green: 0.361, blue: 0.965) : Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selectedZone == zone ? Color(red: 0.545, green: 0.361, blue: 0.965) : Color.clear, lineWidth: 2)
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
            HStack(spacing: 12) {
                Image(type == "Platform" ? "platform" : "hands")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                
                Text(type)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .foregroundStyle(selectedContactType == type ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(selectedContactType == type ? Color(red: 0.545, green: 0.361, blue: 0.965) : Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Body Contact Position Section
    private var contactLocationSection: some View {
        VStack(spacing: 12) {
            // Title centered
            VStack(spacing: 4) {
                Text("Body Contact Position")
                    .font(.headline)
                Text("Where on your body did you contact the ball?")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            // 3x3 grid centered - no row labels
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    contactLocationButton(label: "LEFT HIGH", row: "High", position: "Left")
                    contactLocationButton(label: "MID HIGH", row: "High", position: "Mid")
                    contactLocationButton(label: "RIGHT HIGH", row: "High", position: "Right")
                }
                
                HStack(spacing: 8) {
                    contactLocationButton(label: "LEFT WAIST", row: "Waist", position: "Left")
                    contactLocationButton(label: "MID WAIST", row: "Waist", position: "Mid")
                    contactLocationButton(label: "RIGHT WAIST", row: "Waist", position: "Right")
                }
                
                HStack(spacing: 8) {
                    contactLocationButton(label: "LEFT LOW", row: "Low", position: "Left")
                    contactLocationButton(label: "MID LOW", row: "Low", position: "Mid")
                    contactLocationButton(label: "RIGHT LOW", row: "Low", position: "Right")
                }
            }
        }
    }

    private func contactLocationButton(label: String, row: String, position: String) -> some View {
        let locationString = "\(row)-\(position)"
        
        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedContactLocation = locationString
            }
        } label: {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(selectedContactLocation == locationString ? .white : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(selectedContactLocation == locationString ? Color(red: 0.545, green: 0.361, blue: 0.965) : Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Serve Type Section
    private var serveTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Serve Type")
                    .font(.headline)
                Text("Type of serve received")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 12) {
                serveTypeButton(type: "Float")
                serveTypeButton(type: "Spin")
            }
        }
    }
    
    private func serveTypeButton(type: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedServeType = type
            }
        } label: {
            HStack(spacing: 12) {
                Image(type == "Float" ? "floatserve" : "spinserve")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                
                Text(type)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .foregroundStyle(selectedServeType == type ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(selectedServeType == type ? Color(red: 0.545, green: 0.361, blue: 0.965) : Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Actions
    private func logPass() {
        guard let score = selectedScore else { return }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
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
