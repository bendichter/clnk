#!/bin/bash

# Script to capture App Store screenshots for Clnk

SCREENSHOTS_DIR="$HOME/.openclaw/workspace/Clnk/Screenshots"
APP_BUNDLE_ID="com.clnk.app"

# Device configurations: name|folder_name|required_width|required_height
DEVICES=(
  "iPhone 16 Pro Max|6.7-inch|1290|2796"
  "iPhone 16 Plus|6.5-inch|1284|2778"
  "iPhone SE (3rd generation)|5.5-inch|1242|2208"
)

# Screenshot names and descriptions
SCREENS=(
  "01_home|Home screen with restaurant list"
  "02_restaurant_detail|Restaurant detail view"
  "03_dish_detail|Dish detail with reviews"
  "04_map_view|Map view with restaurants"
  "05_rate_dish|Rate a dish interface"
  "06_profile|User profile"
)

# Function to take screenshot
take_screenshot() {
  local device_name="$1"
  local folder="$2"
  local screen_name="$3"
  local description="$4"
  
  echo "📸 Taking screenshot: $screen_name - $description"
  echo "   Device: $device_name"
  echo ""
  echo "Press ENTER when ready to capture..."
  read
  
  local output_path="$SCREENSHOTS_DIR/$folder/${screen_name}.png"
  xcrun simctl io booted screenshot "$output_path"
  
  if [ $? -eq 0 ]; then
    echo "✅ Saved to: $output_path"
    # Get actual dimensions
    local dims=$(sips -g pixelWidth -g pixelHeight "$output_path" 2>/dev/null | grep pixel | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
    echo "   Dimensions: $dims"
  else
    echo "❌ Failed to capture screenshot"
  fi
  echo ""
}

# Function to resize screenshot
resize_screenshot() {
  local input_path="$1"
  local target_width="$2"
  local target_height="$3"
  
  # Get current dimensions
  local current_width=$(sips -g pixelWidth "$input_path" | grep pixelWidth | awk '{print $2}')
  local current_height=$(sips -g pixelHeight "$input_path" | grep pixelHeight | awk '{print $2}')
  
  if [ "$current_width" != "$target_width" ] || [ "$current_height" != "$target_height" ]; then
    echo "Resizing $input_path from ${current_width}x${current_height} to ${target_width}x${target_height}"
    sips -z "$target_height" "$target_width" "$input_path" > /dev/null
  fi
}

# Main capture function
capture_for_device() {
  IFS='|' read -r device_name folder_name target_width target_height <<< "$1"
  
  echo "=========================================="
  echo "📱 Capturing screenshots for: $device_name"
  echo "   Target size: ${target_width}x${target_height}"
  echo "=========================================="
  echo ""
  
  # Create directory
  mkdir -p "$SCREENSHOTS_DIR/$folder_name"
  
  # Shutdown all simulators
  echo "Shutting down all simulators..."
  xcrun simctl shutdown all 2>/dev/null
  sleep 2
  
  # Boot the specific device
  echo "Booting $device_name..."
  xcrun simctl boot "$device_name"
  sleep 5
  
  # Install app
  echo "Installing Clnk..."
  xcrun simctl install booted "$HOME/.openclaw/workspace/Clnk/DerivedData/Build/Products/Debug-iphonesimulator/Clnk.app"
  sleep 2
  
  # Launch app in demo mode
  echo "Launching Clnk in demo mode..."
  xcrun simctl launch booted "$APP_BUNDLE_ID" --args "--uitesting" "--demo-mode"
  sleep 5
  
  echo ""
  echo "App is now running in demo mode on $device_name"
  echo "Navigate through the app and capture screenshots for each screen."
  echo ""
  
  # Capture each screen
  for screen in "${SCREENS[@]}"; do
    IFS='|' read -r screen_name description <<< "$screen"
    take_screenshot "$device_name" "$folder_name" "$screen_name" "$description"
  done
  
  echo "✅ Completed screenshots for $device_name"
  echo ""
}

# Function to resize all screenshots
resize_all() {
  echo "=========================================="
  echo "🔧 Resizing all screenshots to App Store sizes"
  echo "=========================================="
  echo ""
  
  for device in "${DEVICES[@]}"; do
    IFS='|' read -r device_name folder_name target_width target_height <<< "$device"
    
    echo "Processing $folder_name (${target_width}x${target_height})..."
    
    for img in "$SCREENSHOTS_DIR/$folder_name"/*.png; do
      if [ -f "$img" ]; then
        resize_screenshot "$img" "$target_width" "$target_height"
      fi
    done
    
    echo ""
  done
  
  echo "✅ All screenshots resized"
}

# Show menu
show_menu() {
  echo "=========================================="
  echo "📸 Clnk Screenshot Capture Tool"
  echo "=========================================="
  echo ""
  echo "1. Capture screenshots for iPhone 16 Pro Max (6.7\")"
  echo "2. Capture screenshots for iPhone 16 Plus (6.5\")"
  echo "3. Capture screenshots for iPhone SE 3rd gen (5.5\")"
  echo "4. Capture all device sizes (sequential)"
  echo "5. Resize all existing screenshots"
  echo "6. Exit"
  echo ""
  echo -n "Select option: "
}

# Main script
if [ "$1" == "--resize" ]; then
  resize_all
  exit 0
fi

if [ "$1" == "--auto" ]; then
  for device in "${DEVICES[@]}"; do
    capture_for_device "$device"
  done
  resize_all
  exit 0
fi

# Interactive mode
while true; do
  show_menu
  read choice
  
  case $choice in
    1) capture_for_device "${DEVICES[0]}" ;;
    2) capture_for_device "${DEVICES[1]}" ;;
    3) capture_for_device "${DEVICES[2]}" ;;
    4)
      for device in "${DEVICES[@]}"; do
        capture_for_device "$device"
      done
      ;;
    5) resize_all ;;
    6) echo "Goodbye!"; exit 0 ;;
    *) echo "Invalid option" ;;
  esac
  
  echo ""
  echo "Press ENTER to continue..."
  read
done
