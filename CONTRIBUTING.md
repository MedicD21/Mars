# Contributing to Mars Clock System

**NASA/JPL Flight Software Standard**

Thank you for your interest in contributing to the Mars Clock System! This project implements scientifically accurate Mars time calculations for mission operations, astronaut timekeeping, and planetary science applications.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Contribution Guidelines](#contribution-guidelines)
- [Testing Requirements](#testing-requirements)
- [Documentation Standards](#documentation-standards)
- [Pull Request Process](#pull-request-process)
- [NASA/JPL Compliance](#nasajpl-compliance)

---

## Code of Conduct

This project adheres to professional engineering standards. We expect all contributors to:

- Maintain scientific accuracy and cite sources
- Follow NASA/JPL flight software standards
- Write clear, maintainable, well-documented code
- Respect the mission-grade nature of this software
- Collaborate professionally and constructively

---

## Getting Started

### Prerequisites

**For Swift/iOS/watchOS development:**
- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+

**For Kotlin/Android development:**
- JDK 17+
- Android Studio Hedgehog (2023.1.1)+
- Kotlin 1.9+

### Clone and Setup

```bash
# Clone the repository
git clone https://github.com/MedicD21/Mars.git
cd Mars

# Explore the structure
ls -la
```

### Project Structure

```
Mars/
├── docs/                          # Technical documentation
├── core/                          # Platform-agnostic engine
│   ├── reference-implementation/  # Swift & Kotlin engines
│   └── validation/                # NASA reference data
├── tests/                         # Test suites
├── ios/                           # iOS implementation guide
├── watchos/                       # watchOS implementation guide
└── android/                       # Android implementation guide
```

---

## Development Workflow

### 1. Create a Branch

```bash
# For new features
git checkout -b feature/your-feature-name

# For bug fixes
git checkout -b fix/bug-description

# For documentation
git checkout -b docs/documentation-update
```

### 2. Make Changes

Follow the coding standards for your platform:

**Swift**:
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftLint for code style
- Maintain existing architectural patterns

**Kotlin**:
- Follow [Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html)
- Use detekt for code analysis
- Maintain Material 3 design consistency

### 3. Test Your Changes

**Required**: All code changes must include tests.

```bash
# Swift tests
cd core/reference-implementation/swift
swift test

# Kotlin tests
cd core/reference-implementation/kotlin
./gradlew test
```

### 4. Commit Your Changes

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
git commit -m "feat: Add solar longitude calculation"
git commit -m "fix: Correct leap second handling for 2025"
git commit -m "docs: Update REFERENCES.md with new citations"
git commit -m "test: Add edge case for longitude wrapping"
```

**Commit Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `test`: Adding or updating tests
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `chore`: Maintenance tasks

---

## Contribution Guidelines

### Scientific Accuracy

**CRITICAL**: All Mars time calculations must be scientifically accurate.

#### Required for Algorithm Changes:

1. **Citation**: Provide NASA/JPL source reference
2. **Validation**: Include test against NASA Mars24
3. **Precision**: Document expected accuracy
4. **Rationale**: Explain why the change is needed

Example:
```swift
// Calculate solar longitude using equation from:
// Allison & McEwen (2000), Equation 19, Page 227
// Validated against NASA Mars24 output (±0.1° accuracy)
func calculateSolarLongitude(_ msd: Double) -> Double {
    // Implementation with inline citations
}
```

### Code Quality Standards

#### Swift

```swift
// ✅ GOOD - Clear, documented, type-safe
/// Calculate Coordinated Mars Time from Mars Sol Date
/// - Parameter msd: Mars Sol Date (continuous day count)
/// - Returns: Coordinated Mars Time (24-hour format)
/// - Reference: Allison & McEwen (2000), Section 3
public func marsSolDateToCoordinatedMarsTime(_ msd: Double) -> MarsTime {
    let fractionalSol = msd - floor(msd)
    let decimalHours = fractionalSol * 24.0
    return MarsTime(decimalHours: decimalHours)
}

// ❌ BAD - No documentation, unclear purpose
func calc(x: Double) -> Double {
    return (x - floor(x)) * 24
}
```

#### Kotlin

```kotlin
// ✅ GOOD - KDoc, clear naming, proper error handling
/**
 * Calculate Coordinated Mars Time from Mars Sol Date
 *
 * @param msd Mars Sol Date (continuous day count)
 * @return Coordinated Mars Time (24-hour format)
 *
 * Reference: Allison & McEwen (2000), Section 3
 */
fun marsSolDateToCoordinatedMarsTime(msd: Double): MarsTime {
    val fractionalSol = msd - floor(msd)
    val decimalHours = fractionalSol * 24.0
    return MarsTime.fromDecimalHours(decimalHours)
}

// ❌ BAD - No documentation, magic numbers
fun calc(x: Double) = MarsTime.fromDecimalHours((x - floor(x)) * 24.0)
```

### Cross-Platform Consistency

**REQUIRED**: Swift and Kotlin implementations must produce identical results.

When modifying the engine:

1. **Update both platforms**: Make equivalent changes to Swift and Kotlin
2. **Add cross-platform test**: Verify outputs match within epsilon
3. **Document differences**: If platforms differ, explain why

Example test:
```swift
// Swift
func testCrossPlatformConsistency() {
    let date = Date(timeIntervalSince1970: 1609459200)
    let result = try! engine.calculate(earthUTC: date, longitudeEast: 137.4)

    // This value should match Kotlin output exactly
    XCTAssertEqual(result.marsSolDate, 52297.123456, accuracy: 1e-9)
}
```

```kotlin
// Kotlin
@Test
fun `test cross-platform consistency`() {
    val instant = Instant.ofEpochSecond(1609459200)
    val result = engine.calculate(instant, 137.4)

    // This value should match Swift output exactly
    assertEquals(52297.123456, result.marsSolDate, 1e-9)
}
```

---

## Testing Requirements

### Minimum Test Coverage

| Component | Minimum | Target |
|-----------|---------|--------|
| Core Engine | 95% | 100% |
| Conversion Functions | 100% | 100% |
| Error Handling | 90% | 100% |
| Helper Functions | 85% | 95% |

### Required Test Types

1. **Unit Tests**: Test individual functions
2. **Integration Tests**: Test full calculation pipeline
3. **NASA Validation Tests**: Compare against reference data
4. **Edge Case Tests**: Boundary conditions, extreme values
5. **Error Handling Tests**: Invalid inputs, out of range dates

### Writing Tests

**Add NASA Reference Test:**

1. Get verified timestamp from [NASA Mars24](https://www.giss.nasa.gov/tools/mars24/)
2. Add to `core/validation/nasa-reference-timestamps.json`:

```json
{
  "id": "your_test_case",
  "description": "Description of test case",
  "earth_utc": {
    "iso8601": "2025-01-15T12:00:00Z",
    "year": 2025,
    "month": 1,
    "day": 15,
    "hour": 12,
    "minute": 0,
    "second": 0
  },
  "expected_output": {
    "mars_sol_date": 54XXX.XX,
    "coordinated_mars_time": {
      "hours": XX,
      "minutes": XX,
      "seconds": XX
    }
  },
  "validation_priority": "high"
}
```

3. Create test in both Swift and Kotlin
4. Document source and precision requirements

---

## Documentation Standards

### Code Documentation

**Swift** - Use DocC format:
```swift
/// Calculate Mars time for given UTC timestamp
///
/// This function implements the NASA Mars24 algorithm for converting
/// Earth UTC time to Mars Coordinated Time.
///
/// - Parameters:
///   - earthUTC: Earth UTC timestamp
///   - longitudeEast: East longitude in degrees [-180, 180]
/// - Returns: Complete Mars time data structure
/// - Throws: `MarsTimeError` if inputs are invalid
///
/// ## Reference
/// Allison & McEwen (2000), NASA Mars24 v8.0
///
/// ## Example
/// ```swift
/// let marsTime = try engine.calculate(
///     earthUTC: Date(),
///     longitudeEast: 137.4
/// )
/// print("MTC: \(marsTime.coordinatedMarsTime.formatted)")
/// ```
public func calculate(earthUTC: Date, longitudeEast: Double) throws -> MarsTimeData
```

**Kotlin** - Use KDoc format:
```kotlin
/**
 * Calculate Mars time for given UTC timestamp
 *
 * This function implements the NASA Mars24 algorithm for converting
 * Earth UTC time to Mars Coordinated Time.
 *
 * @param earthUTC Earth UTC timestamp
 * @param longitudeEast East longitude in degrees [-180, 180]
 * @return Complete Mars time data structure
 * @throws MarsTimeError if inputs are invalid
 *
 * ## Reference
 * Allison & McEwen (2000), NASA Mars24 v8.0
 *
 * ## Example
 * ```kotlin
 * val marsTime = engine.calculate(
 *     earthUTC = Instant.now(),
 *     longitudeEast = 137.4
 * )
 * println("MTC: ${marsTime.coordinatedMarsTime.formatted}")
 * ```
 */
@Throws(MarsTimeError::class)
fun calculate(earthUTC: Instant, longitudeEast: Double = 0.0): MarsTimeData
```

### Technical Documentation

When updating docs:

1. **Maintain NASA citations**: Always reference sources
2. **Update all platforms**: If algorithm changes, update all guides
3. **Include examples**: Provide code examples where relevant
4. **Version information**: Note which version introduced changes

---

## Pull Request Process

### Before Submitting

**Checklist**:
- [ ] Code compiles without errors
- [ ] All tests pass (Swift and Kotlin)
- [ ] New tests added for new functionality
- [ ] Code follows style guidelines
- [ ] Documentation updated (if applicable)
- [ ] NASA references cited (for algorithm changes)
- [ ] Cross-platform consistency verified
- [ ] No secrets or sensitive data committed

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Algorithm improvement
- [ ] Performance optimization

## NASA/JPL Compliance
- [ ] Algorithm changes cite NASA/JPL sources
- [ ] Validated against NASA Mars24 (if applicable)
- [ ] Precision requirements met

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Cross-platform consistency verified

## Platforms Affected
- [ ] Swift (iOS/watchOS)
- [ ] Kotlin (Android)
- [ ] Documentation only

## References
- Link to NASA source (if applicable)
- Related issues

## Screenshots (if UI changes)
```

### Review Process

1. **Automated CI**: GitHub Actions will run tests
2. **Code Review**: Maintainers will review for:
   - Scientific accuracy
   - Code quality
   - Test coverage
   - Documentation
3. **Approval**: Requires approval from maintainer
4. **Merge**: Squash and merge to main branch

---

## NASA/JPL Compliance

### Algorithm Sources

All Mars time calculations must trace to:

1. **Primary**: Allison & McEwen (2000)
   - "A post-Pathfinder evaluation of areocentric solar coordinates..."
   - DOI: 10.1016/S0032-0633(00)00002-6

2. **Validation**: NASA Mars24 Sunclock
   - https://www.giss.nasa.gov/tools/mars24/

3. **Constants**: IAU/IAG Working Group
   - Mars rotation and orbital parameters

### Updating Constants

If leap seconds or astronomical constants change:

1. **Source**: IERS Bulletin C or IAU publication
2. **Update both platforms**: Swift and Kotlin
3. **Update tests**: Adjust expected values if needed
4. **Document**: Note in commit message and CHANGELOG

Example:
```
fix: Update leap second count to 38 (new leap second 2027-01-01)

- Updated DELTA_T_SECONDS from 69.184 to 70.184
- Source: IERS Bulletin C #XX
- Updated all affected tests
- Validated against NASA Mars24 post-update
```

---

## Common Tasks

### Adding a Landing Site

1. Find coordinates from NASA mission data
2. Add to UI quick-select (iOS, Android guides)
3. Add test case with LMST calculation
4. Document source

### Improving Performance

1. Profile current performance
2. Make optimization (maintain accuracy!)
3. Verify no precision loss
4. Add performance test
5. Document improvement

### Fixing Bugs

1. Add failing test that reproduces bug
2. Fix the bug
3. Verify test passes
4. Add regression test if needed
5. Update documentation if behavior changed

---

## Getting Help

### Resources

- **Documentation**: See `docs/` directory
- **Implementation Guides**: See platform-specific guides
- **NASA Mars24**: https://www.giss.nasa.gov/tools/mars24/
- **Issues**: Check existing issues for similar problems

### Questions?

- Open a GitHub Discussion for questions
- File an Issue for bugs
- Tag maintainers for urgent matters

---

## Recognition

Contributors will be acknowledged in:
- Repository CONTRIBUTORS.md
- Release notes
- Project documentation

Thank you for helping make Mars timekeeping more accessible and accurate!

---

**Document Version**: 1.0
**Last Updated**: 2026-01-06
**Maintained By**: Mars Clock System Team
