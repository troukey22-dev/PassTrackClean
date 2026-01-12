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
        NavigationStack {
            if teams.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(teams) { team in
                        TeamRow(team: team)
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
                .foregroundStyle(.secondary)
            
            Text("No Teams Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Create your first team to get started")
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
    @Environment(DataStore.self) private var dataStore
    var team: Team
    @State private var showingSelectPassers = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(team.name)
                .font(.headline)
            
            HStack {
                Text("\(team.playerCount) players")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    showingSelectPassers = true
                } label: {
                    Text("Start Session")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showingSelectPassers) {
            SelectPassersView(team: team, isPresented: $showingSelectPassers)
        }
    }
}
