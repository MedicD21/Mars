# iOS Mars Clock - Implementation Guide

**NASA/JPL Flight Software Standard**
**SwiftUI • iOS 17+ • Mission Control Aesthetic**

---

## Overview

This guide provides complete implementation details for the iOS Mars Clock application, including architecture, SwiftUI views, state management, and integration with the MarsTimeEngine.

---

## Project Setup

### 1. Create Xcode Project

```bash
# Create new iOS App project
# Name: MarsTime
# Interface: SwiftUI
# Language: Swift
# iOS Deployment Target: 17.0+
```

### 2. Project Structure

```
MarsTime/
├── MarsTime.xcodeproj
├── MarsTime/
│   ├── App/
│   │   ├── MarsTimeApp.swift              # App entry point
│   │   └── AppDelegate.swift              # App lifecycle (if needed)
│   ├── Views/
│   │   ├── MainClockView.swift            # Primary clock display
│   │   ├── TimeDisplayGrid.swift          # Time value grid
│   │   ├── LongitudeInputView.swift       # Longitude picker
│   │   └── Components/
│   │       ├── TimeCard.swift             # Individual time display
│   │       └── MissionControlBackground.swift
│   ├── ViewModels/
│   │   └── MarsClockViewModel.swift       # State management
│   ├── Engine/
│   │   └── MarsTimeEngine.swift           # Link from core/
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   └── Colors.xcassets
│   └── Info.plist
└── MarsTimeTests/
    └── MarsTimeEngineTests.swift          # Link from tests/
```

### 3. Link Core Engine

```bash
# Create symbolic link to core engine
cd MarsTime/Engine
ln -s ../../../core/reference-implementation/swift/MarsTimeEngine.swift .
```

Or add as Swift Package dependency.

---

## Architecture

### State Management

```
┌─────────────────────────────────────┐
│       MarsTimeApp (Entry)           │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│      MarsClockViewModel             │
│  @Observable                        │
│  • Timer (1 second updates)         │
│  • MarsTimeData state               │
│  • Longitude setting                │
│  • Lifecycle management             │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│       MainClockView                 │
│  • Observes ViewModel               │
│  • Displays time data               │
│  • Mission control aesthetic        │
└─────────────────────────────────────┘
```

---

## Implementation

### 1. App Entry Point

**`MarsTimeApp.swift`**

```swift
import SwiftUI

@main
struct MarsTimeApp: App {
    @State private var viewModel = MarsClockViewModel()

    var body: some Scene {
        WindowGroup {
            MainClockView()
                .environment(viewModel)
                .preferredColorScheme(.dark)  // Mission control aesthetic
        }
    }
}
```

### 2. View Model

**`MarsClockViewModel.swift`**

```swift
import Foundation
import Observation

@Observable
final class MarsClockViewModel {
    // MARK: - State

    private(set) var marsTimeData: MarsTimeData?
    private(set) var lastUpdateError: Error?
    private(set) var isUpdating: Bool = false

    var longitudeEast: Double = 0.0 {
        didSet {
            updateMarsTime()
        }
    }

    // MARK: - Private Properties

    private let engine = MarsTimeEngine()
    private var timer: Timer?
    private var isActive: Bool = false

    // MARK: - Initialization

    init() {
        startUpdates()
    }

    deinit {
        stopUpdates()
    }

    // MARK: - Public Methods

    func startUpdates() {
        guard !isActive else { return }
        isActive = true

        // Immediate update
        updateMarsTime()

        // Start 1-second timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMarsTime()
        }
    }

    func stopUpdates() {
        isActive = false
        timer?.invalidate()
        timer = nil
    }

    func updateMarsTime() {
        isUpdating = true
        lastUpdateError = nil

        do {
            let now = Date()
            marsTimeData = try engine.calculate(earthUTC: now, longitudeEast: longitudeEast)
        } catch {
            lastUpdateError = error
            print("Mars time calculation error: \(error)")
        }

        isUpdating = false
    }

    // MARK: - Lifecycle

    func onAppear() {
        startUpdates()
    }

    func onDisappear() {
        stopUpdates()
    }
}
```

### 3. Main Clock View

**`MainClockView.swift`**

```swift
import SwiftUI

struct MainClockView: View {
    @Environment(MarsClockViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            ZStack {
                // Mission control background
                MissionControlBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection

                        // Main time display grid
                        if let data = viewModel.marsTimeData {
                            TimeDisplayGrid(data: data)
                        } else {
                            loadingView
                        }

                        // Longitude input
                        LongitudeInputView(longitude: $viewModel.longitudeEast)

                        // Mission info
                        missionInfoSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Mars Clock")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.onAppear()
            }
            .onDisappear {
                viewModel.onDisappear()
            }
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("MARS TIME SYSTEM")
                .font(.system(.caption, design: .monospaced, weight: .bold))
                .foregroundStyle(.secondary)

            if let data = viewModel.marsTimeData {
                Text("SOL \(data.solNumber)")
                    .font(.system(.title, design: .rounded, weight: .semibold))
                    .foregroundStyle(.orange)
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Calculating Mars Time...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }

    private var missionInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NASA/JPL Standard Algorithm")
                .font(.caption2)
                .foregroundStyle(.tertiary)

            Text("Based on Allison & McEwen (2000)")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 32)
    }
}
```

### 4. Time Display Grid

**`TimeDisplayGrid.swift`**

```swift
import SwiftUI

struct TimeDisplayGrid: View {
    let data: MarsTimeData

    var body: some View {
        VStack(spacing: 16) {
            // Primary Mars times
            VStack(spacing: 12) {
                TimeCard(
                    label: "COORDINATED MARS TIME",
                    value: data.coordinatedMarsTime.formatted,
                    subtitle: "Prime Meridian (0°)",
                    accentColor: .orange
                )

                TimeCard(
                    label: "LOCAL MEAN SOLAR TIME",
                    value: data.localMeanSolarTime.formatted,
                    subtitle: "Longitude: \(String(format: "%.2f", data.longitudeEast))°E",
                    accentColor: .cyan
                )
            }

            Divider()
                .padding(.vertical, 8)

            // Earth reference
            TimeCard(
                label: "EARTH UTC",
                value: formatEarthTime(data.earthUTC),
                subtitle: "Reference Time",
                accentColor: .blue
            )

            // Advanced metrics
            DisclosureGroup("Advanced Metrics") {
                VStack(spacing: 12) {
                    MetricRow(label: "Julian Date", value: String(format: "%.6f", data.julianDate))
                    MetricRow(label: "Terrestrial Time", value: String(format: "%.6f", data.terrestrialTime))
                    MetricRow(label: "Mars Sol Date", value: String(format: "%.6f", data.marsSolDate))
                }
                .padding(.top, 12)
            }
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(.secondary)
        }
    }

    private func formatEarthTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
}

struct TimeCard: View {
    let label: String
    let value: String
    let subtitle: String
    let accentColor: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(.caption, design: .monospaced, weight: .medium))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(.largeTitle, design: .monospaced, weight: .bold))
                .foregroundStyle(accentColor)

            Text(subtitle)
                .font(.system(.caption2, design: .default))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(accentColor.opacity(0.3), lineWidth: 1)
                }
        }
    }
}

struct MetricRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .foregroundStyle(.primary)
        }
    }
}
```

### 5. Longitude Input

**`LongitudeInputView.swift`**

```swift
import SwiftUI

struct LongitudeInputView: View {
    @Binding var longitude: Double

    @State private var isExpanded: Bool = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(spacing: 16) {
                // Slider
                VStack(spacing: 8) {
                    HStack {
                        Text("180°W")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("0°")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("180°E")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Slider(value: $longitude, in: -180...180, step: 0.1)
                        .tint(.orange)
                }

                // Quick select buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        LandingSiteButton(name: "Prime Meridian", longitude: 0.0, binding: $longitude)
                        LandingSiteButton(name: "Jezero Crater", longitude: 77.5, binding: $longitude)
                        LandingSiteButton(name: "Gale Crater", longitude: 137.4, binding: $longitude)
                        LandingSiteButton(name: "Olympus Mons", longitude: -133.8, binding: $longitude)
                    }
                }
            }
            .padding(.top, 12)
        } label: {
            HStack {
                Label("Longitude", systemImage: "globe.europe.africa")
                Spacer()
                Text(formatLongitude(longitude))
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.orange)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        }
    }

    private func formatLongitude(_ value: Double) -> String {
        let direction = value >= 0 ? "E" : "W"
        return String(format: "%.1f° %@", abs(value), direction)
    }
}

struct LandingSiteButton: View {
    let name: String
    let longitude: Double
    @Binding var binding: Double

    var body: some View {
        Button {
            binding = longitude
        } label: {
            Text(name)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(.orange.opacity(0.2)))
                .foregroundStyle(.orange)
        }
    }
}
```

### 6. Mission Control Background

**`MissionControlBackground.swift`**

```swift
import SwiftUI

struct MissionControlBackground: View {
    var body: some View {
        ZStack {
            // Base color
            Color.black.ignoresSafeArea()

            // Subtle grid
            GeometryReader { geometry in
                Path { path in
                    let spacing: CGFloat = 40
                    let width = geometry.size.width
                    let height = geometry.size.height

                    // Vertical lines
                    for x in stride(from: 0, through: width, by: spacing) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: height))
                    }

                    // Horizontal lines
                    for y in stride(from: 0, through: height, by: spacing) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                }
                .stroke(Color.white.opacity(0.02), lineWidth: 0.5)
            }

            // Vignette
            RadialGradient(
                colors: [.clear, .black.opacity(0.5)],
                center: .center,
                startRadius: 200,
                endRadius: 500
            )
            .ignoresSafeArea()
        }
    }
}
```

---

## Color Scheme

**`Assets.xcassets/Colors/`**

```swift
// Mission Control Color Palette
extension Color {
    static let marsOrange = Color(red: 1.0, green: 0.4, blue: 0.0)
    static let marsCyan = Color(red: 0.0, green: 0.8, blue: 1.0)
    static let marsBackground = Color(red: 0.05, green: 0.05, blue: 0.1)
    static let marsSecondary = Color(red: 0.3, green: 0.3, blue: 0.35)
}
```

---

## Accessibility

### VoiceOver Support

```swift
extension TimeCard {
    var body: some View {
        // ... existing code
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value). \(subtitle)")
    }
}
```

### Dynamic Type

All text uses system fonts with automatic scaling:
```swift
.font(.system(.body, design: .monospaced))
```

---

## App Icon

Mission-grade icon suggestions:
- Base: Dark background (#0A0A10)
- Primary: Mars orange (#FF6600)
- Symbol: Clock face with Mars symbol (♂)
- Style: Minimalist, professional, non-gamified

---

## Build and Run

```bash
cd ios/MarsTime
xcodebuild -scheme MarsTime -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## Next Steps

1. Implement watchOS companion app (see `watchos/IMPLEMENTATION_GUIDE.md`)
2. Add widgets (iOS 17+)
3. Implement Shortcuts support
4. Add landing site library

---

**Implementation Status**: ✅ Architecture Complete
**Ready for**: Xcode project creation
**NASA Standard**: Mars24 v8.0 compliant
