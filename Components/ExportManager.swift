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
            yPosition += 120
            
            // Footer
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.secondaryLabel
            ]
            "Generated by PassTrack on \(Date().formatted())".draw(at: CGPoint(x: 50, y: pageHeight - 50), withAttributes: footerAttributes)
        }
        
        // Save to temporary file
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
            let goodPassPercentage = (Double(goodPasses) / Double(playerRallies.count)) * 100
            
            stats.append(PlayerSessionStatExport(
                name: player.name,
                number: player.number,
                passCount: playerRallies.count,
                average: average,
                goodPassPercentage: goodPassPercentage
            ))
        }
        
        return stats
    }
}

struct PlayerSessionStatExport {
    let name: String
    let number: Int
    let passCount: Int
    let average: Double
    let goodPassPercentage: Double
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
