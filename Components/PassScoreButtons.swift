//
//  PassScoreButtons.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/8/26.
//

import SwiftUI

struct PassScoreButtons: View {
    let score: Int
    let label: String
    let emoji: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Show emoji and label only if they're not empty (old style)
                if !emoji.isEmpty {
                    Text(emoji)
                        .font(.system(size: 40))
                }
                
                Text("\(score)")
                    .font(.system(size: emoji.isEmpty ? 90 : 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(isSelected && emoji.isEmpty ? .white : .primary)
                
                if !label.isEmpty {
                    Text(label)
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
            .background(isSelected ? color : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 3)
            )
            .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// Helper function to create score buttons
extension PassScoreButtons {
    static func scoreButton(score: Int, isSelected: Bool, action: @escaping () -> Void) -> PassScoreButtons {
        switch score {
        case 3:
            return PassScoreButtons(
                score: 3,
                label: "Perfect",
                emoji: "🟢",
                color: .green,
                isSelected: isSelected,
                action: action
            )
        case 2:
            return PassScoreButtons(
                score: 2,
                label: "Good",
                emoji: "🟡",
                color: .yellow,
                isSelected: isSelected,
                action: action
            )
        case 1:
            return PassScoreButtons(
                score: 1,
                label: "Poor",
                emoji: "🟠",
                color: .orange,
                isSelected: isSelected,
                action: action
            )
        case 0:
            return PassScoreButtons(
                score: 0,
                label: "Ace",
                emoji: "🔴",
                color: .red,
                isSelected: isSelected,
                action: action
            )
        default:
            return PassScoreButtons(
                score: 0,
                label: "Ace",
                emoji: "🔴",
                color: .red,
                isSelected: isSelected,
                action: action
            )
        }
        
    }
    static func tallScoreButton(score: Int, isSelected: Bool, action: @escaping () -> Void) -> PassScoreButtons {
        let (color, _) = scoreProperties(for: score)
        
        return PassScoreButtons(
            score: score,
            label: "",  // No label
            emoji: "",  // No emoji
            color: color,
            isSelected: isSelected,
            action: action
        )
    }
    
    // Helper function to get color for each score
    private static func scoreProperties(for score: Int) -> (color: Color, label: String) {
        switch score {
        case 3: return (.scorePerfect, "Perfect")
        case 2: return (.scoreGood, "Good")
        case 1: return (.scorePoor, "Poor")
        case 0: return (.scoreAce, "Ace")
        default: return (.gray, "Unknown")
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PassScoreButtons.scoreButton(score: 3, isSelected: false) {}
        PassScoreButtons.scoreButton(score: 2, isSelected: true) {}
    }
    .padding()
}
