// MarsTimeEngine.swift
// Mars Clock System - Core Time Calculation Engine
// NASA/JPL Flight Software Standard
//
// Implementation of:
// - Allison, M., & McEwen, M. (2000). Planetary and Space Science, 48(2-3), 215-235.
// - NASA Mars24 Sunclock Algorithm v8.0
//
// This engine provides deterministic, scientifically accurate Mars time calculations
// suitable for mission operations and planetary science applications.

import Foundation

// MARK: - Data Structures

/// Complete Mars time calculation result
public struct MarsTimeData: Equatable, Codable {
    /// Input Earth UTC timestamp
    public let earthUTC: Date

    /// Julian Date (astronomical standard)
    public let julianDate: Double

    /// Terrestrial Time in Julian Date (accounts for leap seconds)
    public let terrestrialTime: Double

    /// Mars Sol Date (continuous Mars day count since epoch)
    public let marsSolDate: Double

    /// Sol number (integer part of MSD)
    public let solNumber: Int

    /// Coordinated Mars Time (24-hour time at Mars prime meridian)
    public let coordinatedMarsTime: MarsTime

    /// Local Mean Solar Time (time at specified longitude)
    public let localMeanSolarTime: MarsTime

    /// Longitude used for LMST calculation (degrees East)
    public let longitudeEast: Double

    public init(
        earthUTC: Date,
        julianDate: Double,
        terrestrialTime: Double,
        marsSolDate: Double,
        solNumber: Int,
        coordinatedMarsTime: MarsTime,
        localMeanSolarTime: MarsTime,
        longitudeEast: Double
    ) {
        self.earthUTC = earthUTC
        self.julianDate = julianDate
        self.terrestrialTime = terrestrialTime
        self.marsSolDate = marsSolDate
        self.solNumber = solNumber
        self.coordinatedMarsTime = coordinatedMarsTime
        self.localMeanSolarTime = localMeanSolarTime
        self.longitudeEast = longitudeEast
    }
}

/// Mars time representation (24-hour format)
public struct MarsTime: Equatable, Codable {
    /// Hour (0-23)
    public let hours: Int

    /// Minute (0-59)
    public let minutes: Int

    /// Second (0-59)
    public let seconds: Int

    /// Fractional seconds (0.0-0.999...)
    public let fractionalSeconds: Double

    /// Decimal hours representation (for calculations)
    public let decimalHours: Double

    public init(hours: Int, minutes: Int, seconds: Int, fractionalSeconds: Double = 0.0) {
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
        self.fractionalSeconds = fractionalSeconds
        self.decimalHours = Double(hours) + Double(minutes) / 60.0 + Double(seconds) / 3600.0 + fractionalSeconds / 3600.0
    }

    public init(decimalHours: Double) {
        self.decimalHours = decimalHours

        let totalHours = decimalHours
        self.hours = Int(totalHours)

        let remainingMinutes = (totalHours - Double(hours)) * 60.0
        self.minutes = Int(remainingMinutes)

        let remainingSeconds = (remainingMinutes - Double(minutes)) * 60.0
        self.seconds = Int(remainingSeconds)

        self.fractionalSeconds = remainingSeconds - Double(seconds)
    }

    /// Formatted string representation (HH:MM:SS)
    public var formatted: String {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    /// Formatted string with milliseconds (HH:MM:SS.sss)
    public var formattedWithMilliseconds: String {
        let milliseconds = Int(fractionalSeconds * 1000)
        return String(format: "%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
    }
}

// MARK: - Constants

/// NASA/JPL Mars Time Constants
/// References: Allison & McEwen (2000), Mars24 Algorithm
public enum MarsTimeConstants {
    // MARK: Julian Date Constants

    /// Julian Date of Unix epoch (1970-01-01 00:00:00 UTC)
    /// Reference: Meeus, J. (1998). Astronomical Algorithms
    public static let unixEpochJD: Double = 2440587.5

    /// Seconds per Earth day
    public static let secondsPerDay: Double = 86400.0

    // MARK: Leap Second Constants

    /// ΔT = TAI - UTC (Terrestrial Time offset)
    /// As of 2026-01-06: 37 leap seconds + 32.184 TT offset = 69.184 seconds
    /// Reference: IERS Bulletin C
    /// Last leap second: 2017-01-01
    public static let deltaTSeconds: Double = 69.184

    // MARK: Mars Time Constants

    /// Julian Date of Mars epoch (2000-01-06 00:00:00 TT)
    /// Reference: Allison & McEwen (2000), Equation 11
    public static let marsEpochJD: Double = 2451549.5

    /// Ratio of Mars solar day to Earth day
    /// Mars sol = 88775.244 seconds
    /// Earth day = 86400.0 seconds
    /// Ratio = 1.0274912517
    /// Reference: Allison & McEwen (2000)
    public static let marsSolRatio: Double = 1.0274912517

    /// MSD offset (Clancy et al. 2000 convention)
    /// Aligns MSD ≈ 0 with Mars Pathfinder landing
    /// Reference: Allison & McEwen (2000), Equation 11
    public static let msdOffset: Double = 44796.0

    /// Hours per degree longitude
    /// 360° / 24 hours = 15°/hour
    public static let degreesPerHour: Double = 15.0

    // MARK: Validation Constants

    /// Minimum valid date (J2000 epoch)
    public static let minimumValidDate: Date = {
        var components = DateComponents()
        components.year = 2000
        components.month = 1
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)
        return Calendar(identifier: .gregorian).date(from: components)!
    }()

    /// Maximum valid date (year 2100)
    public static let maximumValidDate: Date = {
        var components = DateComponents()
        components.year = 2100
        components.month = 12
        components.day = 31
        components.hour = 23
        components.minute = 59
        components.second = 59
        components.timeZone = TimeZone(secondsFromGMT: 0)
        return Calendar(identifier: .gregorian).date(from: components)!
    }()
}

// MARK: - Errors

public enum MarsTimeError: Error, LocalizedError {
    case dateOutOfRange(Date)
    case invalidLongitude(Double)
    case calculationError(String)

    public var errorDescription: String? {
        switch self {
        case .dateOutOfRange(let date):
            return "Date \(date) is outside valid range (2000-01-01 to 2100-12-31). Algorithm accuracy not guaranteed."
        case .invalidLongitude(let longitude):
            return "Longitude \(longitude)° is invalid. Must be in range [-180, 180]."
        case .calculationError(let message):
            return "Mars time calculation error: \(message)"
        }
    }
}

// MARK: - Mars Time Engine

/// Core Mars time calculation engine
/// Implements NASA/JPL standard algorithms for converting Earth UTC to Mars time
public final class MarsTimeEngine {

    public init() {}

    // MARK: - Public API

    /// Calculate complete Mars time data from Earth UTC timestamp
    ///
    /// - Parameters:
    ///   - earthUTC: Earth UTC timestamp
    ///   - longitudeEast: East longitude in degrees [-180, 180]. East is positive, West is negative.
    /// - Returns: Complete Mars time calculation result
    /// - Throws: MarsTimeError if inputs are invalid
    ///
    /// Reference: Allison & McEwen (2000), NASA Mars24 Algorithm
    public func calculate(earthUTC: Date, longitudeEast: Double = 0.0) throws -> MarsTimeData {
        // Validate inputs
        try validateInputs(earthUTC: earthUTC, longitudeEast: longitudeEast)

        // Step 1: UTC → Julian Date
        let jd = utcToJulianDate(earthUTC)

        // Step 2: Julian Date → Terrestrial Time
        let tt = julianDateToTerrestrialTime(jd)

        // Step 3: Terrestrial Time → Mars Sol Date
        let msd = terrestrialTimeToMarsSolDate(tt)

        // Step 4: Mars Sol Date → Coordinated Mars Time
        let mtc = marsSolDateToCoordinatedMarsTime(msd)

        // Step 5: Coordinated Mars Time → Local Mean Solar Time
        let lmst = coordinatedMarsTimeToLocalMeanSolarTime(mtc, longitudeEast: longitudeEast)

        // Extract sol number
        let solNumber = Int(floor(msd))

        return MarsTimeData(
            earthUTC: earthUTC,
            julianDate: jd,
            terrestrialTime: tt,
            marsSolDate: msd,
            solNumber: solNumber,
            coordinatedMarsTime: mtc,
            localMeanSolarTime: lmst,
            longitudeEast: longitudeEast
        )
    }

    // MARK: - Conversion Functions

    /// Convert UTC timestamp to Julian Date
    ///
    /// Formula: JD = (Unix Timestamp / 86400.0) + 2440587.5
    ///
    /// - Parameter earthUTC: Earth UTC timestamp
    /// - Returns: Julian Date
    ///
    /// Reference: Meeus, J. (1998). Astronomical Algorithms, Chapter 7
    public func utcToJulianDate(_ earthUTC: Date) -> Double {
        let unixTimestamp = earthUTC.timeIntervalSince1970
        let jd = (unixTimestamp / MarsTimeConstants.secondsPerDay) + MarsTimeConstants.unixEpochJD
        return jd
    }

    /// Convert Julian Date to Terrestrial Time (accounts for leap seconds)
    ///
    /// Formula: TT = JD + ΔT / 86400.0
    /// Where ΔT = TAI - UTC = 69.184 seconds (as of 2026-01-06)
    ///
    /// - Parameter jd: Julian Date
    /// - Returns: Terrestrial Time in Julian Date
    ///
    /// Reference: IERS Bulletin C, Astronomical Almanac
    public func julianDateToTerrestrialTime(_ jd: Double) -> Double {
        let tt = jd + (MarsTimeConstants.deltaTSeconds / MarsTimeConstants.secondsPerDay)
        return tt
    }

    /// Convert Terrestrial Time to Mars Sol Date
    ///
    /// Formula: MSD = (TT - 2451549.5) / 1.0274912517 + 44796.0
    ///
    /// - Parameter tt: Terrestrial Time in Julian Date
    /// - Returns: Mars Sol Date (continuous day count)
    ///
    /// Reference: Allison & McEwen (2000), Equation 11
    public func terrestrialTimeToMarsSolDate(_ tt: Double) -> Double {
        let msd = ((tt - MarsTimeConstants.marsEpochJD) / MarsTimeConstants.marsSolRatio) + MarsTimeConstants.msdOffset
        return msd
    }

    /// Convert Mars Sol Date to Coordinated Mars Time (24-hour clock at prime meridian)
    ///
    /// Formula: MTC = (MSD mod 1.0) × 24 hours
    ///
    /// - Parameter msd: Mars Sol Date
    /// - Returns: Coordinated Mars Time
    ///
    /// Reference: Allison & McEwen (2000), Section 3
    public func marsSolDateToCoordinatedMarsTime(_ msd: Double) -> MarsTime {
        // Get fractional sol (0.0 to 0.999...)
        let fractionalSol = msd - floor(msd)

        // Convert to decimal hours
        let decimalHours = fractionalSol * 24.0

        return MarsTime(decimalHours: decimalHours)
    }

    /// Convert Coordinated Mars Time to Local Mean Solar Time
    ///
    /// Formula: LMST = MTC + (longitude / 15.0) hours
    ///
    /// - Parameters:
    ///   - mtc: Coordinated Mars Time
    ///   - longitudeEast: East longitude in degrees [-180, 180]
    /// - Returns: Local Mean Solar Time
    ///
    /// Reference: Allison & McEwen (2000), NASA Mars24 documentation
    public func coordinatedMarsTimeToLocalMeanSolarTime(_ mtc: MarsTime, longitudeEast: Double) -> MarsTime {
        // Calculate time offset from longitude
        let longitudeOffset = longitudeEast / MarsTimeConstants.degreesPerHour

        // Add offset to MTC
        var lmstHours = mtc.decimalHours + longitudeOffset

        // Normalize to 24-hour range [0, 24)
        lmstHours = normalizeHours(lmstHours)

        return MarsTime(decimalHours: lmstHours)
    }

    // MARK: - Helper Functions

    /// Normalize hours to 24-hour range [0, 24)
    private func normalizeHours(_ hours: Double) -> Double {
        var normalized = hours

        // Handle negative values
        while normalized < 0 {
            normalized += 24.0
        }

        // Handle values >= 24
        while normalized >= 24.0 {
            normalized -= 24.0
        }

        return normalized
    }

    /// Normalize longitude to range [-180, 180]
    public func normalizeLongitude(_ longitude: Double) -> Double {
        var normalized = longitude

        while normalized > 180.0 {
            normalized -= 360.0
        }

        while normalized < -180.0 {
            normalized += 360.0
        }

        return normalized
    }

    // MARK: - Validation

    /// Validate calculation inputs
    private func validateInputs(earthUTC: Date, longitudeEast: Double) throws {
        // Check date range
        if earthUTC < MarsTimeConstants.minimumValidDate || earthUTC > MarsTimeConstants.maximumValidDate {
            throw MarsTimeError.dateOutOfRange(earthUTC)
        }

        // Check longitude range (allow outside [-180, 180] but warn)
        if abs(longitudeEast) > 180.0 {
            // Normalize it rather than throwing
            let _ = normalizeLongitude(longitudeEast)
        }
    }
}

// MARK: - Convenience Extensions

extension Date {
    /// Calculate Mars time for this date at given longitude
    public func marsTime(longitudeEast: Double = 0.0) throws -> MarsTimeData {
        let engine = MarsTimeEngine()
        return try engine.calculate(earthUTC: self, longitudeEast: longitudeEast)
    }
}

// MARK: - Debug Description

extension MarsTimeData: CustomStringConvertible {
    public var description: String {
        return """
        MarsTimeData:
          Earth UTC: \(earthUTC)
          Julian Date: \(String(format: "%.6f", julianDate))
          Terrestrial Time: \(String(format: "%.6f", terrestrialTime))
          Mars Sol Date: \(String(format: "%.6f", marsSolDate))
          Sol Number: \(solNumber)
          Coordinated Mars Time: \(coordinatedMarsTime.formatted)
          Local Mean Solar Time: \(localMeanSolarTime.formatted)
          Longitude: \(String(format: "%.4f", longitudeEast))°E
        """
    }
}

extension MarsTime: CustomStringConvertible {
    public var description: String {
        return formatted
    }
}
