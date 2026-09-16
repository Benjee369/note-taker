# <div align="center">📝 NOTE TAKER 📝</div>

<div align="center">


![](https://img.shields.io/badge/Platform-Everything-blueviolet?style=for-the-badge)
![](https://img.shields.io/badge/Price-$0-success?style=for-the-badge)
![](https://img.shields.io/badge/Subscriptions-NO-red?style=for-the-badge)

</div>

---

I have often never been able to find a simple note taking app that will sync my notes from my **PC (Windows)** and my **phone (iOS)**.
I understand theres options like **Obsidian**, but such solutions are either not straight forward on how one can setup syncing, or one has to pay.

# **I HATE THAT.**
> *[options like google docs exist but meh, too bland]*

---

A note taker app that **'will'** work across all platforms, all devices.
Trying to be device inclusive in this ho.

---

And ofcourse this is also meant to be a way to truly understand Flutter capabilities.
I have often viewed it as a framework for building mobile applications...
but theres more to that.
### It is capable of so much more.

*"One codebase to rule them all."*

</div>

---

# How it works

## What this app is

A cross-platform note taker built with Flutter. The same codebase runs on **desktop** (Windows, macOS, Linux) and **mobile** (Android, iOS), plus web. Notes are stored **locally** on-device using **Hive** (a fast key-value store), so there's no account, no subscription, and nothing uploaded to a server. Notes are saved as plain text with a **live markdown preview** on the side.

## Folder layout (feature-first architecture)

The code is organised into three layers. Everything that can be shared is shared; only the parts that genuinely differ per platform live in the platform folders.

```
lib/
├── main.dart                 # Entry point. Wires the setup wizard or the app up
├── app/                      # Bootstrap / wiring
│   ├── app.dart              # Root MaterialApp + light/dark themes
│   ├── provider_layer.dart   # Registers all databases & providers (DI)
│   └── setup_wizard.dart     # First-run flow: pick where to store your notes
├── shared/                   # Code reused everywhere
│   ├── constants/            # app_colors, app_images, app_sizes, strings
│   ├── database/             # Hive boxes (notes, previews, folders, settings...)
│   ├── models/               # Data models (notes, folders, settings)
│   ├── navigation/           # Route helpers
│   ├── providers/            # State management (NoteProvider, settings...)
│   └── widgets/              # Reusable UI pieces
├── auth/
│   └── splash_screen.dart    # Loading / entry screen
├── features/                 # Business features
│   ├── notes/
│   │   ├── home_screen.dart  # The coordinator: picks the platform home screen
│   │   ├── note_screen.dart  # The shared note editor (text + markdown)
│   │   └── widgets/
│   └── settings/
│       ├── settings_screen.dart
│       ├── providers/
│       └── widgets/
└── platform/                 # The only platform-specific UI
    ├── desktop/              # Desktop home screen + note drawer
    └── mobile/               # Mobile home screen + drawer
```

## How a note flows through the app

1. **Startup** — `main()` checks `SharedPreferences` for a saved storage location. If there's none yet it shows the **setup wizard** to let you pick one; otherwise it starts Hive and launches `ProviderLayer`.
2. **Wiring** — `ProviderLayer` creates the Hive-backed databases and the state providers, then hands control to `App`, which builds the themed `MaterialApp` and shows the splash screen.
3. **Platform branch** — the splash navigates to the notes `HomeScreen`, which checks `isMobile`/`isDesktop` (via `platform_provider.dart`) and shows either the **mobile** or **desktop** home screen. That single branch is the *only* place the two platform UIs meet.
4. **Reading/writing** — every screen talks to a provider (e.g. `NoteProvider`), which talks to the databases. Changes are written straight to local Hive boxes — no network calls.

## Adding a new platform-specific screen

Add it under `platform/<platform>/`, keep any shared logic/widgets in `shared/` or `features/`, and branch to it from `features/notes/home_screen.dart` (or wherever the relevant coordinator lives). Avoid importing across the two `platform/` folders — that's what keeps the two platforms decoupled.

## Regenerating code

The `*.g.dart` files are generated from the `@JsonSerializable()` models. After changing a model, run:

```
flutter pub run build_runner build --delete-conflicting-outputs
```

---

# Building & using the app

## Prerequisites

Install the Flutter SDK and make sure the target platform's toolchain is set up — run `flutter doctor` and fix anything red for the platform you want to build. Roughly:

- **Windows** → Visual Studio with the "Desktop development with C++" workload
- **macOS** → Xcode command-line tools
- **Linux** → `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`
- **Android** → Android SDK / Android Studio

## Using the app

1. On **first launch** the desktop build asks you to **choose a storage location** for your notes database. Pick any folder — that's where your notes live, so it's a good candidate for a synced/cloud folder (OneDrive, Dropbox, etc.) if you want to share notes between machines.
2. You land on the notes list. Use the **+** button to create a note (desktop also has a **create folder** button).
3. Tap/click a note to edit it. On desktop the editor shows a **live markdown preview** on the right; drag the divider to resize it.
4. **Right-click** (desktop) or **long-press** (mobile) a note for pin, duplicate, delete, select, and "add to folder".
5. Desktop settings (theme colour, dark mode, note font size/weight) are behind the **gear icon**; on mobile they're in the **drawer**.
6. Everything is stored locally. There's no account and no sync service — syncing is as simple as pointing the storage folder at a cloud-synced directory.

## Building a release

### Windows

```
flutter build windows --release
```

Output: `build\windows\x64\runner\Release\`

**To share:** zip the whole **contents** of that `Release` folder (the `notes.exe` needs the bundled `.dll`s and `data\` folder next to it) and hand it over. Recipients unzip and double-click `notes.exe` — it's portable, no installer required.

### macOS

```
flutter build macos --release
```

Output: `build/macos/Build/Products/Release/notes.app`

**To share:** zip the `.app` bundle (zipping preserves the bundle structure and executable permissions). Recipients unzip and open it. Because the build isn't code-signed, macOS Gatekeeper will block it the first time — tell them to **right-click → Open**, then confirm.

### Linux

```
flutter build linux --release
```

Output: `build/linux/x64/release/bundle/`

**To share:** zip the entire `bundle` folder and have recipients run the `notes` executable inside it. Keep the `lib\` and `data\` folders alongside the executable.

### Android

APK (easy sideloading):

```
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

Smaller per-architecture APKs:

```
flutter build apk --split-per-abi
```

Google Play upload bundle:

```
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

**To share:** copy the `.apk` to the phone and open it, allowing "install from unknown sources" if prompted. For the Play Store, upload the `.aab`.

### Web

```
flutter build web --release
```

Output: `build/web/`

**To use:** serve that folder with any static host (GitHub Pages, Netlify, `python -m http.server` inside `build/web`, etc.) and open the URL. Note that the local-storage setup wizard is aimed at desktop/mobile, so treat the web build as experimental.

> iOS isn't covered here since a release build requires a Mac with Xcode and code signing, and can only be installed via TestFlight or the App Store.

