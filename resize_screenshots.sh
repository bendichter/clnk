#!/bin/bash

# Resize all screenshots to App Store Connect requirements
# App Store Connect Screenshot Specifications:
# - 6.7" Display (iPhone 15/16 Pro Max): 1290 x 2796 pixels
# - 6.5" Display (iPhone 14/15/16 Plus): 1284 x 2778 pixels  
# - 5.5" Display (iPhone 8 Plus): 1242 x 2208 pixels

SCREENSHOTS_DIR="$HOME/.openclaw/workspace/Clnk/Screenshots"

echo "=========================================="
echo "📐 Resizing screenshots to App Store specs"
echo "=========================================="
echo ""

# Function to resize images in a directory
resize_directory() {
    local dir="$1"
    local target_width="$2"
    local target_height="$3"
    local display_name="$4"
    
    if [ ! -d "$dir" ]; then
        echo "⚠️  Directory not found: $dir"
        return
    fi
    
    local count=0
    echo "Processing: $display_name (${target_width}x${target_height})"
    
    for img in "$dir"/*.png; do
        if [ -f "$img" ] && [[ "$(basename "$img")" != "temp_"* ]]; then
            # Get current dimensions
            local current_width=$(sips -g pixelWidth "$img" 2>/dev/null | grep pixelWidth | awk '{print $2}')
            local current_height=$(sips -g pixelHeight "$img" 2>/dev/null | grep pixelHeight | awk '{print $2}')
            
            if [ -n "$current_width" ] && [ -n "$current_height" ]; then
                if [ "$current_width" != "$target_width" ] || [ "$current_height" != "$target_height" ]; then
                    echo "  Resizing: $(basename "$img") (${current_width}x${current_height} → ${target_width}x${target_height})"
                    sips -z "$target_height" "$target_width" "$img" > /dev/null 2>&1
                    ((count++))
                else
                    echo "  ✓ Already correct size: $(basename "$img")"
                fi
            fi
        fi
    done
    
    if [ $count -gt 0 ]; then
        echo "✅ Resized $count images in $display_name"
    else
        echo "✅ All images already correct size"
    fi
    echo ""
}

# Resize each device category
resize_directory "$SCREENSHOTS_DIR/6.7-inch" 1290 2796 "6.7\" Display (iPhone Pro Max)"
resize_directory "$SCREENSHOTS_DIR/6.5-inch" 1284 2778 "6.5\" Display (iPhone Plus)"
resize_directory "$SCREENSHOTS_DIR/5.5-inch" 1242 2208 "5.5\" Display (iPhone 8 Plus)"

echo "=========================================="
echo "✅ Resize complete!"
echo "=========================================="
echo ""

# Validate final sizes
echo "Validating screenshots..."
echo ""

validate_dir() {
    local dir="$1"
    local expected_w="$2"
    local expected_h="$3"
    local name="$4"
    
    if [ ! -d "$dir" ]; then
        return
    fi
    
    echo "$name:"
    local all_valid=true
    for img in "$dir"/*.png; do
        if [ -f "$img" ] && [[ "$(basename "$img")" != "temp_"* ]]; then
            local w=$(sips -g pixelWidth "$img" 2>/dev/null | grep pixelWidth | awk '{print $2}')
            local h=$(sips -g pixelHeight "$img" 2>/dev/null | grep pixelHeight | awk '{print $2}')
            
            if [ "$w" == "$expected_w" ] && [ "$h" == "$expected_h" ]; then
                echo "  ✅ $(basename "$img"): ${w}x${h}"
            else
                echo "  ❌ $(basename "$img"): ${w}x${h} (expected ${expected_w}x${expected_h})"
                all_valid=false
            fi
        fi
    done
    
    if $all_valid; then
        echo "  All screenshots valid for App Store Connect! ✅"
    else
        echo "  ⚠️  Some screenshots have incorrect dimensions"
    fi
    echo ""
}

validate_dir "$SCREENSHOTS_DIR/6.7-inch" 1290 2796 "6.7\" Display"
validate_dir "$SCREENSHOTS_DIR/6.5-inch" 1284 2778 "6.5\" Display"
validate_dir "$SCREENSHOTS_DIR/5.5-inch" 1242 2208 "5.5\" Display"

echo ""
echo "Screenshots ready for App Store Connect upload!"
echo "Location: $SCREENSHOTS_DIR"
echo ""
