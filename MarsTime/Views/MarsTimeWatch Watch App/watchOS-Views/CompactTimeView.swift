// CompactTimeView.swift
// Mars Clock System - watchOS Compact Display
// NASA/JPL Flight Software Standard

import SwiftUI

struct CompactTimeView: View {
    let data: MarsTimeData

    var body: some View {
        VStack(spacing: 8) {
            // Sol number
            Text("SOL \(data.solNumber)")
                .font(.caption2)
                .foregroundStyle(.secondary)

            // Primary time
            Text(data.coordinatedMarsTime.formatted)
                .font(.system(.title3, design: .monospaced, weight: .bold))
                .foregroundStyle(.orange)

            // Label
            Text("MTC")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}
