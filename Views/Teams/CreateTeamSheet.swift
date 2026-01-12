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
    
    @State private var teamName: String = ""
    @State private var players: [PlayerDraft] = []
    @State private var showingAddPlayer = false
    
    struct PlayerDraft: Identifiable {
        let id = UUID()
        var name: String
        var number: Int
        var position: String
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Team Info") {
                    TextField("Team Name", text: $teamName)
                }
                
                Section("Roster") {
                    if players.isEmpty {
                        Text("No players yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(players) { player in
                            HStack {
                                Text("#\(player.number)")
                                    .fontWeight(.bold)
                                    .frame(width: 40)
                                Text(player.name)
                                Spacer()
                                Text(player.position)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete(perform: deletePlayers)
                    }
                    
                    Button {
                        showingAddPlayer = true
                    } label: {
                        Label("Add Player", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("New Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createTeam()
                    }
                    .disabled(teamName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showingAddPlayer) {
                AddPlayerSheet(isPresented: $showingAddPlayer) { name, number, position in
                    players.append(PlayerDraft(name: name, number: number, position: position))
                }
            }
        }
    }
    
    private func deletePlayers(at offsets: IndexSet) {
        players.remove(atOffsets: offsets)
    }
    
    private func createTeam() {
        let playerObjects = players.map { draft in
            Player(name: draft.name, number: draft.number, position: draft.position)
        }
        
        dataStore.createTeam(name: teamName, players: playerObjects)
        isPresented = false
        dismiss()
    }
}
