// WatchClockView.swift
// Mars Clock System - watchOS Main View
// NASA/JPL Flight Software Standard

import SwiftUI

struct WatchClockView: View {
    @Environment(WatchClockViewModel.self) private var viewModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let data = viewModel.marsTimeData {
                        // Sol number header
                        solHeader(data)

                        // Primary time displays
                        coordinatedMarsTimeCard(data)
                        localMeanSolarTimeCard(data)

                        // Quick longitude picker
                        longitudePicker
                    } else {
                        loadingView
                    }
                }
                .padding(.horizontal, 8)
            }
            .navigationTitle("Mars Time")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                viewModel.onAppear()
            case .background, .inactive:
                viewModel.onDisappear()
            @unknown default:
                break
            }
        }
    }

    // MARK: - View Components

    private func solHeader(_ data: MarsTimeData) -> some View {
        VStack(spacing: 4) {
            Text("SOL")
                .font(.system(.caption2, design: .monospaced, weight: .bold))
                .foregroundStyle(.secondary)

            Text("\(data.solNumber)")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(.orange)
        }
    }

    private func coordinatedMarsTimeCard(_ data: MarsTimeData) -> some View {
        VStack(spacing: 4) {
            Text("MTC")
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)

            Text(data.coordinatedMarsTime.formatted)
                .font(.system(.title3, design: .monospaced, weight: .bold))
                .foregroundStyle(.orange)

            Text("Prime Meridian")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
        }
    }

    private func localMeanSolarTimeCard(_ data: MarsTimeData) -> some View {
        VStack(spacing: 4) {
            Text("LMST")
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)

            Text(data.localMeanSolarTime.formatted)
                .font(.system(.title3, design: .monospaced, weight: .bold))
                .foregroundStyle(.cyan)

            Text(formatLongitude(data.longitudeEast))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
        }
    }

    private var longitudePicker: some View {
        VStack(spacing: 8) {
            Text("Landing Site")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Picker("Longitude", selection: Binding(
                get: { viewModel.longitudeEast },
                set: { viewModel.longitudeEast = $0 }
            )) {
                Text("Prime (0°)").tag(0.0)
                Text("Jezero (77.5°E)").tag(77.5)
                Text("Gale (137.4°E)").tag(137.4)
                Text("Olympus (-133.8°W)").tag(-133.8)
            }
            .pickerStyle(.navigationLink)
        }
        .padding(.top, 8)
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Calculating...")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
    }

    private func formatLongitude(_ value: Double) -> String {
        let direction = value >= 0 ? "E" : "W"
        return String(format: "%.1f° %@", abs(value), direction)
    }
}
