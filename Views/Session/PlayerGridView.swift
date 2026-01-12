//
//  PlayerGridView.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/8/26.
//

import SwiftUI

struct PlayerGridView: View {
    @Environment(DataStore.self) private var dataStore
    @State private var selectedPlayer: Player?
    @State private var showingLogSheet = false
    @State private var showingCompleteConfirmation = false
    @State private var passers: [Player] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let session = dataStore.currentSession {
                    sessionHeader(session: session)
                        .padding()
                        .background(Color(.systemGroupedBackground))
                    
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(passers) { player in
                                PlayerTile(player: player)
                                    .onTapGesture {
                                        selectedPlayer = player
                                        showingLogSheet = true
                                    }
                            }
                        }
                        .padding()
                    }
                    
                    HStack(spacing: 12) {
                        Button {
                            dataStore.undoLastLog()
                        } label: {
                            Label("Undo", systemImage: "arrow.uturn.backward")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(session.rallyCount > 0 ? Color.orange : Color.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(session.rallyCount == 0)
                        
                        Button {
                            showingCompleteConfirmation = true
                        } label: {
                            Label("Complete", systemImage: "checkmark.circle.fill")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("Session")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingLogSheet) {
                if let player = selectedPlayer {
                    LogSheetView(player: player, isPresented: $showingLogSheet)
                }
            }
            .alert("Complete Practice?", isPresented: $showingCompleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Complete", role: .destructive) {
                    completeSession()
                }
            } message: {
                if let session = dataStore.currentSession {
                    Text("\(session.rallyCount) passes logged\nDuration: \(session.durationFormatted)")
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
        }
    }
    
    private func loadPassers() {
        guard let session = dataStore.currentSession else { return }
        passers = dataStore.getPassers(for: session)
    }
    
    private func sessionHeader(session: Session) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.teamName)
                        .font(.headline)
                    Text(session.durationFormatted)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(session.rallyCount) passes")
                        .font(.headline)
                    if session.rallyCount > 0 {
                        Text(String(format: "%.1f avg", session.teamAverage))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    private func completeSession() {
        dataStore.completeSession()
    }
}
