//
//  TeamsListView.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/8/26.
//

import SwiftUI
import SwiftData

struct TeamsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(DataStore.self) private var dataStore
    @Query(sort: \Team.createdAt, order: .reverse) private var teams: [Team]
    @State private var showingCreateTeam = false
    
    var body: some View {
            Group {
                if teams.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(teams) { team in
                            NavigationLink {
                                TeamDetailView(team: team)
                            } label: {
                                TeamRow(team: team)
                            }
                        }
                        .onDelete(perform: deleteTeams)
                    }
                    .navigationTitle("Teams")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                showingCreateTeam = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarLeading) {
                            EditButton()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCreateTeam) {
                CreateTeamSheet(isPresented: $showingCreateTeam)
            }
        }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text("No Teams Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Create your first team to get started with tracking")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingCreateTeam = true
            } label: {
                Label("Create Team", systemImage: "plus")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }
    
    private func deleteTeams(at offsets: IndexSet) {
        for index in offsets {
            let team = teams[index]
            dataStore.deleteTeam(team)
        }
    }
}

struct TeamRow: View {
    var team: Team
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(team.name)
                .font(.headline)
            
            Text("\(team.playerCount) players")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct TeamDetailView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(\.dismiss) private var dismiss
    @Bindable var team: Team
    @State private var showingAddPlayer = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        List {
            Section("Roster") {
                if team.players.isEmpty {
                    Text("No players yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(team.players) { player in
                        HStack {
                            Text("#\(player.number)")
                                .fontWeight(.bold)
                                .frame(width: 40)
                            Text(player.name)
                            Spacer()
                            if let position = player.position {
                                Text(position)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
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
            
            Section {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Text("Delete Team")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle(team.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddPlayer) {
            AddPlayerSheet(isPresented: $showingAddPlayer) { name, number, position in
                let newPlayer = Player(name: name, number: number, position: position)
                dataStore.addPlayer(to: team, player: newPlayer)
            }
        }
        .alert("Delete Team?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataStore.deleteTeam(team)
                dismiss()
            }
        } message: {
            Text("This will permanently delete \(team.name) and all associated data.")
        }
    }
    
    private func deletePlayers(at offsets: IndexSet) {
        for index in offsets {
            let player = team.players[index]
            dataStore.removePlayer(from: team, player: player)
        }
    }
}
