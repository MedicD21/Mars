// Mars Time Engine - Kotlin Example
// NASA/JPL Flight Software Standard
//
// This example demonstrates basic usage of the MarsTimeEngine
// for calculating Mars time from Earth UTC timestamps.

package com.nasa.marstime.examples

import com.nasa.marstime.engine.*
import java.time.Instant
import java.time.ZoneOffset
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import kotlin.concurrent.fixedRateTimer

// Note: In a real project, import the MarsTimeEngine from your module
// In this example, assume MarsTimeEngine.kt is in your classpath

/// Example 1: Calculate current Mars time
fun example1CurrentMarsTime() {
    println("=== Example 1: Current Mars Time ===")

    val engine = MarsTimeEngine()
    val now = Instant.now()

    try {
        val marsTime = engine.calculate(now, longitudeEast = 0.0)

        println("Current Earth UTC: $now")
        println("Sol Number: ${marsTime.solNumber}")
        println("Coordinated Mars Time (MTC): ${marsTime.coordinatedMarsTime.formatted}")
        println("Julian Date: ${"%.6f".format(marsTime.julianDate)}")
        println("Mars Sol Date: ${"%.6f".format(marsTime.marsSolDate)}")
    } catch (e: Exception) {
        println("Error: ${e.message}")
    }

    println()
}

/// Example 2: Calculate Mars time for a specific date
fun example2SpecificDate() {
    println("=== Example 2: Mars Pathfinder Landing ===")

    val engine = MarsTimeEngine()

    // Mars Pathfinder landing: July 4, 1997, 16:56:55 UTC
    val pathfinderLanding = ZonedDateTime.of(
        1997, 7, 4, 16, 56, 55, 0, ZoneOffset.UTC
    ).toInstant()

    try {
        val marsTime = engine.calculate(pathfinderLanding, longitudeEast = 0.0)

        println("Pathfinder Landing:")
        println("  Earth UTC: 1997-07-04 16:56:55")
        println("  Sol Number: ${marsTime.solNumber}")
        println("  MTC: ${marsTime.coordinatedMarsTime.formatted}")
        println("  MSD: ${"%.4f".format(marsTime.marsSolDate)}")
        println("  (This is approximately Sol 0 - the MSD epoch!)")
    } catch (e: Exception) {
        println("Error: ${e.message}")
    }

    println()
}

/// Example 3: Calculate Local Mean Solar Time at different landing sites
fun example3LandingSites() {
    println("=== Example 3: LMST at Mars Landing Sites ===")

    val engine = MarsTimeEngine()
    val now = Instant.now()

    val landingSites = listOf(
        "Prime Meridian (Airy-0)" to 0.0,
        "Jezero Crater (Perseverance)" to 77.5,
        "Gale Crater (Curiosity)" to 137.4,
        "Olympus Mons" to -133.8,
        "Valles Marineris" to -68.0
    )

    println("Current Mars times at various locations:")
    println()

    try {
        for ((name, longitude) in landingSites) {
            val marsTime = engine.calculate(now, longitudeEast = longitude)

            val direction = if (longitude >= 0) "E" else "W"
            println("$name (${"%.1f°%s".format(kotlin.math.abs(longitude), direction)}):")
            println("  LMST: ${marsTime.localMeanSolarTime.formatted}")
            println()
        }
    } catch (e: Exception) {
        println("Error: ${e.message}")
    }
}

/// Example 4: Using the Instant extension
fun example4InstantExtension() {
    println("=== Example 4: Using Instant Extension ===")

    val now = Instant.now()

    try {
        // Convenient one-liner using extension
        val marsTime = now.marsTime(longitudeEast = 137.4)

        println("Using Instant.marsTime() extension:")
        println("MTC: ${marsTime.coordinatedMarsTime.formatted}")
        println("LMST at Gale Crater: ${marsTime.localMeanSolarTime.formatted}")
    } catch (e: Exception) {
        println("Error: ${e.message}")
    }

    println()
}

/// Example 5: Watching Mars time change in real-time
fun example5RealtimeUpdates() {
    println("=== Example 5: Real-time Mars Time (5 seconds) ===")

    val engine = MarsTimeEngine()
    var count = 0

    // Create a timer that updates every second
    val timer = fixedRateTimer(period = 1000) {
        count++

        try {
            val marsTime = engine.calculate(Instant.now(), longitudeEast = 0.0)
            println("[$count] MTC: ${marsTime.coordinatedMarsTime.formattedWithMilliseconds}")

            if (count >= 5) {
                this.cancel()
                println()
            }
        } catch (e: Exception) {
            println("Error: ${e.message}")
            this.cancel()
        }
    }

    // Wait for timer to complete
    Thread.sleep(6000)
}

/// Example 6: Individual conversion steps
fun example6StepByStep() {
    println("=== Example 6: Step-by-Step Conversion ===")

    val engine = MarsTimeEngine()
    val now = Instant.now()

    println("Converting Earth UTC to Mars time:")
    println()

    // Step 1: UTC → Julian Date
    val jd = engine.utcToJulianDate(now)
    println("1. UTC → Julian Date")
    println("   JD = ${"%.6f".format(jd)}")
    println()

    // Step 2: Julian Date → Terrestrial Time
    val tt = engine.julianDateToTerrestrialTime(jd)
    println("2. Julian Date → Terrestrial Time")
    println("   TT = ${"%.6f".format(tt)}")
    println("   (Added ΔT = 69.184 seconds for leap seconds)")
    println()

    // Step 3: Terrestrial Time → Mars Sol Date
    val msd = engine.terrestrialTimeToMarsSolDate(tt)
    println("3. Terrestrial Time → Mars Sol Date")
    println("   MSD = ${"%.6f".format(msd)}")
    println()

    // Step 4: Mars Sol Date → Coordinated Mars Time
    val mtc = engine.marsSolDateToCoordinatedMarsTime(msd)
    println("4. Mars Sol Date → Coordinated Mars Time")
    println("   MTC = ${mtc.formatted}")
    println()

    // Step 5: Coordinated Mars Time → Local Mean Solar Time
    val lmst = engine.coordinatedMarsTimeToLocalMeanSolarTime(mtc, longitudeEast = 137.4)
    println("5. Coordinated Mars Time → Local Mean Solar Time")
    println("   LMST at Gale Crater (137.4°E) = ${lmst.formatted}")
    println()
}

/// Example 7: Formatting and displaying Mars time data
fun example7Formatting() {
    println("=== Example 7: Formatting Mars Time ===")

    val engine = MarsTimeEngine()
    val now = Instant.now()

    try {
        val marsTime = engine.calculate(now, longitudeEast = 137.4)

        // Standard formatting
        println("Standard time format (HH:MM:SS):")
        println("  ${marsTime.coordinatedMarsTime.formatted}")
        println()

        // With milliseconds
        println("With milliseconds (HH:MM:SS.sss):")
        println("  ${marsTime.coordinatedMarsTime.formattedWithMilliseconds}")
        println()

        // Decimal hours
        println("Decimal hours:")
        println("  ${"%.6f".format(marsTime.coordinatedMarsTime.decimalHours)} hours")
        println()

        // Creating MarsTime from decimal hours
        val customTime = MarsTime.fromDecimalHours(12.5)
        println("Created from 12.5 decimal hours:")
        println("  ${customTime.formatted} (should be 12:30:00)")
        println()

    } catch (e: Exception) {
        println("Error: ${e.message}")
    }
}

/// Example 8: Error handling
fun example8ErrorHandling() {
    println("=== Example 8: Error Handling ===")

    val engine = MarsTimeEngine()

    // Try date before year 2000 (should fail)
    println("Attempting calculation for date before 2000:")
    try {
        val oldDate = ZonedDateTime.of(
            1999, 12, 31, 23, 59, 59, 0, ZoneOffset.UTC
        ).toInstant()

        val marsTime = engine.calculate(oldDate, longitudeEast = 0.0)
        println("  Unexpected success: ${marsTime.coordinatedMarsTime.formatted}")
    } catch (e: MarsTimeError.DateOutOfRange) {
        println("  ✓ Correctly rejected: ${e.message}")
    } catch (e: Exception) {
        println("  Unexpected error: ${e.message}")
    }

    println()

    // Valid date should work
    println("Attempting calculation for valid date (2025):")
    try {
        val validDate = ZonedDateTime.of(
            2025, 1, 15, 12, 0, 0, 0, ZoneOffset.UTC
        ).toInstant()

        val marsTime = engine.calculate(validDate, longitudeEast = 0.0)
        println("  ✓ Success: MTC = ${marsTime.coordinatedMarsTime.formatted}")
    } catch (e: Exception) {
        println("  Error: ${e.message}")
    }

    println()
}

// Main function to run all examples
fun main() {
    println("╔════════════════════════════════════════════════════════════╗")
    println("║         Mars Time Engine - Kotlin Examples                ║")
    println("║         NASA/JPL Flight Software Standard                 ║")
    println("╚════════════════════════════════════════════════════════════╝")
    println()

    example1CurrentMarsTime()
    example2SpecificDate()
    example3LandingSites()
    example4InstantExtension()
    example5RealtimeUpdates()
    example6StepByStep()
    example7Formatting()
    example8ErrorHandling()

    println("╔════════════════════════════════════════════════════════════╗")
    println("║         All Examples Complete                              ║")
    println("╚════════════════════════════════════════════════════════════╝")
}
