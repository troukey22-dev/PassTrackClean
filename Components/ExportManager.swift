//
//  ExportManager.swift
//  PassTrackClean
//
//  Handles PDF and CSV export functionality
//

import SwiftUI
import PDFKit

class ExportManager {
    
    // MARK: - Session Export to PDF
    
    static func exportSessionToPDF(session: Session, passers: [Player]) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "PassTrack App",
            kCGPDFContextTitle: "\(session.teamName) - Session Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = 50
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.label
            ]
            let title = "\(session.teamName) - Session Report"
            title.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
            yPosition += 40
            
            // Date and time
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            let dateString = dateFormatter.string(from: session.startTime)
            
            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.secondaryLabel
            ]
            dateString.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: subtitleAttributes)
            yPosition += 40
            
            // Summary Stats Section
            let sectionAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.label
            ]
            "Session Summary".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 30
            
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.label
            ]
            
            let summaryText = """
            Total Passes: \(session.rallyCount)
            Team Average: \(String(format: "%.2f", session.teamAverage))
            Good Pass Percentage: \(String(format: "%.0f%%", session.goodPassPercentage))
            Duration: \(session.durationFormatted)
            """
            
            summaryText.draw(in: CGRect(x: 50, y: yPosition, width: pageWidth - 100, height: 100), withAttributes: bodyAttributes)
            yPosition += 120
            
            // Player Performance Section
            "Player Performance".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 30
            
            // Table headers
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 11),
                .foregroundColor: UIColor.label
            ]
            
            "Player".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: headerAttributes)
            "Passes".draw(at: CGPoint(x: 200, y: yPosition), withAttributes: headerAttributes)
            "Average".draw(at: CGPoint(x: 300, y: yPosition), withAttributes: headerAttributes)
            "Good %".draw(at: CGPoint(x: 400, y: yPosition), withAttributes: headerAttributes)
            yPosition += 20
            
            // Player rows
            let playerStats = calculatePlayerStats(session: session, passers: passers)
            for stat in playerStats.sorted(by: { $0.average > $1.average }) {
                "#\(stat.number) \(stat.name)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: bodyAttributes)
                "\(stat.passCount)".draw(at: CGPoint(x: 200, y: yPosition), withAttributes: bodyAttributes)
                String(format: "%.2f", stat.average).draw(at: CGPoint(x: 300, y: yPosition), withAttributes: bodyAttributes)
                String(format: "%.0f%%", stat.goodPassPercentage).draw(at: CGPoint(x: 400, y: yPosition), withAttributes: bodyAttributes)
                yPosition += 20
            }
            
            yPosition += 20
            
            // Pass Distribution Section
            "Pass Quality Distribution".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 30
            
            let perfect = session.rallies.filter { $0.passScore == 3 }.count
            let good = session.rallies.filter { $0.passScore == 2 }.count
            let poor = session.rallies.filter { $0.passScore == 1 }.count
            let ace = session.rallies.filter { $0.passScore == 0 }.count
            
            let distributionText = """
            Perfect (3): \(perfect)
            Good (2): \(good)
            Poor (1): \(poor)
            Ace (0): \(ace)
            """
            
            distributionText.draw(in: CGRect(x: 50, y: yPosition, width: pageWidth - 100, height: 100), withAttributes: bodyAttributes)
            
            // PAGE 2 - HEAT MAPS AND CHARTS
            context.beginPage()
            yPosition = 50
            
            // Page 2 Title
            "Session Analytics".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
            yPosition += 50
            
            // ZONE HEAT MAP
            if session.trackZone {
                "Zone Performance".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: sectionAttributes)
                yPosition += 30
                
                let zones = ["1", "6", "5"]
                let cellWidth: CGFloat = 150
                let cellHeight: CGFloat = 100
                let spacing: CGFloat = 20
                var xPos: CGFloat = 50
                
                for zone in zones {
                    let zoneRallies = session.rallies.filter { $0.zone == zone }
                    let count = zoneRallies.count
                    let average = count > 0 ? Double(zoneRallies.reduce(0) { $0 + $1.passScore }) / Double(count) : 0.0
                    
                    // Draw colored rectangle
                    let rect = CGRect(x: xPos, y: yPosition, width: cellWidth, height: cellHeight)
                    let color = colorForAverage(average)
                    color.setFill()
                    UIBezierPath(roundedRect: rect, cornerRadius: 8).fill()
                    
                    // Draw border
                    UIColor.systemGray4.setStroke()
                    let borderPath = UIBezierPath(roundedRect: rect, cornerRadius: 8)
                    borderPath.lineWidth = 2
                    borderPath.stroke()
                    
                    // Draw text
                    let zoneTitle = "Zone \(zone)"
                    let zoneTitleSize = zoneTitle.size(withAttributes: headerAttributes)
                    zoneTitle.draw(at: CGPoint(x: xPos + (cellWidth - zoneTitleSize.width) / 2, y: yPosition + 15), withAttributes: headerAttributes)
                    
                    if count > 0 {
                        let avgText = String(format: "%.1f", average)
                        let avgSize = avgText.size(withAttributes: titleAttributes)
                        avgText.draw(at: CGPoint(x: xPos + (cellWidth - avgSize.width) / 2, y: yPosition + 40), withAttributes: titleAttributes)
                        
                        let countText = "\(count) passes"
                        let countSize = countText.size(withAttributes: bodyAttributes)
                        countText.draw(at: CGPoint(x: xPos + (cellWidth - countSize.width) / 2, y: yPosition + 70), withAttributes: bodyAttributes)
                    } else {
                        let noDataText = "No data"
                        let noDataSize = noDataText.size(withAttributes: bodyAttributes)
                        noDataText.draw(at: CGPoint(x: xPos + (cellWidth - noDataSize.width) / 2, y: yPosition + 50), withAttributes: bodyAttributes)
                    }
                    
                    xPos += cellWidth + spacing
                }
                
                yPosition += cellHeight + 40
            }
            
            // BODY CONTACT HEAT MAP
            if session.trackContactLocation {
                "Body Contact Heat Map".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: sectionAttributes)
                yPosition += 30
                
                let gridCellWidth: CGFloat = 120
                let gridCellHeight: CGFloat = 80
                let gridSpacing: CGFloat = 10
                let rows = ["High", "Waist", "Low"]
                let cols = ["Left", "Mid", "Right"]
                
                var gridYPos = yPosition
                
                for (rowIndex, row) in rows.enumerated() {
                    var gridXPos: CGFloat = 120
                    
                    // Row label
                    let rowLabelAttr: [NSAttributedString.Key: Any] = [
                        .font: UIFont.boldSystemFont(ofSize: 10),
                        .foregroundColor: UIColor.secondaryLabel
                    ]
                    row.uppercased().draw(at: CGPoint(x: 50, y: gridYPos + gridCellHeight / 2 - 10), withAttributes: rowLabelAttr)
                    
                    for col in cols {
                        let position = "\(row)-\(col)"
                        let positionRallies = session.rallies.filter { $0.contactLocation == position }
                        let count = positionRallies.count
                        let average = count > 0 ? Double(positionRallies.reduce(0) { $0 + $1.passScore }) / Double(count) : 0.0
                        
                        // Draw colored rectangle
                        let rect = CGRect(x: gridXPos, y: gridYPos, width: gridCellWidth, height: gridCellHeight)
                        let color = count > 0 ? colorForAverage(average).withAlphaComponent(0.6) : UIColor.systemGray6
                        color.setFill()
                        UIBezierPath(roundedRect: rect, cornerRadius: 8).fill()
                        
                        // Draw border
                        let borderColor = count > 0 ? colorForAverage(average) : UIColor.systemGray4
                        borderColor.setStroke()
                        let borderPath = UIBezierPath(roundedRect: rect, cornerRadius: 8)
                        borderPath.lineWidth = 3
                        borderPath.stroke()
                        
                        // Draw stats
                        if count > 0 {
                            let avgText = String(format: "%.1f", average)
                            let avgSize = avgText.size(withAttributes: sectionAttributes)
                            avgText.draw(at: CGPoint(x: gridXPos + (gridCellWidth - avgSize.width) / 2, y: gridYPos + 25), withAttributes: sectionAttributes)
                            
                            let countText = "\(count)"
                            let countSize = countText.size(withAttributes: bodyAttributes)
                            countText.draw(at: CGPoint(x: gridXPos + (gridCellWidth - countSize.width) / 2, y: gridYPos + 50), withAttributes: bodyAttributes)
                        } else {
                            let dashText = "-"
                            let dashSize = dashText.size(withAttributes: sectionAttributes)
                            dashText.draw(at: CGPoint(x: gridXPos + (gridCellWidth - dashSize.width) / 2, y: gridYPos + 30), withAttributes: sectionAttributes)
                        }
                        
                        gridXPos += gridCellWidth + gridSpacing
                    }
                    
                    gridYPos += gridCellHeight + gridSpacing
                }
                
                yPosition = gridYPos + 20
                
                // Legend
                "Legend:".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: bodyAttributes)
                let legendItems = [
                    ("2.5+", UIColor.systemGreen),
                    ("2.0-2.5", UIColor.systemYellow),
                    ("1.5-2.0", UIColor.systemOrange),
                    ("<1.5", UIColor.systemRed)
                ]
                var legendXPos: CGFloat = 120
                for (label, color) in legendItems {
                    let legendRect = CGRect(x: legendXPos, y: yPosition, width: 15, height: 15)
                    color.setFill()
                    UIBezierPath(roundedRect: legendRect, cornerRadius: 3).fill()
                    label.draw(at: CGPoint(x: legendXPos + 20, y: yPosition), withAttributes: bodyAttributes)
                    legendXPos += 100
                }
                
                yPosition += 40
            }
            
            // PASS QUALITY BAR CHART
            "Pass Quality Distribution".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 30
            
            let perfectCount = session.rallies.filter { $0.passScore == 3 }.count
            let goodCount = session.rallies.filter { $0.passScore == 2 }.count
            let mediumCount = session.rallies.filter { $0.passScore == 1 }.count
            let poorCount = session.rallies.filter { $0.passScore == 0 }.count
            let totalCount = session.rallies.count
            
            let barWidth: CGFloat = pageWidth - 250
            let barHeight: CGFloat = 30
            let scoreData = [
                (3, "Perfect", perfectCount, UIColor.systemGreen),
                (2, "Good", goodCount, UIColor.systemBlue),
                (1, "Medium", mediumCount, UIColor.systemOrange),
                (0, "Poor", poorCount, UIColor.systemRed)
            ]
            
            for (score, label, count, color) in scoreData {
                let percentage = totalCount > 0 ? Double(count) / Double(totalCount) : 0.0
                
                // Label
                "\(label) (\(score))".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: bodyAttributes)
                
                // Background bar
                let bgRect = CGRect(x: 150, y: yPosition, width: barWidth, height: barHeight)
                UIColor.systemGray6.setFill()
                UIBezierPath(roundedRect: bgRect, cornerRadius: 4).fill()
                
                // Filled bar
                if count > 0 {
                    let fillWidth = barWidth * CGFloat(percentage)
                    let fillRect = CGRect(x: 150, y: yPosition, width: fillWidth, height: barHeight)
                    color.setFill()
                    UIBezierPath(roundedRect: fillRect, cornerRadius: 4).fill()
                }
                
                // Count and percentage
                let statText = "\(count) (\(String(format: "%.0f%%", percentage * 100)))"
                statText.draw(at: CGPoint(x: 150 + barWidth + 10, y: yPosition + 8), withAttributes: bodyAttributes)
                
                yPosition += barHeight + 10
            }
            
            // PAGE 3 - TOP PERFORMERS
            let topPerformers = playerStats.sorted(by: { $0.average > $1.average }).prefix(3)
            if !topPerformers.isEmpty {
                context.beginPage()
                yPosition = 50
                
                "Top Performers".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
                yPosition += 50
                
                for (index, stat) in topPerformers.enumerated() {
                    // Player header
                    let rank = ["🥇", "🥈", "🥉"][index]
                    let playerTitle = "\(rank) #\(stat.number) \(stat.name)"
                    playerTitle.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: sectionAttributes)
                    yPosition += 30
                    
                    // Stats
                    let statsText = """
                    Passes: \(stat.passCount)
                    Average: \(String(format: "%.2f", stat.average))
                    Good Pass %: \(String(format: "%.0f%%", stat.goodPassPercentage))
                    Perfect Pass %: \(String(format: "%.0f%%", stat.perfectPassPercentage))
                    """
                    statsText.draw(in: CGRect(x: 70, y: yPosition, width: pageWidth - 120, height: 100), withAttributes: bodyAttributes)
                    yPosition += 110
                    
                    // Zone breakdown if available
                    if session.trackZone {
                        "Zone Performance:".draw(at: CGPoint(x: 70, y: yPosition), withAttributes: headerAttributes)
                        yPosition += 20
                        
                        let playerRallies = session.rallies.filter { $0.playerId == stat.playerId }
                        for zone in ["1", "6", "5"] {
                            let zoneRallies = playerRallies.filter { $0.zone == zone }
                            if !zoneRallies.isEmpty {
                                let avg = Double(zoneRallies.reduce(0) { $0 + $1.passScore }) / Double(zoneRallies.count)
                                "  Zone \(zone): \(String(format: "%.2f", avg)) (\(zoneRallies.count) passes)".draw(at: CGPoint(x: 90, y: yPosition), withAttributes: bodyAttributes)
                                yPosition += 18
                            }
                        }
                        yPosition += 10
                    }
                    
                    // Separator
                    if index < topPerformers.count - 1 {
                        let separatorPath = UIBezierPath()
                        separatorPath.move(to: CGPoint(x: 50, y: yPosition))
                        separatorPath.addLine(to: CGPoint(x: pageWidth - 50, y: yPosition))
                        UIColor.systemGray4.setStroke()
                        separatorPath.lineWidth = 1
                        separatorPath.stroke()
                        yPosition += 20
                    }
                }
                
                // Footer
                let footerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.secondaryLabel
                ]
                "Generated by PassTrack on \(Date().formatted())".draw(at: CGPoint(x: 50, y: pageHeight - 50), withAttributes: footerAttributes)
            }
            
            // Footer on Page 2 if no Page 3
            if topPerformers.isEmpty {
                let footerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.secondaryLabel
                ]
                "Generated by PassTrack on \(Date().formatted())".draw(at: CGPoint(x: 50, y: pageHeight - 50), withAttributes: footerAttributes)
            }
        }
        
        // Save to file
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: session.startTime)
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("\(session.teamName)_\(dateString).pdf")
        
        do {
            try data.write(to: fileURL)
            
            // Debug: Check file size
            if let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
               let fileSize = attributes[.size] as? UInt64 {
                print("✅ PDF saved successfully to: \(fileURL)")
                print("📄 File size: \(fileSize) bytes")
            } else {
                print("✅ PDF saved successfully to: \(fileURL)")
            }
            
            return fileURL
        } catch {
            print("âŒ Failed to save PDF: \(error)")
            return nil
        }
    }
    
    // MARK: - Team Export to PDF
    
    static func exportTeamToPDF(team: Team, sessions: [Session]) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "PassTrack App",
            kCGPDFContextTitle: "\(team.name) - Team Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = 50
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.label
            ]
            "\(team.name) - Team Report".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
            yPosition += 40
            
            // Date range
            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.secondaryLabel
            ]
            "Report generated on \(Date().formatted(date: .long, time: .omitted))".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: subtitleAttributes)
            yPosition += 40
            
            // Team Overview
            let sectionAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.label
            ]
            "Team Overview".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 30
            
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.label
            ]
            
            let teamAverage = sessions.isEmpty ? 0.0 : sessions.reduce(0.0) { $0 + $1.teamAverage } / Double(sessions.count)
            let totalPasses = sessions.reduce(0) { $0 + $1.rallyCount }
            
            let overviewText = """
            Total Sessions: \(sessions.count)
            Team Average: \(String(format: "%.2f", teamAverage))
            Total Passes: \(totalPasses)
            Players: \(team.players.count)
            """
            
            overviewText.draw(in: CGRect(x: 50, y: yPosition, width: pageWidth - 100, height: 100), withAttributes: bodyAttributes)
            yPosition += 120
            
            // Recent Sessions
            "Recent Sessions".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 30
            
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 11),
                .foregroundColor: UIColor.label
            ]
            
            "Date".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: headerAttributes)
            "Passes".draw(at: CGPoint(x: 200, y: yPosition), withAttributes: headerAttributes)
            "Average".draw(at: CGPoint(x: 300, y: yPosition), withAttributes: headerAttributes)
            "Duration".draw(at: CGPoint(x: 400, y: yPosition), withAttributes: headerAttributes)
            yPosition += 20
            
            for session in sessions.prefix(10) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.string(from: session.startTime).draw(at: CGPoint(x: 50, y: yPosition), withAttributes: bodyAttributes)
                "\(session.rallyCount)".draw(at: CGPoint(x: 200, y: yPosition), withAttributes: bodyAttributes)
                String(format: "%.2f", session.teamAverage).draw(at: CGPoint(x: 300, y: yPosition), withAttributes: bodyAttributes)
                session.durationFormatted.draw(at: CGPoint(x: 400, y: yPosition), withAttributes: bodyAttributes)
                yPosition += 20
                
                if yPosition > pageHeight - 100 {
                    break
                }
            }
            
            // PAGE 2 - PERFORMANCE TREND & TOP PERFORMERS
            context.beginPage()
            yPosition = 50
            
            "Performance Analysis".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
            yPosition += 50
            
            // PERFORMANCE TREND CHART
            if sessions.count > 1 {
                "Performance Trend".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: sectionAttributes)
                yPosition += 30
                
                let sortedSessions = sessions.sorted { $0.startTime < $1.startTime }
                let chartWidth: CGFloat = pageWidth - 150
                let chartHeight: CGFloat = 200
                let chartX: CGFloat = 100
                let chartY = yPosition
                
                // Draw background zones
                let zoneHeight = chartHeight / 4
                let zones: [(CGFloat, UIColor)] = [
                    (0, UIColor.systemRed.withAlphaComponent(0.1)),
                    (zoneHeight, UIColor.systemOrange.withAlphaComponent(0.1)),
                    (zoneHeight * 2, UIColor.systemYellow.withAlphaComponent(0.1)),
                    (zoneHeight * 3, UIColor.systemGreen.withAlphaComponent(0.1))
                ]
                
                for (offset, color) in zones {
                    let rect = CGRect(x: chartX, y: chartY + offset, width: chartWidth, height: zoneHeight)
                    color.setFill()
                    UIBezierPath(rect: rect).fill()
                }
                
                // Draw grid lines and Y-axis labels
                UIColor.systemGray4.setStroke()
                for i in 0...4 {
                    let y = chartY + (chartHeight / 4) * CGFloat(i)
                    let gridPath = UIBezierPath()
                    gridPath.move(to: CGPoint(x: chartX, y: y))
                    gridPath.addLine(to: CGPoint(x: chartX + chartWidth, y: y))
                    gridPath.lineWidth = 0.5
                    gridPath.stroke()
                    
                    let label = String(format: "%.1f", 3.0 - Double(i) * 0.75)
                    let labelSize = label.size(withAttributes: bodyAttributes)
                    label.draw(at: CGPoint(x: chartX - labelSize.width - 10, y: y - labelSize.height / 2), withAttributes: bodyAttributes)
                }
                
                // Draw line path
                if sortedSessions.count > 1 {
                    let linePath = UIBezierPath()
                    let xStep = chartWidth / CGFloat(sortedSessions.count - 1)
                    
                    for (index, session) in sortedSessions.enumerated() {
                        let x = chartX + CGFloat(index) * xStep
                        let normalizedAvg = (3.0 - session.teamAverage) / 3.0
                        let y = chartY + chartHeight * CGFloat(normalizedAvg)
                        
                        if index == 0 {
                            linePath.move(to: CGPoint(x: x, y: y))
                        } else {
                            linePath.addLine(to: CGPoint(x: x, y: y))
                        }
                        
                        // Draw point
                        let pointPath = UIBezierPath(ovalIn: CGRect(x: x - 4, y: y - 4, width: 8, height: 8))
                        UIColor.systemPurple.setFill()
                        pointPath.fill()
                    }
                    
                    UIColor.systemPurple.setStroke()
                    linePath.lineWidth = 3
                    linePath.stroke()
                }
                
                yPosition += chartHeight + 40
                
                // X-axis labels (dates)
                if sortedSessions.count > 0 {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "M/d"
                    
                    let firstDate = dateFormatter.string(from: sortedSessions.first!.startTime)
                    firstDate.draw(at: CGPoint(x: chartX - 10, y: yPosition), withAttributes: bodyAttributes)
                    
                    if sortedSessions.count > 1 {
                        let lastDate = dateFormatter.string(from: sortedSessions.last!.startTime)
                        let lastSize = lastDate.size(withAttributes: bodyAttributes)
                        lastDate.draw(at: CGPoint(x: chartX + chartWidth - lastSize.width + 10, y: yPosition), withAttributes: bodyAttributes)
                    }
                }
                
                yPosition += 40
            }
            
            // TOP PERFORMERS
            "Top Performers".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 30
            
            // Calculate aggregate player stats across all sessions
            var playerAggregateStats: [UUID: (name: String, number: Int, totalPasses: Int, totalScore: Int, goodPasses: Int)] = [:]
            
            for session in sessions {
                for rally in session.rallies {
                    if let player = team.players.first(where: { $0.id == rally.playerId }) {
                        if var stats = playerAggregateStats[player.id] {
                            stats.totalPasses += 1
                            stats.totalScore += rally.passScore
                            if rally.passScore >= 2 {
                                stats.goodPasses += 1
                            }
                            playerAggregateStats[player.id] = stats
                        } else {
                            playerAggregateStats[player.id] = (
                                name: player.name,
                                number: player.number,
                                totalPasses: 1,
                                totalScore: rally.passScore,
                                goodPasses: rally.passScore >= 2 ? 1 : 0
                            )
                        }
                    }
                }
            }
            
            let topPlayers = playerAggregateStats.values
                .map { (name: $0.name, number: $0.number, passes: $0.totalPasses, average: Double($0.totalScore) / Double($0.totalPasses), goodPct: Double($0.goodPasses) / Double($0.totalPasses) * 100) }
                .sorted { $0.average > $1.average }
                .prefix(5)
            
            // Table header
            "Player".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: headerAttributes)
            "Passes".draw(at: CGPoint(x: 250, y: yPosition), withAttributes: headerAttributes)
            "Average".draw(at: CGPoint(x: 350, y: yPosition), withAttributes: headerAttributes)
            "Good %".draw(at: CGPoint(x: 450, y: yPosition), withAttributes: headerAttributes)
            yPosition += 20
            
            for player in topPlayers {
                "#\(player.number) \(player.name)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: bodyAttributes)
                "\(player.passes)".draw(at: CGPoint(x: 250, y: yPosition), withAttributes: bodyAttributes)
                String(format: "%.2f", player.average).draw(at: CGPoint(x: 350, y: yPosition), withAttributes: bodyAttributes)
                String(format: "%.0f%%", player.goodPct).draw(at: CGPoint(x: 450, y: yPosition), withAttributes: bodyAttributes)
                yPosition += 20
            }
            
            // PAGE 3 - AGGREGATE HEAT MAPS
            context.beginPage()
            yPosition = 50
            
            "Team Aggregate Analysis".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
            yPosition += 50
            
            // Aggregate all rallies
            let allRallies = sessions.flatMap { $0.rallies }
            
            // ZONE HEAT MAP
            "Zone Performance (All Sessions)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 30
            
            let zones = ["1", "6", "5"]
            let cellWidth: CGFloat = 150
            let cellHeight: CGFloat = 100
            let spacing: CGFloat = 20
            var xPos: CGFloat = 50
            
            for zone in zones {
                let zoneRallies = allRallies.filter { $0.zone == zone }
                let count = zoneRallies.count
                let average = count > 0 ? Double(zoneRallies.reduce(0) { $0 + $1.passScore }) / Double(count) : 0.0
                
                let rect = CGRect(x: xPos, y: yPosition, width: cellWidth, height: cellHeight)
                let color = colorForAverage(average)
                color.setFill()
                UIBezierPath(roundedRect: rect, cornerRadius: 8).fill()
                
                UIColor.systemGray4.setStroke()
                let borderPath = UIBezierPath(roundedRect: rect, cornerRadius: 8)
                borderPath.lineWidth = 2
                borderPath.stroke()
                
                let zoneTitle = "Zone \(zone)"
                let zoneTitleSize = zoneTitle.size(withAttributes: headerAttributes)
                zoneTitle.draw(at: CGPoint(x: xPos + (cellWidth - zoneTitleSize.width) / 2, y: yPosition + 15), withAttributes: headerAttributes)
                
                if count > 0 {
                    let avgText = String(format: "%.1f", average)
                    let avgSize = avgText.size(withAttributes: titleAttributes)
                    avgText.draw(at: CGPoint(x: xPos + (cellWidth - avgSize.width) / 2, y: yPosition + 40), withAttributes: titleAttributes)
                    
                    let countText = "\(count) passes"
                    let countSize = countText.size(withAttributes: bodyAttributes)
                    countText.draw(at: CGPoint(x: xPos + (cellWidth - countSize.width) / 2, y: yPosition + 70), withAttributes: bodyAttributes)
                } else {
                    let noDataText = "No data"
                    let noDataSize = noDataText.size(withAttributes: bodyAttributes)
                    noDataText.draw(at: CGPoint(x: xPos + (cellWidth - noDataSize.width) / 2, y: yPosition + 50), withAttributes: bodyAttributes)
                }
                
                xPos += cellWidth + spacing
            }
            
            yPosition += cellHeight + 40
            
            // BODY CONTACT HEAT MAP
            "Body Contact Heat Map (All Sessions)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 30
            
            let gridCellWidth: CGFloat = 120
            let gridCellHeight: CGFloat = 80
            let gridSpacing: CGFloat = 10
            let rows = ["High", "Waist", "Low"]
            let cols = ["Left", "Mid", "Right"]
            
            var gridYPos = yPosition
            
            for row in rows {
                var gridXPos: CGFloat = 120
                
                let rowLabelAttr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 10),
                    .foregroundColor: UIColor.secondaryLabel
                ]
                row.uppercased().draw(at: CGPoint(x: 50, y: gridYPos + gridCellHeight / 2 - 10), withAttributes: rowLabelAttr)
                
                for col in cols {
                    let position = "\(row)-\(col)"
                    let positionRallies = allRallies.filter { $0.contactLocation == position }
                    let count = positionRallies.count
                    let average = count > 0 ? Double(positionRallies.reduce(0) { $0 + $1.passScore }) / Double(count) : 0.0
                    
                    let rect = CGRect(x: gridXPos, y: gridYPos, width: gridCellWidth, height: gridCellHeight)
                    let color = count > 0 ? colorForAverage(average).withAlphaComponent(0.6) : UIColor.systemGray6
                    color.setFill()
                    UIBezierPath(roundedRect: rect, cornerRadius: 8).fill()
                    
                    let borderColor = count > 0 ? colorForAverage(average) : UIColor.systemGray4
                    borderColor.setStroke()
                    let borderPath = UIBezierPath(roundedRect: rect, cornerRadius: 8)
                    borderPath.lineWidth = 3
                    borderPath.stroke()
                    
                    if count > 0 {
                        let avgText = String(format: "%.1f", average)
                        let avgSize = avgText.size(withAttributes: sectionAttributes)
                        avgText.draw(at: CGPoint(x: gridXPos + (gridCellWidth - avgSize.width) / 2, y: gridYPos + 25), withAttributes: sectionAttributes)
                        
                        let countText = "\(count)"
                        let countSize = countText.size(withAttributes: bodyAttributes)
                        countText.draw(at: CGPoint(x: gridXPos + (gridCellWidth - countSize.width) / 2, y: gridYPos + 50), withAttributes: bodyAttributes)
                    } else {
                        let dashText = "-"
                        let dashSize = dashText.size(withAttributes: sectionAttributes)
                        dashText.draw(at: CGPoint(x: gridXPos + (gridCellWidth - dashSize.width) / 2, y: gridYPos + 30), withAttributes: sectionAttributes)
                    }
                    
                    gridXPos += gridCellWidth + gridSpacing
                }
                
                gridYPos += gridCellHeight + gridSpacing
            }
            
            yPosition = gridYPos + 20
            
            // Legend
            "Legend:".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: bodyAttributes)
            let legendItems = [
                ("2.5+", UIColor.systemGreen),
                ("2.0-2.5", UIColor.systemYellow),
                ("1.5-2.0", UIColor.systemOrange),
                ("<1.5", UIColor.systemRed)
            ]
            var legendXPos: CGFloat = 120
            for (label, color) in legendItems {
                let legendRect = CGRect(x: legendXPos, y: yPosition, width: 15, height: 15)
                color.setFill()
                UIBezierPath(roundedRect: legendRect, cornerRadius: 3).fill()
                label.draw(at: CGPoint(x: legendXPos + 20, y: yPosition), withAttributes: bodyAttributes)
                legendXPos += 100
            }
            
            // Footer
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.secondaryLabel
            ]
            "Generated by PassTrack on \(Date().formatted())".draw(at: CGPoint(x: 50, y: pageHeight - 50), withAttributes: footerAttributes)
        }
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("\(team.name)_TeamReport.pdf")
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to save PDF: \(error)")
            return nil
        }
    }
    
    // MARK: - CSV Export
    
    static func exportSessionToCSV(session: Session, passers: [Player]) -> URL? {
        var csvText = "Pass Number,Player Name,Player Number,Pass Score,Zone,Contact Type,Contact Location,Serve Type,Timestamp\n"
        
        let sortedRallies = session.rallies.sorted { $0.rallyNumber < $1.rallyNumber }
        
        for rally in sortedRallies {
            let player = passers.first { $0.id == rally.playerId }
            let playerName = player?.name ?? "Unknown"
            let playerNumber = player?.number ?? 0
            
            let row = "\(rally.rallyNumber),\(playerName),\(playerNumber),\(rally.passScore),\(rally.zone ?? ""),\(rally.contactType ?? ""),\(rally.contactLocation ?? ""),\(rally.serveType ?? ""),\(rally.timestamp.formatted())\n"
            csvText.append(row)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: session.startTime)
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("\(session.teamName)_\(dateString).csv")
        
        do {
            try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to save CSV: \(error)")
            return nil
        }
    }
    
    // MARK: - Helper Functions
    
    private static func calculatePlayerStats(session: Session, passers: [Player]) -> [PlayerSessionStatExport] {
        var stats: [PlayerSessionStatExport] = []
        
        for player in passers {
            let playerRallies = session.rallies.filter { $0.playerId == player.id }
            guard !playerRallies.isEmpty else { continue }
            
            let totalScore = playerRallies.reduce(0) { $0 + $1.passScore }
            let average = Double(totalScore) / Double(playerRallies.count)
            let goodPasses = playerRallies.filter { $0.passScore >= 2 }.count
            let perfectPasses = playerRallies.filter { $0.passScore == 3 }.count
            let goodPassPercentage = (Double(goodPasses) / Double(playerRallies.count)) * 100
            let perfectPassPercentage = (Double(perfectPasses) / Double(playerRallies.count)) * 100
            
            stats.append(PlayerSessionStatExport(
                playerId: player.id,
                name: player.name,
                number: player.number,
                passCount: playerRallies.count,
                average: average,
                goodPassPercentage: goodPassPercentage,
                perfectPassPercentage: perfectPassPercentage
            ))
        }
        
        return stats
    }
    
    // Helper function to get color based on average
    private static func colorForAverage(_ average: Double) -> UIColor {
        if average >= 2.5 { return .systemGreen }
        if average >= 2.0 { return .systemYellow }
        if average >= 1.5 { return .systemOrange }
        return .systemRed
    }
}

struct PlayerSessionStatExport {
    let playerId: UUID
    let name: String
    let number: Int
    let passCount: Int
    let average: Double
    let goodPassPercentage: Double
    let perfectPassPercentage: Double
}

// MARK: - Share Sheet Helper

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIViewController {
        // Create a simple container view controller
        let viewController = UIViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Present the activity controller on update (when sheet appears)
        guard uiViewController.presentedViewController == nil else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        // For iPad - required popover presentation
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = uiViewController.view
            popover.sourceRect = CGRect(x: uiViewController.view.bounds.midX, y: uiViewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            if let error = error {
                print("❌ Share error: \(error.localizedDescription)")
            } else if success {
                print("✅ Share succeeded with activity: \(activity?.rawValue ?? "unknown")")
            } else {
                print("⚠️ Share cancelled")
            }
        }
        
        DispatchQueue.main.async {
            uiViewController.present(activityVC, animated: true)
        }
    }
}

// MARK: - Share Presentation

struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
    let type: FileType
    
    enum FileType {
        case pdf
        case csv
    }
}

struct SharePresentationModifier: ViewModifier {
    @Binding var item: ShareItem?
    let items: (ShareItem) -> [Any]
    
    func body(content: Content) -> some View {
        content
            .background(
                SharePresentationHelper(item: $item, items: items)
            )
    }
}

struct SharePresentationHelper: UIViewControllerRepresentable {
    @Binding var item: ShareItem?
    let items: (ShareItem) -> [Any]
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if item == nil && uiViewController.presentedViewController != nil {
            uiViewController.dismiss(animated: true)
            return
        }
        
        guard let shareItem = item,
              uiViewController.presentedViewController == nil else {
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: items(shareItem),
            applicationActivities: nil
        )
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = uiViewController.view
            popover.sourceRect = CGRect(x: uiViewController.view.bounds.midX,
                                       y: uiViewController.view.bounds.midY,
                                       width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        activityVC.completionWithItemsHandler = { _, _, _, _ in
            DispatchQueue.main.async {
                self.item = nil
            }
        }
        
        DispatchQueue.main.async {
            uiViewController.present(activityVC, animated: true)
        }
    }
}

extension View {
    func sharePresentation(item: Binding<ShareItem?>, items: @escaping (ShareItem) -> [Any]) -> some View {
        self.modifier(SharePresentationModifier(item: item, items: items))
    }
}
