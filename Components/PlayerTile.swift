//
//  PlayerTile.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/8/26.
//

import SwiftUI

struct PlayerTile: View {
    @Bindable var player: Player
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text(player.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("#\(player.number)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            if player.passCount > 0 {
                VStack(spacing: 4) {
                    Text("\(player.passCount) passes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(String(format: "%.1f avg", player.average))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(performanceColor)
                }
            } else {
                VStack(spacing: 4) {
                    Text("No passes yet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("–")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .padding()
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: 2)
        }
    }
    
    private var performanceColor: Color {
        let avg = player.average
        if avg >= 2.5 { return .green }
        if avg >= 2.0 { return .orange }
        if avg >= 1.5 { return .red }
        return .secondary
    }
    
    private var backgroundColor: Color {
        if player.passCount == 0 {
            return Color(.secondarySystemBackground)
        }
        return performanceColor.opacity(0.1)
    }
    
    private var borderColor: Color {
        if player.passCount == 0 {
            return Color(.systemGray4)
        }
        return performanceColor
    }
}
