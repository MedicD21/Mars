# MARS CLOCK SYSTEM - ARCHITECTURE

**NASA/JPL Flight Software Standards**
**Cross-Platform Planetary Time System**

---

## OVERVIEW

This system provides scientifically accurate Mars time calculations for mission operations, astronaut timekeeping, and planetary science applications.

### Design Principles

1. **Scientific Accuracy**: All calculations based on NASA/JPL published algorithms
2. **Determinism**: Identical outputs across all platforms for identical inputs
3. **Cross-Platform Consistency**: Shared mathematical core, platform-specific UI
4. **Offline-First**: No network dependency for core functionality
5. **Battery Efficiency**: Optimized update cadence, especially for wearables
6. **Maintainability**: Clear separation of concerns, comprehensive testing

---

## ARCHITECTURE OVERVIEW

```
┌─────────────────────────────────────────────────────────────┐
│                     PLATFORM LAYER                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   iOS/Swift  │  │watchOS/Swift │  │Android/Kotlin│      │
│  │   SwiftUI    │  │  SwiftUI     │  │   Compose    │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
└─────────┼──────────────────┼──────────────────┼──────────────┘
          │                  │                  │
┌─────────┼──────────────────┼──────────────────┼──────────────┐
│         │    CORE TIME CALCULATION ENGINE     │              │
│         ▼                  ▼                  ▼              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │            MarsTimeEngine (Math Core)                │   │
│  │  • UTC → Julian Date                                 │   │
│  │  • Julian Date → Mars Sol Date (MSD)                 │   │
│  │  • MSD → Coordinated Mars Time (MTC)                 │   │
│  │  • MTC → Local Mean Solar Time (LMST)                │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  Reference Implementations:                                 │
│  • Swift (iOS/watchOS)                                      │
│  • Kotlin (Android)                                         │
│                                                              │
│  Validation: NASA/JPL reference timestamps                  │
└──────────────────────────────────────────────────────────────┘
```

---

## COMPONENT BREAKDOWN

### 1. CORE TIME CALCULATION ENGINE

**Location**: `core/reference-implementation/`

**Purpose**: Platform-agnostic Mars time mathematics

**Implementations**:
- `swift/MarsTimeEngine.swift` - iOS/watchOS
- `kotlin/MarsTimeEngine.kt` - Android

**Responsibilities**:
- Convert Earth UTC to Julian Date (JD)
- Calculate Mars Sol Date (MSD) from JD
- Derive Coordinated Mars Time (MTC) from MSD
- Compute Local Mean Solar Time (LMST) using longitude
- Handle leap seconds and precision requirements

**Key Requirements**:
- Bit-identical results across platforms (within floating-point epsilon)
- No external dependencies
- Pure functions (no side effects)
- Comprehensive inline documentation with NASA citations

---

### 2. VALIDATION LAYER

**Location**: `core/validation/`

**Contents**:
- `nasa-reference-timestamps.json` - Known good values from NASA/JPL

**Purpose**: Ensure calculation accuracy against published NASA data

**Reference Points** (minimum 3):
1. Mars Pathfinder Landing (Sol 0)
2. Mars Science Laboratory (Curiosity) reference
3. Mars 2020 (Perseverance) reference
4. Additional validation points across Mars year

---

### 3. iOS APPLICATION

**Location**: `ios/MarsTime/`

**Technology Stack**:
- Swift 5.9+
- SwiftUI (iOS 17+)
- Observation framework for state management

**Structure**:
```
MarsTime/
├── App/
│   └── MarsTimeApp.swift
├── Views/
│   ├── MainClockView.swift
│   ├── TimeDisplayGrid.swift
│   └── LongitudeInputView.swift
├── ViewModels/
│   └── MarsClockViewModel.swift
├── Engine/
│   └── MarsTimeEngine.swift (linked from core)
└── Resources/
    └── Assets.xcassets
```

**State Management**:
- `@Observable` class for MarsClockViewModel
- Timer-based updates (1 second cadence)
- Pause updates when app backgrounded (battery optimization)

**UI Requirements**:
- Dark mode optimized (mission control aesthetic)
- Dynamic Type support
- VoiceOver accessibility
- Haptic feedback for interactions
- Instrument-grade typography

---

### 4. watchOS APPLICATION

**Location**: `watchos/MarsTimeWatch/`

**Technology Stack**:
- Swift 5.9+
- SwiftUI (watchOS 10+)
- WidgetKit for complications

**Structure**:
```
MarsTimeWatch/
├── App/
│   └── MarsTimeWatchApp.swift
├── Views/
│   └── WatchClockView.swift
├── Complications/
│   ├── MarsTimeComplicationProvider.swift
│   ├── CircularComplication.swift
│   ├── ModularComplication.swift
│   └── UltraComplication.swift
├── Engine/
│   └── MarsTimeEngine.swift (shared)
└── Resources/
```

**Complication Strategy**:
- Update timeline: 15-minute intervals (balance accuracy/battery)
- Support families: Circular, Modular, Graphic Corner, Extra Large
- Apple Watch Ultra: Dedicated wayfinder complications

**Battery Optimization**:
- Throttle updates when wrist down
- Pre-compute complication timeline (not real-time)
- Minimize wake cycles

---

### 5. ANDROID APPLICATION

**Location**: `android/MarsTime/`

**Technology Stack**:
- Kotlin 1.9+
- Jetpack Compose (Material 3)
- ViewModel + StateFlow architecture

**Structure**:
```
MarsTime/
├── app/src/main/java/com/nasa/marstime/
│   ├── MainActivity.kt
│   ├── ui/
│   │   ├── theme/
│   │   │   ├── Theme.kt
│   │   │   └── Color.kt
│   │   ├── screens/
│   │   │   └── MainClockScreen.kt
│   │   └── components/
│   │       ├── TimeDisplay.kt
│   │       └── LongitudeInput.kt
│   ├── viewmodels/
│   │   └── MarsClockViewModel.kt
│   └── engine/
│       └── MarsTimeEngine.kt (linked from core)
└── build.gradle.kts
```

**State Management**:
- ViewModel with StateFlow for reactive updates
- Coroutines for timer management
- Lifecycle-aware updates (pause in background)

**UI Requirements**:
- Material 3 subdued dark theme
- Mission-control color palette (amber/cyan accents)
- Monospace typography for numeric displays
- Accessibility: TalkBack, font scaling

---

## DATA FLOW

### Update Cycle (Real-Time Display)

```
1. Timer Tick (1 second)
         ↓
2. Get Current System Time (UTC)
         ↓
3. MarsTimeEngine.calculate(utcTime, longitude)
         ↓
4. Return MarsTimeData {
       earthUTC: DateTime
       julianDate: Double
       marsSolDate: Double
       coordinatedMarsTime: Time
       localMeanSolarTime: Time
   }
         ↓
5. Update UI State
         ↓
6. SwiftUI/Compose Re-render
```

### Complication Timeline (watchOS)

```
1. System requests timeline
         ↓
2. Generate next 24 hours of entries (15-min intervals)
         ↓
3. For each interval:
    - Calculate MarsTimeData for that future UTC
    - Create ComplicationTimelineEntry
         ↓
4. Return Timeline to system
         ↓
5. System displays and updates automatically
```

---

## PRECISION AND ERROR HANDLING

### Floating-Point Considerations

- **Julian Date**: Double precision (64-bit)
- **Mars Sol Date**: Double precision
- **Time Components**: Integer seconds, fractional seconds as needed
- **Cross-platform epsilon**: ±1e-9 acceptable variance

### Error Boundaries

1. **Invalid Input**: Reject dates before J2000 epoch (2000-01-01)
2. **Longitude Bounds**: Clamp to [-180°, 180°], wrap appropriately
3. **Leap Seconds**: Use TAI-UTC offset table (updated periodically)
4. **Far Future**: Accurate to year 2100+ (algorithm remains valid)

---

## TESTING STRATEGY

### Unit Tests

**Location**: `tests/swift/` and `tests/kotlin/`

**Coverage**:
- Each conversion function (UTC→JD, JD→MSD, etc.)
- Boundary conditions (epoch, far future)
- Known NASA reference values
- Cross-platform consistency

**Test Categories**:
1. **Algorithm Correctness**: Match NASA published values
2. **Determinism**: Same input = same output, always
3. **Cross-Platform Parity**: Swift vs Kotlin within epsilon
4. **Edge Cases**: Leap seconds, time zone handling

### Integration Tests

- Full UI workflow testing
- Timer accuracy verification
- Background/foreground transitions
- Battery impact profiling (watchOS)

---

## DEPENDENCIES

### iOS/watchOS
- **Zero external dependencies** (stdlib only)
- Native Foundation framework for Date handling

### Android
- **Jetpack Compose** (UI)
- **Kotlin stdlib** (calculations)
- **AndroidX Lifecycle** (state management)
- No network libraries (offline-first)

---

## FUTURE EXPANSION

### Phase 2 Enhancements (Mission-Aligned)

1. **Landing Site Library**
   - Pre-configured locations: Olympus Mons, Jezero Crater, Valles Marineris
   - Quick-select for mission sites

2. **Mission Sol Counter**
   - Track sols since landing (e.g., "Perseverance Sol 1234")
   - Multiple mission tracking

3. **Widgets**
   - iOS Lock Screen / Home Screen widgets
   - Android Home Screen widgets

4. **Watch Ultra Mode**
   - Wayfinder face integration
   - Action button shortcut
   - Low-power always-on display optimization

5. **Sunset/Sunrise Calculator**
   - Solar position for given latitude/longitude
   - Twilight times

---

## DEVELOPMENT WORKFLOW

### Build and Test

```bash
# iOS/watchOS
cd ios/MarsTime
xcodebuild test -scheme MarsTime -destination 'platform=iOS Simulator,name=iPhone 15'

# Android
cd android/MarsTime
./gradlew test
./gradlew connectedAndroidTest
```

### Cross-Platform Validation

```bash
# Run validation suite (compares Swift vs Kotlin outputs)
cd tests
./run_cross_platform_validation.sh
```

---

## REFERENCES

See `docs/REFERENCES.md` for complete bibliography including:
- Allison, M., & McEwen, M. (2000)
- NASA Mars24 Algorithm Documentation
- JPL Horizons System
- IERS Bulletin C (Leap Seconds)

---

**Document Version**: 1.0
**Last Updated**: 2026-01-06
**Author**: NASA/JPL Flight Software Engineering Team
