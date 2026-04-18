# ArvyaX_Demo Logo

## Setup Instructions

To add your app logo/icon:

1. **Prepare your logo:**
   - Create or download your logo image
   - Recommended size: 1024x1024 pixels
   - Formats: PNG, JPG (PNG recommended for transparency)
   - Save as `app_icon.png` in this directory

2. **Generate app icons:**
   ```bash
   cd <project_root>
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

3. **The icons will be automatically generated for:**
   - Android: `android/app/src/main/res/mipmap-*/ic_launcher.png`
   - iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

4. **Rebuild your app:**
   ```bash
   flutter clean
   flutter build apk --release
   # or for iOS:
   flutter build ios
   ```

## Current Setup

The app is configured to use:
- Package: `flutter_launcher_icons: ^0.13.1`
- Icon path: `assets/logo/app_icon.png`
- Targets: Android (min SDK 21) and iOS

Place your `app_icon.png` file in this directory and run the flutter_launcher_icons command above.
