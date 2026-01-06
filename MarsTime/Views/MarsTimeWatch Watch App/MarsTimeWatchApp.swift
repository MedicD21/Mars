// MarsTimeWatchApp.swift
// Mars Clock System - watchOS App Entry Point
// NASA/JPL Flight Software Standard

import SwiftUI

struct MarsTimeWatchApp: App {
    @State private var viewModel = WatchClockViewModel()

    var body: some Scene {
        WindowGroup {
            WatchClockView()
                .environment(viewModel)
        }
    }
}
