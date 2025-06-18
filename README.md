# Lina
Lina is an AAR/AEA app for iOS using my [libNeoAppleArchive](https://github.com/0xilis/libNeoAppleArchive) library. While libNeoAppleArchive is made in C, Lina is made in Swift and UIKit.

# Why Lina?

Backend library powering Lina is libNeoAppleArchive, my open source library for Apple Archive.

libNeoAppleArchive = LNAA, LNAA sounds like Lina, so I chose Lina.

# Features

- Creating Apple Archives
- Extracting Apple Archives
- Creating Apple Encrypted Archives
- Extracting Apple Encrypted Archives
- Verifying Apple Encrypted Archives
- Share Sheet Integration
- Create AAR Siri Shortcut Action
- Extract AAR Siri Shortcut Action
- Create AEA Siri Shortcut Action
- Extract AEA Siri Shortcut Action

# App Store

[This app is on the iOS App Store!](https://apps.apple.com/us/app/lina-aar-aea-app/id6746178492) If you want to test pre-release builds on TestFlight, please DM/Contact me for a TestFlight link!

# Compatibility

**Lina 1.1:** iOS 9.0+ armv7/arm64, macOS 10.15+ Catalyst x86_64/arm64
**Lina 1.0:** iOS 13.0+ arm64 (macOS arm64, visionOS can run iOS app)

# Planned

### Next Release (1.1):

- [x] Support iOS 9, iOS 10, iOS 11, and iOS 12. armv7 iOS 9/10 is also supported.
- [x] Migrate from UIOnboarding to new LaunchBoarding framework.
- [ ] Figure out documentation for App Encryption for release in France.
- [ ] Translators, primarily ones for French.
- [x] Update NeoAppleArchive.framework.
- [x] Add new "Verify AEA" shortcuts action.
- [ ] macOS Catalyst App.
- [ ] Ensure Voice Over support throughout the app for Accessibility. Currently the only thing that voiceover cannot read which it should is the app color scheme buttons.
- [ ] Add Voice Control support for Accessibility.
- [ ] Larger Text Accessibility support.

### Future Releases

- [ ] Add support for all AEAProfile types (Extraction can currently be done but creation needs libNeoAppleArchive updates).
- [ ] Add option for dark mode in iOS 9/10/11/12 app.
- [ ] Add support for all compression types (Needs libNeoAppleArchive updates).
- [ ] URL schemes.
- [ ] Look into more Accessibility features to support.

### Cool Ideas, but not Currently Planned:

- iOS 12 support with Siri Shortcut actions. This would be neat and we already support iOS 13 so this would be the last version we need to support, which would be awesome to support every version of Siri Shortcuts, but this is honestly just too hard for me. For iOS 12 I probably will support using x-callback URL schemes in Shortcuts in the future so it will have some functionality with iOS 12 Shortcuts, even if not ideal.
- Creating ECDSA-P256 key pairs in the app itself. This would be convenient for users so they can instantly generate keys to sign their AEAs with natively in the app itself rather than going to somewhere else and needing extra work, however I do not plan to add this because to be honest I'm not sure of a great way to make a easy to understand UI for this, and it's too much work for something that the user can already do using other tools. If someone else wants to implement this however, feel free!
