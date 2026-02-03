# BiteVue App Store Screenshots

This directory contains App Store Connect-ready screenshots for Great Plate (BiteVue) iOS app.

## Quick Start

**To complete the screenshot capture:**

```bash
cd ~/.openclaw/workspace/BiteVue
./auto_screenshot.sh
```

This interactive script will guide you through capturing all required screenshots.

## Current Status

- **6.7" Display:** 4 screenshots ✅ (need 1-6 more)
- **6.5" Display:** 3 screenshots ⚠️ (need 2-7 more)
- **5.5" Display:** 0 screenshots ❌ (see note below)

App Store Connect requires **5-10 screenshots per device size**.

## Directory Structure

```
Screenshots/
├── 6.7-inch/          # iPhone 16/15/14 Pro Max (1290 x 2796 px)
├── 6.5-inch/          # iPhone 16/15/14 Plus (1284 x 2778 px)
├── 5.5-inch/          # iPhone 8 Plus (1242 x 2208 px)
└── README.md          # This file
```

## Screenshots Needed

Capture these screens for EACH device size:

1. ✅ Home/Restaurant List (captured)
2. ❌ Restaurant Detail View
3. ❌ Dish Detail with Reviews
4. ❌ Map View with Restaurants
5. ❌ Rate a Dish Interface
6. ❌ User Profile/Favorites
7. ❌ Search (optional)
8. ❌ Recommendations/Filters (optional)

## Tools Available

| Script | Purpose |
|--------|---------|
| `../auto_screenshot.sh` | Interactive capture (recommended) |
| `../resize_screenshots.sh` | Ensure correct dimensions |
| `../SCREENSHOT_GUIDE.md` | Detailed documentation |
| `../SCREENSHOT_STATUS.md` | Current progress report |

## About 5.5" Display

iPhone 8 Plus simulator is not available with iOS 18.3. Options:

1. **Resize from 6.5" screenshots** (easiest):
   ```bash
   for img in 6.5-inch/*.png; do
       sips -z 2208 1242 "$img" --out "5.5-inch/$(basename "$img")"
   done
   ```

2. **Install older iOS runtime** - Download iOS 15 simulator from Xcode

3. **Skip if optional** - Apple may not require 5.5" with larger sizes

## Quality Requirements

✅ All screenshots are resized to exact App Store dimensions  
✅ Status bar is clean (use demo mode)  
✅ Real content displayed (restaurants, dishes, ratings)  
✅ Portrait orientation only  
✅ Text is readable  

## Upload to App Store

1. Visit [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app → Media Manager
3. Upload screenshots to appropriate size categories:
   - 6.7" → 6.7" Display section
   - 6.5" → 6.5" Display section  
   - 5.5" → 5.5" Display section
4. Arrange screenshots in desired order (drag & drop)

---

**Next step:** Run `cd .. && ./auto_screenshot.sh` to complete the capture process.
