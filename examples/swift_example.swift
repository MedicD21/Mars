#!/usr/bin/env swift
// Mars Time Engine - Swift Example
// NASA/JPL Flight Software Standard
//
// This example demonstrates basic usage of the MarsTimeEngine
// for calculating Mars time from Earth UTC timestamps.

import Foundation

// Note: In a real project, import the MarsTimeEngine module
// import MarsTimeEngine

// For this example, assume MarsTimeEngine.swift is in the same directory
// or has been added to your Xcode project

/// Example 1: Calculate current Mars time
func example1_CurrentMarsTime() {
    print("=== Example 1: Current Mars Time ===")

    let engine = MarsTimeEngine()
    let now = Date()

    do {
        let marsTime = try engine.calculate(earthUTC: now, longitudeEast: 0.0)

        print("Current Earth UTC: \(now)")
        print("Sol Number: \(marsTime.solNumber)")
        print("Coordinated Mars Time (MTC): \(marsTime.coordinatedMarsTime.formatted)")
        print("Julian Date: \(String(format: "%.6f", marsTime.julianDate))")
        print("Mars Sol Date: \(String(format: "%.6f", marsTime.marsSolDate))")
    } catch {
        print("Error: \(error)")
    }

    print()
}

/// Example 2: Calculate Mars time for a specific date
func example2_SpecificDate() {
    print("=== Example 2: Mars Pathfinder Landing ===")

    let engine = MarsTimeEngine()

    // Mars Pathfinder landing: July 4, 1997, 16:56:55 UTC
    var components = DateComponents()
    components.year = 1997
    components.month = 7
    components.day = 4
    components.hour = 16
    components.minute = 56
    components.second = 55
    components.timeZone = TimeZone(secondsFromGMT: 0)

    let pathfinderLanding = Calendar(identifier: .gregorian).date(from: components)!

    do {
        let marsTime = try engine.calculate(earthUTC: pathfinderLanding, longitudeEast: 0.0)

        print("Pathfinder Landing:")
        print("  Earth UTC: 1997-07-04 16:56:55")
        print("  Sol Number: \(marsTime.solNumber)")
        print("  MTC: \(marsTime.coordinatedMarsTime.formatted)")
        print("  MSD: \(String(format: "%.4f", marsTime.marsSolDate))")
        print("  (This is approximately Sol 0 - the MSD epoch!)")
    } catch {
        print("Error: \(error)")
    }

    print()
}

/// Example 3: Calculate Local Mean Solar Time at different landing sites
func example3_LandingSites() {
    print("=== Example 3: LMST at Mars Landing Sites ===")

    let engine = MarsTimeEngine()
    let now = Date()

    let landingSites: [(String, Double)] = [
        ("Prime Meridian (Airy-0)", 0.0),
        ("Jezero Crater (Perseverance)", 77.5),
        ("Gale Crater (Curiosity)", 137.4),
        ("Olympus Mons", -133.8),
        ("Valles Marineris", -68.0)
    ]

    print("Current Mars times at various locations:")
    print()

    do {
        for (name, longitude) in landingSites {
            let marsTime = try engine.calculate(earthUTC: now, longitudeEast: longitude)

            let direction = longitude >= 0 ? "E" : "W"
            print("\(name) (\(String(format: "%.1f°%@", abs(longitude), direction))):")
            print("  LMST: \(marsTime.localMeanSolarTime.formatted)")
            print()
        }
    } catch {
        print("Error: \(error)")
    }
}

/// Example 4: Using the Date extension
func example4_DateExtension() {
    print("=== Example 4: Using Date Extension ===")

    let now = Date()

    do {
        // Convenient one-liner using extension
        let marsTime = try now.marsTime(longitudeEast: 137.4)

        print("Using Date.marsTime() extension:")
        print("MTC: \(marsTime.coordinatedMarsTime.formatted)")
        print("LMST at Gale Crater: \(marsTime.localMeanSolarTime.formatted)")
    } catch {
        print("Error: \(error)")
    }

    print()
}

/// Example 5: Watching Mars time change in real-time
func example5_RealtimeUpdates() {
    print("=== Example 5: Real-time Mars Time (5 seconds) ===")

    let engine = MarsTimeEngine()
    var count = 0

    // Create a timer that updates every second
    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
        count += 1

        do {
            let marsTime = try engine.calculate(earthUTC: Date(), longitudeEast: 0.0)
            print("[\(count)] MTC: \(marsTime.coordinatedMarsTime.formattedWithMilliseconds)")

            if count >= 5 {
                timer.invalidate()
                print()
            }
        } catch {
            print("Error: \(error)")
            timer.invalidate()
        }
    }

    // Keep the run loop alive for 6 seconds
    RunLoop.current.run(until: Date().addingTimeInterval(6))
}

/// Example 6: Individual conversion steps
func example6_StepByStep() {
    print("=== Example 6: Step-by-Step Conversion ===")

    let engine = MarsTimeEngine()
    let now = Date()

    print("Converting Earth UTC to Mars time:")
    print()

    // Step 1: UTC → Julian Date
    let jd = engine.utcToJulianDate(now)
    print("1. UTC → Julian Date")
    print("   JD = \(String(format: "%.6f", jd))")
    print()

    // Step 2: Julian Date → Terrestrial Time
    let tt = engine.julianDateToTerrestrialTime(jd)
    print("2. Julian Date → Terrestrial Time")
    print("   TT = \(String(format: "%.6f", tt))")
    print("   (Added ΔT = 69.184 seconds for leap seconds)")
    print()

    // Step 3: Terrestrial Time → Mars Sol Date
    let msd = engine.terrestrialTimeToMarsSolDate(tt)
    print("3. Terrestrial Time → Mars Sol Date")
    print("   MSD = \(String(format: "%.6f", msd))")
    print()

    // Step 4: Mars Sol Date → Coordinated Mars Time
    let mtc = engine.marsSolDateToCoordinatedMarsTime(msd)
    print("4. Mars Sol Date → Coordinated Mars Time")
    print("   MTC = \(mtc.formatted)")
    print()

    // Step 5: Coordinated Mars Time → Local Mean Solar Time
    let lmst = engine.coordinatedMarsTimeToLocalMeanSolarTime(mtc, longitudeEast: 137.4)
    print("5. Coordinated Mars Time → Local Mean Solar Time")
    print("   LMST at Gale Crater (137.4°E) = \(lmst.formatted)")
    print()
}

// Run all examples
print("╔════════════════════════════════════════════════════════════╗")
print("║         Mars Time Engine - Swift Examples                 ║")
print("║         NASA/JPL Flight Software Standard                 ║")
print("╚════════════════════════════════════════════════════════════╝")
print()

example1_CurrentMarsTime()
example2_SpecificDate()
example3_LandingSites()
example4_DateExtension()
example5_RealtimeUpdates()
example6_StepByStep()

print("╔════════════════════════════════════════════════════════════╗")
print("║         All Examples Complete                              ║")
print("╚════════════════════════════════════════════════════════════╝")
