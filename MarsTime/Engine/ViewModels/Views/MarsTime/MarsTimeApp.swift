// MarsTimeApp.swift
// Mars Clock System - iOS App Entry Point
// NASA/JPL Flight Software Standard

import SwiftUI

@main
struct MarsTimeApp: App {
    @State private var viewModel = MarsClockViewModel()

    var body: some Scene {
        WindowGroup {
            MainClockView()
                .environment(viewModel)
                .preferredColorScheme(.dark)
        }
    }
}
