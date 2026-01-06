// MarsTimeWidget.swift
// Mars Clock System - Complication Widget Configuration
// NASA/JPL Flight Software Standard

import WidgetKit
import SwiftUI

// MARK: - Widget Configuration

@main
struct MarsTimeComplicationBundle: WidgetBundle {
    var body: some Widget {
        // MTC Only Complication
        MarsTimeMTCWidget()
        
        // LMST Only Complication
        MarsTimeLMSTWidget()
        
        // Sol Number Complication
        MarsTimeSolWidget()
        
        // Mars vs Earth Complication
        MarsTimeEarthWidget()
        
        // Dual Mars Times Complication
        MarsTimeDualWidget()
    }
}

// MARK: - MTC Widget

struct MarsTimeMTCWidget: Widget {
    let kind: String = "MarsTimeMTC"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MarsTimeComplicationProvider()) { entry in
            MarsTimeMTCEntryView(entry: entry)
        }
        .configurationDisplayName("Mars Time (MTC)")
        .description("Coordinated Mars Time at prime meridian")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryInline,
            .accessoryRectangular
        ])
    }
}

struct MarsTimeMTCEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: MarsTimeEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularMTCView(entry: entry)
        case .accessoryInline:
            InlineMTCView(entry: entry)
        case .accessoryRectangular:
            RectangularSolMTCView(entry: entry)
        default:
            EmptyView()
        }
    }
}

// MARK: - LMST Widget

struct MarsTimeLMSTWidget: Widget {
    let kind: String = "MarsTimeLMST"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MarsTimeComplicationProvider()) { entry in
            MarsTimeLMSTEntryView(entry: entry)
        }
        .configurationDisplayName("Mars Local Time (LMST)")
        .description("Local Mean Solar Time")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryInline
        ])
    }
}

struct MarsTimeLMSTEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: MarsTimeEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularLMSTView(entry: entry)
        case .accessoryInline:
            if let marsTime = entry.marsTime {
                Text("LMST \(marsTime.localMeanSolarTime.formatted)")
                    .font(.system(.caption, design: .monospaced, weight: .bold))
            }
        default:
            EmptyView()
        }
    }
}

// MARK: - Sol Widget

struct MarsTimeSolWidget: Widget {
    let kind: String = "MarsTimeSol"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MarsTimeComplicationProvider()) { entry in
            MarsTimeSolEntryView(entry: entry)
        }
        .configurationDisplayName("Mars Sol Number")
        .description("Current Martian day count")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryInline
        ])
    }
}

struct MarsTimeSolEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: MarsTimeEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularSolView(entry: entry)
        case .accessoryInline:
            InlineSolTimeView(entry: entry)
        default:
            EmptyView()
        }
    }
}

// MARK: - Mars vs Earth Widget

struct MarsTimeEarthWidget: Widget {
    let kind: String = "MarsTimeEarth"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MarsTimeComplicationProvider()) { entry in
            MarsTimeEarthEntryView(entry: entry)
        }
        .configurationDisplayName("Mars vs Earth Time")
        .description("Shows both Mars and Earth time")
        .supportedFamilies([
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

struct MarsTimeEarthEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: MarsTimeEntry
    
    var body: some View {
        switch family {
        case .accessoryRectangular:
            RectangularMarsEarthView(entry: entry)
        case .accessoryInline:
            InlineMarsEarthView(entry: entry)
        default:
            EmptyView()
        }
    }
}

// MARK: - Dual Mars Times Widget

struct MarsTimeDualWidget: Widget {
    let kind: String = "MarsTimeDual"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MarsTimeComplicationProvider()) { entry in
            MarsTimeDualEntryView(entry: entry)
        }
        .configurationDisplayName("Mars Dual Times")
        .description("Shows both MTC and LMST")
        .supportedFamilies([
            .accessoryRectangular
        ])
    }
}

struct MarsTimeDualEntryView: View {
    let entry: MarsTimeEntry
    
    var body: some View {
        RectangularDualTimeView(entry: entry)
    }
}
