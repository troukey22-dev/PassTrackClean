//
//  ContentView.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/8/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var dataStore = DataStore()
    @State private var selectedTab: Tab = .liveTrack
    
    enum Tab {
        case liveTrack
        case stats
        case settings
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LiveTrackView()
                .tabItem {
                    Label("Live Track", systemImage: "record.circle")
                }
                .tag(Tab.liveTrack)
            
            ProgressView()
                .tabItem {
                    Label("Team Stats", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(Tab.stats)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(Tab.settings)
        }
        .environment(dataStore)
        .onAppear {
            // Inject modelContext into dataStore
            dataStore.setModelContext(modelContext)
            
            // Load demo data if needed
            dataStore.loadDemoData()
        }
        .onChange(of: dataStore.currentSession) { oldValue, newValue in
            // Auto-navigate to Live Track when session starts
            if newValue != nil && oldValue == nil {
                selectedTab = .liveTrack
            }
            
            // Auto-navigate to Progress when session ends
            if newValue == nil && oldValue != nil {
                selectedTab = .stats
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Team.self, Player.self, Session.self, Rally.self])
}
