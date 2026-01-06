// InlineComplicationView.swift
// Mars Clock System - Inline Complications
// NASA/JPL Flight Software Standard

import SwiftUI
import WidgetKit

// MARK: - Inline MTC

struct InlineMTCView: View {
    let entry: MarsTimeEntry
    
    var body: some View {
        if let marsTime = entry.marsTime {
            Text("MTC \(marsTime.coordinatedMarsTime.formatted)")
                .font(.system(.caption, design: .monospaced, weight: .bold))
        } else {
            Text("MTC --:--:--")
        }
    }
}

// MARK: - Inline Mars vs Earth

struct InlineMarsEarthView: View {
    let entry: MarsTimeEntry
    
    var body: some View {
        if let marsTime = entry.marsTime {
            Text("♂︎ \(marsTime.coordinatedMarsTime.formatted) 🌍 \(formatEarthTime(marsTime.earthUTC))")
                .font(.system(.caption, design: .monospaced, weight: .bold))
        } else {
            Text("Mars Time")
        }
    }
    
    private func formatEarthTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
}

// MARK: - Inline Sol + Time

struct InlineSolTimeView: View {
    let entry: MarsTimeEntry
    
    var body: some View {
        if let marsTime = entry.marsTime {
            Text("Sol \(marsTime.solNumber) • \(marsTime.coordinatedMarsTime.formatted)")
                .font(.system(.caption, design: .monospaced, weight: .bold))
        } else {
            Text("Mars Sol")
        }
    }
}
