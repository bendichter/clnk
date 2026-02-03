#!/bin/bash
# Generate App Store screenshots for BiteVue
# Usage: ./scripts/take-screenshots.sh

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCREENSHOTS_DIR="$PROJECT_DIR/Screenshots"
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"

# Device configurations for App Store
declare -a DEVICES=(
    "iPhone 16 Pro Max"      # 6.9" display (required)
    "iPhone 16 Pro"          # 6.3" display
    "iPhone SE (3rd generation)"  # 4.7" display (optional)
    "iPad Pro 13-inch (M4)"  # iPad (if universal)
)

echo "📸 BiteVue Screenshot Generator"
echo "================================"
echo ""

# Create screenshots directory
mkdir -p "$SCREENSHOTS_DIR"

# Check if UI test target exists
if ! grep -q "BiteVueUITests" "$PROJECT_DIR/BiteVue.xcodeproj/project.pbxproj" 2>/dev/null; then
    echo "⚠️  UI Test target not found in project."
    echo ""
    echo "To add it manually in Xcode:"
    echo "1. Open BiteVue.xcodeproj"
    echo "2. File → New → Target → UI Testing Bundle"
    echo "3. Name it 'BiteVueUITests'"
    echo "4. Copy ScreenshotTests.swift to the new target"
    echo "5. Re-run this script"
    echo ""
    echo "Alternatively, taking manual screenshots with simctl..."
    echo ""
fi

# Function to take screenshots using simctl
take_manual_screenshots() {
    local device_name="$1"
    local safe_name="${device_name// /_}"
    local device_dir="$SCREENSHOTS_DIR/$safe_name"
    mkdir -p "$device_dir"
    
    echo "📱 Device: $device_name"
    
    # Boot simulator if needed
    local udid=$(xcrun simctl list devices available | grep "$device_name" | grep -o '[A-F0-9-]\{36\}' | head -1)
    
    if [ -z "$udid" ]; then
        echo "   ⚠️  Device not found, skipping..."
        return
    fi
    
    echo "   UDID: $udid"
    
    # Boot device
    xcrun simctl boot "$udid" 2>/dev/null || true
    sleep 3
    
    # Install and launch app (if built)
    local app_path=$(find "$DERIVED_DATA" -name "BiteVue.app" -path "*/Debug-iphonesimulator/*" 2>/dev/null | head -1)
    
    if [ -n "$app_path" ]; then
        echo "   Installing app..."
        xcrun simctl install "$udid" "$app_path" 2>/dev/null || true
        
        echo "   Launching app..."
        xcrun simctl launch "$udid" com.bitevue.app 2>/dev/null || true
        sleep 5
        
        # Take screenshot
        echo "   📸 Taking screenshot..."
        xcrun simctl io "$udid" screenshot "$device_dir/01_main.png"
        echo "   ✅ Saved to $device_dir/01_main.png"
    else
        echo "   ⚠️  App not built. Run: xcodebuild -scheme BiteVue -destination 'platform=iOS Simulator,name=$device_name' build"
    fi
    
    echo ""
}

# Option 1: Run UI Tests (if target exists)
run_ui_tests() {
    local device_name="$1"
    local safe_name="${device_name// /_}"
    
    echo "🧪 Running UI Tests on $device_name..."
    
    xcodebuild test \
        -project "$PROJECT_DIR/BiteVue.xcodeproj" \
        -scheme "BiteVueUITests" \
        -destination "platform=iOS Simulator,name=$device_name" \
        -resultBundlePath "$SCREENSHOTS_DIR/TestResults_$safe_name" \
        2>&1 | xcpretty || true
    
    # Extract screenshots from result bundle
    echo "   Extracting screenshots..."
    local attachments_dir=$(find "$SCREENSHOTS_DIR/TestResults_$safe_name" -name "Attachments" -type d 2>/dev/null | head -1)
    
    if [ -d "$attachments_dir" ]; then
        mkdir -p "$SCREENSHOTS_DIR/$safe_name"
        cp "$attachments_dir"/*.png "$SCREENSHOTS_DIR/$safe_name/" 2>/dev/null || true
        echo "   ✅ Screenshots saved to $SCREENSHOTS_DIR/$safe_name/"
    fi
}

# Main execution
echo "📍 Screenshots will be saved to: $SCREENSHOTS_DIR"
echo ""

# Build the app first
echo "🔨 Building BiteVue..."
cd "$PROJECT_DIR"
xcodebuild -project BiteVue.xcodeproj \
    -scheme BiteVue \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
    -configuration Debug \
    build 2>&1 | tail -3

echo ""

# Take screenshots on primary device
echo "📸 Taking screenshots..."
take_manual_screenshots "iPhone 16 Pro Max"

echo ""
echo "================================"
echo "✅ Screenshot generation complete!"
echo ""
echo "Screenshots saved to: $SCREENSHOTS_DIR"
echo ""
echo "For full automated screenshots, add the UI Test target to Xcode:"
echo "  File → New → Target → UI Testing Bundle → BiteVueUITests"
echo "  Then copy BiteVueUITests/ScreenshotTests.swift to the target"
echo ""
ls -la "$SCREENSHOTS_DIR" 2>/dev/null || true
