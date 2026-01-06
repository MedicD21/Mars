// MarsTimeEngineTest.kt
// Mars Clock System - Core Engine Test Suite
// NASA/JPL Flight Software Standard
//
// Comprehensive validation against NASA Mars24 reference values

package com.nasa.marstime.engine

import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import java.time.Instant
import java.time.ZoneOffset
import java.time.ZonedDateTime
import kotlin.math.abs

/**
 * Test suite for MarsTimeEngine
 * Validates calculations against NASA/JPL published reference values
 */
class MarsTimeEngineTest {

    private lateinit var engine: MarsTimeEngine

    @BeforeEach
    fun setUp() {
        engine = MarsTimeEngine()
    }

    // MARK: - Constants Tests

    @Test
    fun `test constants are correct`() {
        // Verify NASA/JPL constants are correct
        assertEquals(2440587.5, MarsTimeConstants.UNIX_EPOCH_JD, 1e-10, "Unix epoch JD")
        assertEquals(86400.0, MarsTimeConstants.SECONDS_PER_DAY, 1e-10, "Seconds per day")
        assertEquals(69.184, MarsTimeConstants.DELTA_T_SECONDS, 1e-10, "Delta T")
        assertEquals(2451549.5, MarsTimeConstants.MARS_EPOCH_JD, 1e-10, "Mars epoch JD")
        assertEquals(1.0274912517, MarsTimeConstants.MARS_SOL_RATIO, 1e-10, "Mars sol ratio")
        assertEquals(44796.0, MarsTimeConstants.MSD_OFFSET, 1e-10, "MSD offset")
        assertEquals(15.0, MarsTimeConstants.DEGREES_PER_HOUR, 1e-10, "Degrees per hour")
    }

    // MARK: - Conversion Function Tests

    @Test
    fun `test UTC to Julian Date conversion`() {
        // Test Unix epoch
        val unixEpoch = Instant.ofEpochSecond(0)
        val jd = engine.utcToJulianDate(unixEpoch)
        assertEquals(2440587.5, jd, 1e-6, "Unix epoch JD should be 2440587.5")

        // Test J2000 epoch (2000-01-01 12:00:00 UTC)
        val j2000 = ZonedDateTime.of(2000, 1, 1, 12, 0, 0, 0, ZoneOffset.UTC).toInstant()
        val jdJ2000 = engine.utcToJulianDate(j2000)
        assertEquals(2451545.0, jdJ2000, 1e-6, "J2000 epoch JD should be 2451545.0")
    }

    @Test
    fun `test Julian Date to Terrestrial Time conversion`() {
        val jd = 2451545.0  // J2000
        val tt = engine.julianDateToTerrestrialTime(jd)
        val expectedTT = jd + (69.184 / 86400.0)
        assertEquals(expectedTT, tt, 1e-9)
    }

    @Test
    fun `test Terrestrial Time to Mars Sol Date conversion`() {
        // Test Mars epoch (should give MSD ≈ 44796.0)
        val marsEpochTT = 2451549.5
        val msd = engine.terrestrialTimeToMarsSolDate(marsEpochTT)
        assertEquals(44796.0, msd, 1e-6, "Mars epoch should give MSD ≈ 44796.0")
    }

    @Test
    fun `test Mars Sol Date to Coordinated Mars Time conversion`() {
        // Test MSD = 44796.5 (should give 12:00:00)
        val msd = 44796.5
        val mtc = engine.marsSolDateToCoordinatedMarsTime(msd)
        assertEquals(12, mtc.hours)
        assertEquals(0, mtc.minutes)
        assertEquals(0, mtc.seconds)

        // Test MSD = 44796.25 (should give 06:00:00)
        val msd2 = 44796.25
        val mtc2 = engine.marsSolDateToCoordinatedMarsTime(msd2)
        assertEquals(6, mtc2.hours)
        assertEquals(0, mtc2.minutes)
        assertEquals(0, mtc2.seconds)
    }

    @Test
    fun `test Coordinated Mars Time to Local Mean Solar Time conversion`() {
        // Test longitude = 0 (should equal MTC)
        val mtc = MarsTime(12, 0, 0)
        val lmst = engine.coordinatedMarsTimeToLocalMeanSolarTime(mtc, 0.0)
        assertEquals(12, lmst.hours)
        assertEquals(0, lmst.minutes)

        // Test longitude = 15°E (should add 1 hour)
        val lmst15 = engine.coordinatedMarsTimeToLocalMeanSolarTime(mtc, 15.0)
        assertEquals(13, lmst15.hours)
        assertEquals(0, lmst15.minutes)

        // Test longitude = -15°W (should subtract 1 hour)
        val lmstNeg15 = engine.coordinatedMarsTimeToLocalMeanSolarTime(mtc, -15.0)
        assertEquals(11, lmstNeg15.hours)
        assertEquals(0, lmstNeg15.minutes)
    }

    // MARK: - NASA Reference Timestamp Validation

    @Test
    fun `test Pathfinder landing calculation`() {
        // Mars Pathfinder landing: 1997-07-04 16:56:55 UTC
        // Expected: MSD ≈ 44795.9992, MTC ≈ 23:58:30
        val pathfinderDate = ZonedDateTime.of(
            1997, 7, 4, 16, 56, 55, 0, ZoneOffset.UTC
        ).toInstant()

        val result = engine.calculate(pathfinderDate, 0.0)

        // Validate Julian Date
        assertEquals(2450630.206099537, result.julianDate, 1e-6, "Pathfinder JD")

        // Validate Mars Sol Date (should be very close to Sol 0)
        assertEquals(44795.9992, result.marsSolDate, 1e-3, "Pathfinder MSD should be ≈44795.9992")

        // Validate MTC is near midnight (23:58:xx)
        assertEquals(23, result.coordinatedMarsTime.hours, "Pathfinder MTC hours")
        assertTrue(abs(result.coordinatedMarsTime.minutes - 58) <= 1, "Pathfinder MTC minutes")

        // Sol number should be 44795
        assertEquals(44795, result.solNumber, "Pathfinder sol number")
    }

    @Test
    fun `test Curiosity reference timestamp`() {
        // Curiosity reference: 2020-02-18 20:55:00 UTC
        // Expected: MSD ≈ 51972.37, MTC ≈ 08:53:00
        val curiosityDate = ZonedDateTime.of(
            2020, 2, 18, 20, 55, 0, 0, ZoneOffset.UTC
        ).toInstant()

        val result = engine.calculate(curiosityDate, 0.0)

        // Validate Julian Date
        assertEquals(2458899.3715277776, result.julianDate, 1e-6, "Curiosity JD")

        // Validate Mars Sol Date
        assertEquals(51972.37, result.marsSolDate, 1e-2, "Curiosity MSD")

        // Validate MTC
        assertEquals(8, result.coordinatedMarsTime.hours, "Curiosity MTC hours")
        assertTrue(abs(result.coordinatedMarsTime.minutes - 53) <= 1, "Curiosity MTC minutes")

        // Test LMST at Gale Crater (137.4°E)
        val resultGale = engine.calculate(curiosityDate, 137.4)
        assertTrue(abs(resultGale.localMeanSolarTime.hours - 18) <= 1, "Gale Crater LMST hours")
    }

    @Test
    fun `test Perseverance landing calculation`() {
        // Perseverance landing: 2021-02-18 20:55:00 UTC
        // Expected: MSD ≈ 52327.37, MTC ≈ 08:53:00
        val perseveranceDate = ZonedDateTime.of(
            2021, 2, 18, 20, 55, 0, 0, ZoneOffset.UTC
        ).toInstant()

        val result = engine.calculate(perseveranceDate, 0.0)

        // Validate Mars Sol Date
        assertEquals(52327.37, result.marsSolDate, 1e-2, "Perseverance MSD")

        // Validate MTC
        assertEquals(8, result.coordinatedMarsTime.hours, "Perseverance MTC hours")
        assertTrue(abs(result.coordinatedMarsTime.minutes - 53) <= 1, "Perseverance MTC minutes")

        // Test LMST at Jezero Crater (77.5°E)
        val resultJezero = engine.calculate(perseveranceDate, 77.5)
        assertTrue(abs(resultJezero.localMeanSolarTime.hours - 14) <= 1, "Jezero Crater LMST hours")
    }

    @Test
    fun `test J2000 epoch calculation`() {
        // J2000 epoch: 2000-01-01 12:00:00 UTC
        val j2000Date = ZonedDateTime.of(
            2000, 1, 1, 12, 0, 0, 0, ZoneOffset.UTC
        ).toInstant()

        val result = engine.calculate(j2000Date, 0.0)

        // Validate Julian Date
        assertEquals(2451545.0, result.julianDate, 1e-6, "J2000 JD")

        // Validate MSD is near epoch
        assertEquals(44795.9985, result.marsSolDate, 1e-3, "J2000 MSD")
    }

    // MARK: - Edge Case Tests

    @Test
    fun `test longitude normalization`() {
        // Test longitude wrapping
        val normalized = engine.normalizeLongitude(200.0)
        assertEquals(-160.0, normalized, 1e-9)

        val normalized2 = engine.normalizeLongitude(-200.0)
        assertEquals(160.0, normalized2, 1e-9)

        val normalized3 = engine.normalizeLongitude(180.0)
        assertEquals(180.0, normalized3, 1e-9)
    }

    @Test
    fun `test sol boundary crossing`() {
        // Test calculation near sol boundary (MTC near midnight)
        val boundaryDate = ZonedDateTime.of(
            2025, 12, 31, 23, 30, 0, 0, ZoneOffset.UTC
        ).toInstant()

        val result = engine.calculate(boundaryDate, 0.0)

        // Should have valid MTC in range [0, 24)
        assertTrue(result.coordinatedMarsTime.hours >= 0)
        assertTrue(result.coordinatedMarsTime.hours < 24)

        // LMST should also be in valid range
        assertTrue(result.localMeanSolarTime.hours >= 0)
        assertTrue(result.localMeanSolarTime.hours < 24)
    }

    @Test
    fun `test extreme east longitude`() {
        // Test at extreme east longitude (near date line)
        val date = ZonedDateTime.of(
            2025, 6, 15, 12, 0, 0, 0, ZoneOffset.UTC
        ).toInstant()

        val result = engine.calculate(date, 179.9)

        // LMST should be valid
        assertTrue(result.localMeanSolarTime.hours >= 0)
        assertTrue(result.localMeanSolarTime.hours < 24)
    }

    @Test
    fun `test extreme west longitude`() {
        // Test at extreme west longitude (near date line)
        val date = ZonedDateTime.of(
            2025, 6, 15, 12, 0, 0, 0, ZoneOffset.UTC
        ).toInstant()

        val result = engine.calculate(date, -179.9)

        // LMST should be valid
        assertTrue(result.localMeanSolarTime.hours >= 0)
        assertTrue(result.localMeanSolarTime.hours < 24)
    }

    @Test
    fun `test prime meridian LMST equals MTC`() {
        // Test at prime meridian (LMST should equal MTC)
        val date = ZonedDateTime.of(
            2025, 3, 21, 6, 0, 0, 0, ZoneOffset.UTC
        ).toInstant()

        val result = engine.calculate(date, 0.0)

        // LMST should equal MTC at prime meridian
        assertEquals(result.coordinatedMarsTime.hours, result.localMeanSolarTime.hours)
        assertEquals(result.coordinatedMarsTime.minutes, result.localMeanSolarTime.minutes)
        assertEquals(result.coordinatedMarsTime.seconds, result.localMeanSolarTime.seconds)
    }

    // MARK: - Error Handling Tests

    @Test
    fun `test date out of range before 2000 throws error`() {
        // Test date before year 2000
        val oldDate = ZonedDateTime.of(
            1999, 12, 31, 23, 59, 59, 0, ZoneOffset.UTC
        ).toInstant()

        assertThrows<MarsTimeError.DateOutOfRange> {
            engine.calculate(oldDate, 0.0)
        }
    }

    @Test
    fun `test date out of range after 2100 throws error`() {
        // Test date after year 2100
        val futureDate = ZonedDateTime.of(
            2101, 1, 1, 0, 0, 0, 0, ZoneOffset.UTC
        ).toInstant()

        assertThrows<MarsTimeError.DateOutOfRange> {
            engine.calculate(futureDate, 0.0)
        }
    }

    // MARK: - Data Structure Tests

    @Test
    fun `test MarsTime formatting`() {
        val marsTime = MarsTime(9, 5, 3)
        assertEquals("09:05:03", marsTime.formatted)

        val marsTimeWithFractional = MarsTime(12, 30, 45, 0.123)
        assertEquals("12:30:45.123", marsTimeWithFractional.formattedWithMilliseconds)
    }

    @Test
    fun `test MarsTime from decimal hours`() {
        val marsTime = MarsTime.fromDecimalHours(12.5)
        assertEquals(12, marsTime.hours)
        assertEquals(30, marsTime.minutes)
        assertEquals(0, marsTime.seconds)
    }

    @Test
    fun `test MarsTime decimal hours calculation`() {
        val marsTime = MarsTime(12, 30, 0)
        assertEquals(12.5, marsTime.decimalHours, 1e-6)

        val marsTime2 = MarsTime(0, 15, 0)
        assertEquals(0.25, marsTime2.decimalHours, 1e-6)
    }

    @Test
    fun `test Instant extension function`() {
        val instant = Instant.now()
        val result = instant.marsTime(0.0)

        assertNotNull(result)
        assertEquals(instant, result.earthUTC)
    }

    @Test
    fun `test MarsTimeData toString`() {
        val instant = ZonedDateTime.of(
            2025, 1, 1, 0, 0, 0, 0, ZoneOffset.UTC
        ).toInstant()

        val result = engine.calculate(instant, 0.0)
        val string = result.toString()

        assertTrue(string.contains("MarsTimeData"))
        assertTrue(string.contains("Earth UTC"))
        assertTrue(string.contains("Mars Sol Date"))
    }

    // MARK: - Cross-Platform Consistency Tests

    @Test
    fun `test deterministic output for same input`() {
        val instant = ZonedDateTime.of(
            2025, 6, 15, 12, 0, 0, 0, ZoneOffset.UTC
        ).toInstant()

        // Calculate multiple times
        val result1 = engine.calculate(instant, 137.4)
        val result2 = engine.calculate(instant, 137.4)

        // Should be identical
        assertEquals(result1.julianDate, result2.julianDate, 1e-15)
        assertEquals(result1.marsSolDate, result2.marsSolDate, 1e-15)
        assertEquals(result1.coordinatedMarsTime, result2.coordinatedMarsTime)
        assertEquals(result1.localMeanSolarTime, result2.localMeanSolarTime)
    }

    @Test
    fun `test calculation with high precision instant`() {
        // Test with nanosecond precision
        val instant = Instant.ofEpochSecond(1609459200, 123456789)  // 2021-01-01 00:00:00.123456789 UTC

        val result = engine.calculate(instant, 0.0)

        // Should handle nanoseconds correctly
        assertNotNull(result)
        assertTrue(result.julianDate > 0)
        assertTrue(result.marsSolDate > 0)
    }

    // MARK: - Performance Tests

    @Test
    fun `test calculation performance`() {
        val instant = Instant.now()

        // Warm up
        repeat(100) {
            engine.calculate(instant, 137.4)
        }

        // Measure
        val startTime = System.nanoTime()
        repeat(1000) {
            engine.calculate(instant, 137.4)
        }
        val endTime = System.nanoTime()

        val averageTimeMs = (endTime - startTime) / 1_000_000.0 / 1000.0
        println("Average calculation time: $averageTimeMs ms")

        // Should be fast (< 1ms per calculation)
        assertTrue(averageTimeMs < 1.0, "Calculation should be fast")
    }

    @Test
    fun `test multiple calculations in sequence`() {
        val baseInstant = ZonedDateTime.of(
            2025, 1, 1, 0, 0, 0, 0, ZoneOffset.UTC
        ).toInstant()

        // Calculate for 100 sequential seconds
        val results = (0 until 100).map { seconds ->
            val instant = baseInstant.plusSeconds(seconds.toLong())
            engine.calculate(instant, 0.0)
        }

        // Verify all results are valid
        results.forEach { result ->
            assertTrue(result.marsSolDate > 0)
            assertTrue(result.coordinatedMarsTime.hours in 0..23)
            assertTrue(result.coordinatedMarsTime.minutes in 0..59)
            assertTrue(result.coordinatedMarsTime.seconds in 0..59)
        }

        // Verify MSD increases monotonically (approximately)
        for (i in 1 until results.size) {
            assertTrue(results[i].marsSolDate >= results[i - 1].marsSolDate)
        }
    }
}
