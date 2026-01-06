// WatchClockViewModel.swift
// Mars Clock System - watchOS View Model
// NASA/JPL Flight Software Standard

import Foundation
import Observation

@Observable
final class WatchClockViewModel {
    // MARK: - State

    private(set) var marsTimeData: MarsTimeData?
    private(set) var lastUpdateError: Error?

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
        // Initialization
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

        // Start timer
        startTimer()
    }

    func stopUpdates() {
        isActive = false
        stopTimer()
    }

    private func startTimer() {
        guard timer == nil else { return }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMarsTime()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func updateMarsTime() {
        do {
            let now = Date()
            marsTimeData = try engine.calculate(earthUTC: now, longitudeEast: longitudeEast)
        } catch {
            lastUpdateError = error
        }
    }

    // MARK: - Lifecycle

    func onAppear() {
        startUpdates()
    }

    func onDisappear() {
        stopUpdates()
    }
}
