# PerfectPass - Volleyball Serve-Receive Tracking App

<p align="center">
  <img width="120" height="120" alt="volleymacotdefault" src="https://github.com/user-attachments/assets/237fae64-0965-45e4-94a3-41367918d641" />
</p>


<p align="center">
  <strong>Advanced volleyball serve-receive analytics for coaches and players</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#technology">Technology</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## ⚠️ License & Usage

**This repository is for portfolio demonstration purposes only.**

- ✅ **You MAY:** View the code for educational purposes
- ✅ **You MAY:** Reference techniques and approaches in your own work
- ❌ **You MAY NOT:** Copy, modify, or distribute this code
- ❌ **You MAY NOT:** Use this code in commercial projects
- ❌ **You MAY NOT:** Create derivative works

**Copyright © 2026 Tyler Roukey]. All Rights Reserved.**

**Developer:** Tyler Roukey  
**Email:** perfectpassapphelp@gmail.com  


## Overview

**PerfectPass** is a comprehensive iOS app designed for volleyball coaches and players to track, analyze, and improve serve-receive performance. With real-time tracking, detailed analytics, and intuitive visualizations, PerfectPass transforms raw passing data into actionable insights.

### Why PerfectPass?

Serve-receive is one of the most critical skills in volleyball, yet tracking performance has traditionally been time-consuming and imprecise. PerfectPass solves this by providing:

- **Real-time tracking** during practice sessions
- **Comprehensive analytics** with heat maps and trend analysis
- **Player-specific insights** to identify strengths and areas for improvement
- **Team performance metrics** to track progress over time
- **Exportable reports** for sharing with coaches and athletes

---

## Features

### 🎯 Live Session Tracking

- **Quick Start** - Begin tracking in seconds with intuitive team selection
- **Multi-Player Grid** - Track multiple passers simultaneously
- **Instant Scoring** - Rate passes from 0-3 with a single tap
- **Real-Time Stats** - View live averages and pass counts as you track
- **Configurable Tracking** - Choose which metrics to track:
  - Zone (where serve came from: 1, 6, 5)
  - Contact Location (3x3 body grid: High/Waist/Low × Left/Mid/Right)
  - Contact Type (Platform vs. Hands)
  - Serve Type (Float vs. Spin)

### 📊 Advanced Analytics

#### Session Analytics
- Pass quality distribution (Perfect/Good/Medium/Ace)
- Zone performance heat maps
- Body contact location heat maps
- Player-by-player breakdowns
- Session duration and pass counts

#### Team Analytics
- Performance trend charts showing improvement over time
- Aggregate statistics across all sessions
- Top performer rankings
- Team-wide heat maps for zone and body contact
- Historical session comparison

#### Player Analytics
- Individual career statistics
- Session-by-session performance tracking
- Zone and contact location breakdowns
- Performance trends over time
- Comparison with team averages

### Customization

- **Team Branding** - Choose from 7 mascot colors with matching themes
- **Personalized Rosters** - Add players with numbers and positions
- **Flexible Tracking** - Enable/disable specific tracking metrics per session
- **Custom Mascots** - Fun volleyball-themed mascot designs for each team

### Export & Sharing

- **PDF Reports** - Generate comprehensive session and team reports
  - Multi-page layouts with heat maps and charts
  - Player spotlights highlighting top performers
  - Professional formatting for presentations
- **CSV Export** - Export raw data for external analysis
- **Share Integration** - Native iOS sharing to Messages, Mail, AirDrop, etc.

---

## Installation

### Requirements

- **iOS 17.0+**
- **Xcode 15.0+**
- **Swift 5.9+**
- **SwiftUI & SwiftData**

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/perfectpass.git
   cd perfectpass
   ```

2. **Open in Xcode**
   ```bash
   open PerfectPass.xcodeproj
   ```

3. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

### Dependencies

PerfectPass uses native iOS frameworks:
- **SwiftUI** - Modern declarative UI framework
- **SwiftData** - Persistent data storage
- **Charts** - Native chart visualizations
- **PDFKit** - PDF generation for reports

*No external dependencies or package managers required!*

---

## Usage

### Creating Your First Team

1. Launch PerfectPass
2. Tap the **"+"** button on the home screen
3. Follow the setup wizard:
   - Enter team name
   - Choose volleyball type (6v6 indoor)
   - Select mascot color and background
   - Add players with names, numbers, and positions
4. Tap **"Create Team"** to finish

### Starting a Session

1. From the home screen, tap **"Quick Start"** on your team
2. Select which players will be passing (4-6 recommended)
3. Configure tracking options:
   - Enable **Zone** to track serve origin
   - Enable **Contact Location** for body heat maps
   - Enable **Contact Type** for platform vs. hands analysis
   - Enable **Serve Type** for float vs. spin tracking
4. Tap **"Start Session"** to begin

### Tracking Passes

1. Tap on a player's tile when they receive a serve
2. Rate the pass quality:
   - **3 - Perfect** (In-system, setter has all options)
   - **2 - Good** (Playable, setter has most options)
   - **1 - Medium** (Out of system, limited options)
   - **0 - Ace** (No touch or unplayable)
3. Real-time stats update automatically
4. Tap **"End Session"** when finished

### Viewing Analytics

1. Navigate to the **"Team Stats"** tab
2. Select a team to view aggregate statistics
3. Tap on a session to see detailed breakdown
4. Export reports as PDF or CSV for sharing

---

## Technology Stack

### Core Technologies

- **SwiftUI** - Declarative UI framework
- **SwiftData** - Persistent data storage with @Model
- **Combine** - Reactive programming for data flow
- **PDFKit** - PDF generation and rendering
- **Charts** - Native charting framework

### Architecture

- **MVVM Pattern** - Clear separation of concerns
- **SwiftData Models** - Type-safe data persistence
- **ObservableObject** - Reactive state management
- **Environment Objects** - Dependency injection
- **Modular Views** - Reusable component architecture

### Data Models

```swift
@Model
class Session {
    var teamName: String
    var startTime: Date
    var endTime: Date?
    var trackZone: Bool
    var trackContactLocation: Bool
    var rallies: [Rally]
    // ... computed properties
}

@Model
class Rally {
    var playerId: UUID
    var passScore: Int  // 0-3
    var zone: String?
    var contactLocation: String?
    var timestamp: Date
}
```

### Key Features

- **Real-time updates** using @Published properties
- **Relationships** between Teams, Players, Sessions, and Rallies
- **Computed properties** for analytics (averages, percentages, trends)
- **Efficient filtering** with SwiftData queries
- **Custom PDF rendering** using Core Graphics

---

## Project Structure

```
PerfectPass/
├── Models/
│   ├── Team.swift
│   ├── Player.swift
│   ├── Session.swift
│   ├── Rally.swift
│   ├── DataStore.swift
│   └── AppSettings.swift
├── Views/
│   ├── LiveTrack/
│   │   ├── LiveTrackView.swift
│   │   ├── SelectPassersView.swift
│   │   ├── ConfigureFieldsView.swift
│   │   └── LiveSessionGridView.swift
│   ├── Stats/
│   │   ├── ProgressView.swift
│   │   ├── TeamsListView.swift
│   │   ├── SessionDetailView.swift
│   │   └── PlayerDetailView.swift
│   ├── TeamCreation/
│   │   └── CreateTeamSheet.swift
│   └── Components/
│       ├── PlayerTile.swift
│       ├── PassScoreButtons.swift
│       ├── SpeechBubble.swift
│       └── ZoneCell.swift
├── Helpers/
│   ├── ExportManager.swift
│   └── Colors_Extension.swift
├── Assets/
│   └── Mascots/
│       ├── headband-Purple.png
│       ├── headband-Blue.png
│       └── ...
└── App/
    └── PerfectPassApp.swift
```

---

## Roadmap

### Version 1.1 (Planned)
- [ ] iPad optimization with multi-column layouts
- [ ] Apple Watch companion app for quick tracking
- [ ] iCloud sync across devices
- [ ] Advanced filtering and search
- [ ] Custom pass scoring systems

### Version 1.2 (Future)
- [ ] Video integration for play-by-play analysis
- [ ] Team comparison and benchmarking
- [ ] Multi-coach collaboration features
- [ ] Advanced machine learning predictions
- [ ] Tournament mode with bracket management

---

## Contributing

We welcome contributions from the volleyball and iOS development communities!

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit your changes**
   ```bash
   git commit -m 'Add amazing feature'
   ```
4. **Push to your branch**
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open a Pull Request**

### Development Guidelines

- Follow Swift style conventions
- Write clear commit messages
- Add tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting PR

### Code Style

- Use SwiftLint for consistent formatting
- Follow MVVM architecture patterns
- Prefer composition over inheritance
- Use meaningful variable and function names
- Add comments for complex logic

---

## Testing

### Unit Tests
```bash
# Run unit tests
xcodebuild test -scheme PerfectPass -destination 'platform=iOS Simulator,name=iPhone 15'
```

### UI Tests
- Automated UI testing for critical user flows
- Manual testing checklist for each release

---

## Acknowledgments

- **Volleyball Community** - Thanks to coaches and players who provided feedback
- **SwiftUI Community** - For excellent tutorials and resources
- **Beta Testers** - For helping identify bugs and suggest improvements

---
