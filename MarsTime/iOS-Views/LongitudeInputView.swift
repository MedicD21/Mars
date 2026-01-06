// LongitudeInputView.swift
// Mars Clock System - iOS Longitude Input
// NASA/JPL Flight Software Standard

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
