# UGC Compliance Implementation for BiteVue

## Overview
This implementation adds User-Generated Content (UGC) compliance features to meet App Store Guidelines 1.2, which requires apps with user-generated content to provide mechanisms for reporting, blocking, and filtering inappropriate content.

## Features Implemented

### 1. Report Review ✅
- **Location**: Review cards in `DishDetailView` and `ActivityCard`
- **UI**: Three-dot menu button (⋮) on each review
- **Modal**: `ReportReviewView.swift` with predefined report reasons
- **Report Reasons**:
  - Inappropriate content
  - Spam
  - False information
  - Harassment
  - Other (with text field for details)

### 2. Block User ✅
- **Location**: User profile pages (`UserProfileView`)
- **UI**: Menu button in navigation bar with "Block User" option
- **Features**:
  - Block/unblock users
  - Confirmation alerts
  - Blocked users list management
  - Reviews from blocked users are hidden throughout the app

### 3. Content Filtering ✅
- **Implementation**: 
  - `RestaurantViewModel.blockedUserIds: Set<UUID>`
  - All views filter out blocked users' reviews automatically
  - Filtering applied in:
    - `DishDetailView` (review list)
    - `ActivityView` (community feed)
    - `UserProfileView` (user's reviews)
    - Search results

### 4. Blocked Users Management ✅
- **Location**: Profile tab → Settings → "Blocked Users"
- **View**: `BlockedUsersView.swift`
- **Features**:
  - List all blocked users
  - Unblock users with confirmation
  - Empty state when no users blocked
  - Info banner explaining blocking behavior

## Files Created

### Views
1. **`BiteVue/Views/ReportReviewView.swift`**
   - Full-screen modal for reporting reviews
   - Radio button selection for report reasons
   - Text field for additional details
   - Preview of the review being reported

2. **`BiteVue/Views/BlockedUsersView.swift`**
   - List view of blocked users
   - Unblock functionality
   - Empty state UI

### Database Schema
1. **`database/ugc_compliance_schema.sql`**
   - SQL schema for Supabase
   - Creates `reports` and `blocked_users` tables
   - Includes RLS policies for security
   - Optional auto-moderation trigger (commented out)

## Files Modified

### ViewModels
1. **`BiteVue/ViewModels/RestaurantViewModel.swift`**
   - Added `blockedUserIds: Set<UUID>`
   - Added `loadBlockedUsers()` / `saveBlockedUsers()`
   - Added `blockUser(_:)` / `unblockUser(_:)`
   - Added `reportReview(ratingId:reason:details:)`
   - Added `isUserBlocked(_:)` helper
   - Added `filteredRatings(for:)` method

### Services
2. **`BiteVue/Services/SupabaseService.swift`**
   - Added UGC compliance models:
     - `NewBlockedUser`, `SupabaseBlockedUser`
     - `NewReport`, `SupabaseReport`
   - Added methods:
     - `fetchBlockedUsers()`
     - `blockUser(userId:)`
     - `unblockUser(userId:)`
     - `reportReview(ratingId:reason:details:)`

### Views
3. **`BiteVue/Views/DishDetailView.swift`**
   - Added report menu to `ReviewCard`
   - Added `showReportSheet` state
   - Filter blocked users in `sortedRatings`
   - Sheet presentation for `ReportReviewView`

4. **`BiteVue/Views/MainTabView.swift`**
   - Added report menu to `ActivityCard`
   - Added navigation to user profile from avatar
   - Filter blocked users in `ActivityView`

5. **`BiteVue/Views/UserProfileView.swift`**
   - Added block/unblock menu in toolbar
   - Added confirmation alerts
   - Filter out blocked users' reviews

6. **`BiteVue/Views/ProfileView.swift`**
   - Added "Blocked Users" option in Settings
   - Sheet presentation for `BlockedUsersView`

## Database Setup

### Step 1: Run SQL Schema
1. Open Supabase Dashboard
2. Navigate to SQL Editor
3. Copy contents of `database/ugc_compliance_schema.sql`
4. Run the SQL script

### Step 2: Verify Tables
```sql
-- Check if tables were created
SELECT * FROM reports LIMIT 1;
SELECT * FROM blocked_users LIMIT 1;
```

### Step 3: Test Functionality
The schema includes RLS policies that ensure:
- Users can only report content when authenticated
- Users can only view their own reports
- Users can only block/unblock for themselves
- Blocked user relationships are unique

## Data Persistence

### Local Storage (UserDefaults)
- **Blocked Users**: Cached locally for offline support
- **Key**: `"blockedUserIds"`
- **Sync**: Automatically syncs with Supabase when online

### Supabase Storage
- **Reports Table**: All reports stored permanently
- **Blocked Users Table**: User blocking relationships
- **Automatic**: Syncs on app launch and after each action

## Testing Checklist

### Report Review
- [ ] Report button appears on other users' reviews
- [ ] Report button hidden on own reviews
- [ ] All report reasons selectable
- [ ] "Other" reason shows text field
- [ ] Report submits successfully
- [ ] Modal dismisses after submission

### Block User
- [ ] Block button appears in user profile menu
- [ ] Block button hidden on own profile
- [ ] Confirmation alert shows before blocking
- [ ] User appears in "Blocked Users" list
- [ ] Blocked user's reviews disappear immediately
- [ ] Unblock works correctly

### Content Filtering
- [ ] Blocked users' reviews hidden in dish detail
- [ ] Blocked users' reviews hidden in activity feed
- [ ] Blocked users' reviews hidden in search
- [ ] Rating counts reflect filtered reviews
- [ ] App doesn't crash with no reviews after filtering

### Blocked Users Management
- [ ] "Blocked Users" appears in Profile → Settings
- [ ] List shows all blocked users
- [ ] Unblock button works
- [ ] Empty state shows when no blocked users
- [ ] Changes reflect immediately across app

## Build & Verify

### Build Command
```bash
cd ~/.openclaw/workspace/BiteVue && \
xcodebuild -project BiteVue.xcodeproj \
  -scheme BiteVue \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```

### Expected Result
- ✅ Build succeeds with no errors
- ✅ All new views compile
- ✅ No missing imports

## App Store Compliance

### Guideline 1.2 Requirements
✅ **"A method for filtering objectionable material"**
   - Content filtering based on blocked users
   - Reviews from blocked users hidden throughout app

✅ **"A mechanism to report offensive content and timely responses to concerns"**
   - Report button on every review
   - Reports stored with reason and details
   - Ready for moderation workflow

✅ **"The ability to block abusive users from the service"**
   - Block user from profile
   - Blocked users list management
   - Unblock functionality

✅ **"Published contact information so users can easily reach you"**
   - Add support email in Settings → Help & Support
   - Recommended: support@bitevue.com

## Future Enhancements (Optional)

### 1. Auto-Moderation
Uncomment the trigger in `ugc_compliance_schema.sql` to automatically hide reviews with 3+ reports:
```sql
-- Auto-hide ratings with multiple reports
CREATE TRIGGER trigger_check_rating_reports...
```

### 2. Moderation Dashboard
Create an admin panel to:
- Review pending reports
- Take action on reported content
- Ban users system-wide
- View moderation statistics

### 3. In-App Appeals
Allow users to:
- Appeal blocked status
- Contest report decisions
- Request review of hidden content

### 4. Email Notifications
Notify users when:
- Their content is reported
- Their report is reviewed
- Action is taken on their report

## Notes

### Performance
- Filtering is client-side for now
- For large apps, consider server-side filtering
- Blocked user IDs cached locally for instant filtering

### Privacy
- Reports are private (only visible to reporter and admins)
- Blocked relationships are private (blocked user not notified)
- No public "blocked by" counters

### Security
- Row Level Security (RLS) enabled on all tables
- Users can only manage their own blocks/reports
- Admin policies commented out (add role-based access as needed)

## Support

For issues or questions:
1. Check Supabase logs for errors
2. Verify RLS policies are active
3. Test with multiple user accounts
4. Check console for sync errors

## License
This implementation is part of BiteVue and follows the same license.
