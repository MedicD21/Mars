# Mars Clock System

**NASA/JPL Flight Software Standard**
**Planetary Time System for Mission Operations**

---

## Overview

Professional Mars time calculation system for astronauts, mission controllers, and planetary scientists. Implements NASA/JPL standards with scientifically accurate algorithms based on Allison & McEwen (2000) and the Mars24 Sunclock.

### Supported Platforms

- **iOS** (Swift/SwiftUI, iOS 17+)
- **watchOS** (SwiftUI, complications, watchOS 10+)
- **Android** (Kotlin/Jetpack Compose, Material 3, Android 14+)

---

## Features

### Time Systems
- **Earth UTC** - Coordinated Universal Time reference
- **Julian Date (JD)** - Astronomical standard
- **Mars Sol Date (MSD)** - Continuous Mars day count
- **Coordinated Mars Time (MTC)** - Mars prime meridian time
- **Local Mean Solar Time (LMST)** - Time at specific longitude

### Capabilities
- Real-time Mars clock with 1-second precision
- Configurable longitude for landing site LMST
- Offline-first (no network required)
- Battery-optimized for wearables
- watchOS complications (Modular, Circular, Ultra)
- Cross-platform mathematical consistency
- Dark-mode mission control aesthetic

---

## Project Structure

```
Mars/
├── docs/                          # Documentation
│   ├── ARCHITECTURE.md            # System architecture & design
│   ├── MARS_TIME_ALGORITHM.md     # Mathematical formulas & NASA citations
│   └── REFERENCES.md              # Scientific bibliography
│
├── core/                          # Platform-agnostic core
│   ├── reference-implementation/
│   │   ├── swift/                 # Swift engine (iOS/watchOS)
│   │   │   └── MarsTimeEngine.swift
│   │   └── kotlin/                # Kotlin engine (Android)
│   │       └── MarsTimeEngine.kt
│   └── validation/
│       └── nasa-reference-timestamps.json  # Known-good test data
│
├── ios/                           # iOS application
│   └── MarsTime/                  # Xcode project
│
├── watchos/                       # watchOS application
│   └── MarsTimeWatch/             # Watch app & complications
│
├── android/                       # Android application
│   └── MarsTime/                  # Android Studio project
│
└── tests/                         # Test suites
    ├── swift/                     # iOS/watchOS tests
    └── kotlin/                    # Android tests
```

---

## Quick Start

### Prerequisites

**iOS/watchOS Development**:
- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+

**Android Development**:
- Android Studio Hedgehog (2023.1.1)+
- Kotlin 1.9+
- Gradle 8.0+

### Building

#### iOS/watchOS
```bash
cd ios/MarsTime
xcodebuild -scheme MarsTime -destination 'platform=iOS Simulator,name=iPhone 15'
```

#### Android
```bash
cd android/MarsTime
./gradlew assembleDebug
```

### Testing

#### iOS/watchOS
```bash
cd ios/MarsTime
xcodebuild test -scheme MarsTime -destination 'platform=iOS Simulator,name=iPhone 15'
```

#### Android
```bash
cd android/MarsTime
./gradlew test
./gradlew connectedAndroidTest
```

---

## Algorithm Summary

### UTC → Mars Time Conversion Pipeline

```
1. Earth UTC Time
   ↓
2. Julian Date (JD = Unix_Timestamp/86400 + 2440587.5)
   ↓
3. Terrestrial Time (TT = JD + ΔT/86400, ΔT = 69.184s)
   ↓
4. Mars Sol Date (MSD = (TT - 2451549.5)/1.0274912517 + 44796.0)
   ↓
5. Coordinated Mars Time (MTC = (MSD mod 1.0) × 24 hours)
   ↓
6. Local Mean Solar Time (LMST = MTC + longitude/15.0)
```

### Key Constants

```swift
// Julian Date
UNIX_EPOCH_JD = 2440587.5
SECONDS_PER_DAY = 86400.0

// Leap Seconds (as of 2026-01-06)
DELTA_T_SECONDS = 69.184

// Mars Time
MARS_EPOCH_JD = 2451549.5
MARS_SOL_RATIO = 1.0274912517
MSD_OFFSET = 44796.0
```

See [`docs/MARS_TIME_ALGORITHM.md`](docs/MARS_TIME_ALGORITHM.md) for complete formulas and derivations.

---

## Validation

All implementations validated against NASA Mars24 reference values:

| Test Case | Earth UTC | Expected MSD | Expected MTC |
|-----------|-----------|--------------|--------------|
| Pathfinder Landing | 1997-07-04 16:56:55 | 44795.9992 | 23:58:30 |
| Curiosity Reference | 2020-02-18 20:55:00 | 51972.37 | 08:53:00 |
| Perseverance Landing | 2021-02-18 20:55:00 | 52327.37 | 08:53:00 |

Full validation dataset: [`core/validation/nasa-reference-timestamps.json`](core/validation/nasa-reference-timestamps.json)

### Precision Requirements
- Julian Date: ±0.000001 days (±0.0864 seconds)
- Mars Sol Date: ±0.000001 sols
- Time Components: ±1 second

---

## Documentation

### Technical Documentation
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - System design, data flow, component breakdown
- **[MARS_TIME_ALGORITHM.md](docs/MARS_TIME_ALGORITHM.md)** - Mathematical formulas, NASA citations, validation
- **[REFERENCES.md](docs/REFERENCES.md)** - Scientific bibliography, mission data sources

### Scientific References

**Primary Sources**:
1. Allison, M., & McEwen, M. (2000). *A post-Pathfinder evaluation of areocentric solar coordinates with improved timing recipes for Mars seasonal/diurnal climate studies.* Planetary and Space Science, 48(2-3), 215-235.

2. NASA Mars24 Sunclock Algorithm
   https://www.giss.nasa.gov/tools/mars24/

3. Meeus, J. (1998). *Astronomical Algorithms* (2nd ed.). Willmann-Bell.

**Supporting**:
- JPL Horizons System (https://ssd.jpl.nasa.gov/horizons/)
- IERS Bulletin C (Leap Seconds)
- IAU Standards of Fundamental Astronomy (SOFA)

---

## Design Philosophy

### Priorities (In Order)
1. **Scientific Accuracy** - NASA/JPL standard algorithms
2. **Reliability** - Deterministic, testable, traceable
3. **Cross-Platform Consistency** - Bit-identical math
4. **Battery Efficiency** - Optimized update cadence
5. **Professional UI** - Mission control aesthetic
6. **Maintainability** - Clear architecture, comprehensive tests

### Non-Goals
- ❌ Gamification or novelty features
- ❌ Approximations or simplified formulas
- ❌ Network dependency for core functionality
- ❌ Consumer-focused marketing language

This is **mission-grade software** designed for technical professionals.

---

## Future Enhancements

### Phase 2 (Mission-Aligned)
- Landing site library (Olympus Mons, Jezero, Gale Crater, etc.)
- Mission sol counters (e.g., "Perseverance Sol 1234")
- iOS/Android widgets
- Apple Watch Ultra wayfinder integration
- Sunset/sunrise calculator

---

## Contributing

This project implements published NASA/JPL algorithms. Contributions must:

1. Maintain scientific accuracy (cite sources)
2. Pass all validation tests
3. Preserve cross-platform consistency
4. Include appropriate unit tests
5. Follow mission-grade coding standards

### Code Standards
- **Swift**: Swift Style Guide, SwiftLint compliant
- **Kotlin**: Kotlin Coding Conventions, detekt compliant
- **Comments**: Cite NASA/JPL sources for all formulas
- **Tests**: Required for all calculation functions

---

## License

[To be determined - consult with repository owner]

**Algorithm Sources**: Publicly available NASA/JPL publications (see REFERENCES.md)

---

## Acknowledgments

- **Dr. Michael Allison** (NASA GISS) - Mars time algorithm development
- **NASA Jet Propulsion Laboratory** - Mission data and validation
- **International Astronomical Union** - Planetary constants
- **IERS** - Earth rotation and leap second data

---

## Contact

**Repository**: [MedicD21/Mars](https://github.com/MedicD21/Mars)
**Branch**: `claude/mars-clock-system-rJhz4`

---

**STATUS**: ✅ Architecture Defined | ⏳ Implementation In Progress

**Last Updated**: 2026-01-06
**Version**: 0.1.0-alpha
**NASA Standards**: Mars24 v8.0 / Allison & McEwen (2000)
