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
    @State private var refreshID = UUID()
    
    // Timer that fires every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            if let session = dataStore.currentSession {
                // Header with timer
                sessionHeader(session: session)
                    .padding()
                    .background(Color(.systemGroupedBackground))
                
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
                
                // Player grid
                ScrollView {
                    LazyVGrid(columns: [
                                            GridItem(.flexible()),
                                            GridItem(.flexible())
                                        ], spacing: 16) {
                                            ForEach(passers) { player in
                                                LivePlayerTile(player: player)
                                                    .onTapGesture {
                                                        selectedPlayer = player
                                                        showingLogSheet = true
                                                    }
                                            }
                                        }
                                        .id(refreshID)
                                        .padding()                }
            }
        }
        .navigationTitle("Serve-Receive")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingEndSession = true
                } label: {
                    Text("End Session")
                        .foregroundStyle(.red)
                        .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingLogSheet, onDismiss: {
                    // Refresh passers to trigger tile updates
                    loadPassers()
                }) {
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
                    // Also refresh to pick up any player stat changes
                    refreshID = UUID()
                }
    }
    
    private func loadPassers() {
        guard let session = dataStore.currentSession else { return }
        passers = dataStore.getPassers(for: session)
    }
    
    private func sessionHeader(session: Session) -> some View {
        VStack(spacing: 12) {
            // Timer - now updates every second via currentTime state
            Text(session.durationFormatted)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .monospacedDigit()
                .id(currentTime) // Force refresh when currentTime changes
            
            // Stats
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text("\(session.rallyCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Passes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if session.rallyCount > 0 {
                    VStack(spacing: 4) {
                        Text(String(format: "%.2f", session.teamAverage))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(teamAverageColor(session.teamAverage))
                        Text("Avg Rating")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(Int(session.goodPassPercentage))%")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Good Pass")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
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
    
    var body: some View {
        VStack(spacing: 12) {
            // Player info header
            HStack {
                Text("#\(player.number)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                Spacer()
                Text(player.name.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            
            // Circular progress with average
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 10)
                
                Circle()
                    .trim(from: 0, to: progressValue)
                    .stroke(performanceColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progressValue)
                
                VStack(spacing: 2) {
                    Text(String(format: "%.1f", player.average))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text("AVG RATING")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 110)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(performanceColor.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: performanceColor.opacity(0.2), radius: 8, y: 4)
    }
    
    private var progressValue: Double {
        guard player.passCount > 0 else { return 0 }
        // Progress from 0 to 1 based on average (3 is max now, not 4)
        return min(max(player.average / 3.0, 0), 1.0)
    }
    
    private var performanceColor: Color {
        let avg = player.average
        if avg >= 2.5 { return .green }
        if avg >= 2.0 { return .yellow }
        if avg >= 1.5 { return .orange }
        return .red
    }
}

#Preview {
    NavigationStack {
        LiveSessionGridView()
            .environment(DataStore())
    }
}
