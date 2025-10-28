# Build Information

This document provides comprehensive instructions for building My Todo App for various platforms including Android, iOS, Web, and Desktop (Windows, macOS, Linux).

## Introduction

My Todo App is built with Flutter, which enables cross-platform development from a single codebase. This guide will walk you through building the application for different target platforms.

## Prerequisites

Before building the app, ensure you have the following installed:

### Required Software

- **Flutter SDK** (version 3.0.0 or higher)
  - Download from: https://flutter.dev/docs/get-started/install
  - Verify installation: `flutter doctor`

- **Dart SDK** (bundled with Flutter)
  - Verify installation: `dart --version`

- **Git** (for version control)
  - Download from: https://git-scm.com/downloads

### Platform-Specific Requirements

- **Android**: Android Studio, Android SDK, Java Development Kit (JDK)
- **iOS**: macOS with Xcode (Mac only)
- **Web**: Chrome browser (for testing)
- **Desktop**: Platform-specific development tools
  - Windows: Visual Studio 2022 or higher
  - macOS: Xcode command line tools
  - Linux: Clang, CMake, GTK development headers

### Verify Your Setup

Run the Flutter doctor command to check your environment:

```bash
flutter doctor -v
```

This will show you what's installed and what's missing. Install any missing components before proceeding.

## Building for Android

### APK Build (Debug)

To build a debug APK for testing:

```bash
flutter build apk --debug
```

**Build output location:**
- `build/app/outputs/flutter-apk/app-debug.apk`

### APK Build (Release)

To build a release APK for distribution:

```bash
flutter build apk --release
```

**Build output location:**
- `build/app/outputs/flutter-apk/app-release.apk`

**Note**: For release builds, you should sign the APK with a keystore. See [Flutter's Android deployment guide](https://flutter.dev/docs/deployment/android) for details.

### App Bundle (Recommended for Google Play)

To build an Android App Bundle (AAB) for Google Play Store:

```bash
flutter build appbundle --release
```

**Build output location:**
- `build/app/outputs/bundle/release/app-release.aab`

### Building via Android Studio

1. Open the project in Android Studio
2. Select **Build > Flutter > Build APK** from the menu
3. Wait for the build to complete
4. Find the APK in `build/app/outputs/flutter-apk/`

### Installing APK on Device

To install the APK directly on a connected device:

```bash
flutter install
```

Or manually install using ADB:

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Building for iOS

### Requirements

- **macOS** operating system
- **Xcode** (latest stable version recommended)
- **CocoaPods** (install via: `sudo gem install cocoapods`)
- **Apple Developer Account** (for device testing and App Store deployment)

### IPA Build (Debug)

To build a debug IPA:

```bash
flutter build ios --debug --no-codesign
```

### IPA Build (Release)

To build a release IPA for distribution:

```bash
flutter build ios --release
```

**Build output location:**
- `build/ios/iphoneos/Runner.app`

### Building via Xcode

1. Open the iOS project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Select your target device or simulator

3. Click **Product > Build** or press `Cmd + B`

4. For archiving: **Product > Archive**

### Installing on iOS Device

Connect your iOS device and run:

```bash
flutter run --release
```

Or deploy via Xcode by selecting your device and clicking the Run button.

## Building for Web

### Web Build (Release)

To build an optimized web version:

```bash
flutter build web --release
```

**Build output location:**
- `build/web/`

### Web Build (Debug)

For development builds with debugging enabled:

```bash
flutter build web --debug
```

### Serve Locally for Testing

To run the web app locally for testing:

```bash
# Run in development mode
flutter run -d chrome

# Or serve the built files
cd build/web
python -m http.server 8000
# Then open http://localhost:8000 in your browser
```

### Deploying to Web Hosting

After building, upload the contents of `build/web/` to your web hosting service:

- **GitHub Pages**: Use `gh-pages` branch
- **Firebase Hosting**: Use `firebase deploy`
- **Netlify/Vercel**: Drag and drop the `build/web` folder

## Building for Desktop

### Windows

#### Build for Windows

```bash
flutter build windows --release
```

**Build output location:**
- `build/windows/runner/Release/`

The executable file will be named `my_todo_app.exe`.

#### Running Windows Build

Navigate to the build directory and run:

```bash
.\build\windows\runner\Release\my_todo_app.exe
```

### macOS

#### Build for macOS

```bash
flutter build macos --release
```

**Build output location:**
- `build/macos/Build/Products/Release/my_todo_app.app`

#### Running macOS Build

```bash
open build/macos/Build/Products/Release/my_todo_app.app
```

### Linux

#### Build for Linux

```bash
flutter build linux --release
```

**Build output location:**
- `build/linux/x64/release/bundle/`

#### Running Linux Build

```bash
./build/linux/x64/release/bundle/my_todo_app
```

## Testing Checklist

Before releasing any build, ensure you complete the following tests:

### Functionality Tests

- [ ] **Add new todo**: Create a new todo item successfully
- [ ] **Delete todo**: Remove an existing todo item
- [ ] **Edit todo** (if applicable): Modify todo text or status
- [ ] **Mark complete/incomplete**: Toggle todo completion status
- [ ] **Persistence**: Todos are saved and restored after app restart
- [ ] **Empty state**: App displays appropriate message when no todos exist

### UI/UX Tests

- [ ] **Responsive design**: UI adapts to different screen sizes
- [ ] **Button interactions**: All buttons are clickable and responsive
- [ ] **Input validation**: Appropriate error messages for invalid input
- [ ] **Loading states**: Loading indicators appear when needed
- [ ] **Animations**: Smooth transitions and animations work correctly
- [ ] **Accessibility**: Screen readers can navigate the app (if implemented)

### Performance Tests

- [ ] **App launch time**: App starts within reasonable time (< 3 seconds)
- [ ] **Smooth scrolling**: List scrolls smoothly with many items (50+ todos)
- [ ] **Memory usage**: No memory leaks during extended use
- [ ] **Battery usage**: Reasonable battery consumption on mobile devices

### Network Tests (If Applicable)

- [ ] **API connectivity**: App connects to backend successfully
- [ ] **Timeout handling**: Graceful handling of network timeouts
- [ ] **Offline mode**: App functions offline (if supported)
- [ ] **Error messages**: Clear error messages for network failures

### Platform-Specific Tests

- [ ] **Android**: Test on Android 8.0+ devices
- [ ] **iOS**: Test on iOS 12+ devices
- [ ] **Web**: Test on Chrome, Firefox, Safari
- [ ] **Desktop**: Test window resizing and keyboard shortcuts

## Troubleshooting

### Common Build Issues

#### Issue: "Flutter SDK not found"

**Solution:**
```bash
# Add Flutter to your PATH
export PATH="$PATH:/path/to/flutter/bin"

# Verify Flutter is accessible
flutter doctor
```

#### Issue: "Gradle build failed" (Android)

**Solution:**
```bash
# Clean build cache
flutter clean

# Get dependencies again
flutter pub get

# Rebuild
flutter build apk
```

#### Issue: "CocoaPods not installed" (iOS)

**Solution:**
```bash
# Install CocoaPods
sudo gem install cocoapods

# Install pods
cd ios
pod install
cd ..
```

#### Issue: "Out of memory" during build

**Solution:**
```bash
# Increase Gradle memory (Android)
# Edit android/gradle.properties and add:
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m
```

#### Issue: Web build fails with "webdev not found"

**Solution:**
```bash
# Activate webdev
flutter pub global activate webdev

# Add to PATH
export PATH="$PATH:$HOME/.pub-cache/bin"
```

#### Issue: Desktop build fails with missing dependencies

**Solution:**

**Windows:**
- Install Visual Studio 2022 with C++ desktop development tools

**Linux:**
```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

**macOS:**
```bash
xcode-select --install
```

## Development Build Performance Tips

To improve build performance during development:

### 1. Use Debug Builds

Debug builds are faster and include debugging tools:

```bash
flutter run --debug
```

### 2. Enable Hot Reload

Use hot reload to see changes instantly without rebuilding:

- Press `r` in the terminal while the app is running
- Or use your IDE's hot reload button

### 3. Use Hot Restart

For larger changes that need a full restart:

- Press `R` in the terminal while the app is running

### 4. Clean Build Cache Periodically

Clean the build cache when switching between platforms:

```bash
flutter clean
flutter pub get
```

### 5. Use Build Variants

For Android, use build variants to speed up development:

```bash
# Build only for your device's architecture
flutter build apk --target-platform android-arm64
```

### 6. Optimize Dependencies

Remove unused dependencies from `pubspec.yaml` to reduce build time.

### 7. Use Incremental Builds

Flutter uses incremental builds by default, but ensure you're not doing full rebuilds unnecessarily.

## Build Size Optimization

To reduce the size of production builds:

### Android

```bash
# Build separate APKs per ABI
flutter build apk --split-per-abi
```

### Web

```bash
# Build with optimizations
flutter build web --release --tree-shake-icons
```

### General Tips

- Remove unused assets and dependencies
- Use vector graphics (SVG) instead of raster images where possible
- Enable code shrinking and obfuscation for release builds
- Use lazy loading for large resources

## Additional Resources

- **Flutter Documentation**: https://flutter.dev/docs
- **Flutter Build & Release**: https://flutter.dev/docs/deployment
- **Platform Integration**: https://flutter.dev/docs/development/platform-integration
- **Performance Best Practices**: https://flutter.dev/docs/perf/best-practices

---

**Note**: Build times and output locations may vary depending on your Flutter version and configuration. Always refer to the official Flutter documentation for the most up-to-date information.

For questions or issues not covered in this guide, please open an issue on GitHub or consult the [CONTRIBUTING.md](CONTRIBUTING.md) guide.
