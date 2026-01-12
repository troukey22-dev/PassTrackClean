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
    @Query(sort: \Session.startTime, order: .reverse) private var completedSessions: [Session]
    @State private var passers: [Player] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if let session = dataStore.currentSession {
                    currentSessionStats(session: session)
                } else if !completedSessions.isEmpty {
                    recentSessionsList
                } else {
                    emptyState
                }
            }
            .navigationTitle("Progress")
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Sessions Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Start a session to see live stats and progress")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity)
        .padding()
    }
    
    private var recentSessionsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("RECENT SESSIONS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            ForEach(completedSessions.prefix(10)) { session in
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
    
    private func currentSessionStats(session: Session) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("CURRENT SESSION")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Passes")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("\(session.rallyCount)")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Team Average")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.2f", session.teamAverage))
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Duration")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(session.durationFormatted)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Good Pass %")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.0f%%", session.goodPassPercentage))
                            .font(.headline)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 12) {
                Text("PLAYER STATS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                ForEach(passers.sorted(by: { $0.average > $1.average })) { player in
                    PlayerStatRow(player: player)
                }
            }
            
            if session.rallyCount > 0 {
                VStack(alignment: .leading, spacing: 12) {
                    Text("PASS DISTRIBUTION")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    passDistributionChart(session: session)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .onAppear {
            passers = dataStore.getPassers(for: session)
        }
    }
    
    private func passDistributionChart(session: Session) -> some View {
        VStack(spacing: 8) {
            ForEach([3, 2, 1, 0], id: \.self) { score in
                let count = session.rallies.filter { $0.passScore == score }.count
                let percentage = session.rallyCount > 0 ? Double(count) / Double(session.rallyCount) : 0.0
                
                HStack {
                    Text(scoreLabel(score))
                        .font(.subheadline)
                        .frame(width: 80, alignment: .leading)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.systemGray5))
                            
                            Rectangle()
                                .fill(scoreColor(score))
                                .frame(width: geometry.size.width * percentage)
                        }
                    }
                    .frame(height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    Text("\(count)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
    }
    
    private func scoreLabel(_ score: Int) -> String {
        switch score {
        case 3: return "🟢 Perfect"
        case 2: return "🟡 Good"
        case 1: return "🟠 Poor"
        case 0: return "🔴 Ace"
        default: return "Unknown"
        }
    }
    
    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 3: return .green
        case 2: return .yellow
        case 1: return .orange
        case 0: return .red
        default: return .gray
        }
    }
}

struct SessionRow: View {
    let session: Session
    
    var body: some View {
        HStack(spacing: 16) {
            // Session icon
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: "chart.bar.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
            
            // Session info
            VStack(alignment: .leading, spacing: 4) {
                Text(session.teamName)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(session.startTime, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(session.rallyCount) passes • \(String(format: "%.1f", session.teamAverage)) avg")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

struct PlayerStatRow: View {
    @Bindable var player: Player
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(player.passCount) passes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(String(format: "%.2f", player.average))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(averageColor(player.average))
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func averageColor(_ avg: Double) -> Color {
        if avg >= 2.5 { return .green }
        if avg >= 2.0 { return .orange }
        if avg >= 1.5 { return .red }
        return .secondary
    }
}
