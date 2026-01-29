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
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name
        case number
    }
    
    let positions = ["Libero", "OH", "MB", "Setter", "Opp", "DS"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $playerName)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .name)
                    
                    TextField("Jersey Number", text: $jerseyNumber)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .number)
                        .onChange(of: jerseyNumber) { oldValue, newValue in
                            // Limit to 2 digits
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count > 2 {
                                jerseyNumber = String(filtered.prefix(2))
                            } else if filtered != newValue {
                                jerseyNumber = filtered
                            }
                        }
                } header: {
                    Text("Player Info")
                }
                
                Section {
                    Picker(selection: $selectedPosition, label: EmptyView()) {
                        ForEach(positions, id: \.self) { position in
                            Text(position).tag(position)
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                } header: {
                    Text("Position")
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
                        addPlayer()
                    }
                    .disabled(!isValidInput)
                }
            }
        }
    }
    
    private var isValidInput: Bool {
        !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !jerseyNumber.isEmpty &&
        Int(jerseyNumber) != nil
    }
    
    private func addPlayer() {
        guard let number = Int(jerseyNumber) else { return }
        onAdd(playerName, number, selectedPosition)
        isPresented = false
        dismiss()
    }
}
