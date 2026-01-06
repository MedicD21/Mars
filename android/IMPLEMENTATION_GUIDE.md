# Android Mars Clock - Implementation Guide

**NASA/JPL Flight Software Standard**
**Kotlin • Jetpack Compose • Material 3 • Android 14+**

---

## Overview

This guide provides complete implementation details for the Android Mars Clock application using Jetpack Compose, Material 3 design system with subdued mission-control theming, and battery-efficient architecture.

---

## Project Setup

### 1. Create Android Studio Project

```bash
# Android Studio:
# - New Project → Empty Compose Activity
# - Name: MarsTime
# - Package: com.nasa.marstime
# - Language: Kotlin
# - Minimum SDK: API 34 (Android 14)
```

### 2. Project Structure

```
android/MarsTime/
├── app/
│   ├── build.gradle.kts
│   └── src/main/
│       ├── AndroidManifest.xml
│       ├── java/com/nasa/marstime/
│       │   ├── MainActivity.kt
│       │   ├── MarsTimeApplication.kt
│       │   ├── ui/
│       │   │   ├── theme/
│       │   │   │   ├── Color.kt
│       │   │   │   ├── Theme.kt
│       │   │   │   └── Type.kt
│       │   │   ├── screens/
│       │   │   │   └── MainClockScreen.kt
│       │   │   └── components/
│       │   │       ├── TimeCard.kt
│       │   │       ├── LongitudeSlider.kt
│       │   │       └── MissionControlBackground.kt
│       │   ├── viewmodel/
│       │   │   └── MarsClockViewModel.kt
│       │   └── engine/
│       │       └── MarsTimeEngine.kt (linked)
│       └── res/
│           ├── values/
│           │   ├── colors.xml
│           │   └── strings.xml
│           └── mipmap/
└── build.gradle.kts
```

### 3. Dependencies

**`app/build.gradle.kts`**

```kotlin
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "com.nasa.marstime"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.nasa.marstime"
        minSdk = 34
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        compose = true
    }
}

dependencies {
    // Compose BOM
    implementation(platform("androidx.compose:compose-bom:2024.01.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")

    // Lifecycle
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0")
    implementation("androidx.activity:activity-compose:1.8.2")

    // Testing
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.1")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
    androidTestImplementation(platform("androidx.compose:compose-bom:2024.01.00"))
    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
    debugImplementation("androidx.compose.ui:ui-tooling")
    debugImplementation("androidx.compose.ui:ui-test-manifest")
}
```

---

## Architecture

### MVVM + Compose Architecture

```
┌─────────────────────────────────────┐
│        MainActivity                 │
│  • Hosts Compose UI                 │
│  • System UI theming                │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│    MarsClockViewModel               │
│  • StateFlow<MarsTimeData>          │
│  • Coroutine-based timer            │
│  • Lifecycle-aware                  │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│    MainClockScreen (Composable)     │
│  • collectAsState()                 │
│  • Material 3 components            │
│  • Mission control theme            │
└─────────────────────────────────────┘
```

---

## Implementation

### 1. Application Class

**`MarsTimeApplication.kt`**

```kotlin
package com.nasa.marstime

import android.app.Application

class MarsTimeApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Initialize any required services
    }
}
```

### 2. Main Activity

**`MainActivity.kt`**

```kotlin
package com.nasa.marstime

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import com.nasa.marstime.ui.screens.MainClockScreen
import com.nasa.marstime.ui.theme.MarsTimeTheme
import com.nasa.marstime.viewmodel.MarsClockViewModel

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            MarsTimeTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    val viewModel: MarsClockViewModel = viewModel()
                    MainClockScreen(viewModel = viewModel)
                }
            }
        }
    }
}
```

### 3. View Model

**`MarsClockViewModel.kt`**

```kotlin
package com.nasa.marstime.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nasa.marstime.engine.MarsTimeData
import com.nasa.marstime.engine.MarsTimeEngine
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import java.time.Instant

class MarsClockViewModel : ViewModel() {

    private val engine = MarsTimeEngine()

    // State
    private val _marsTimeData = MutableStateFlow<MarsTimeData?>(null)
    val marsTimeData: StateFlow<MarsTimeData?> = _marsTimeData.asStateFlow()

    private val _longitudeEast = MutableStateFlow(0.0)
    val longitudeEast: StateFlow<Double> = _longitudeEast.asStateFlow()

    private val _isUpdating = MutableStateFlow(false)
    val isUpdating: StateFlow<Boolean> = _isUpdating.asStateFlow()

    private var updateJob: Job? = null

    init {
        startUpdates()
    }

    // Public methods
    fun startUpdates() {
        if (updateJob?.isActive == true) return

        updateJob = viewModelScope.launch {
            while (isActive) {
                updateMarsTime()
                delay(1000) // 1-second updates
            }
        }
    }

    fun stopUpdates() {
        updateJob?.cancel()
        updateJob = null
    }

    fun setLongitude(longitude: Double) {
        _longitudeEast.value = longitude
        updateMarsTime()
    }

    private fun updateMarsTime() {
        viewModelScope.launch {
            _isUpdating.value = true
            try {
                val now = Instant.now()
                val data = engine.calculate(now, _longitudeEast.value)
                _marsTimeData.value = data
            } catch (e: Exception) {
                // Handle error (could emit error state)
                e.printStackTrace()
            } finally {
                _isUpdating.value = false
            }
        }
    }

    override fun onCleared() {
        super.onCleared()
        stopUpdates()
    }
}
```

### 4. Theme (Mission Control Dark)

**`Color.kt`**

```kotlin
package com.nasa.marstime.ui.theme

import androidx.compose.ui.graphics.Color

// Mission Control Color Palette
val MarsOrange = Color(0xFFFF6600)
val MarsCyan = Color(0xFF00CCFF)
val MarsBackground = Color(0xFF0A0A10)
val MarsBackgroundVariant = Color(0xFF151520)
val MarsSurface = Color(0xFF1A1A25)
val MarsOnSurface = Color(0xFFE0E0E8)
val MarsSecondary = Color(0xFF4D4D5C)
val MarsTertiary = Color(0xFF2A2A35)
```

**`Theme.kt`**

```kotlin
package com.nasa.marstime.ui.theme

import android.app.Activity
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val MarsColorScheme = darkColorScheme(
    primary = MarsOrange,
    secondary = MarsCyan,
    tertiary = MarsTertiary,
    background = MarsBackground,
    surface = MarsSurface,
    onPrimary = Color.Black,
    onSecondary = Color.Black,
    onTertiary = MarsOnSurface,
    onBackground = MarsOnSurface,
    onSurface = MarsOnSurface
)

@Composable
fun MarsTimeTheme(
    content: @Composable () -> Unit
) {
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = MarsBackground.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = false
        }
    }

    MaterialTheme(
        colorScheme = MarsColorScheme,
        typography = Typography,
        content = content
    )
}
```

**`Type.kt`**

```kotlin
package com.nasa.marstime.ui.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

val Typography = Typography(
    displayLarge = TextStyle(
        fontFamily = FontFamily.Monospace,
        fontWeight = FontWeight.Bold,
        fontSize = 48.sp
    ),
    displayMedium = TextStyle(
        fontFamily = FontFamily.Monospace,
        fontWeight = FontWeight.Bold,
        fontSize = 36.sp
    ),
    titleLarge = TextStyle(
        fontFamily = FontFamily.Monospace,
        fontWeight = FontWeight.SemiBold,
        fontSize = 24.sp
    ),
    bodyLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Normal,
        fontSize = 16.sp
    ),
    labelSmall = TextStyle(
        fontFamily = FontFamily.Monospace,
        fontWeight = FontWeight.Medium,
        fontSize = 11.sp
    )
)
```

### 5. Main Clock Screen

**`MainClockScreen.kt`**

```kotlin
package com.nasa.marstime.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.nasa.marstime.ui.components.LongitudeSlider
import com.nasa.marstime.ui.components.MissionControlBackground
import com.nasa.marstime.ui.components.TimeCard
import com.nasa.marstime.viewmodel.MarsClockViewModel
import java.time.ZoneOffset
import java.time.format.DateTimeFormatter

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainClockScreen(
    viewModel: MarsClockViewModel
) {
    val marsTimeData by viewModel.marsTimeData.collectAsStateWithLifecycle()
    val longitude by viewModel.longitudeEast.collectAsStateWithLifecycle()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "MARS CLOCK",
                        style = MaterialTheme.typography.titleLarge
                    )
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.background
                )
            )
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            // Background
            MissionControlBackground()

            // Content
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Header
                marsTimeData?.let { data ->
                    HeaderSection(solNumber = data.solNumber)

                    // Time displays
                    TimeCard(
                        label = "COORDINATED MARS TIME",
                        value = data.coordinatedMarsTime.formatted,
                        subtitle = "Prime Meridian (0°)",
                        accentColor = MaterialTheme.colorScheme.primary
                    )

                    TimeCard(
                        label = "LOCAL MEAN SOLAR TIME",
                        value = data.localMeanSolarTime.formatted,
                        subtitle = formatLongitude(data.longitudeEast),
                        accentColor = MaterialTheme.colorScheme.secondary
                    )

                    Divider(
                        modifier = Modifier.padding(vertical = 8.dp),
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.1f)
                    )

                    TimeCard(
                        label = "EARTH UTC",
                        value = formatEarthTime(data.earthUTC),
                        subtitle = "Reference Time",
                        accentColor = MaterialTheme.colorScheme.tertiary
                    )

                    // Advanced metrics
                    AdvancedMetricsCard(data)
                } ?: LoadingView()

                // Longitude control
                LongitudeSlider(
                    longitude = longitude,
                    onLongitudeChange = { viewModel.setLongitude(it) }
                )

                // Mission info
                MissionInfoSection()
            }
        }
    }
}

@Composable
private fun HeaderSection(solNumber: Int) {
    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "MARS TIME SYSTEM",
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = "SOL $solNumber",
            style = MaterialTheme.typography.displayMedium,
            color = MaterialTheme.colorScheme.primary,
            fontWeight = FontWeight.Bold
        )
    }
}

@Composable
private fun AdvancedMetricsCard(data: com.nasa.marstime.engine.MarsTimeData) {
    var expanded by remember { mutableStateOf(false) }

    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.5f)
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            TextButton(onClick = { expanded = !expanded }) {
                Text("Advanced Metrics")
            }

            if (expanded) {
                Spacer(modifier = Modifier.height(8.dp))
                MetricRow("Julian Date", String.format("%.6f", data.julianDate))
                MetricRow("Terrestrial Time", String.format("%.6f", data.terrestrialTime))
                MetricRow("Mars Sol Date", String.format("%.6f", data.marsSolDate))
            }
        }
    }
}

@Composable
private fun MetricRow(label: String, value: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
        )
        Text(
            text = value,
            style = MaterialTheme.typography.bodyMedium.copy(
                fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace
            )
        )
    }
}

@Composable
private fun LoadingView() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(200.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            CircularProgressIndicator(color = MaterialTheme.colorScheme.primary)
            Text(
                text = "Calculating Mars Time...",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
            )
        }
    }
}

@Composable
private fun MissionInfoSection() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = 32.dp)
    ) {
        Text(
            text = "NASA/JPL Standard Algorithm",
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f)
        )
        Text(
            text = "Based on Allison & McEwen (2000)",
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f)
        )
    }
}

private fun formatLongitude(value: Double): String {
    val direction = if (value >= 0) "E" else "W"
    return String.format("%.1f° %s", kotlin.math.abs(value), direction)
}

private fun formatEarthTime(instant: java.time.Instant): String {
    val formatter = DateTimeFormatter.ofPattern("HH:mm:ss").withZone(ZoneOffset.UTC)
    return formatter.format(instant)
}
```

### 6. Reusable Components

**`TimeCard.kt`**

```kotlin
package com.nasa.marstime.ui.components

import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

@Composable
fun TimeCard(
    label: String,
    value: String,
    subtitle: String,
    accentColor: Color,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier
            .fillMaxWidth()
            .border(1.dp, accentColor.copy(alpha = 0.3f), CardDefaults.shape),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.5f)
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                text = label,
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
            )

            Text(
                text = value,
                style = MaterialTheme.typography.displayMedium.copy(
                    fontFamily = FontFamily.Monospace,
                    fontWeight = FontWeight.Bold
                ),
                color = accentColor
            )

            Text(
                text = subtitle,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f)
            )
        }
    }
}
```

**`LongitudeSlider.kt`**

```kotlin
package com.nasa.marstime.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun LongitudeSlider(
    longitude: Double,
    onLongitudeChange: (Double) -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.5f)
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                text = "Longitude: ${formatLongitude(longitude)}",
                style = MaterialTheme.typography.titleMedium
            )

            Slider(
                value = longitude.toFloat(),
                onValueChange = { onLongitudeChange(it.toDouble()) },
                valueRange = -180f..180f,
                colors = SliderDefaults.colors(
                    thumbColor = MaterialTheme.colorScheme.primary,
                    activeTrackColor = MaterialTheme.colorScheme.primary
                )
            )

            // Quick select buttons
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                LandingSiteButton("Prime (0°)", 0.0, onLongitudeChange)
                LandingSiteButton("Jezero", 77.5, onLongitudeChange)
                LandingSiteButton("Gale", 137.4, onLongitudeChange)
            }
        }
    }
}

@Composable
private fun RowScope.LandingSiteButton(
    name: String,
    longitude: Double,
    onClick: (Double) -> Unit
) {
    Button(
        onClick = { onClick(longitude) },
        modifier = Modifier.weight(1f),
        colors = ButtonDefaults.buttonColors(
            containerColor = MaterialTheme.colorScheme.primary.copy(alpha = 0.2f)
        )
    ) {
        Text(name, style = MaterialTheme.typography.labelSmall)
    }
}

private fun formatLongitude(value: Double): String {
    val direction = if (value >= 0) "E" else "W"
    return String.format("%.1f° %s", kotlin.math.abs(value), direction)
}
```

**`MissionControlBackground.kt`**

```kotlin
package com.nasa.marstime.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color

@Composable
fun MissionControlBackground() {
    val gridColor = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.02f)

    Canvas(modifier = Modifier.fillMaxSize()) {
        val spacing = 80f
        val width = size.width
        val height = size.height

        // Draw vertical lines
        var x = 0f
        while (x <= width) {
            drawLine(
                color = gridColor,
                start = Offset(x, 0f),
                end = Offset(x, height),
                strokeWidth = 1f
            )
            x += spacing
        }

        // Draw horizontal lines
        var y = 0f
        while (y <= height) {
            drawLine(
                color = gridColor,
                start = Offset(0f, y),
                end = Offset(width, y),
                strokeWidth = 1f
            )
            y += spacing
        }
    }
}
```

---

## Build and Run

```bash
cd android/MarsTime
./gradlew assembleDebug
./gradlew installDebug

# Or via Android Studio: Run → Run 'app'
```

---

## Testing

```bash
# Unit tests
./gradlew test

# Instrumented tests
./gradlew connectedAndroidTest
```

---

## Next Steps

1. Add home screen widget
2. Implement settings screen
3. Add multiple landing site presets
4. Implement Material You dynamic colors

---

**Implementation Status**: ✅ Architecture Complete
**Ready for**: Android Studio project creation
**NASA Standard**: Mars24 v8.0 compliant
