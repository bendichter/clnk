# BiteVue App Store Screenshots Guide

## Current Status

✅ **Completed:**
- Project built successfully for iOS Simulator
- Screenshot infrastructure created
- Automated scripts developed
- Initial screenshots captured and resized to App Store specifications

📊 **Screenshots Captured:**
- 6.7" Display (iPhone Pro Max): 4 screenshots
- 6.5" Display (iPhone Plus): 1 screenshot  
- 5.5" Display (iPhone 8 Plus): 0 screenshots (see note below)

## App Store Connect Requirements

Each device size class needs **5-10 high-quality screenshots** in the following dimensions:

| Device Class | Required Size | Devices |
|--------------|---------------|---------|
| 6.7" Display | 1290 x 2796 px | iPhone 16/15/14 Pro Max |
| 6.5" Display | 1284 x 2778 px | iPhone 16/15/14 Plus, XS Max, 11 Pro Max |
| 5.5" Display | 1242 x 2208 px | iPhone 8/7/6s Plus |

## Required Screens to Capture

To showcase BiteVue effectively, capture these screens:

1. **✅ Home/Restaurant List** - Show nearby restaurants with ratings
2. **Restaurant Detail** - Show a restaurant with top dishes, ratings
3. **Dish Detail** - Show a dish with reviews and rating
4. **Map View** - Show restaurants on map
5. **Rate a Dish** - Show the rating interface
6. **Search** - Show search functionality
7. **Profile** - Show user profile with favorites
8. **Additional** - Any other compelling features (filters, recommendations, etc.)

## Automated Capture Process

### Method 1: Interactive Script (Recommended)

```bash
cd ~/.openclaw/workspace/BiteVue
./auto_screenshot.sh
```

This script will:
1. Boot each simulator (iPhone 16 Pro Max, iPhone 16 Plus)
2. Install and launch BiteVue in demo mode
3. Prompt you to navigate to each screen
4. Capture and properly resize screenshots
5. Save to organized folders

### Method 2: Manual with Helper Commands

```bash
# 1. Boot desired simulator
xcrun simctl boot "iPhone 16 Pro Max"

# 2. Install app
xcrun simctl install booted ~/.openclaw/workspace/BiteVue/DerivedData/Build/Products/Debug-iphonesimulator/BiteVue.app

# 3. Launch in demo mode (pre-populated with data)
xcrun simctl launch booted com.greatplate.app --args "--uitesting" "--demo-mode"

# 4. Navigate to desired screen in Simulator window, then capture:
xcrun simctl io booted screenshot ~/. openclaw/workspace/BiteVue/Screenshots/6.7-inch/02_restaurant_detail.png

# 5. Repeat for each screen, incrementing filename numbers

# 6. After all screenshots, resize to App Store specs:
./resize_screenshots.sh
```

### Method 3: Fastlane (If UI Tests Are Configured)

*Note: UI Tests are not currently integrated into the Xcode project. See "Setting Up Automated UI Tests" section below.*

```bash
bundle exec fastlane screenshots
```

## Naming Convention

Use descriptive, sequential names:

```
01_home.png or 01_restaurant_list.png
02_restaurant_detail.png
03_dish_detail.png
04_dish_reviews.png
05_map_view.png
06_search.png
07_rate_dish.png
08_profile.png
09_favorites.png
10_recommendations.png
```

## Post-Capture Processing

After capturing screenshots, run:

```bash
./resize_screenshots.sh
```

This ensures all screenshots are exactly the right dimensions for App Store Connect.

## About 5.5" Display (iPhone 8 Plus)

**Issue:** iPhone 8 Plus simulators are not available with iOS 18.3 runtime (incompatible).

**Solutions:**
1. **Use older Xcode/iOS runtime** - Install Xcode with iOS 15 or earlier support
2. **Resize from 6.5"** - Scale down 6.5" screenshots (may reduce quality slightly):
   ```bash
   # Example resize from 6.5" to 5.5"
   for img in Screenshots/6.5-inch/*.png; do
       sips -z 2208 1242 "$img" --out "Screenshots/5.5-inch/$(basename "$img")"
   done
   ```
3. **Skip if optional** - Apple may not require 5.5" if you have larger sizes

## Screenshot Quality Tips

✨ **Best Practices:**
- Use **demo mode** (pre-populated data): App launches with `--demo-mode` flag
- Ensure **good lighting** and readable text
- Show **real content** (restaurants, dishes, ratings)
- **Hide status bar** or use Xcode's "Clean Status Bar" feature
- Capture **vertical/portrait orientation only**
- Use **light mode** for consistency (unless showcasing dark mode)
- Show **compelling features** that differentiate your app

## Setting Up Automated UI Tests (Advanced)

To enable fully automated screenshot capture with Fastlane:

1. **Add UI Test Target to Xcode Project**:
   - Open `BiteVue.xcodeproj` in Xcode
   - File → New → Target → iOS UI Testing Bundle
   - Name it `BiteVueUITests`
   
2. **Replace the generated test file** with `BiteVueUITests/ScreenshotTests.swift` (already created)

3. **Configure the scheme**:
   - Product → Scheme → Edit Scheme
   - Select "Test" action
   - Add `BiteVueUITests` to test targets

4. **Update fastlane configuration** (already done in `fastlane/Fastfile`)

5. **Run automated capture**:
   ```bash
   bundle install
   bundle exec fastlane screenshots
   ```

## Troubleshooting

**Problem:** Screenshots are wrong dimensions  
**Solution:** Run `./resize_screenshots.sh`

**Problem:** Simulator won't boot  
**Solution:** `xcrun simctl shutdown all && xcrun simctl boot "iPhone 16 Pro Max"`

**Problem:** App crashes or shows empty data  
**Solution:** Ensure demo mode is enabled with launch args: `--uitesting --demo-mode`

**Problem:** Can't find simulators  
**Solution:** `xcrun simctl list devices | grep iPhone`

## Files Created

```
BiteVue/
├── Screenshots/
│   ├── 6.7-inch/          # iPhone Pro Max screenshots
│   ├── 6.5-inch/          # iPhone Plus screenshots
│   └── 5.5-inch/          # iPhone 8 Plus screenshots
├── auto_screenshot.sh     # Interactive capture script
├── resize_screenshots.sh  # Batch resize to App Store specs
├── capture_screenshots.sh # Manual capture helper
└── SCREENSHOT_GUIDE.md    # This file
```

## Next Steps

1. **Capture remaining screenshots** using `./auto_screenshot.sh`
2. **Ensure 5-10 screenshots per device size**
3. **Run resize script** to validate dimensions
4. **Review screenshots** for quality
5. **Upload to App Store Connect**

## Upload to App Store Connect

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Go to your app → App Store tab
3. Select version → Media Manager → App Previews and Screenshots
4. Upload screenshots to appropriate device size categories
5. Arrange in desired order (drag and drop)
6. Add localized descriptions if needed

---

**Questions or issues?** Check the troubleshooting section or review the automated scripts.
