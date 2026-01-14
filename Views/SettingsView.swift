//
//  SettingsView.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/12/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(DataStore.self) private var dataStore
    @Query(sort: \Team.createdAt, order: .reverse) private var teams: [Team]
    
    var body: some View {
        NavigationStack {
            Form {
                // Teams Section
                  Section {
                    NavigationLink {
                        TeamsListView()
                    } label: {
                        HStack {
                            Image(systemName: "person.3.fill")
                                .foregroundStyle(.blue)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Manage Teams")
                                    .font(.body)
                                Text("\(teams.count) team\(teams.count == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Teams")
                }
                
                // Scoring Section
                Section {
                    Picker("Scoring System", selection: Binding(
                        get: { dataStore.settings.scoringSystem },
                        set: { dataStore.settings.scoringSystem = $0 }
                    )) {
                        ForEach(AppSettings.ScoringSystem.allCases, id: \.self) { system in
                            Text(system.rawValue).tag(system)
                        }
                    }
                } header: {
                    Text("Scoring")
                } footer: {
                    Text("Current system uses 0-3 scale (Ace, Poor, Good, Perfect)")
                }
                
                // Default Data Fields Section
                Section {
                    Toggle("Zone Tracking", isOn: Binding(
                        get: { dataStore.settings.trackZone },
                        set: { dataStore.settings.trackZone = $0 }
                    ))
                    Toggle("Contact Type", isOn: Binding(
                        get: { dataStore.settings.trackContactType },
                        set: { dataStore.settings.trackContactType = $0 }
                    ))
                    Toggle("Contact Location", isOn: Binding(
                        get: { dataStore.settings.trackContactLocation },
                        set: { dataStore.settings.trackContactLocation = $0 }
                    ))
                    Toggle("Serve Type", isOn: Binding(
                        get: { dataStore.settings.trackServeType },
                        set: { dataStore.settings.trackServeType = $0 }
                    ))
                } header: {
                    Text("Default Data Fields")
                } footer: {
                    Text("These fields can be enabled/disabled when starting each session")
                }
                
                // Interface Section
                                Section {
                                    Picker("Grid Layout", selection: Binding(
                                        get: { dataStore.settings.gridColumns },
                                        set: { dataStore.settings.gridColumns = $0 }
                                    )) {
                                        Text("Standard (2 columns)").tag(2)
                                        Text("Compact (3 columns)").tag(3)
                                    }
                                    
                                    Toggle("Haptic Feedback", isOn: Binding(
                                        get: { dataStore.settings.enableHaptics },
                                        set: { dataStore.settings.enableHaptics = $0 }
                                    ))
                                    Toggle("Show Player Photos", isOn: Binding(
                                        get: { dataStore.settings.showPlayerPhotos },
                                        set: { dataStore.settings.showPlayerPhotos = $0 }
                                    ))
                                } header: {
                                    Text("Interface")
                                } footer: {
                                    Text("Compact view fits more players on screen with smaller tiles")
                                }
                
                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("2026.01")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                } footer: {
                    Text("PassTrack - Made for coaches who love data")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environment(DataStore())
        .modelContainer(for: [Team.self, Player.self, Session.self, Rally.self])
}
