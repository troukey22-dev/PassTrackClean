//
//  SettingsView.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/12/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(DataStore.self) private var dataStore
    
    var body: some View {
        NavigationStack {
            Form {
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
                
                Section {
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
                }
                
                Section {
                    Text("PassTrack v1.0")
                        .foregroundStyle(.secondary)
                    Text("Made for coaches who love data")
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
}
