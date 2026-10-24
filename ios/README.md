# NIKNOLIG iOS

This standalone repository includes the iOS project exported from
[`nikolausnold/NIKNOLIG`](https://github.com/nikolausnold/NIKNOLIG), source
commit [`6eec28f`](https://github.com/nikolausnold/NIKNOLIG/commit/6eec28fc830056b57127ddd06d934e62f2dba50d).
The export preserves the source project's `ios/` paths so its Xcode references
and local Swift package continue to resolve.

## Open and build

- Requires macOS and Xcode 16 or later; the app deployment target is iOS 17.0.
- Open `ios/NIKNOLIG.xcodeproj` and select the shared `NIKNOLIG` scheme, or use
  `xcodebuild -project ios/NIKNOLIG.xcodeproj -scheme NIKNOLIG -destination 'generic/platform=iOS Simulator' build`.
- The bundle identifier is `org.niknolig.ios`. The target uses automatic
  signing; choose a development team in Xcode when signing for a physical
  device. No signing certificates, private keys, or provisioning profiles are
  included.

The app depends only on the local `ios/NIKNOLIGCore` Swift package; there are
no remote Swift packages or other external iOS dependencies. The package's
unit tests can be run with `swift test --package-path ios/NIKNOLIGCore`.
Building or running the iOS app and simulator tests requires Xcode on macOS.

## iOS brand styling

The shared NIKNOLIG palette, typography, card treatment, and screen background
are defined in `ios/NIKNOLIG/App/NIKNOLIGTheme.swift`. Native SwiftUI styling is
applied in `HomeView.swift`, `MainTabView.swift`, `AssistantView.swift`,
`LearningProfileView.swift`, and `OfficialWebsiteView.swift`. The current app
has no onboarding screen and uses no dedicated image assets; the brand mark is
composed from native SF Symbols and text.
