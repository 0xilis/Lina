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

# Planned

### Next Release (1.1):

- [x] Support iOS 11 and iOS 12.
- [ ] Migrate from UIOnboarding to new LaunchBoarding framework. (partially complete, LaunchBoard not yet complete)
- [ ] Figure out documentation for App Encryption for release in France.
- [ ] Translators, primarily ones for French.
- [ ] Update NeoAppleArchive.framework.
- [ ] Add new "Verify AEA" shortcuts action.

### Future Releases

- [ ] Add support for all AEAProfile types (Extraction can currently be done but creation needs libNeoAppleArchive updates).
- [ ] Add support for all compression types (Needs libNeoAppleArchive updates).
- [ ] OS X native app, or at least a Catalyst one.
