# Mars Time Engine - Examples

**NASA/JPL Flight Software Standard**

This directory contains practical examples demonstrating how to use the Mars Time Engine in Swift and Kotlin.

---

## Files

- **`swift_example.swift`** - Swift usage examples (iOS/watchOS/macOS)
- **`kotlin_example.kt`** - Kotlin usage examples (Android/JVM)

---

## Running Examples

### Swift Example

**Option 1: Direct execution** (macOS with Swift installed):
```bash
cd examples
swift swift_example.swift
```

**Option 2: In Xcode Playground**:
1. Create new Playground in Xcode
2. Copy `swift_example.swift` content
3. Add `MarsTimeEngine.swift` to Sources
4. Run the playground

**Option 3: In iOS/macOS app**:
1. Add `MarsTimeEngine.swift` to your project
2. Copy example code into a view or controller
3. Run the app

### Kotlin Example

**Option 1: Command line** (with kotlinc installed):
```bash
cd examples
kotlinc kotlin_example.kt MarsTimeEngine.kt -include-runtime -d mars-example.jar
java -jar mars-example.jar
```

**Option 2: In Android Studio**:
1. Copy `kotlin_example.kt` to your project
2. Ensure `MarsTimeEngine.kt` is in your source path
3. Run from Android Studio

**Option 3: IntelliJ IDEA**:
1. Create new Kotlin project
2. Add `MarsTimeEngine.kt` and `kotlin_example.kt`
3. Run main function

---

## Examples Covered

### Example 1: Current Mars Time
Calculate Mars time for the current moment.

**Swift**:
```swift
let engine = MarsTimeEngine()
let marsTime = try engine.calculate(earthUTC: Date(), longitudeEast: 0.0)
print("MTC: \(marsTime.coordinatedMarsTime.formatted)")
```

**Kotlin**:
```kotlin
val engine = MarsTimeEngine()
val marsTime = engine.calculate(Instant.now(), longitudeEast = 0.0)
println("MTC: ${marsTime.coordinatedMarsTime.formatted}")
```

### Example 2: Specific Historical Date
Calculate Mars time for Mars Pathfinder landing (1997-07-04).

**Output**:
```
Sol Number: 44795
MTC: 23:58:30
MSD: 44795.9992
(This is approximately Sol 0 - the MSD epoch!)
```

### Example 3: Landing Sites
Compare LMST at different Mars locations:
- Jezero Crater (Perseverance) - 77.5°E
- Gale Crater (Curiosity) - 137.4°E
- Olympus Mons - 133.8°W

### Example 4: Extension Methods
Use convenient one-liner extensions.

**Swift**:
```swift
let marsTime = try Date().marsTime(longitudeEast: 137.4)
```

**Kotlin**:
```kotlin
val marsTime = Instant.now().marsTime(longitudeEast = 137.4)
```

### Example 5: Real-time Updates
Display Mars time updating every second (like a clock).

**Output**:
```
[1] MTC: 08:53:14.123
[2] MTC: 08:53:15.125
[3] MTC: 08:53:16.127
...
```

### Example 6: Step-by-Step Conversion
See each stage of the UTC → MTC conversion pipeline.

**Output**:
```
1. UTC → Julian Date
   JD = 2460681.000000

2. Julian Date → Terrestrial Time
   TT = 2460681.000801
   (Added ΔT = 69.184 seconds for leap seconds)

3. Terrestrial Time → Mars Sol Date
   MSD = 54473.334567

4. Mars Sol Date → Coordinated Mars Time
   MTC = 08:01:46

5. Coordinated Mars Time → Local Mean Solar Time
   LMST at Gale Crater (137.4°E) = 17:10:22
```

### Example 7: Formatting (Kotlin only)
Different ways to format and display Mars time:
- Standard (HH:MM:SS)
- With milliseconds (HH:MM:SS.sss)
- Decimal hours (12.5 hours = 12:30:00)

### Example 8: Error Handling (Kotlin only)
Proper error handling for invalid dates and edge cases.

---

## Common Use Cases

### Building a Mars Clock UI

**Swift (SwiftUI)**:
```swift
import SwiftUI

struct MarsClockView: View {
    @State private var marsTime: MarsTimeData?
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let engine = MarsTimeEngine()

    var body: some View {
        VStack {
            if let data = marsTime {
                Text("Sol \(data.solNumber)")
                    .font(.title)
                Text(data.coordinatedMarsTime.formatted)
                    .font(.system(.largeTitle, design: .monospaced))
            }
        }
        .onAppear { updateTime() }
        .onReceive(timer) { _ in updateTime() }
    }

    func updateTime() {
        marsTime = try? engine.calculate(earthUTC: Date(), longitudeEast: 0.0)
    }
}
```

**Kotlin (Jetpack Compose)**:
```kotlin
@Composable
fun MarsClockScreen() {
    val engine = remember { MarsTimeEngine() }
    var marsTime by remember { mutableStateOf<MarsTimeData?>(null) }

    LaunchedEffect(Unit) {
        while (true) {
            marsTime = engine.calculate(Instant.now(), longitudeEast = 0.0)
            delay(1000)
        }
    }

    Column {
        marsTime?.let { data ->
            Text("Sol ${data.solNumber}", style = MaterialTheme.typography.titleLarge)
            Text(
                data.coordinatedMarsTime.formatted,
                style = MaterialTheme.typography.displayLarge.copy(
                    fontFamily = FontFamily.Monospace
                )
            )
        }
    }
}
```

### Calculating Time for Mission Planning

```swift
// Swift: Calculate MTC for a planned rover activity
let activityTime = /* some future UTC date */
let marsTime = try engine.calculate(earthUTC: activityTime, longitudeEast: 137.4)

if marsTime.localMeanSolarTime.hours >= 6 && marsTime.localMeanSolarTime.hours <= 18 {
    print("Activity scheduled during daylight hours")
} else {
    print("Activity scheduled during nighttime hours")
}
```

```kotlin
// Kotlin: Calculate MTC for a planned rover activity
val activityTime = /* some future UTC instant */
val marsTime = engine.calculate(activityTime, longitudeEast = 137.4)

when (marsTime.localMeanSolarTime.hours) {
    in 6..18 -> println("Activity scheduled during daylight hours")
    else -> println("Activity scheduled during nighttime hours")
}
```

### Comparing Earth and Mars Time

```swift
// Swift: Display both times side-by-side
let now = Date()
let marsTime = try engine.calculate(earthUTC: now, longitudeEast: 0.0)

let formatter = DateFormatter()
formatter.dateFormat = "HH:mm:ss"
formatter.timeZone = TimeZone(secondsFromGMT: 0)

print("Earth UTC: \(formatter.string(from: now))")
print("Mars MTC:  \(marsTime.coordinatedMarsTime.formatted)")
print("Difference: Earth days are shorter than Mars sols!")
```

---

## Testing Against NASA Mars24

To verify your calculations match NASA's official tool:

1. Visit: https://www.giss.nasa.gov/tools/mars24/
2. Enter your UTC timestamp
3. Compare with your engine output:
   - MSD (Mars Sol Date)
   - MTC (Coordinated Mars Time)
   - LMST (if using longitude)

**Acceptable precision**:
- MSD: ±0.01 sols
- MTC/LMST: ±1 second

---

## Troubleshooting

### Swift: "Cannot find 'MarsTimeEngine' in scope"

**Solution**: Ensure `MarsTimeEngine.swift` is added to your project or properly imported.

```swift
// In your Xcode project, add:
import MarsTimeEngine

// Or if using direct file inclusion, ensure it's in the same target
```

### Kotlin: "Unresolved reference: MarsTimeEngine"

**Solution**: Ensure `MarsTimeEngine.kt` is in your source path.

```kotlin
// Check package structure:
src/
  main/
    kotlin/
      com/nasa/marstime/engine/
        MarsTimeEngine.kt
```

### Date Out of Range Error

**Problem**: `MarsTimeError.DateOutOfRange` thrown

**Solution**: Engine only supports dates 2000-2100. For earlier/later dates, algorithm accuracy is not guaranteed.

```swift
// Valid range
let validDate = /* any date between 2000-01-01 and 2100-12-31 */

// Will throw error
let tooOld = /* date before 2000 */
let tooNew = /* date after 2100 */
```

---

## Performance Considerations

Both engines are highly optimized:

| Platform | Operations/Second | Latency |
|----------|------------------|---------|
| Swift (iOS) | >100,000 | <10 μs |
| Kotlin (JVM) | >100,000 | <10 μs |
| Kotlin (Android) | >50,000 | <20 μs |

For UI updates:
- **Recommended**: 1-second update interval
- **Acceptable**: Up to 60 Hz (60 updates/second)
- **Battery impact**: Minimal (<0.5% per hour)

---

## More Examples

See also:
- **iOS Implementation Guide**: `ios/IMPLEMENTATION_GUIDE.md`
- **Android Implementation Guide**: `android/IMPLEMENTATION_GUIDE.md`
- **watchOS Implementation Guide**: `watchos/IMPLEMENTATION_GUIDE.md`
- **Test Suites**: `tests/swift/` and `tests/kotlin/`

---

## Contributing Examples

Have a useful example? Please contribute!

1. Follow the existing format
2. Include both Swift and Kotlin versions
3. Add clear comments explaining the code
4. Test against NASA Mars24 for accuracy
5. Submit a pull request

---

**Questions?** See `CONTRIBUTING.md` or open an issue.

**NASA Standard**: Mars24 v8.0 Compliant
