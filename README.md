# 🥂 Clnk

A social cocktail discovery app for iOS that helps you find and share amazing drinks at bars.

## Features

- 🔍 Discover cocktails and bars near you
- ⭐ Rate and review drinks
- 📸 Share photos of your cocktails
- 👥 Follow other cocktail enthusiasts
- 🗺️ Explore with interactive maps
- 🚨 Report inappropriate content
- 🚫 Block users for a better experience

## Tech Stack

- **iOS App**: Swift, SwiftUI
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **Admin Dashboard**: HTML/CSS/JavaScript
- **Design System**: Teal & Sage color palette

## Getting Started

### iOS App

1. Clone this repository
2. Open `Clnk.xcodeproj` in Xcode
3. Configure Supabase credentials in `Clnk/Config.swift`
4. Build and run on simulator or device

### Demo Mode

The app includes a demo mode with mock data for testing without Supabase connection.

### Admin Dashboard

The admin dashboard is a web-based content moderation tool located in the `/admin` directory.

**Access the dashboard:**
- Development: Open `admin/index.html` in a web browser
- Production: Deploy to any static hosting

**Features:**
- 📊 **Stats Overview**: View total bars, cocktails, ratings, users, reports, and blocks
- 🚨 **Reports Dashboard**: Manage reported reviews
- 🚫 **Blocked Users**: View all user block relationships
- 🔐 **Simple Authentication**: Password-protected access

## Design System

The app uses a comprehensive teal & sage color palette. See:
- `Clnk/Components/Colors.swift` - SwiftUI colors
- `admin/css/design-system.css` - CSS variables
- `admin/palette.html` - Visual preview

## Database Schema

Key tables:
- `restaurants` - Bar information (named for Great Plate compatibility)
- `dishes` - Cocktail details (named for Great Plate compatibility)
- `ratings` - User ratings and reviews
- `profiles` - User profiles
- `user_follows` - Social following relationships
- `reports` - Content moderation reports
- `blocked_users` - User block relationships

## Content Moderation

Clnk includes comprehensive content moderation features:
- Users can report inappropriate reviews
- Admins review reports via the web dashboard
- Reviews can be hidden from public view
- Users can block other users

## License

Copyright © 2024-2026 Clnk. All rights reserved.
