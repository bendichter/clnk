# Clnk App Store Screenshots - Status Report

**Generated:** February 2, 2026  
**Project:** Clnk iOS App  
**Location:** `~/.openclaw/workspace/Clnk/Screenshots/`

---

## ✅ Completed

### Infrastructure
- ✅ Xcode project built successfully for iOS Simulator
- ✅ Screenshot directories created and organized
- ✅ Automated capture scripts developed
- ✅ Resize automation implemented
- ✅ All captured screenshots resized to App Store specifications

### Screenshots Captured

#### 6.7" Display (iPhone 16/15/14 Pro Max) - 1290 x 2796 px
**Status: 4/5 minimum captured** ⚠️ Need 1-6 more

```
✅ 01_app_launch.png
✅ 01_home.png  
✅ 02_restaurant_list.png
✅ 03_main_view.png
```

#### 6.5" Display (iPhone 16/15/14 Plus) - 1284 x 2778 px
**Status: 3/5 minimum captured** ⚠️ Need 2-7 more

```
✅ 01_home.png
✅ 02_main_screen.png
✅ 03_app_state.png
```

#### 5.5" Display (iPhone 8 Plus) - 1242 x 2208 px
**Status: 0/5 captured** ❌ Not started

**Issue:** iPhone 8 Plus simulator not available with iOS 18.3 runtime (incompatible)

---

## 📋 Remaining Work

### Priority 1: Complete Screenshot Sets

To meet App Store Connect requirements (5-10 screenshots per size), you need:

**6.7" Display:** Need **1-6 more screenshots**
- ❌ Restaurant Detail View (with menu/dishes)
- ❌ Dish Detail with Reviews
- ❌ Map View with Restaurants
- ❌ Rate a Dish Interface
- ❌ User Profile/Favorites
- ❌ Search Interface (optional)

**6.5" Display:** Need **2-7 more screenshots**
- ❌ Same screens as above for 6.5" device

**5.5" Display:** Need **5-10 screenshots** (see solutions below)

### Priority 2: Screenshot Variety

Ensure screenshots showcase:
1. **Home/Restaurant List** ✅ (captured)
2. **Restaurant Detail** ❌ (missing)
3. **Dish Detail with Reviews** ❌ (missing)
4. **Map View** ❌ (missing)
5. **Rate a Dish** ❌ (missing)
6. **Profile/Favorites** ❌ (missing)
7. **Search** ❌ (optional)
8. **Filters/Recommendations** ❌ (optional)

---

## 🛠 How to Complete

### Option A: Interactive Script (Recommended)

```bash
cd ~/.openclaw/workspace/Clnk
./auto_screenshot.sh
```

This will guide you through:
1. Booting each simulator
2. Navigating to each required screen
3. Capturing and naming screenshots
4. Automatic resizing to App Store specs

### Option B: Manual Capture

```bash
# 1. Boot simulator
xcrun simctl boot "iPhone 16 Pro Max"

# 2. Install app
xcrun simctl install booted \
  ~/.openclaw/workspace/Clnk/DerivedData/Build/Products/Debug-iphonesimulator/Clnk.app

# 3. Launch in demo mode
xcrun simctl launch booted com.clnk.app \
  --args "--uitesting" "--demo-mode"

# 4. Open Simulator app, navigate to desired screen

# 5. Capture screenshot
xcrun simctl io booted screenshot \
  ~/.openclaw/workspace/Clnk/Screenshots/6.7-inch/04_restaurant_detail.png

# 6. Repeat for each screen and device

# 7. Resize all
./resize_screenshots.sh
```

### Option C: Set Up Automated UI Tests

See `SCREENSHOT_GUIDE.md` section "Setting Up Automated UI Tests" for fully automated capture using Fastlane + XCUITest.

---

## 📱 About 5.5" Display (iPhone 8 Plus)

### The Problem
iPhone 8 Plus requires iOS 15 or earlier, which is not available with the current Xcode/iOS 18.3 SDK.

### Solutions

**Option 1: Install Older Simulator Runtime** (Best Quality)
1. Download iOS 15.x simulator runtime from Xcode preferences
2. Create iPhone 8 Plus simulator with iOS 15
3. Build app for older iOS target (if compatible)
4. Capture screenshots normally

**Option 2: Resize from 6.5" Screenshots** (Good Quality)
```bash
mkdir -p Screenshots/5.5-inch

# Resize each 6.5" screenshot to 5.5" dimensions
for img in Screenshots/6.5-inch/*.png; do
    filename=$(basename "$img")
    sips -z 2208 1242 "$img" --out "Screenshots/5.5-inch/$filename"
done
```

**Option 3: Skip 5.5" Display** (If Acceptable)
- Apple may not strictly require 5.5" if you provide larger sizes
- Check current App Store Connect requirements for your app
- Most users are on newer devices anyway

**Recommendation:** Use Option 2 (resize from 6.5") for quick solution, or Option 1 for highest quality if you have time to set up older runtime.

---

## 📊 Screenshot Checklist

Use this checklist as you capture screenshots:

### 6.7" Display (iPhone 16 Pro Max)
- [x] 01 - Home/Restaurant List
- [ ] 02 - Restaurant Detail
- [ ] 03 - Dish Detail
- [ ] 04 - Map View
- [ ] 05 - Rate a Dish
- [ ] 06 - Profile
- [ ] 07 - Search (optional)
- [ ] 08 - Filters (optional)

### 6.5" Display (iPhone 16 Plus)
- [x] 01 - Home/Restaurant List
- [ ] 02 - Restaurant Detail
- [ ] 03 - Dish Detail
- [ ] 04 - Map View
- [ ] 05 - Rate a Dish
- [ ] 06 - Profile
- [ ] 07 - Search (optional)
- [ ] 08 - Filters (optional)

### 5.5" Display (iPhone 8 Plus)
- [ ] 01 - Home/Restaurant List
- [ ] 02 - Restaurant Detail
- [ ] 03 - Dish Detail
- [ ] 04 - Map View
- [ ] 05 - Rate a Dish
- [ ] 06 - Profile
- [ ] 07 - Search (optional)
- [ ] 08 - Filters (optional)

---

## 📁 Files & Scripts

All tools are ready to use:

| Script | Purpose |
|--------|---------|
| `auto_screenshot.sh` | Interactive screenshot capture tool |
| `resize_screenshots.sh` | Batch resize to App Store specs |
| `capture_screenshots.sh` | Manual capture helper |
| `SCREENSHOT_GUIDE.md` | Comprehensive documentation |
| `SCREENSHOT_STATUS.md` | This status report |

### Directory Structure

```
Clnk/
├── Screenshots/
│   ├── 6.7-inch/          ✅ 4 screenshots (need 1-6 more)
│   ├── 6.5-inch/          ⚠️ 3 screenshots (need 2-7 more)
│   └── 5.5-inch/          ❌ 0 screenshots (need 5-10)
├── ClnkUITests/
│   └── ScreenshotTests.swift  ✅ Ready (needs Xcode integration)
├── auto_screenshot.sh         ✅ Ready to use
├── resize_screenshots.sh      ✅ Ready to use
├── capture_screenshots.sh     ✅ Ready to use
├── SCREENSHOT_GUIDE.md        ✅ Complete documentation
└── SCREENSHOT_STATUS.md       📄 This file
```

---

## ✨ Quality Checklist

Before uploading to App Store Connect, verify:

- [ ] All screenshots are **1290x2796** (6.7"), **1284x2778** (6.5"), or **1242x2208** (5.5")
- [ ] Screenshots show **real content** (restaurants, dishes, ratings)
- [ ] **Text is readable** and UI elements are clear
- [ ] **Status bar** is clean (no low battery, weird times, etc.)
- [ ] Screenshots are in **portrait orientation**
- [ ] **Demo mode** was used (pre-populated data)
- [ ] **5-10 screenshots** per device size
- [ ] Screenshots **showcase key features**
- [ ] **No copyrighted content** visible
- [ ] **No personal information** (real user data)

---

## 🚀 Next Steps

1. **Run interactive capture:**
   ```bash
   cd ~/.openclaw/workspace/Clnk
   ./auto_screenshot.sh
   ```

2. **Navigate through app** and capture required screens

3. **Handle 5.5" display** using one of the solutions above

4. **Validate final screenshots:**
   ```bash
   ./resize_screenshots.sh
   ```

5. **Review screenshot quality**

6. **Upload to App Store Connect:**
   - Login to [App Store Connect](https://appstoreconnect.apple.com)
   - Navigate to your app → Media Manager
   - Upload screenshots to appropriate size categories
   - Arrange in desired order

---

## 📞 Need Help?

- Review `SCREENSHOT_GUIDE.md` for detailed instructions
- Check Troubleshooting section for common issues
- Run `xcrun simctl list devices` to see available simulators
- Ensure app is launched with `--demo-mode` for best screenshots

---

**Status Summary:**  
🟡 Partial - 7/30 minimum screenshots captured (23%)  
📅 Estimated time to complete: 30-60 minutes  
🎯 Ready to proceed with `./auto_screenshot.sh`
