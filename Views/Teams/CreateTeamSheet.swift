//
//  CreateTeamSheet.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/8/26.
//

import SwiftUI

struct CreateTeamSheet: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    
    @State private var currentStep: CreationStep = .teamInfo
    @State private var teamName: String = ""
    @State private var selectedZoneType: ZoneType = .indoor
    @State private var selectedMascotColor: String = "purple"
    @State private var selectedBackgroundColor: String = "#8B5CF6"
    @State private var players: [PlayerDraft] = []
    @State private var showingAddPlayer = false
    @State private var isMovingForward = true
    
    enum CreationStep: Int, CaseIterable {
        case teamInfo = 0
        case zoneType = 1
        case customizeColors = 2
        case addPlayers = 3
        case success = 4
        
        var title: String {
            switch self {
            case .teamInfo: return "Info"
            case .zoneType: return "Zone"
            case .customizeColors: return "Colors"
            case .addPlayers: return "Roster"
            case .success: return "Done"
            }
        }
    }
    
    struct PlayerDraft: Identifiable {
        let id = UUID()
        var name: String
        var number: Int
        var position: String
    }
    
    let mascotColors = ["purple", "blue", "green", "red", "orange", "pink", "yellow", "navy", "black", "grey"]
    
    let backgroundColors: [(name: String, hex: String)] = [
        ("Purple", "#8B5CF6"),
        ("Blue", "#3B82F6"),
        ("Green", "#10B981"),
        ("Red", "#EF4444"),
        ("Orange", "#F97316"),
        ("Pink", "#EC4899"),
        ("Yellow", "#FBBF24"),
        ("Teal", "#14B8A6"),
        ("Indigo", "#6366F1"),
        ("Rose", "#F43F5E"),
        ("Cyan", "#06B6D4"),
        ("Emerald", "#059669")
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom header with title and cancel button
                HStack {
                    Button("Cancel") {
                        isPresented = false
                        dismiss()
                    }
                    .foregroundStyle(Color(red: 0.545, green: 0.361, blue: 0.965))
                    .opacity(currentStep == .success ? 0 : 1)
                    
                    Spacer()
                    
                    Text("Create Team")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    // Invisible button for symmetry
                    Button("Cancel") {
                    }
                    .foregroundStyle(Color(red: 0.545, green: 0.361, blue: 0.965))
                    .opacity(0)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 12)
                .background(Color(.systemGroupedBackground))
                
                // Progress dots
                progressIndicator
                
                // Current step view
                Group {
                    switch currentStep {
                    case .teamInfo:
                        teamInfoStep
                    case .zoneType:
                        zoneTypeStep
                    case .customizeColors:
                        customizeColorsStep
                    case .addPlayers:
                        addPlayersStep
                    case .success:
                        successStep
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: isMovingForward ? .trailing : .leading).combined(with: .opacity),
                    removal: .move(edge: isMovingForward ? .leading : .trailing).combined(with: .opacity)
                ))
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(CreationStep.allCases, id: \.self) { step in
                Circle()
                    .fill(step.rawValue <= currentStep.rawValue ? Color(red: 0.545, green: 0.361, blue: 0.965) : Color(.systemGray4))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Step 1: Team Info
    private var teamInfoStep: some View {
        VStack(spacing: 0) {
            // Mascot header
            HStack(alignment: .top, spacing: 16) {
                Image("circleclipboard1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Let's create your team!")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("Start by giving your team a name")
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
            
            // Form
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Team Name")
                            .font(.headline)
                        
                        TextField("Enter team name", text: $teamName)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            
            Spacer()
            
            // Bottom button
            VStack {
                Button {
                    isMovingForward = true
                    withAnimation {
                        currentStep = .zoneType
                    }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(teamName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color(red: 0.545, green: 0.361, blue: 0.965))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(teamName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Step 2: Zone Type
    private var zoneTypeStep: some View {
        VStack(spacing: 0) {
            // Mascot header
            HStack(alignment: .top, spacing: 16) {
                Image("circleclipboard2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("What type of volleyball?")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("This determines court positions for tracking")
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
            
            // Zone type selection
            ScrollView {
                VStack(spacing: 12) {
                    ZoneTypeCard(
                        zoneType: .indoor,
                        isSelected: selectedZoneType == .indoor
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedZoneType = .indoor
                        }
                    }
                    
                    ZoneTypeCard(
                        zoneType: .beach,
                        isSelected: selectedZoneType == .beach
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedZoneType = .beach
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            
            Spacer()
            
            // Bottom buttons
            VStack(spacing: 12) {
                Button {
                    isMovingForward = true
                    withAnimation {
                        currentStep = .customizeColors
                    }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.545, green: 0.361, blue: 0.965))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    isMovingForward = false
                    withAnimation {
                        currentStep = .teamInfo
                    }
                } label: {
                    Text("Back")
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.545, green: 0.361, blue: 0.965))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.545, green: 0.361, blue: 0.965), lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Step 3: Customize Colors
    private var customizeColorsStep: some View {
        VStack(spacing: 0) {
            // Mascot header
            HStack(alignment: .top, spacing: 16) {
                Image("circleclipboard1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose your team colors!")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("Pick a mascot color and background")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    SpeechBubble(tailPosition: .left)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                )
                .padding(.leading, 8)
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            
            // Color selection
            ScrollView {
                VStack(spacing: 32) {
                    // Preview
                    VStack(spacing: 12) {
                        Text("PREVIEW")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        Circle()
                            .fill(Color(hex: selectedBackgroundColor))
                            .frame(width: 120, height: 120)
                            .overlay {
                                Image("headband-\(selectedMascotColor)")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .offset(y: 2)
                            }
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                    }
                    
                    // Mascot Color Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("MASCOT COLOR")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(mascotColors, id: \.self) { color in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedMascotColor = color
                                        }
                                    } label: {
                                        VStack(spacing: 8) {
                                            Image("headband-\(color)")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                                .overlay(
                                                    Circle()
                                                        .stroke(selectedMascotColor == color ? Color(red: 0.545, green: 0.361, blue: 0.965) : Color.clear, lineWidth: 3)
                                                )
                                            
                                            Text(color.capitalized)
                                                .font(.caption2)
                                                .foregroundStyle(selectedMascotColor == color ? Color(red: 0.545, green: 0.361, blue: 0.965) : .secondary)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                    }
                    
                    // Background Color Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("BACKGROUND COLOR")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(backgroundColors, id: \.hex) { bgColor in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedBackgroundColor = bgColor.hex
                                        }
                                    } label: {
                                        VStack(spacing: 8) {
                                            Circle()
                                                .fill(Color(hex: bgColor.hex))
                                                .frame(width: 60, height: 60)
                                                .overlay(
                                                    Circle()
                                                        .stroke(selectedBackgroundColor == bgColor.hex ? Color(red: 0.545, green: 0.361, blue: 0.965) : Color.clear, lineWidth: 3)
                                                )
                                            
                                            Text(bgColor.name)
                                                .font(.caption2)
                                                .foregroundStyle(selectedBackgroundColor == bgColor.hex ? Color(red: 0.545, green: 0.361, blue: 0.965) : .secondary)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            
            Spacer()
            
            // Bottom buttons
            VStack(spacing: 12) {
                Button {
                    isMovingForward = true
                    withAnimation {
                        currentStep = .addPlayers
                    }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.545, green: 0.361, blue: 0.965))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    isMovingForward = false
                    withAnimation {
                        currentStep = .zoneType
                    }
                } label: {
                    Text("Back")
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.545, green: 0.361, blue: 0.965))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.545, green: 0.361, blue: 0.965), lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Step 4: Add Players
    private var addPlayersStep: some View {
        VStack(spacing: 0) {
            // Mascot header
            HStack(alignment: .top, spacing: 16) {
                Image("circleclipboard1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Who's on the team?")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("Add players to your roster (you can add more later)")
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
            
            // Player list
            if players.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image("sitting")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    Text("No players yet")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("Tap the button below to add your first player")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            }
            else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(players) { player in
                            PlayerDraftRow(player: player) {
                                if let index = players.firstIndex(where: { $0.id == player.id }) {
                                    withAnimation {
                                        players.remove(at: index)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
            }
            
            // Bottom buttons
            VStack(spacing: 12) {
                Button {
                    showingAddPlayer = true
                } label: {
                    Label("Add Player", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.545, green: 0.361, blue: 0.965))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                HStack(spacing: 12) {
                    Button {
                        isMovingForward = false
                        withAnimation {
                            currentStep = .customizeColors
                        }
                    } label: {
                        Text("Back")
                            .font(.subheadline)
                            .foregroundStyle(Color(red: 0.545, green: 0.361, blue: 0.965))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.545, green: 0.361, blue: 0.965), lineWidth: 2)
                            )
                    }
                    
                    Button {
                        createTeamAndFinish()
                    } label: {
                        Text("Create Team")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(players.isEmpty ? Color.gray : Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(players.isEmpty)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showingAddPlayer) {
            AddPlayerSheet(isPresented: $showingAddPlayer) { name, number, position in
                players.append(PlayerDraft(name: name, number: number, position: position))
            }
        }
    }
    
    // MARK: - Step 5: Success
    private var successStep: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Success mascot
            Image("hype")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            
            VStack(spacing: 12) {
                Text("Team Created! 🎉")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("\(teamName) is ready to go!")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("\(players.count) player\(players.count == 1 ? "" : "s") added")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("\(selectedZoneType.rawValue) mode")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Custom team colors set")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Ready for live tracking")
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            
            Spacer()
            
            // Done button
            VStack {
                Button {
                    isPresented = false
                    dismiss()
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.545, green: 0.361, blue: 0.965))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Actions
    private func createTeamAndFinish() {
        let playerObjects = players.map { draft in
            Player(name: draft.name, number: draft.number, position: draft.position)
        }
        
        dataStore.createTeam(
            name: teamName,
            players: playerObjects,
            zoneType: selectedZoneType,
            mascotColor: selectedMascotColor,
            backgroundColor: selectedBackgroundColor
        )
        
        withAnimation {
            currentStep = .success
        }
    }
}

// MARK: - Zone Type Card
struct ZoneTypeCard: View {
    let zoneType: ZoneType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: zoneType == .indoor ? "building.2.fill" : "sun.max.fill")
                        .font(.title)
                        .foregroundStyle(isSelected ? .white : Color(red: 0.545, green: 0.361, blue: 0.965))
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(isSelected ? Color.white : Color(.systemGray5))
                            .frame(width: 28, height: 28)
                        
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color(red: 0.545, green: 0.361, blue: 0.965))
                        }
                    }
                }
                
                Text(zoneType.rawValue)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(isSelected ? .white : .primary)
                
                Text(zoneType == .indoor ? "Uses zones 5, 6, and 1" : "Uses Left and Right positions")
                    .font(.subheadline)
                    .foregroundStyle(isSelected ? .white.opacity(0.85) : .secondary)
            }
            .padding()
            .background(isSelected ? Color(red: 0.545, green: 0.361, blue: 0.965) : Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 2)
            )
            .shadow(color: isSelected ? Color(red: 0.545, green: 0.361, blue: 0.965).opacity(0.3) : Color.black.opacity(0.05), radius: isSelected ? 8 : 2, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Player Draft Row
struct PlayerDraftRow: View {
    let player: CreateTeamSheet.PlayerDraft
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color(red: 0.545, green: 0.361, blue: 0.965).opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay {
                    Text("#\(player.number)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(red: 0.545, green: 0.361, blue: 0.965))
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(player.position)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
