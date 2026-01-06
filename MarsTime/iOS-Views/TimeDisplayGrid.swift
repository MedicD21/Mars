// TimeDisplayGrid.swift
// Mars Clock System - iOS Time Display Components
// NASA/JPL Flight Software Standard

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
