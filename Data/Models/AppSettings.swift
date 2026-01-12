//
//  AppSettings.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/8/26.
//

import Foundation
import SwiftUI

@Observable
class AppSettings {
    // Scoring system
    var scoringSystem: ScoringSystem = .fourPoint
    
    // Data fields to track
    var trackZone: Bool = true
    var trackContactType: Bool = true
    var trackContactLocation: Bool = false
    var trackServeType: Bool = false
    
    // UI preferences
    var buttonLayout: ButtonLayout = .grid
    var showPlayerPhotos: Bool = false
    var enableHaptics: Bool = true
    
    enum ScoringSystem: String, CaseIterable {
        case fourPoint = "4-Point (3-2-1-0)"
        case fivePoint = "5-Point (4-3-2-1-0)"
        case sixPoint = "6-Point (4-3-2-1-0--1)"
        
        var maxScore: Int {
            switch self {
            case .fourPoint: return 3
            case .fivePoint: return 4
            case .sixPoint: return 4
            }
        }
    }
    
    enum ButtonLayout: String, CaseIterable {
        case grid = "Grid"
        case list = "List"
    }
}
