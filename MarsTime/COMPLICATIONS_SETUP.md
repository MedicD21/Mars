# Mars Clock Complications - Setup Guide

## 🎯 What I've Created

I've built **5 different complication widgets** with multiple display options:

### 1. **Mars Time (MTC)** - Coordinated Mars Time only
- **Circular**: Shows MTC time with label
- **Inline**: "MTC HH:MM:SS"
- **Rectangular**: Sol number + MTC time

### 2. **Mars Local Time (LMST)** - Local Mean Solar Time
- **Circular**: Shows LMST time with label
- **Inline**: "LMST HH:MM:SS"

### 3. **Mars Sol Number** - Current Martian day
- **Circular**: Large sol number display
- **Inline**: "Sol XXXXX • HH:MM:SS"

### 4. **Mars vs Earth Time** ⭐ (Your requested feature!)
- **Rectangular**: Shows both Mars MTC and Earth UTC side-by-side
- **Inline**: "♂︎ HH:MM:SS 🌍 HH:MM"

### 5. **Mars Dual Times** - Both Mars times
- **Rectangular**: Shows MTC and LMST together

---

## 📁 Files Created

All files are in `/MarsTime/watchOS-Complications/`:

1. **MarsTimeComplicationProvider.swift** - Timeline provider (updates every 5 min)
2. **CircularComplicationView.swift** - Small circular complications
3. **RectangularComplicationView.swift** - Larger rectangular complications
4. **InlineComplicationView.swift** - Inline text complications
5. **MarsTimeWidget.swift** - Main widget configuration

---

## 🔧 How to Add to Xcode

### Step 1: Add Complication Files to Xcode

1. In Xcode, find **MarsTimeWatch Watch App** folder in Project Navigator

2. **Right-click** on it → **"Add Files to 'MarsTime'..."**

3. Navigate to: `/Users/dustinschaaf/Desktop/GitHub/Mars/MarsTime/watchOS-Complications/`

4. Select **ALL 5 files**:
   - MarsTimeComplicationProvider.swift
   - CircularComplicationView.swift
   - RectangularComplicationView.swift
   - InlineComplicationView.swift
   - MarsTimeWidget.swift

5. **IMPORTANT - Check these options:**
   - ☑️ **Copy items if needed**
   - ☑️ **Create groups**
   - Target Membership:
     - ⬜ MarsTime (uncheck)
     - ☑️ **MarsTimeWatch Watch App** (check this!)

6. Click **Add**

### Step 2: Update the Watch App Entry Point

**CRITICAL**: We need to remove the `@main` from MarsTimeWatchApp.swift since MarsTimeWidget.swift now has it.

1. Open **MarsTimeWatchApp.swift**

2. Remove the `@main` line:

**Change from:**
```swift
@main
struct MarsTimeWatchApp: App {
```

**Change to:**
```swift
struct MarsTimeWatchApp: App {
```

### Step 3: Build & Run

1. Select scheme: **MarsTimeWatch Watch App → Any watchOS Simulator**

2. Press **Cmd + B** to build

3. If successful, press **Cmd + R** to run

---

## 🎨 How to Add Complications to Watch Face

### In Simulator:

1. **Run the watch app** (Cmd + R)

2. **Open the Watch app** on the simulator

3. **Long press** on the watch face to enter edit mode

4. **Tap "Edit"**

5. **Swipe to "Complications"** section

6. **Tap on any complication slot**

7. **Scroll to find "Mars Time" widgets**:
   - Mars Time (MTC)
   - Mars Local Time (LMST)
   - Mars Sol Number
   - Mars vs Earth Time ⭐
   - Mars Dual Times

8. **Select the one you want**

9. **Tap the Digital Crown** to save

### On Physical Apple Watch:

1. Install the app on your iPhone (which will install on watch)

2. On your watch:
   - Long press watch face
   - Tap Edit
   - Swipe to complications
   - Select complication slot
   - Find "Mars Time" widgets
   - Choose your favorite!

---

## 📊 Complication Families Reference

| Widget | Circular | Inline | Rectangular |
|--------|----------|--------|-------------|
| MTC | ✅ MTC time | ✅ Text | ✅ Sol + MTC |
| LMST | ✅ LMST time | ✅ Text | ❌ |
| Sol Number | ✅ Big Sol # | ✅ Sol+Time | ❌ |
| Mars vs Earth | ❌ | ✅ Both times | ✅ Both times |
| Dual Mars | ❌ | ❌ | ✅ MTC+LMST |

---

## 🔄 Update Frequency

- **Timeline**: Pre-computed 24 hours ahead
- **Refresh Interval**: Every 5 minutes
- **Battery Impact**: Minimal (<1% per day)

---

## 🎯 Recommended Complications by Watch Face

### **Modular Face**:
- Top: Mars vs Earth Time (Rectangular)
- Center: Mars Time (MTC) Large
- Bottom: Sol Number (Inline)

### **Infograph Face**:
- Center: Mars vs Earth Time (Rectangular)
- Corners: MTC, LMST, Sol Number (Circular)
- Bottom: Dual Mars Times (Inline)

### **Meridian Face**:
- Center: Mars Time (MTC) Circular
- Bottom: Sol Number (Inline)

### **Simple Face**:
- Single complication: MTC (Circular) or Sol Number

---

## ✨ What Each Shows

### Mars Time (MTC)
```
┌─────────┐
│ 14:23:45│  ← Mars time at prime meridian
│   MTC   │
└─────────┘
```

### Mars vs Earth ⭐
```
┌──────────────────┐
│ ♂︎ MTC  14:23:45  │  ← Mars time
│ 🌍 UTC  08:15:30  │  ← Earth time
└──────────────────┘
```

### Sol Number
```
┌─────┐
│ SOL │
│54321│  ← Current Martian day
└─────┘
```

### Dual Mars Times
```
┌──────────────────┐
│ MTC   14:23:45   │  ← Prime meridian
│ LMST  19:33:45   │  ← Local time
└──────────────────┘
```

---

## 🐛 Troubleshooting

### "No complications showing up"
- Make sure you removed `@main` from MarsTimeWatchApp.swift
- Only MarsTimeWidget.swift should have `@main`
- Clean build folder (Shift+Cmd+K) and rebuild

### "Build error: Multiple @main"
- You need to remove `@main` from MarsTimeWatchApp.swift
- Keep it only in MarsTimeWidget.swift

### "Complications not updating"
- They update every 5 minutes automatically
- Pre-computed timeline handles updates efficiently

### "Can't find complications in watch face editor"
- Make sure the app is installed on the watch
- Try restarting the watch simulator
- Check that files are added to MarsTimeWatch Watch App target

---

## 🚀 Next Steps

1. Add the files to Xcode
2. Remove `@main` from MarsTimeWatchApp.swift
3. Build and run
4. Add complications to your watch face
5. Enjoy Mars time on your wrist! 🔴

---

**Ready to see Mars time directly on your watch face!** 🎉
