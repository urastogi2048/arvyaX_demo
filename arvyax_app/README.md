# ArvyaX - Mindfulness Sessions App

A Flutter app for immersive nature-based meditation sessions with journaling.

## How to Run

```bash
cd arvyax_app

# Install dependencies
flutter pub get

# Generate code (Hive adapters)
flutter pub run build_runner build

# Run on device/emulator
flutter run

# Build APK
flutter build apk --release
```

Output APK: `build/app/outputs/apk/release/app-release.apk`

---

## Architecture

### Folder Structure

```
lib/
├── main.dart                    # App entry point, lifecycle handling
├── core/
│   └── providers/               # Riverpod state management
├── data/
│   ├── models/                  # Ambience, Session, JournalEntry
│   └── repositories/            # Data access layer
├── features/
│   ├── ambience/               # Browse & filter ambiences
│   ├── player/                 # Session playback (full screen + mini player)
│   └── journal/                # Reflection & history
└── shared/
    ├── theme/                  # Colors, typography
    └── widgets/                # Reusable UI components
```

### State Management: Riverpod

Why Riverpod? Compile-safe, testable, no BuildContext needed for logic.

**Pattern:**
- `StateNotifierProvider` - Mutable state (sessions, journal entries)
- `FutureProvider` - Async data loading (ambiences from JSON)
- Notifier classes hold business logic (timers, audio control, persistence)

**Data Flow:**
```
User Action → Notifier Method → State Update → UI Rebuilds
                ↓
        Save to Hive (persistence)
```

Example: Starting a session
1. User taps "Start" button
2. UI calls `ref.read(sessionProvider.notifier).startSession(ambience)`
3. SessionNotifier creates SessionModel, starts timer, plays audio
4. Session saved to Hive
5. PlayerScreen watches sessionProvider → rebuilds with new elapsed time

### Key Design Decisions

- **Timer in provider, not widget** - Survives screen navigation, background
- **Audio in provider** - Pause/resume from MiniPlayer on Home screen works
- **Session persistence** - App closed? Timer resumes where it left off
- **Auto-navigation** - Session complete → auto-navigate to Journal
- **Lifecycle validation** - App resumes → checks if session expired

---

## Packages Used

| Package | Why |
|---------|-----|
| **flutter_riverpod** (3.3.1) | Type-safe state management. Business logic stays in Notifier classes, not widgets. |
| **just_audio** (0.10.5) | Reliable audio playback with looping. Persists across background. |
| **hive** + **hive_flutter** (2.2.3, 1.1.0) | Fast local persistence. Stores sessions, journal entries. No internet needed. |
| **intl** (0.20.2) | Date formatting. Shows "MMM dd, yyyy • HH:mm" in journal. |
| **simple_animations** (5.2.0) | Breathing animation overlay. Smooth opacity curves. |
| **flutter_screenutil** (5.9.0) | Responsive UI on all phone sizes. Scales text, padding, icons. |
| **flutter_launcher_icons** (0.13.1) | Auto-generates app icons. One command generates Android & iOS. |

---

## Tradeoffs

### What Works Now
- All core features (browse → session → journal → history)
- Session timer persists across app close
- Audio plays and loops
- Responsive design on all screens
- Clean, testable architecture

### What Would Improve with 2 More Days

1. **Analytics Dashboard** - Track: sessions started, completed, mood trends
   - Currently logs to Hive, no UI to view it

2. **Dark Mode** - Theme tokens ready, just need toggle + persistence
   - Would take 2 hours

3. **Push Notifications** - "Time for your daily session"
   - Would integrate Firebase Cloud Messaging

4. **Widget/Shortcut** - Quick session start from home screen
   - Android only, 1-2 hours

5. **Music Selection** - Let users pick background music instead of just ambience
   - UI already designed, needs audio mixing

6. **Export Journal** - PDF or CSV of reflections
   - Would use `pdf` package

### Known Limitations

- **No offline JSON loading** - Ambiences loaded from assets/data/ambiences.json at startup
- **No backend sync** - Journal only stores locally, no cloud backup
- **No user accounts** - Single user per device
- **No haptic feedback** - Could add vibration on play/pause (1 hour)
- **Accessibility** - Could be better for screen readers (text sizes are responsive though)

---

## Testing the App

### Manual Scenarios

1. **Session Persistence**
   - Start session → Wait 10 sec → Close app → Reopen → Timer continues ✓

2. **MiniPlayer Control**
   - Start session → Go to Home → Play/pause from MiniPlayer works ✓
   - Timer updates on both PlayerScreen and MiniPlayer ✓

3. **Session End Flow**
   - Start session → Click "End" → Confirm → Journal screen appears ✓
   - Save reflection → Appears in History ✓

4. **Navigation**
   - Home → Details → Player → Journal → History → Back to Home ✓
   - All buttons work, no infinite loops

---

## Build Size

- APK: 61 MB (includes all ambience audio)
- Could shrink with code splitting or removing some ambiences

---

## Contact

Built for ArvyaX interview assignment.
