# iOS App Icon Switching Troubleshooting Guide

## Known Behavior

On iOS, the app icon change works but requires **a clean build and app relaunch** to be visible. This is due to iOS's icon caching system.

## Steps to Test App Icon Switching

### For Development/Testing:

1. **Clean the build**:
   ```bash
   flutter clean
   cd ios
   rm -rf Pods
   rm Podfile.lock
   cd ..
   ```

2. **Get dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run on iOS device/simulator**:
   ```bash
   flutter run -v
   ```

4. **Switch theme in the app** via the theme selector screen

5. **Manually kill the app** (swipe up on iPhone or use Xcode)

6. **Relaunch the app** - the icon should now display the new theme's icon

### For Release/Production:

The icon switching will work seamlessly after the initial app launch following:
- First install
- Major iOS update
- App update/reinstall

## Technical Details

- **iOS Version**: iOS 10.3+ supports alternate app icons
- **Platform Plugin**: Using `flutter_dynamic_icon` v2.1.0
- **Configuration**: Icons are registered in `ios/Runner/Info.plist` under `CFBundleIcons`
- **Icon Sets**:
  - Primary: `AppIcon.appiconset`
  - Girly Theme: `AppIcon-girly.appiconset`
  - Boy Theme: `AppIcon-boy.appiconset`

## If Icon Still Doesn't Change

1. **Verify Icon Sets Exist**:
   Check `ios/Runner/Assets.xcassets/` contains:
   - `AppIcon.appiconset/`
   - `AppIcon-girly.appiconset/`
   - `AppIcon-boy.appiconset/`

2. **Check Info.plist Configuration**:
   Verify `CFBundleIcons` section has:
   - `CFBundlePrimaryIcon` pointing to `AppIcon`
   - `CFBundleAlternateIcons` with entries for `girly` and `boy`

3. **Rebuild with Xcode**:
   ```bash
   cd ios
   xcodebuild clean -workspace Runner.xcworkspace -scheme Runner
   xcodebuild build -workspace Runner.xcworkspace -scheme Runner
   cd ..
   ```

4. **Check Console Logs**:
   Watch for error messages starting with "Failed to change app icon:"

## Note About the Default Icon

The default icon showing in system dialogs is normal iOS behavior. The actual app icon on the home screen will update after the app is relaunched.
