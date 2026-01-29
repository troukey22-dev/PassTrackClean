//
//  Colors+Extension.swift
//  PassTrackClean
//
//  App color palette
//

import SwiftUI

extension Color {
    // MARK: - Primary Brand Colors
    static let appPurple = Color(hex: "8B5CF6")
    static let appPurpleDark = Color(hex: "7C3AED")
    static let appPurpleLight = Color(hex: "A78BFA")
    
    // MARK: - Score Colors
    static let scorePerfect = Color(hex: "10B981")
    static let scoreGood = Color(hex: "F59E0B")
    static let scorePoor = Color(hex: "F97316")
    static let scoreAce = Color(hex: "EF4444")
    
    // MARK: - Neutral Colors
    static let cardBackground = Color(hex: "FFFFFF")
    static let appBackground = Color(hex: "F9FAFB")
    
    // MARK: - Helper for hex colors
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
