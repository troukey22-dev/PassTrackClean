//
//  SelectPassersView.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/8/26.
//

import SwiftUI

struct SelectPassersView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(\.dismiss) private var dismiss
    @Bindable var team: Team
    @Binding var isPresented: Bool
    @State private var showingConfigureFields = false
    
    var body: some View {
        NavigationStack {
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
                        proceedToConfigureFields()
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
            .sheet(isPresented: $showingConfigureFields) {
                ConfigureFieldsView(
                    team: team,
                    passers: team.activePlayers,
                    isPresented: $showingConfigureFields
                )
            }
        }
    }
    
    private func proceedToConfigureFields() {
        showingConfigureFields = true
    }
}
