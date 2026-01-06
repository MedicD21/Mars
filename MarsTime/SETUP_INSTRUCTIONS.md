# Mars Clock - Complete Setup Instructions

## ✅ What I've Created For You

I've generated all the necessary code files for both iOS and watchOS apps. Here's what's ready:

### iOS App Files (Created in `/iOS-Views/`)
1. **MainClockView.swift** - Main iOS clock display
2. **TimeDisplayGrid.swift** - Time cards and metrics display
3. **LongitudeInputView.swift** - Longitude selector with landing sites
4. **Components/MissionControlBackground.swift** - Mission control aesthetic background

### watchOS App Files (Created in `/watchOS-Views/`)
1. **WatchClockView.swift** - Main watch display
2. **CompactTimeView.swift** - Compact watch display

### View Models (Already Updated)
1. **Engine/ViewModels/MarsClockViewModel.swift** - iOS ViewModel ✅
2. **Engine/ViewModels/WatchClockViewModel.swift** - watchOS ViewModel ✅

### App Entry Points (Already Updated)
1. **Engine/ViewModels/Views/MarsTime/MarsTimeApp.swift** - iOS entry point ✅
2. **Views/MarsTimeWatch Watch App/MarsTimeWatchApp.swift** - watchOS entry point ✅

---

## 🎯 Next Steps - Add Files to Xcode

Now you need to add these new view files to your Xcode project:

### Step 1: Open Your Project in Xcode

```bash
open /Users/dustinschaaf/Desktop/GitHub/Mars/MarsTime/MarsTime.xcodeproj
```

---

### Step 2: Add iOS View Files

1. In Xcode's Project Navigator (left sidebar), find the **MarsTime** folder (iOS app)

2. Right-click on **MarsTime** folder → **Add Files to "MarsTime"...**

3. Navigate to: `/Users/dustinschaaf/Desktop/GitHub/Mars/MarsTime/iOS-Views/`

4. Select ALL files in this folder:
   - MainClockView.swift
   - TimeDisplayGrid.swift
   - LongitudeInputView.swift
   - Components/ (folder with MissionControlBackground.swift)

5. **IMPORTANT**: Check the following options:
   - ☑️ **Copy items if needed** (check this)
   - ☑️ **Create groups** (selected)
   - ☑️ **Add to targets: MarsTime** (iOS target only)
   - ⬜ MarsTimeWatch Watch App (leave unchecked)

6. Click **Add**

---

### Step 3: Add watchOS View Files

1. In Project Navigator, find the **MarsTimeWatch Watch App** folder (watch app)

2. Right-click on **MarsTimeWatch Watch App** folder → **Add Files to "MarsTime"...**

3. Navigate to: `/Users/dustinschaaf/Desktop/GitHub/Mars/MarsTime/watchOS-Views/`

4. Select ALL files:
   - WatchClockView.swift
   - CompactTimeView.swift

5. **IMPORTANT**: Check the following options:
   - ☑️ **Copy items if needed** (check this)
   - ☑️ **Create groups** (selected)
   - ⬜ MarsTime (leave unchecked)
   - ☑️ **Add to targets: MarsTimeWatch Watch App** (watchOS target only)

6. Click **Add**

---

### Step 4: Verify File Organization

Your Xcode Project Navigator should now look like this:

```
MarsTime/
├── MarsTimeApp.swift (updated ✅)
├── MainClockView.swift (new ✅)
├── TimeDisplayGrid.swift (new ✅)
├── LongitudeInputView.swift (new ✅)
├── Components/
│   └── MissionControlBackground.swift (new ✅)
├── ViewModels/
│   └── MarsClockViewModel.swift (updated ✅)
├── Engine/
│   └── MarsTimeEngine.swift (shared ✅)
└── Assets.xcassets

MarsTimeWatch Watch App/
├── MarsTimeWatchApp.swift (updated ✅)
├── WatchClockView.swift (new ✅)
├── CompactTimeView.swift (new ✅)
├── ViewModels/
│   └── WatchClockViewModel.swift (updated ✅)
├── Engine/
│   └── MarsTimeEngine.swift (shared ✅)
└── Assets.xcassets
```

---

### Step 5: Build the iOS App

1. At the top of Xcode, select the scheme: **MarsTime** → **iPhone 17 Pro Max**

2. Press **Cmd+B** or click the Build button (hammer icon)

3. If successful, press **Cmd+R** to run the app

**Expected Result**: You should see the Mars Clock app with:
- Dark mission control background
- Current Sol number
- Coordinated Mars Time (MTC)
- Local Mean Solar Time (LMST)
- Longitude selector with landing sites

---

### Step 6: Build the watchOS App

1. Change scheme to: **MarsTimeWatch Watch App** → **Any watchOS Simulator Device**

2. Press **Cmd+B** to build

3. Press **Cmd+R** to run

**Note**: The watch simulator may take time to boot. You'll see the Mars Clock on the watch face.

---

## 🔧 Troubleshooting

### Issue: "Cannot find 'MainClockView' in scope"

**Solution**: Make sure MainClockView.swift is added to the **MarsTime** (iOS) target:
1. Click on MainClockView.swift in Project Navigator
2. In the right sidebar (File Inspector), check **Target Membership**
3. Ensure **MarsTime** is checked

### Issue: "Cannot find 'WatchClockView' in scope"

**Solution**: Make sure WatchClockView.swift is added to the **MarsTimeWatch Watch App** target:
1. Click on WatchClockView.swift
2. Check Target Membership in File Inspector
3. Ensure **MarsTimeWatch Watch App** is checked

### Issue: "No such module 'WatchKit'"

**Solution**: This is normal for iOS files. Make sure WatchClockViewModel.swift is only added to the watchOS target, not iOS.

### Issue: Build errors about missing types

**Solution**: Make sure MarsTimeEngine.swift has BOTH targets checked:
1. Click on MarsTimeEngine.swift
2. Target Membership should show:
   - ☑️ MarsTime
   - ☑️ MarsTimeWatch Watch App

---

## ✨ What Each Component Does

### iOS Components:

- **MainClockView**: Main screen with all time displays and controls
- **TimeDisplayGrid**: Displays MTC, LMST, UTC with beautiful cards
- **LongitudeInputView**: Slider and quick-pick buttons for landing sites
- **MissionControlBackground**: NASA-style grid background
- **MarsClockViewModel**: Manages state, timer, and Mars time calculations

### watchOS Components:

- **WatchClockView**: Compact watch display optimized for small screen
- **CompactTimeView**: Even more minimal display option
- **WatchClockViewModel**: Battery-optimized with wrist-up detection

### Shared:

- **MarsTimeEngine**: NASA/JPL standard Mars time calculation engine
  - Converts UTC → Julian Date → Terrestrial Time → Mars Sol Date → MTC → LMST
  - Used by both iOS and watchOS apps

---

## 🚀 Next Features to Add (Future)

After you have the basic app working:

1. **watchOS Complications** - Show Mars time on watch faces
2. **iOS Widgets** - Home screen and Lock Screen widgets
3. **Landing Site Library** - More Mars locations
4. **Mission Sol Counters** - Track specific rover sols
5. **Sunset/Sunrise Calculator** - Local Mars solar events

---

## 📝 Summary

You now have:
- ✅ Complete iOS Mars Clock app
- ✅ Complete watchOS Mars Clock app
- ✅ Shared calculation engine (NASA-standard)
- ✅ Battery-optimized updates
- ✅ Mission control aesthetics
- ✅ 4 famous Mars landing sites

Just add the files to Xcode and build!
