#!/bin/bash
# Run this script after navigating to each screen in the Simulator
# Usage: ./capture.sh <screen_name>
# Example: ./capture.sh home_explore

SCREEN_NAME=${1:-"screenshot"}
TIMESTAMP=$(date +%H%M%S)
OUTPUT_DIR="$(dirname "$0")"

xcrun simctl io booted screenshot "${OUTPUT_DIR}/${SCREEN_NAME}_${TIMESTAMP}.png"
echo "Captured: ${SCREEN_NAME}_${TIMESTAMP}.png"
