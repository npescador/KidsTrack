# Repository Guidelines

## Project Structure & Module Organization
- `KidsTrack/` hosts the SwiftUI app entry (`KidsTrackApp.swift`), root view (`ContentView.swift`), and assets under `Assets.xcassets`.
- `KidsTrackTests/` and `KidsTrackUITests/` contain XCTest targets; mirror production filenames when adding new suites.
- Grow features by introducing folders inside `KidsTrack` (e.g., `KidsTrack/Features/Habits`) with co-located models, view models, and coordinators.

## Build, Test, and Development Commands
- `xed .` opens the project in Xcode with the correct schemes.
- `xcodebuild -scheme KidsTrack -destination 'platform=iOS Simulator,name=iPhone 15' build` performs a headless build for CI and pre-PR checks.
- `xcodebuild test -scheme KidsTrack -destination 'platform=iOS Simulator,name=iPhone 15'` runs unit and UI suites; add `-only-testing KidsTrackTests/<Case>` to scope reruns.
- Run `swiftformat .` and `swiftlint` when configs are present; keep diffs lint-clean before committing.

## Coding Style & Naming Conventions
- Follow Swift 5.9 defaults with 4-space soft tabs; group modifiers by intent (layout, visuals, behavior).
- Prefer SwiftUI Observation (`@Observable`, `@Bindable`); use legacy wrappers only with a justification comment in code.
- Use UpperCamelCase for types, lowerCamelCase for members, and suffix async functions with `Async` when they expose concurrency.
- Localize user-facing strings via String Catalogs and reference generated keys instead of literals.

## Testing Guidelines
- Add XCTest cases under matching directories, e.g., `KidsTrackTests/HabitsViewModelTests.swift`.
- Cover error paths, async flows, and boundary conditions; use `XCTExpectFailure` for documented debt.
- UI specs belong in `KidsTrackUITests`; stabilize elements with accessibility identifiers and disable animations via launch arguments.

## Commit & Pull Request Guidelines
- Follow Conventional Commits (`feat:`, `fix:`, `test:`) with a scoped module or feature.
- PRs must include a focused summary, linked issue, simulator screenshots for UI changes, and notes on accessibility/localization impacts.
- Re-run `xcodebuild test` before requesting review and mention the simulator/device used in the PR description.

## SwiftUI Implementation Notes
- Keep navigation orchestration in view models or coordinators using `NavigationStack` with typed routes.
- Move heavy calculations out of `body`; use `.task` for async work and cache expensive data.
- Ensure interactive elements expose accessibility labels/hints and verify layouts under Dynamic Type and Reduce Motion settings.
