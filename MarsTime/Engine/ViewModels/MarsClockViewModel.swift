// MarsClockViewModel.swift
// Mars Clock System - iOS View Model
// NASA/JPL Flight Software Standard

import Foundation
import Observation

@Observable
final class MarsClockViewModel {
    // MARK: - State

    private(set) var marsTimeData: MarsTimeData?
    private(set) var lastUpdateError: Error?
    private(set) var isUpdating: Bool = false

    var longitudeEast: Double = 0.0 {
        didSet {
            updateMarsTime()
        }
    }

    // MARK: - Private Properties

    private let engine = MarsTimeEngine()
    private var timer: Timer?
    private var isActive: Bool = false

    // MARK: - Initialization

    init() {
        startUpdates()
    }

    deinit {
        stopUpdates()
    }

    // MARK: - Public Methods

    func startUpdates() {
        guard !isActive else { return }
        isActive = true

        // Immediate update
        updateMarsTime()

        // Start 1-second timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMarsTime()
        }
    }

    func stopUpdates() {
        isActive = false
        timer?.invalidate()
        timer = nil
    }

    func updateMarsTime() {
        isUpdating = true
        lastUpdateError = nil

        do {
            let now = Date()
            marsTimeData = try engine.calculate(earthUTC: now, longitudeEast: longitudeEast)
        } catch {
            lastUpdateError = error
            print("Mars time calculation error: \(error)")
        }

        isUpdating = false
    }

    // MARK: - Lifecycle

    func onAppear() {
        startUpdates()
    }

    func onDisappear() {
        stopUpdates()
    }
}
