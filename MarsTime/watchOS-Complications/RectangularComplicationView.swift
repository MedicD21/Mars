// RectangularComplicationView.swift
// Mars Clock System - Rectangular Complications
// NASA/JPL Flight Software Standard

import SwiftUI
import WidgetKit

// MARK: - Mars vs Earth Time (Rectangular)

struct RectangularMarsEarthView: View {
    let entry: MarsTimeEntry
    
    var body: some View {
        if let marsTime = entry.marsTime {
            VStack(alignment: .leading, spacing: 4) {
                // Mars Time
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10))
                        .foregroundStyle(.orange)
                    
                    Text("MTC")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                    
                    Text(marsTime.coordinatedMarsTime.formatted)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(.orange)
                }
                
                // Earth Time
                HStack(spacing: 4) {
                    Image(systemName: "globe")
                        .font(.system(size: 10))
                        .foregroundStyle(.blue)
                    
                    Text("UTC")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                    
                    Text(formatEarthTime(marsTime.earthUTC))
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(.blue)
                }
            }
        }
    }
    
    private func formatEarthTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
}

// MARK: - Sol + MTC (Rectangular)

struct RectangularSolMTCView: View {
    let entry: MarsTimeEntry
    
    var body: some View {
        if let marsTime = entry.marsTime {
            HStack(spacing: 8) {
                // Sol Number
                VStack(alignment: .leading, spacing: 2) {
                    Text("SOL")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                    
                    Text("\(marsTime.solNumber)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.orange)
                }
                
                Divider()
                    .frame(height: 30)
                
                // MTC
                VStack(alignment: .leading, spacing: 2) {
                    Text("MTC")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                    
                    Text(marsTime.coordinatedMarsTime.formatted)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(.orange)
                }
            }
        }
    }
}

// MARK: - MTC + LMST (Rectangular)

struct RectangularDualTimeView: View {
    let entry: MarsTimeEntry
    
    var body: some View {
        if let marsTime = entry.marsTime {
            VStack(alignment: .leading, spacing: 4) {
                // MTC
                HStack(spacing: 4) {
                    Text("MTC")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                    
                    Text(marsTime.coordinatedMarsTime.formatted)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(.orange)
                }
                
                // LMST
                HStack(spacing: 4) {
                    Text("LMST")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                    
                    Text(marsTime.localMeanSolarTime.formatted)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(.cyan)
                }
            }
        }
    }
}
