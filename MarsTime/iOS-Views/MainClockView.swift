// MainClockView.swift
// Mars Clock System - iOS Main Clock Display
// NASA/JPL Flight Software Standard

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
                        LongitudeInputView(longitude: Binding(
                            get: { viewModel.longitudeEast },
                            set: { viewModel.longitudeEast = $0 }
                        ))

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
