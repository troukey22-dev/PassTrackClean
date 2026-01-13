//
//  ConfigureFieldsView.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/8/26.
//

import SwiftUI

struct ConfigureFieldsView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(\.dismiss) private var dismiss
    let team: Team
    let passers: [Player]
    @Binding var isPresented: Bool
    
    @State private var enabledFields: Set<String> = ["zone", "contactType"]
    
    let availableFields = [
        ("zone", "Zone", "Court position (5, 6, 1)"),
        ("contactType", "Contact Type", "Platform or Hands"),
        ("contactLocation", "Contact Location", "Where on court contact was made"),
        ("serveType", "Serve Type", "Type of serve received")
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Data Fields")
                        .font(.headline)
                    Text("Select which data to track for each pass")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Fields list
                List {
                    Section {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text("Pass Score")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("Always tracked")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        Text("Required")
                    }
                    
                    Section {
                        ForEach(availableFields, id: \.0) { field in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    if enabledFields.contains(field.0) {
                                        enabledFields.remove(field.0)
                                    } else {
                                        enabledFields.insert(field.0)
                                    }
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(field.1)
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.primary)
                                        Text(field.2)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: enabledFields.contains(field.0) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(enabledFields.contains(field.0) ? .blue : .secondary)
                                        .font(.title3)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        Text("Optional Fields")
                    } footer: {
                        Text("Estimated: \(estimatedTaps) taps per log")
                            .font(.caption)
                    }
                }
                
                // Bottom bar
                VStack(spacing: 12) {
                    Button {
                        startSession()
                    } label: {
                        Text("Start Session")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("Configure")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var estimatedTaps: Int {
        // Pass score: 1 tap
        // Zone: 1 tap
        // Contact type: 1 tap
        // Contact location: 1 tap
        // Serve type: 1 tap
        // Log button: 1 tap
        return 1 + enabledFields.count + 1
    }
    
    private func startSession() {
        print("🔥 ConfigureFieldsView.startSession() called!")
        print("🔥 Team: \(team.name)")
        print("🔥 Passers: \(passers.map { $0.name })")
        
        dataStore.startSession(
            team: team,
            passers: passers,
            enabledFields: [
                "zone": enabledFields.contains("zone"),
                "contactType": enabledFields.contains("contactType"),
                "contactLocation": enabledFields.contains("contactLocation"),
                "serveType": enabledFields.contains("serveType")
            ]
        )
        
        print("🔥 After calling dataStore.startSession")
        print("🔥 currentSession: \(dataStore.currentSession?.teamName ?? "nil")")
        
        isPresented = false
        dismiss()
    }
}
