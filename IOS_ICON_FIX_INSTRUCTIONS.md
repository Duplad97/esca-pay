# iOS App Icon Switching - Complete Fix Instructions

If app icons are stuck and not changing between themes, follow these steps:

## Quick Fix (Try This First)

1. **Full Clean Build:**
   ```bash
   cd /Users/david/Projects/EscaPay/esca_pay
   flutter clean
   cd ios
   rm -rf Pods/ Podfile.lock
   cd ..
   flutter pub get
   ```

2. **Delete from Simulator/Device:**
   - Long press the app icon on home screen
   - Tap "Remove App"
   - Confirm deletion

3. **Rebuild and Run:**
   ```bash
   flutter run -v
   ```

4. **Test Icon Switching:**
   - Go to Theme Selector
   - Switch theme
   - Check console for debug logs starting with `[ThemeManager]`
   - Expected log output:
     ```
     [ThemeManager] Attempting to change app icon to: boy
     [ThemeManager] Successfully changed app icon to: boy
     ```
   - Return to home screen and verify icon changed

## If Still Not Working

### Check Xcode Project Settings

1. Open Xcode project:
   ```bash
   open ios/Runner.xcworkspace
   ```
   (Note: Use `.xcworkspace`, not `.xcodeproj`)

2. Verify Icon Assets in Xcode:
   - Select `Runner` project
   - Select `Runner` target
   - Go to Build Phases tab
   - Expand "Copy Bundle Resources"
   - Verify these three icon sets are listed:
     - `AppIcon.appiconset`
     - `AppIcon-girly.appiconset`
     - `AppIcon-boy.appiconset`

3. Check Build Settings:
   - Select Runner target
   - Search for "App Icon"
   - Verify "App Icons and Launch Images Set Name" is set to `AppIcon`

### Verify Info.plist Configuration

The Info.plist should have this structure under `CFBundleIcons`:

```xml
<key>CFBundleIcons</key>
<dict>
    <key>CFBundlePrimaryIcon</key>
    <dict>
        <key>CFBundleIconFiles</key>
        <array>
            <string>AppIcon</string>
        </array>
    </dict>
    <key>CFBundleAlternateIcons</key>
    <dict>
        <key>girly</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>AppIcon-girly</string>
            </array>
        </dict>
        <key>boy</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>AppIcon-boy</string>
            </array>
        </dict>
    </dict>
</dict>
```

## Understanding Icon Switching on iOS

### How It Works

1. **On Startup:**
   - iOS loads the primary icon (`AppIcon`)
   - Theme preference is loaded from SharedPreferences
   - If theme is 'girly', primary icon is already correct - nothing to do
   - If theme is 'boy', alternate icon is set via `FlutterDynamicIcon.setAlternateIconName('boy')`

2. **On Theme Change:**
   - User selects new theme in Theme Selector
   - Theme is saved to SharedPreferences
   - If new theme is 'girly': `setAlternateIconName(null)` → reset to primary icon
   - If new theme is 'boy': `setAlternateIconName('boy')` → switch to alternate icon

3. **Important Notes:**
   - Icon changes require iOS to reload app metadata
   - User must return to home screen to see icon change
   - Icon change doesn't happen while app is in foreground
   - Icon caching is normal on iOS - requires clean install to reset

### Why It Might Get Stuck

1. **Primary Icon Not Set as AppIcon:**
   - If app was on "boy" theme at last uninstall
   - iOS cached the "boy" icon set
   - Reinstalling doesn't clear app data
   - **Solution:** Delete app from device, rebuild, reinstall

2. **Info.plist Mismatch:**
   - Icon set names don't match key names
   - e.g., `CFBundleAlternateIcons/boy` must point to asset set named `AppIcon-boy`
   - **Solution:** Verify Info.plist structure above

3. **Missing Icon Assets:**
   - Icon files not included in app bundle
   - Xcode isn't including AppiconSets in build
   - **Solution:** Run `flutter clean`, rebuild

4. **Flutter Dynamic Icon Plugin Issue:**
   - Plugin version incompatibility
   - Native layer not properly configured
   - **Solution:** Run `flutter pub get` after clean

## Console Debugging

When testing, watch for these debug logs:

**Success Case:**
```
[ThemeManager] Attempting to change app icon to: boy
[ThemeManager] Successfully changed app icon to: boy
```

**Failure Cases:**
```
[ThemeManager] Device does not support alternate icons
  → Device or iOS version doesn't support feature

[ThemeManager] Failed to change app icon: [error details]
  → Plugin error - check error message for details
```

## Last Resort

If nothing works:

1. Create fresh build with new product bundle identifier:
   ```bash
   # Edit ios/Runner.xcodeproj/project.pbxproj
   # Change bundle ID from com.example.escaPay to com.example.escaPay2
   ```

2. Perform clean install with new ID:
   ```bash
   flutter clean
   flutter run
   ```

3. This will force iOS to treat it as a new app, clearing all caches

## Platform Limitations

- **Android:** Does not support alternate app icons in this version of flutter_dynamic_icon
- **iOS:** Requires iOS 10.3+
- **Web:** Not applicable
- **macOS:** Not applicable
- **Linux/Windows:** Not applicable

## Success Criteria

✅ Icon should change when theme is changed
✅ Icon should persist after app restart
✅ Both "girly" and "boy" icons visible when switching themes
✅ Primary "girly" icon visible on first app launch
