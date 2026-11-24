# Nazar Dangle

A native Apple Silicon macOS app that places a traditional hanging charm on the **Desktop only**. It is not a browser extension or web overlay.

## What it does

- Shows the charm on the Desktop/Home Screen; it automatically hides whenever another app, browser, or full-screen window becomes active.
- Starts at the right side instead of the centre/notch.
- Includes the supplied transparent designs: a copper bell, lemon-and-chilli charm, and blue nazar battu.
- Open **Settings** or the menu-bar icon to choose the charm and its size.
- Choose **Unlock position — drag to move** and drag the charm wherever you like on the Desktop. Its position is remembered.
- With position locked, drag or click the charm to make it swing. The bell plays a sound when it changes direction.
- Supports optional Launch at Login. Place the signed app in `/Applications` before enabling this for the best macOS compatibility.

## Run from Xcode

1. Open `Package.swift` in Xcode 16 or later.
2. Select **NazarDangle** and **My Mac**.
3. Run the project. Use the eye icon in the menu bar to open Settings.

## Build a double-clickable app

```zsh
chmod +x Scripts/build-app.sh
Scripts/build-app.sh
open "dist/Nazar Dangle.app"
```

The app targets macOS 14+ and builds as an `arm64` Apple Silicon executable. The packaging script creates an ad-hoc signed bundle at `dist/Nazar Dangle.app`. For sharing outside the build Mac, sign with an Apple Developer certificate and notarize it.

## Motion detection

Native macOS does not expose a public MacBook accelerometer API: `CMMotionManager` is unavailable for native macOS targets. The settings screen therefore explains this limitation rather than promising physical laptop-motion support. The app uses no private APIs, camera input, or keyboard monitoring. Apple also cautions that iOS-specific hardware features such as Core Motion may be unavailable on macOS. [Apple documentation](https://developer.apple.com/documentation/apple-silicon/adapting-ios-code-to-run-in-the-macos-environment)
