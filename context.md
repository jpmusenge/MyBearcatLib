# BearcatLib - Project Context

## Overview
**BearcatLib** is a native iOS library app for Rust College's Leontyne Price Library, built as a senior capstone project by Joseph Musenge. It includes a companion **Librarian Dashboard** web app built with React + TypeScript.

- **iOS App**: SwiftUI + MVVM, Firebase Auth + Firestore backend
- **Web Dashboard**: React 19 + TypeScript + Vite + Tailwind CSS v4 + Firebase JS SDK
- **Firebase Project**: `mybearcatlib` (mybearcatlib.firebaseapp.com)
- **Bundle ID**: com.jmusenge.BearcatLib
- **Min Target**: iOS (iPhone 17 Pro simulator used for testing)

---

## Git Workflow
- **Main branch**: `main` (ahead of origin/main by ~20 commits)
- **Dev branch**: `claude/nervous-blackburn` (git worktree at `.claude/worktrees/nervous-blackburn/`)
- Work is done on the worktree branch, then merged to `main`
- Remote: `origin/main`

---

## Design System (Theme.swift)
- **Primary Color**: Royal Blue `#1A3C8B`
- **Accent Color**: Gold `#D4952A`
- **Font Family**: Avenir Next (all weights)
- **Dark Mode**: AdaptiveColors pattern using `@EnvironmentObject var settings: AppSettings` with `private var dk: Bool { settings.isDarkMode }`
- **Layout**: Theme.Layout constants for padding, corner radius, shadows
- All views follow Apple's Human Interface Guidelines (HIG)

---

## iOS App Architecture

### Project Structure
```
BearcatLib/
├── BearcatLibApp.swift          # App entry point, Firebase init, environment setup
├── Models/
│   ├── Book.swift               # Book data model (UUID id, Firestore fields, location)
│   └── Checkout.swift           # Checkout record (Firestore doc ID, dates, renew tracking)
├── Services/
│   ├── AuthService.swift        # Firebase Auth wrapper (protocol-based)
│   ├── BookService.swift        # Firestore book catalog, real-time listener, deduplication
│   ├── CheckoutService.swift    # Checkout/return/renew operations, real-time listener
│   └── NotificationService.swift # Local push notifications for due date reminders
├── Utilities/
│   ├── AppSettings.swift        # @AppStorage persistence (isDarkMode, notificationsEnabled)
│   ├── Theme.swift              # Colors, fonts, layout constants, AdaptiveColors
│   ├── BearcatLibLogo.swift     # Custom geometric logo component
│   └── SampleData.swift         # LibraryResource model, library announcements
├── ViewModels/
│   └── AuthViewModel.swift      # Auth state machine, form validation, flow routing
└── Views/
    ├── MainTabView.swift        # Tab bar: Home, Search, My Books, Profile
    ├── HomeView.swift           # Browse screen, quick actions, due soon section
    ├── SearchView.swift         # Book search + genre filtering from Firestore
    ├── MyBooksView.swift        # User's checked-out books, renew/return buttons
    ├── ProfileView.swift        # Account info, stats, dark mode toggle, notifications toggle
    ├── NotificationsView.swift  # Due date alerts + library announcements
    ├── BookDetailView.swift     # Full book details + checkout button
    ├── BookCardView.swift       # Reusable book card for grid layouts
    ├── DigitalResourcesView.swift # Library databases/resources with detail views
    ├── TutoringRequestView.swift  # Peer tutoring request form (mailto:)
    ├── BarcodeScannerView.swift   # AVFoundation camera barcode scanner (UIViewControllerRepresentable)
    ├── ISBNScannerView.swift      # Full scanner flow: scanning → found/notFound
    ├── WelcomeView.swift        # Landing screen
    ├── LoginView.swift          # Sign-in (@rustcollege.edu email validation)
    ├── RegisterView.swift       # Account creation
    ├── ForgotPasswordView.swift # Password reset
    └── BookSearch/
        └── BookRowView.swift    # List row component
```

### Key Patterns
- **Environment Objects**: `AppSettings`, `AuthViewModel`, `BookService`, `CheckoutService` injected at app root
- **Singleton Services**: `BookService.shared`, `CheckoutService.shared`, `NotificationService.shared`
- **Real-time Firestore Listeners**: Both BookService and CheckoutService use `addSnapshotListener`
- **Book Deduplication**: BookService groups physical copies by title+author, shows "X of Y available"
- **Auth Flow**: AuthViewModel manages states: `.welcome`, `.login`, `.register`, `.forgotPassword`
- **Email Validation**: Only `@rustcollege.edu` emails allowed for registration

### Firestore Collections
| Collection | Purpose | Key Fields |
|-----------|---------|-----------|
| `books` | Library catalog (~19,800 books from LS2 PAC scraper) | title, author, isbn, genre, isAvailable, floor, section, aisle, shelf, callNumber, barcode, resourceId, collectionName, branchName, status |
| `checkouts` | Active book checkouts | userId, bookFirestoreId, title, author, isbn, checkedOutDate (Timestamp), dueDate (Timestamp), renewCount, isReturned |
| `users` | User profiles | displayName/name, email |

### Book Model (Book.swift)
```swift
struct Book: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String, author: String, isbn: String, genre: String
    let coverImageName: String?, description: String
    let floor: Int, section: String, aisle: String, shelf: String
    var isAvailable: Bool, dueDate: Date?
    // Firestore fields (optional for backward compat)
    var firestoreId: String?, resourceId: Int?, barcode: String?
    var callNumber: String?, collectionName: String?, branchName: String?
    var status: String?, lastUpdated: String?, source: String?
}
```

### Checkout Model (Checkout.swift)
```swift
struct Checkout: Identifiable, Hashable {
    let id: String  // Firestore document ID
    let userId: String, bookFirestoreId: String
    let title: String, author: String, isbn: String
    let checkedOutDate: Date
    var dueDate: Date, renewCount: Int, isReturned: Bool
    // Computed: daysUntilDue, isOverdue, isDueSoon, statusText, canRenew (max 2)
}
```

### Notification System (NotificationService.swift)
- Uses `UNUserNotificationCenter` for local push notifications
- Schedules 4 reminders per checkout: 2 days before, 1 day before, day of, 1 day overdue (all at 9 AM)
- Actionable notifications with "Renew Book" and "View Details" buttons
- Auto-reschedules when checkouts change (triggered from CheckoutService's snapshot listener)
- Toggle in ProfileView controls `notificationsEnabled` in UserDefaults

### ISBN Scanner (BarcodeScannerView + ISBNScannerView)
- AVFoundation's `AVCaptureMetadataOutput` for EAN-13/EAN-8 barcodes
- Camera viewfinder with gold corner guides
- States: `.scanning` → `.found(book)` / `.notFound`
- Shows availability, copy count, location, "View Full Details" button
- Requires physical device (camera not available in simulator)
- `NSCameraUsageDescription` set in project build settings

---

## Librarian Dashboard (Web App)

### Location
`LibrarianDashboard/` in project root

### Tech Stack
- React 19 + TypeScript + Vite 8 + Tailwind CSS v4
- Firebase JS SDK v12 (Auth + Firestore)
- Lucide React for icons

### Structure
```
LibrarianDashboard/
├── package.json
├── vite.config.ts
├── tsconfig.json
└── src/
    ├── main.tsx, App.tsx, index.css
    ├── lib/firebase.ts           # Firebase config (real credentials)
    ├── types/index.ts            # Checkout, Borrower, TabId types
    ├── hooks/
    │   ├── useAuth.ts            # Auth state, sign-in/out
    │   └── useCheckouts.ts       # Real-time checkouts, user name resolution, stats
    └── components/
        ├── LoginPage.tsx         # Librarian sign-in
        ├── Dashboard.tsx         # Main layout with tabs
        ├── Header.tsx            # Branded nav bar
        ├── StatsCards.tsx        # 4 stat cards (active, overdue, due soon, borrowers)
        ├── CheckoutsTable.tsx    # Searchable checkout table with Check In
        ├── BorrowersTable.tsx    # Student overview table
        └── StatusBadge.tsx       # Color-coded due date badge
```

### Features
- Real-time checkout tracking with Firestore `onSnapshot`
- Tabs: All Checkouts, Overdue, Due Soon, Borrowers
- Book check-in (batch write: checkout `isReturned=true` + book `isAvailable=true`)
- User display name caching/resolution
- Search across checkouts and borrowers

### Running the Dashboard
```bash
cd LibrarianDashboard
npm install
npm run dev
```

---

## Prioritized Requirements (Sprint Backlog)

| # | Requirement | Status | Notes |
|---|------------|--------|-------|
| 1 | Connecting the Real Library Book Catalog | DONE | 19,800 books from LS2 PAC scraper in Firestore |
| 2 | Student Sign-In and Account Creation | DONE | Firebase Auth, @rustcollege.edu validation |
| 3 | Live Book Availability Updates | DONE | Real-time Firestore snapshot listeners |
| 4 | My Profile Saves Between Sessions | DONE | @AppStorage persistence, dynamic stats |
| 5 | Reminders Before Books Are Due | DONE | Local push notifications (2d, 1d, day-of, overdue) |
| 6 | Reserve a Book and Join a Waitlist | NOT STARTED | 48-hour hold, waitlist with notifications |
| 7 | Library Staff Book Management | PARTIALLY DONE | React dashboard built; needs: add/edit books, full CRUD |
| 8 | Searching the Full Library Catalog | DONE | Real-time search with genre filtering, deduplication |
| 9 | Up-to-Date Library Resources and Services | DONE | Resources view with working links, detail views, tutoring form, MAGNOLIA |
| 10 | Scan a Book to Look It Up | DONE | AVFoundation barcode scanner, ISBN lookup |

---

## Current State & Known Issues

### Active Issue: EXC_BAD_ACCESS Crash
- **Symptom**: App builds successfully but crashes on simulator launch with `EXC_BAD_ACCESS (code=1, address=0x18)` in HomeView at `settings.isDarkMode`
- **Root Cause**: Corrupted Xcode derived data from unexpected MacBook shutdown (NOT a code bug)
- **Error in Xcode**: `HomeView.o GetDIE for DIE 0x... is outside of its CU 0x...` (debug info corruption)
- **Fix**: Clean derived data:
  1. Xcode: Product → Clean Build Folder (⇧⌘K)
  2. Quit Xcode
  3. Terminal: `rm -rf ~/Library/Developer/Xcode/DerivedData`
  4. Reopen project and rebuild

### Recent Code Fix Applied (not yet tested due to crash)
- Removed unused `@State private var checkoutCancellable: AnyCancellable?` from BearcatLibApp.swift
- Removed `import Combine` from BearcatLibApp.swift
- Moved `.onReceive(checkoutService.$userCheckouts)` notification rescheduling into CheckoutService's snapshot listener (reads `notificationsEnabled` directly from UserDefaults)
- Added `UserDefaults.standard.register(defaults: ["notificationsEnabled": true])` in app init

### Uncommitted Changes (on claude/nervous-blackburn)
- `BearcatLib/BearcatLibApp.swift` - Removed Combine import, unused state, moved onReceive
- `BearcatLib/Services/CheckoutService.swift` - Added notification rescheduling in snapshot listener

### Main Branch Uncommitted Changes
- `LibrarianDashboard/src/components/Header.tsx` - Modified
- `LibrarianDashboard/src/components/LoginPage.tsx` - Modified
- `LibrarianDashboard/src/components/StatsCards.tsx` - Modified
- `LibrarianDashboard/src/components/Logo.tsx` - New (untracked)

---

## Next Features to Implement

### 1. Reserve a Book / Waitlist (Requirement #6)
- Add "Reserve" button on BookDetailView when book is unavailable
- Create `reservations` Firestore collection
- 48-hour hold timer with auto-release
- Waitlist queue with position tracking
- Push notification when reserved book becomes available

### 2. Complete Librarian Dashboard (Requirement #7)
- Add book CRUD (add new books, edit book info)
- Manage reservations/waitlist
- View overdue analytics
- Possibly add librarian role verification

### 3. Additional Enhancements
- Book cover images (currently placeholder)
- Reading history / past checkouts
- Fine calculation system
- App onboarding flow
- Testing on physical device (required for barcode scanner)

---

## Firebase Configuration

### iOS (GoogleService-Info.plist)
- Project: mybearcatlib
- Bundle ID: com.jmusenge.BearcatLib

### Web (LibrarianDashboard)
```typescript
{
  apiKey: "AIzaSyBmDqnq2JsV6UTO-DWFSj_RNxt3OoWa_VA",
  authDomain: "mybearcatlib.firebaseapp.com",
  projectId: "mybearcatlib",
  storageBucket: "mybearcatlib.firebasestorage.app",
  messagingSenderId: "509579807960",
  appId: "1:509579807960:web:0b7b9c5e7885e4559fdbad",
  measurementId: "G-J70YZ7Q2PY"
}
```

### Firestore Free Tier Limits
- 50,000 reads/day, 20,000 writes/day, 20,000 deletes/day
- Each snapshot listener re-read on app launch counts toward reads (~19,800 for books collection)

---

## Important Conventions

- **Never "vibe code"** - User explicitly rejected vibe-coded designs. All UI must follow the established Theme system and Apple HIG
- **Dark mode**: Always use AdaptiveColors pattern with `dk` computed property
- **Environment objects**: AppSettings, AuthViewModel, BookService, CheckoutService must be passed via `.environmentObject()`
- **Email domain**: All user accounts must be `@rustcollege.edu`
- **Loan period**: 14 days, max 2 renewals per checkout
- **Library name**: Leontyne Price Library at Rust College
