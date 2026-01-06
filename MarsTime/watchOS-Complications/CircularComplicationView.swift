// CircularComplicationView.swift
// Mars Clock System - Circular Complications
// NASA/JPL Flight Software Standard

import SwiftUI
import WidgetKit

// MARK: - MTC Only (Circular Small)

struct CircularMTCView: View {
    let entry: MarsTimeEntry
    
    var body: some View {
        if let marsTime = entry.marsTime {
            VStack(spacing: 1) {
                Text(marsTime.coordinatedMarsTime.formatted)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                
                Text("MTC")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundStyle(.orange)
            }
        } else {
            Text("--:--")
                .font(.caption2)
        }
    }
}

// MARK: - LMST Only (Circular Small)

struct CircularLMSTView: View {
    let entry: MarsTimeEntry
    
    var body: some View {
        if let marsTime = entry.marsTime {
            VStack(spacing: 1) {
                Text(marsTime.localMeanSolarTime.formatted)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                
                Text("LMST")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundStyle(.cyan)
            }
        } else {
            Text("--:--")
                .font(.caption2)
        }
    }
}

// MARK: - Sol Number (Circular Small)

struct CircularSolView: View {
    let entry: MarsTimeEntry
    
    var body: some View {
        if let marsTime = entry.marsTime {
            VStack(spacing: 1) {
                Text("SOL")
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)
                
                Text("\(marsTime.solNumber)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)
                    .minimumScaleFactor(0.5)
            }
        } else {
            Text("---")
                .font(.caption2)
        }
    }
}
