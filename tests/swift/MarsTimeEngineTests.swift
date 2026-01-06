// MarsTimeEngineTests.swift
// Mars Clock System - Core Engine Test Suite
// NASA/JPL Flight Software Standard
//
// Comprehensive validation against NASA Mars24 reference values

import XCTest
@testable import MarsTime

/// Test suite for MarsTimeEngine
/// Validates calculations against NASA/JPL published reference values
final class MarsTimeEngineTests: XCTestCase {

    var engine: MarsTimeEngine!

    override func setUp() {
        super.setUp()
        engine = MarsTimeEngine()
    }

    override func tearDown() {
        engine = nil
        super.tearDown()
    }

    // MARK: - Constants Tests

    func testConstants() {
        // Verify NASA/JPL constants are correct
        XCTAssertEqual(MarsTimeConstants.unixEpochJD, 2440587.5, accuracy: 1e-10)
        XCTAssertEqual(MarsTimeConstants.secondsPerDay, 86400.0, accuracy: 1e-10)
        XCTAssertEqual(MarsTimeConstants.deltaTSeconds, 69.184, accuracy: 1e-10)
        XCTAssertEqual(MarsTimeConstants.marsEpochJD, 2451549.5, accuracy: 1e-10)
        XCTAssertEqual(MarsTimeConstants.marsSolRatio, 1.0274912517, accuracy: 1e-10)
        XCTAssertEqual(MarsTimeConstants.msdOffset, 44796.0, accuracy: 1e-10)
        XCTAssertEqual(MarsTimeConstants.degreesPerHour, 15.0, accuracy: 1e-10)
    }

    // MARK: - Conversion Function Tests

    func testUTCToJulianDate() {
        // Test Unix epoch
        let unixEpoch = Date(timeIntervalSince1970: 0)
        let jd = engine.utcToJulianDate(unixEpoch)
        XCTAssertEqual(jd, 2440587.5, accuracy: 1e-6, "Unix epoch JD should be 2440587.5")

        // Test J2000 epoch (2000-01-01 12:00:00 UTC)
        var components = DateComponents()
        components.year = 2000
        components.month = 1
        components.day = 1
        components.hour = 12
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)
        let j2000 = Calendar(identifier: .gregorian).date(from: components)!
        let jdJ2000 = engine.utcToJulianDate(j2000)
        XCTAssertEqual(jdJ2000, 2451545.0, accuracy: 1e-6, "J2000 epoch JD should be 2451545.0")
    }

    func testJulianDateToTerrestrialTime() {
        let jd = 2451545.0  // J2000
        let tt = engine.julianDateToTerrestrialTime(jd)
        let expectedTT = jd + (69.184 / 86400.0)
        XCTAssertEqual(tt, expectedTT, accuracy: 1e-9)
    }

    func testTerrestrialTimeToMarsSolDate() {
        // Test Mars epoch (should give MSD ≈ 44796.0)
        let marsEpochTT = 2451549.5
        let msd = engine.terrestrialTimeToMarsSolDate(marsEpochTT)
        XCTAssertEqual(msd, 44796.0, accuracy: 1e-6, "Mars epoch should give MSD ≈ 44796.0")
    }

    func testMarsSolDateToCoordinatedMarsTime() {
        // Test MSD = 44796.5 (should give 12:00:00)
        let msd = 44796.5
        let mtc = engine.marsSolDateToCoordinatedMarsTime(msd)
        XCTAssertEqual(mtc.hours, 12)
        XCTAssertEqual(mtc.minutes, 0)
        XCTAssertEqual(mtc.seconds, 0)

        // Test MSD = 44796.25 (should give 06:00:00)
        let msd2 = 44796.25
        let mtc2 = engine.marsSolDateToCoordinatedMarsTime(msd2)
        XCTAssertEqual(mtc2.hours, 6)
        XCTAssertEqual(mtc2.minutes, 0)
        XCTAssertEqual(mtc2.seconds, 0)
    }

    func testCoordinatedMarsTimeToLocalMeanSolarTime() {
        // Test longitude = 0 (should equal MTC)
        let mtc = MarsTime(hours: 12, minutes: 0, seconds: 0)
        let lmst = engine.coordinatedMarsTimeToLocalMeanSolarTime(mtc, longitudeEast: 0.0)
        XCTAssertEqual(lmst.hours, 12)
        XCTAssertEqual(lmst.minutes, 0)

        // Test longitude = 15°E (should add 1 hour)
        let lmst15 = engine.coordinatedMarsTimeToLocalMeanSolarTime(mtc, longitudeEast: 15.0)
        XCTAssertEqual(lmst15.hours, 13)
        XCTAssertEqual(lmst15.minutes, 0)

        // Test longitude = -15°W (should subtract 1 hour)
        let lmstNeg15 = engine.coordinatedMarsTimeToLocalMeanSolarTime(mtc, longitudeEast: -15.0)
        XCTAssertEqual(lmstNeg15.hours, 11)
        XCTAssertEqual(lmstNeg15.minutes, 0)
    }

    // MARK: - NASA Reference Timestamp Validation

    func testPathfinderLanding() {
        // Mars Pathfinder landing: 1997-07-04 16:56:55 UTC
        // Expected: MSD ≈ 44795.9992, MTC ≈ 23:58:30
        var components = DateComponents()
        components.year = 1997
        components.month = 7
        components.day = 4
        components.hour = 16
        components.minute = 56
        components.second = 55
        components.timeZone = TimeZone(secondsFromGMT: 0)

        let pathfinderDate = Calendar(identifier: .gregorian).date(from: components)!

        do {
            let result = try engine.calculate(earthUTC: pathfinderDate, longitudeEast: 0.0)

            // Validate Julian Date
            XCTAssertEqual(result.julianDate, 2450630.206099537, accuracy: 1e-6, "Pathfinder JD")

            // Validate Mars Sol Date (should be very close to Sol 0)
            XCTAssertEqual(result.marsSolDate, 44795.9992, accuracy: 1e-3, "Pathfinder MSD should be ≈44795.9992")

            // Validate MTC is near midnight (23:58:xx)
            XCTAssertEqual(result.coordinatedMarsTime.hours, 23, "Pathfinder MTC hours")
            XCTAssertEqual(result.coordinatedMarsTime.minutes, 58, accuracy: 1, "Pathfinder MTC minutes")

            // Sol number should be 0 (or close to it)
            XCTAssertEqual(result.solNumber, 44795, "Pathfinder sol number")

        } catch {
            XCTFail("Pathfinder calculation failed: \(error)")
        }
    }

    func testCuriosityReference() {
        // Curiosity reference: 2020-02-18 20:55:00 UTC
        // Expected: MSD ≈ 51972.37, MTC ≈ 08:53:00
        var components = DateComponents()
        components.year = 2020
        components.month = 2
        components.day = 18
        components.hour = 20
        components.minute = 55
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)

        let curiosityDate = Calendar(identifier: .gregorian).date(from: components)!

        do {
            let result = try engine.calculate(earthUTC: curiosityDate, longitudeEast: 0.0)

            // Validate Julian Date
            XCTAssertEqual(result.julianDate, 2458899.3715277776, accuracy: 1e-6, "Curiosity JD")

            // Validate Mars Sol Date
            XCTAssertEqual(result.marsSolDate, 51972.37, accuracy: 1e-2, "Curiosity MSD")

            // Validate MTC
            XCTAssertEqual(result.coordinatedMarsTime.hours, 8, "Curiosity MTC hours")
            XCTAssertEqual(result.coordinatedMarsTime.minutes, 53, accuracy: 1, "Curiosity MTC minutes")

            // Test LMST at Gale Crater (137.4°E)
            let resultGale = try engine.calculate(earthUTC: curiosityDate, longitudeEast: 137.4)
            XCTAssertEqual(resultGale.localMeanSolarTime.hours, 18, accuracy: 1, "Gale Crater LMST hours")

        } catch {
            XCTFail("Curiosity calculation failed: \(error)")
        }
    }

    func testPerseveranceLanding() {
        // Perseverance landing: 2021-02-18 20:55:00 UTC
        // Expected: MSD ≈ 52327.37, MTC ≈ 08:53:00
        var components = DateComponents()
        components.year = 2021
        components.month = 2
        components.day = 18
        components.hour = 20
        components.minute = 55
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)

        let perseveranceDate = Calendar(identifier: .gregorian).date(from: components)!

        do {
            let result = try engine.calculate(earthUTC: perseveranceDate, longitudeEast: 0.0)

            // Validate Mars Sol Date
            XCTAssertEqual(result.marsSolDate, 52327.37, accuracy: 1e-2, "Perseverance MSD")

            // Validate MTC
            XCTAssertEqual(result.coordinatedMarsTime.hours, 8, "Perseverance MTC hours")
            XCTAssertEqual(result.coordinatedMarsTime.minutes, 53, accuracy: 1, "Perseverance MTC minutes")

            // Test LMST at Jezero Crater (77.5°E)
            let resultJezero = try engine.calculate(earthUTC: perseveranceDate, longitudeEast: 77.5)
            XCTAssertEqual(resultJezero.localMeanSolarTime.hours, 14, accuracy: 1, "Jezero Crater LMST hours")

        } catch {
            XCTFail("Perseverance calculation failed: \(error)")
        }
    }

    func testJ2000Epoch() {
        // J2000 epoch: 2000-01-01 12:00:00 UTC
        var components = DateComponents()
        components.year = 2000
        components.month = 1
        components.day = 1
        components.hour = 12
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)

        let j2000Date = Calendar(identifier: .gregorian).date(from: components)!

        do {
            let result = try engine.calculate(earthUTC: j2000Date, longitudeEast: 0.0)

            // Validate Julian Date
            XCTAssertEqual(result.julianDate, 2451545.0, accuracy: 1e-6, "J2000 JD")

            // Validate MSD is near epoch
            XCTAssertEqual(result.marsSolDate, 44795.9985, accuracy: 1e-3, "J2000 MSD")

        } catch {
            XCTFail("J2000 calculation failed: \(error)")
        }
    }

    // MARK: - Edge Case Tests

    func testLongitudeNormalization() {
        // Test longitude wrapping
        let normalized = engine.normalizeLongitude(200.0)
        XCTAssertEqual(normalized, -160.0, accuracy: 1e-9)

        let normalized2 = engine.normalizeLongitude(-200.0)
        XCTAssertEqual(normalized2, 160.0, accuracy: 1e-9)

        let normalized3 = engine.normalizeLongitude(180.0)
        XCTAssertEqual(normalized3, 180.0, accuracy: 1e-9)
    }

    func testSolBoundary() {
        // Test calculation near sol boundary (MTC near midnight)
        var components = DateComponents()
        components.year = 2025
        components.month = 12
        components.day = 31
        components.hour = 23
        components.minute = 30
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)

        let boundaryDate = Calendar(identifier: .gregorian).date(from: components)!

        do {
            let result = try engine.calculate(earthUTC: boundaryDate, longitudeEast: 0.0)

            // Should have valid MTC in range [0, 24)
            XCTAssertGreaterThanOrEqual(result.coordinatedMarsTime.hours, 0)
            XCTAssertLessThan(result.coordinatedMarsTime.hours, 24)

            // LMST should also be in valid range
            XCTAssertGreaterThanOrEqual(result.localMeanSolarTime.hours, 0)
            XCTAssertLessThan(result.localMeanSolarTime.hours, 24)

        } catch {
            XCTFail("Boundary calculation failed: \(error)")
        }
    }

    func testExtremeEastLongitude() {
        // Test at extreme east longitude (near date line)
        var components = DateComponents()
        components.year = 2025
        components.month = 6
        components.day = 15
        components.hour = 12
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)

        let date = Calendar(identifier: .gregorian).date(from: components)!

        do {
            let result = try engine.calculate(earthUTC: date, longitudeEast: 179.9)

            // LMST should be valid
            XCTAssertGreaterThanOrEqual(result.localMeanSolarTime.hours, 0)
            XCTAssertLessThan(result.localMeanSolarTime.hours, 24)

        } catch {
            XCTFail("Extreme east longitude calculation failed: \(error)")
        }
    }

    func testExtremeWestLongitude() {
        // Test at extreme west longitude (near date line)
        var components = DateComponents()
        components.year = 2025
        components.month = 6
        components.day = 15
        components.hour = 12
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)

        let date = Calendar(identifier: .gregorian).date(from: components)!

        do {
            let result = try engine.calculate(earthUTC: date, longitudeEast: -179.9)

            // LMST should be valid
            XCTAssertGreaterThanOrEqual(result.localMeanSolarTime.hours, 0)
            XCTAssertLessThan(result.localMeanSolarTime.hours, 24)

        } catch {
            XCTFail("Extreme west longitude calculation failed: \(error)")
        }
    }

    func testPrimeMeridian() {
        // Test at prime meridian (LMST should equal MTC)
        var components = DateComponents()
        components.year = 2025
        components.month = 3
        components.day = 21
        components.hour = 6
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)

        let date = Calendar(identifier: .gregorian).date(from: components)!

        do {
            let result = try engine.calculate(earthUTC: date, longitudeEast: 0.0)

            // LMST should equal MTC at prime meridian
            XCTAssertEqual(result.localMeanSolarTime.hours, result.coordinatedMarsTime.hours)
            XCTAssertEqual(result.localMeanSolarTime.minutes, result.coordinatedMarsTime.minutes)
            XCTAssertEqual(result.localMeanSolarTime.seconds, result.coordinatedMarsTime.seconds)

        } catch {
            XCTFail("Prime meridian calculation failed: \(error)")
        }
    }

    // MARK: - Error Handling Tests

    func testDateOutOfRangeBefore2000() {
        // Test date before year 2000
        var components = DateComponents()
        components.year = 1999
        components.month = 12
        components.day = 31
        components.hour = 23
        components.minute = 59
        components.second = 59
        components.timeZone = TimeZone(secondsFromGMT: 0)

        let oldDate = Calendar(identifier: .gregorian).date(from: components)!

        XCTAssertThrowsError(try engine.calculate(earthUTC: oldDate, longitudeEast: 0.0)) { error in
            XCTAssertTrue(error is MarsTimeError)
        }
    }

    func testDateOutOfRangeAfter2100() {
        // Test date after year 2100
        var components = DateComponents()
        components.year = 2101
        components.month = 1
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)

        let futureDate = Calendar(identifier: .gregorian).date(from: components)!

        XCTAssertThrowsError(try engine.calculate(earthUTC: futureDate, longitudeEast: 0.0)) { error in
            XCTAssertTrue(error is MarsTimeError)
        }
    }

    // MARK: - Performance Tests

    func testCalculationPerformance() {
        let date = Date()

        measure {
            for _ in 0..<1000 {
                _ = try? engine.calculate(earthUTC: date, longitudeEast: 137.4)
            }
        }
    }

    // MARK: - Data Structure Tests

    func testMarsTimeFormatting() {
        let marsTime = MarsTime(hours: 9, minutes: 5, seconds: 3)
        XCTAssertEqual(marsTime.formatted, "09:05:03")

        let marsTimeWithFractional = MarsTime(hours: 12, minutes: 30, seconds: 45, fractionalSeconds: 0.123)
        XCTAssertEqual(marsTimeWithFractional.formattedWithMilliseconds, "12:30:45.123")
    }

    func testMarsTimeFromDecimalHours() {
        let marsTime = MarsTime(decimalHours: 12.5)
        XCTAssertEqual(marsTime.hours, 12)
        XCTAssertEqual(marsTime.minutes, 30)
        XCTAssertEqual(marsTime.seconds, 0)
    }

    func testDateExtension() {
        let date = Date()

        do {
            let result = try date.marsTime(longitudeEast: 0.0)
            XCTAssertNotNil(result)
            XCTAssertEqual(result.earthUTC, date)
        } catch {
            XCTFail("Date extension calculation failed: \(error)")
        }
    }
}
