//
//  AddPlayerSheet.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/8/26.
//

import SwiftUI

struct AddPlayerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    var onAdd: (String, Int, String) -> Void
    
    @State private var playerName: String = ""
    @State private var jerseyNumber: String = ""
    @State private var selectedPosition: String = "Libero"
    
    let positions = ["Libero", "OH", "MB", "Setter", "Opp", "DS"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Player Info") {
                    TextField("Name", text: $playerName)
                    
                    TextField("Jersey Number", text: $jerseyNumber)
                        .keyboardType(.numberPad)
                    
                    Picker("Position", selection: $selectedPosition) {
                        ForEach(positions, id: \.self) { position in
                            Text(position).tag(position)
                        }
                    }
                }
            }
            .navigationTitle("Add Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let number = Int(jerseyNumber) {
                            onAdd(playerName, number, selectedPosition)
                            isPresented = false
                            dismiss()
                        }
                    }
                    .disabled(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || jerseyNumber.isEmpty)
                }
            }
        }
    }
}
