//
//  SpeechBubble.swift
//  PassTrackClean
//
//  Custom speech bubble shape with tail
//

import SwiftUI

struct SpeechBubble: Shape {
    var tailPosition: TailPosition = .left
    
    enum TailPosition {
        case left
        case right
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let cornerRadius: CGFloat = 16
        let tailWidth: CGFloat = 20
        let tailHeight: CGFloat = 15
        
        if tailPosition == .left {
            // Start from top-left (after tail area)
            path.move(to: CGPoint(x: cornerRadius, y: 0))
            
            // Top edge
            path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))
            
            // Top-right corner
            path.addArc(
                center: CGPoint(x: rect.width - cornerRadius, y: cornerRadius),
                radius: cornerRadius,
                startAngle: Angle(degrees: -90),
                endAngle: Angle(degrees: 0),
                clockwise: false
            )
            
            // Right edge
            path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
            
            // Bottom-right corner
            path.addArc(
                center: CGPoint(x: rect.width - cornerRadius, y: rect.height - cornerRadius),
                radius: cornerRadius,
                startAngle: Angle(degrees: 0),
                endAngle: Angle(degrees: 90),
                clockwise: false
            )
            
            // Bottom edge
            path.addLine(to: CGPoint(x: cornerRadius, y: rect.height))
            
            // Bottom-left corner
            path.addArc(
                center: CGPoint(x: cornerRadius, y: rect.height - cornerRadius),
                radius: cornerRadius,
                startAngle: Angle(degrees: 90),
                endAngle: Angle(degrees: 180),
                clockwise: false
            )
            
            // Left edge (until tail)
            path.addLine(to: CGPoint(x: 0, y: tailHeight + 20))
            
            // Tail pointing left
            path.addLine(to: CGPoint(x: -tailWidth, y: 15))
            path.addLine(to: CGPoint(x: 0, y: 10))
            
            // Continue left edge up
            path.addLine(to: CGPoint(x: 0, y: cornerRadius))
            
            // Top-left corner
            path.addArc(
                center: CGPoint(x: cornerRadius, y: cornerRadius),
                radius: cornerRadius,
                startAngle: Angle(degrees: 180),
                endAngle: Angle(degrees: -90),
                clockwise: false
            )
        }
        
        return path
    }
}
