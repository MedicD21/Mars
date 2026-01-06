// WatchClockViewModel.swift
// Mars Clock System - watchOS View Model
// NASA/JPL Flight Software Standard

import Foundation
import Observation
import WatchKit

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
    private var wristState: WKInterfaceDeviceWristState = .wristUp

    // MARK: - Initialization

    init() {
        setupWristStateObservation()
    }

    deinit {
        stopUpdates()
    }

    // MARK: - Wrist State Management

    private func setupWristStateObservation() {
        // Observe wrist state for battery optimization
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(wristStateChanged),
            name: NSNotification.Name("WKInterfaceDeviceWristStateDidChangeNotification"),
            object: nil
        )
    }

    @objc private func wristStateChanged(_ notification: Notification) {
        let device = WKInterfaceDevice.current()
        wristState = device.wristState

        switch wristState {
        case .wristUp:
            // Wrist raised - immediate update and start timer
            updateMarsTime()
            if isActive {
                startTimer()
            }
        case .wristDown:
            // Wrist down - stop timer to save battery
            stopTimer()
        @unknown default:
            break
        }
    }

    // MARK: - Public Methods

    func startUpdates() {
        guard !isActive else { return }
        isActive = true

        // Immediate update
        updateMarsTime()

        // Start timer only if wrist is up
        if wristState == .wristUp {
            startTimer()
        }
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
