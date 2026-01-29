//
//  LiveSessionGridView.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/12/26.
//

import SwiftUI
import Combine

struct LiveSessionGridView: View {
    @Environment(DataStore.self) private var dataStore
    @State private var selectedPlayer: Player?
    @State private var showingLogSheet = false
    @State private var showingEndSession = false
    @State private var passers: [Player] = []
    @State private var currentTime = Date()
    @State private var showingUndoToast = false
    @State private var undoMessage = ""
    
    // Timer that fires every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if let session = dataStore.currentSession {
                                    // Title header with End Session button
                                    HStack {
                                        Image(systemName: "volleyball.fill")
                                            .font(.title2)
                                            .foregroundStyle(Color.appPurple)
                                        Text("Serve-Receive")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        Spacer()
                                        
                                        Button {
                                            showingEndSession = true
                                        } label: {
                                            Text("End Session")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.red)
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemBackground))
                                    
                                    // Header with timer
                                    sessionHeader(session: session)                                    .background(Color(.systemBackground))
                    // Live tracking indicator
                    HStack {
                        Text("TEAM LIVE FEED")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        Spacer()
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text("LIVE TRACKING")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                    
                    // Player grid
                    ScrollView {
                        LazyVGrid(columns: gridColumns, spacing: gridSpacing) {
                            ForEach(passers) { player in
                                Button {
                                    // Haptic feedback on tile press
                                    let impact = UIImpactFeedbackGenerator(style: .medium)
                                    impact.impactOccurred()
                                    
                                    selectedPlayer = player
                                    showingLogSheet = true
                                } label: {
                                    LivePlayerTile(player: player, isCompact: dataStore.settings.gridColumns == 3)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                        .id(dataStore.refreshTrigger)
                        .padding()
                    }
                    .background(Color(.systemBackground))
                    
                    // Bottom bar with Undo
                    HStack(spacing: 12) {
                        Button {
                            performUndo()
                        } label: {
                            Label("Undo Last Pass", systemImage: "arrow.uturn.backward")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(session.rallyCount > 0 ? Color.orange : Color.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(session.rallyCount == 0)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                }
            }
            
            // Undo toast
            if showingUndoToast {
                VStack {
                    Spacer()
                    Text(undoMessage)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
                    // Toolbar items removed - title and button now in content
                }
        .sheet(isPresented: $showingLogSheet) {
            if let player = selectedPlayer {
                LogSheetView(player: player, isPresented: $showingLogSheet)
            }
        }
        .alert("End Session?", isPresented: $showingEndSession) {
            Button("Cancel", role: .cancel) { }
            Button("End Session", role: .destructive) {
                endSession()
            }
        } message: {
            if let session = dataStore.currentSession {
                Text("\(session.rallyCount) passes logged • \(session.durationFormatted) elapsed")
            }
        }
        .onAppear {
            loadPassers()
        }
        .onChange(of: dataStore.currentSession) { _, newSession in
            if newSession != nil {
                loadPassers()
            }
        }
        .onReceive(timer) { time in
            currentTime = time
        }
    }
    
    private var gridColumns: [GridItem] {
        let columns = dataStore.settings.gridColumns
        return Array(repeating: GridItem(.flexible()), count: columns)
    }
    
    private var gridSpacing: CGFloat {
        return dataStore.settings.gridColumns == 3 ? 12 : 16
    }
    
    private func loadPassers() {
        passers = dataStore.currentSessionPassers
    }
    
    private func performUndo() {
        guard let session = dataStore.currentSession else { return }
        guard let lastRally = session.rallies.last else { return }
        
        // Get player name for toast message
        if let player = passers.first(where: { $0.id == lastRally.playerId }) {
            undoMessage = "Undid pass for \(player.name)"
        } else {
            undoMessage = "Undid last pass"
        }
        
        // Perform undo
        dataStore.undoLastLog()
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Show toast
        withAnimation {
            showingUndoToast = true
        }
        
        // Hide toast after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showingUndoToast = false
            }
        }
    }
    
    private func sessionHeader(session: Session) -> some View {
        VStack(spacing: 0) {
            // Timer card with stats
            VStack(spacing: 12) {
                // Timer
                HStack(spacing: 8) {
                    VStack(spacing: 2) {
                        Text(String(format: "%02d", Int(session.duration) / 60))
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appPurple)
                        Text("MIN")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(":")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 10)
                    
                    VStack(spacing: 2) {
                        Text(String(format: "%02d", Int(session.duration) % 60))
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appPurple)
                        Text("SEC")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                }
                .monospacedDigit()
                .id(currentTime)
                
                // Always show stats row for consistent height
                HStack(spacing: 24) {
                    VStack(spacing: 2) {
                        Text(session.rallyCount > 0 ? "\(session.rallyCount)" : "—")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("Passes")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(spacing: 2) {
                        Text(session.rallyCount > 0 ? String(format: "%.2f", session.teamAverage) : "—")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(session.rallyCount > 0 ? teamAverageColor(session.teamAverage) : .primary)
                        Text("Avg Rating")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(spacing: 2) {
                        Text(session.rallyCount > 0 ? "\(Int(session.goodPassPercentage))%" : "—")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("Good Pass")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.08), radius: 10, y: 3)
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Divider
            Divider()
                .padding(.top, 12)
        }
    }
    
    private func teamAverageColor(_ average: Double) -> Color {
        if average >= 2.5 { return .green }
        if average >= 2.0 { return .orange }
        return .red
    }
    
    private func endSession() {
        dataStore.completeSession()
    }
}

struct LivePlayerTile: View {
    @Bindable var player: Player
    let isCompact: Bool
    
    var body: some View {
        VStack(spacing: isCompact ? 8 : 12) {
            // Player info header
            HStack {
                Text("#\(player.number)")
                    .font(isCompact ? .body : .title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appPurple)
                Spacer()
                Text(player.name.uppercased())
                    .font(isCompact ? .caption2 : .caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            // Circular progress with average
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: isCompact ? 8 : 10)
                
                Circle()
                    .trim(from: 0, to: progressValue)
                    .stroke(performanceColor, style: StrokeStyle(lineWidth: isCompact ? 8 : 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progressValue)
                
                VStack(spacing: 2) {
                    if player.passCount > 0 {
                        Text(String(format: "%.1f", player.average))
                            .font(.system(size: isCompact ? 28 : 36, weight: .bold, design: .rounded))
                            .animation(.easeInOut(duration: 0.3), value: player.average)
                    } else {
                        Text("—")
                            .font(.system(size: isCompact ? 28 : 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    Text("AVG RATING")
                        .font(.system(size: isCompact ? 8 : 9, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: isCompact ? 90 : 110)
        }
        .padding(isCompact ? 12 : 16)
        .background(tileBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: isCompact ? 12 : 16))
        .overlay(
            RoundedRectangle(cornerRadius: isCompact ? 12 : 16)
                .stroke(tileBorderColor, lineWidth: 2)
        )
        .shadow(color: tileShadowColor, radius: 8, y: 4)
    }
    
    private var progressValue: Double {
        guard player.passCount > 0 else { return 0 }
        return min(max(player.average / 3.0, 0), 1.0)
    }
    
    private var performanceColor: Color {
        guard player.passCount > 0 else { return .gray }
        let avg = player.average
        if avg >= 2.5 { return .scorePerfect }
        if avg >= 2.0 { return .scoreGood }
        if avg >= 1.5 { return .scorePoor }
        return .scoreAce
    }
    
    private var tileBackgroundColor: Color {
        return Color(.secondarySystemBackground)
    }
    
    private var tileBorderColor: Color {
        guard player.passCount > 0 else { return Color(.systemGray4) }
        return performanceColor
    }
    
    private var tileShadowColor: Color {
        guard player.passCount > 0 else { return .clear }
        return performanceColor.opacity(0.3)
    }
}

// Custom button style for scale animation
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
        LiveSessionGridView()
            .environment(DataStore())
    }
}
