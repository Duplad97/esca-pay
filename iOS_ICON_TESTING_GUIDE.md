# iOS App Icon Switching - Testing & Verification

## Overview
This guide provides step-by-step instructions to verify iOS app icon switching is working correctly.

## Prerequisites
- Physical iOS device running iOS 10.3 or later (iPhone 13+ recommended)
- Device connected via USB or wireless to Mac
- Developer Mode enabled on device
- Xcode installed with valid provisioning profiles

## Test Procedure

### Phase 1: Clean Build

**Step 1a:** Remove cached builds
```bash
cd /Users/david/Projects/EscaPay/esca_pay
flutter clean
```

**Step 1b:** Remove iOS build artifacts
```bash
cd ios
rm -rf Pods
rm -rf Podfile.lock
cd ..
```

**Step 1c:** Get fresh dependencies
```bash
flutter pub get
```

**Expected Result:** No errors, dependencies resolved successfully

### Phase 2: Uninstall Previous App

**Step 2a:** On your iOS device
- Long press the EscaPay app icon on home screen
- Tap "Remove App"
- Select "Remove" (not "Move to App Library")
- Wait for app to disappear

**Expected Result:** App completely removed from device

### Phase 3: Fresh Installation

**Step 3a:** Identify your device
```bash
flutter devices
```
Look for your device in the output. Note the device ID (e.g., `00008110-001A18403EDA401E`)

**Step 3b:** Build and install
```bash
flutter run -d <your-device-id> -v
```
Replace `<your-device-id>` with your actual device ID

**Expected Result:**
- App builds without errors
- App installs on device
- App launches
- Home screen shows app with "girly" icon (primary icon)
- Console shows no errors

### Phase 4: Test Icon Switching

**Step 4a:** Test switching FROM "girly" TO "boy"

1. In the app, navigate to **Theme Selector** page (typically bottom navigation)
2. Look at the two theme options - one should show checkmark (girly)
3. Tap on the "boy" theme card (blue one)
4. Watch the Xcode console for these logs:
   ```
   [ThemeManager] Attempting to change app icon to: boy
   [ThemeManager] Successfully changed app icon to: boy
   ```
   ✅ If you see these logs → Code executed successfully

5. **Return to home screen** (double-tap or swipe up from bottom)
6. Look at the app icon on home screen
7. ✅ Icon should change from pink/girly to blue/boy

**Expected Result:**
- Console shows both success messages
- App icon on home screen changes to "boy" (blue) icon
- No error messages in console

**Step 4b:** Test switching FROM "boy" BACK TO "girly"

1. Open the app again
2. Go back to Theme Selector
3. Verify "boy" theme now has the checkmark
4. Tap on "girly" theme (pink one)
5. Watch console for:
   ```
   [ThemeManager] Attempting to change app icon to: girly
   [ThemeManager] Setting to primary icon (girly is default)
   [ThemeManager] Successfully changed app icon to: girly
   ```

6. **Return to home screen**
7. ✅ Icon should change back to pink/girly icon

**Expected Result:**
- Console shows success messages including "Setting to primary icon" line
- App icon on home screen changes back to "girly" (pink) icon
- No error messages

**Step 4c:** Test repeated switching

1. Switch to "boy" → return home → verify icon
2. Switch to "girly" → return home → verify icon
3. Repeat 2-3 times

**Expected Result:**
- Icon changes correctly each time
- Each theme change produces appropriate console logs
- No degradation in switching behavior

### Phase 5: Test Theme Persistence

**Step 5a:** Set theme to "boy"
1. In app, switch to "boy" theme
2. Return to home screen
3. Verify icon is "boy"

**Step 5b:** Force close and reopen app
1. Swipe app up in App Switcher to force close
2. Tap app icon to reopen
3. ✅ App should open with "boy" theme
4. ✅ App icon on home screen should still be "boy"

**Expected Result:**
- Theme persists after app restart
- Icon remains "boy" after restart
- Console shows theme was loaded from preferences

**Step 5c:** Restart device (hard reset)
1. Force restart device
2. Unlock device
3. Open app
4. ✅ Theme should still be "boy"
5. ✅ Icon should still be "boy"

**Expected Result:**
- Theme persists across device restarts
- Icon persists across device restarts
- No loss of preference data

### Phase 6: Console Log Analysis

**Success Logs to Expect:**
```
[ThemeManager] Attempting to change app icon to: boy
[ThemeManager] Successfully changed app icon to: boy
```

**Or for girly theme:**
```
[ThemeManager] Attempting to change app icon to: girly
[ThemeManager] Setting to primary icon (girly is default)
[ThemeManager] Successfully changed app icon to: girly
```

**Error Logs (if present) to Investigate:**
```
[ThemeManager] Device does not support alternate icons
  → Device running iOS version < 10.3
  → Device is simulator (doesn't support alternate icons)

[ThemeManager] Failed to change app icon: [error message]
  → Check error message for details
  → May indicate plugin issue or permission problem
```

## Troubleshooting During Testing

### Issue: App Icon Doesn't Change

**Possible Cause 1: Wrong iOS Version**
- **Fix:** Verify device is iOS 10.3+
  - Go to Settings > General > About
  - Check "Software Version"
  - If < 10.3, update iOS

**Possible Cause 2: Using Simulator**
- **Fix:** Test on physical device
  - iOS simulator doesn't support alternate icons
  - Use `flutter devices` to list physical devices

**Possible Cause 3: Icon Still Showing in App Cache**
- **Fix:** Force close app from App Switcher
  - Double-tap home button
  - Swipe app up to close
  - Tap icon to reopen

**Possible Cause 4: Info.plist Not Loaded**
- **Fix:** Clean build
  ```bash
  flutter clean
  cd ios && rm -rf Pods/ Podfile.lock && cd ..
  flutter run -d <device-id>
  ```

### Issue: Console Shows Error

**Error: "Device does not support alternate icons"**
- Device is simulator or iOS < 10.3
- Switch to physical device or update iOS

**Error: "Failed to change app icon: ..."**
- Check the specific error message
- May indicate plugin issue: Try `flutter pub get`
- May indicate icon asset missing: Check Info.plist matches actual icon set names

### Issue: App Crashes on Theme Change

**Possible Causes:**
1. Theme name doesn't match icon name in Info.plist
2. Icon asset file missing
3. Plugin compatibility issue

**Troubleshooting:**
1. Check console for exception details
2. Verify icon sets exist: `ls ios/Runner/Assets.xcassets/ | grep AppIcon`
3. Verify theme names match icon keys in Info.plist

### Issue: Icon Changed but Other Screens Didn't Update

**This is expected behavior!** 
- Icon change is independent of app theme colors
- App theme colors (background, text, etc.) are handled by ThemeManager.themeData
- Icon is just the home screen icon appearance
- App should show new colors if you switch themes properly

## Success Criteria

✅ **Test Passed If:**
1. Icon changes when theme changes
2. Icon changes visible on home screen (not in-app)
3. Both "girly" → "boy" and "boy" → "girly" switching work
4. Icon persists after app restart
5. Icon persists after device restart
6. Console shows success logs without errors
7. No crashes during theme switching
8. Repeated switching works (tested 2-3 times)

✅ **Complete Success:**
- All criteria above met
- Icon switching works reliably
- No errors in console
- App theme colors also change appropriately

## If All Tests Pass

Document results:
```
iOS App Icon Switching: ✅ WORKING
Device: iPhone 13, iOS 26.2
Date: [current date]
Tested Switching: girly ↔ boy (3 times)
Console Logs: ✅ All success
Theme Persistence: ✅ After restart
Home Screen Icon: ✅ Changes correctly
No Errors: ✅ Confirmed
```

## If Tests Fail

Before giving up, try:

1. **Full Clean:**
   ```bash
   flutter clean
   cd ios
   rm -rf Pods Podfile.lock
   rm -rf .symlinks/
   rm -rf Flutter/Flutter.framework
   rm -rf Flutter/Flutter.podspec
   cd ..
   flutter pub get
   ```

2. **Rebuild Pods:**
   ```bash
   cd ios
   pod install --repo-update
   cd ..
   ```

3. **Completely Remove App:**
   - Long press → Remove App → Remove
   - Wait 30 seconds
   - Fresh install: `flutter run -d <device-id>`

4. **Check Xcode Project:**
   ```bash
   open ios/Runner.xcworkspace
   ```
   - Select Runner target
   - Build Phases → Copy Bundle Resources
   - Verify AppIcon.appiconset, AppIcon-girly.appiconset, AppIcon-boy.appiconset are listed

5. **Nuclear Option (Last Resort):**
   ```bash
   flutter clean
   rm -rf ios/Pods ios/Podfile.lock ios/.symlinks ios/Flutter/Flutter.framework ios/Flutter/Flutter.podspec
   flutter pub get
   flutter run -d <device-id>
   ```

## Additional Resources

- Xcode Console View: View → Navigators → Show Debugger
- Filter console logs: Type `ThemeManager` in console search
- Full Xcode logs: Product → Scheme → Edit Scheme → Logging options
- Apple Developer Docs: https://developer.apple.com/documentation/uikit/uiapplication/alternateicon

## Notes

- Icon changes require returning to home screen (iOS limitation)
- Icon changes don't interrupt app function
- Multiple icon changes in succession may take a moment
- Icon caching is normal on iOS devices
- Full uninstall/reinstall clears all caches
