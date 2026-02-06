#!/bin/bash

# Automated screenshot capture for Clnk
# This script launches the app and captures screenshots at intervals
# Manual navigation is required between captures

set -e

SCREENSHOTS_DIR="$HOME/.openclaw/workspace/Clnk/Screenshots"
APP_BUNDLE_ID="com.clnk.app"
APP_PATH="$HOME/.openclaw/workspace/Clnk/DerivedData/Build/Products/Debug-iphonesimulator/Clnk.app"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Devices and their target dimensions for App Store
declare -A DEVICE_TARGETS
DEVICE_TARGETS["iPhone 16 Pro Max"]="6.7-inch:1290:2796"
DEVICE_TARGETS["iPhone 16 Plus"]="6.5-inch:1284:2778"

# iPhone SE 3rd gen actually produces 1170x2532, which isn't 5.5"
# For 5.5" (1242x2208), we'd need iPhone 8 Plus which requires older iOS
# We'll skip it or note it needs manual creation

capture_device_screenshots() {
    local device_name="$1"
    local device_info="${DEVICE_TARGETS[$device_name]}"
    
    IFS=':' read -r folder_name target_width target_height <<< "$device_info"
    
    echo ""
    echo "=========================================="
    log_info "Starting capture for: $device_name"
    log_info "Target size: ${target_width}x${target_height}"
    echo "=========================================="
    echo ""
    
    # Create output directory
    mkdir -p "$SCREENSHOTS_DIR/$folder_name"
    
    # Shutdown all simulators
    log_info "Shutting down all simulators..."
    xcrun simctl shutdown all 2>/dev/null || true
    sleep 2
    
    # Boot device
    log_info "Booting $device_name..."
    xcrun simctl boot "$device_name"
    sleep 5
    
    # Wait for boot to complete
    log_info "Waiting for simulator to fully boot..."
    until xcrun simctl bootstatus "$device_name" 2>&1 | grep -q "Boot status: Booted"; do
        sleep 1
    done
    sleep 3
    
    # Install app
    log_info "Installing Clnk..."
    xcrun simctl install booted "$APP_PATH"
    sleep 2
    
    # Launch app in demo mode
    log_info "Launching Clnk in demo mode..."
    xcrun simctl launch booted "$APP_BUNDLE_ID" --args "--uitesting" "--demo-mode"
    sleep 6
    
    log_success "App launched! Simulator is ready."
    echo ""
    log_warning "MANUAL NAVIGATION REQUIRED"
    echo "================================================"
    echo "The app is now running on $device_name"
    echo "Please navigate to each screen and press ENTER to capture"
    echo "================================================"
    echo ""
    
    # Array of screens to capture
    declare -a screens=(
        "01_login:Login/Home Screen"
        "02_restaurant_list:Restaurant List (Explore Tab)"
        "03_restaurant_detail:Restaurant Detail View"
        "04_dish_detail:Dish Detail with Reviews"
        "05_map_view:Map View with Restaurants"
        "06_search:Search Interface"
        "07_rate_dish:Rate a Dish Screen"
        "08_profile:User Profile"
    )
    
    for screen in "${screens[@]}"; do
        IFS=':' read -r filename description <<< "$screen"
        
        echo ""
        echo "📸 Next: $description"
        echo "   Navigate to this screen, then press ENTER..."
        read
        
        local output_path="$SCREENSHOTS_DIR/$folder_name/${filename}.png"
        xcrun simctl io booted screenshot "$output_path"
        
        # Get and display dimensions
        local dims=$(sips -g pixelWidth -g pixelHeight "$output_path" 2>/dev/null | grep pixel | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
        log_success "Captured: $filename ($dims)"
    done
    
    echo ""
    log_success "Completed screenshots for $device_name"
    echo ""
    
    # Resize screenshots to App Store requirements
    log_info "Resizing screenshots to ${target_width}x${target_height}..."
    for img in "$SCREENSHOTS_DIR/$folder_name"/*.png; do
        if [ -f "$img" ] && [[ "$(basename "$img")" != "temp_"* ]]; then
            sips -z "$target_height" "$target_width" "$img" > /dev/null 2>&1
        fi
    done
    log_success "Resizing complete"
    
    # Shutdown simulator
    xcrun simctl shutdown "$device_name" 2>/dev/null || true
}

# Main execution
echo ""
echo "=========================================="
echo "📸 Clnk App Store Screenshot Generator"
echo "=========================================="
echo ""

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    log_warning "App not found at: $APP_PATH"
    log_info "Building app..."
    cd "$HOME/.openclaw/workspace/Clnk"
    xcodebuild -project Clnk.xcodeproj -scheme Clnk -configuration Debug -sdk iphonesimulator -derivedDataPath ./DerivedData build
    log_success "Build complete"
fi

# Capture for iPhone 16 Pro Max (6.7")
capture_device_screenshots "iPhone 16 Pro Max"

# Capture for iPhone 16 Plus (6.5")
capture_device_screenshots "iPhone 16 Plus"

echo ""
echo "=========================================="
log_success "Screenshot capture complete!"
echo "=========================================="
echo ""
echo "Screenshots saved to: $SCREENSHOTS_DIR"
echo ""
log_info "Summary:"
ls -lh "$SCREENSHOTS_DIR"/*/0*.png | wc -l | xargs echo "Total screenshots:"
echo ""

log_warning "Note about 5.5\" Display (iPhone 8 Plus):"
echo "iPhone 8 Plus is not available with iOS 18.3 runtime."
echo "If you need 5.5\" screenshots (1242x2208), you'll need to:"
echo "  1. Install an older Xcode/simulator runtime"
echo "  2. Or resize 6.5\" screenshots (may affect quality)"
echo ""

log_info "Next steps:"
echo "1. Review screenshots in: $SCREENSHOTS_DIR"
echo "2. Replace any unsatisfactory screenshots"
echo "3. Upload to App Store Connect"
echo ""
