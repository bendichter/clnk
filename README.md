# 🍽️ Great Plate

A social food discovery app for iOS that helps you find and share amazing dishes at restaurants.

## Features

- 🔍 Discover dishes and restaurants near you
- ⭐ Rate and review dishes
- 📸 Share photos of your food
- 👥 Follow other food lovers
- 🗺️ Explore with interactive maps
- 🚨 Report inappropriate content
- 🚫 Block users for a better experience

## Tech Stack

- **iOS App**: Swift, SwiftUI
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **Admin Dashboard**: HTML/CSS/JavaScript

## Getting Started

### iOS App

1. Clone this repository
2. Open `BiteVue.xcodeproj` in Xcode (project name not changed)
3. Configure Supabase credentials in `BiteVue/Config.swift`
4. Build and run on simulator or device

### Admin Dashboard

The admin dashboard is a web-based content moderation tool located in the `/admin` directory.

**Access the dashboard:**
- Development: Open `admin/index.html` in a web browser
- Production: Can be deployed to GitHub Pages or any static hosting

**Features:**
- 📊 **Stats Overview**: View total restaurants, dishes, ratings, users, reports, and blocks
- 🚨 **Reports Dashboard**: Manage reported reviews with actions to mark as reviewed, dismiss, or hide content
- 🚫 **Blocked Users**: View all user block relationships
- 🔐 **Simple Authentication**: Password-protected access (default: `greatplate2024`)

**Dashboard Configuration:**
- Supabase URL and anon key are configured in `admin/app.js`
- Uses Supabase JS client (loaded via CDN)
- No build step required - pure HTML/CSS/JS

**To deploy admin dashboard to GitHub Pages:**
```bash
# Enable GitHub Pages in repo settings, set source to root/admin folder
# Or use gh-pages branch:
git subtree push --prefix admin origin gh-pages
```

**Security Note:** For production, replace the simple password authentication with Supabase Auth or implement proper admin role-based access control.

## Database Schema

Key tables:
- `restaurants` - Restaurant information
- `dishes` - Dish details linked to restaurants
- `ratings` - User ratings and reviews for dishes
- `profiles` - User profiles
- `reports` - Content moderation reports
- `blocked_users` - User block relationships

See `/database` and `/supabase` directories for schema details.

## Content Moderation

Great Plate includes comprehensive content moderation features:

- Users can report inappropriate reviews
- Admins review reports via the web dashboard
- Reviews can be hidden from public view
- Users can block other users
- See `UGC_COMPLIANCE_README.md` for compliance details

## Documentation

- `UGC_COMPLIANCE_README.md` - User-generated content compliance
- `UGC_IMPLEMENTATION_STATUS.md` - Implementation status of UGC features
- `/docs` - Additional documentation

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

Copyright © 2024-2026 Great Plate. All rights reserved.
