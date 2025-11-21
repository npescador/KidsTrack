# Repository Guidelines

## Working Process
- Use `Docs/# Backlog.KidsTrack.md` as the source of truth for upcoming work.
- Tackle one user story (US) per branch: create a dedicated branch, complete the full scope of that US, and open a PR for review before merging.
- Keep branch/PR descriptions tied to the corresponding US; avoid mixing multiple US in the same branch.

## Project Structure & Module Organization
- `KidsTrack/` hosts the SwiftUI app entry (`KidsTrackApp.swift`), root view (`ContentView.swift`), and assets under `Assets.xcassets`.
- `KidsTrackTests/` and `KidsTrackUITests/` contain XCTest targets; mirror production filenames when adding new suites.
- Grow features by introducing folders inside `KidsTrack` (e.g., `KidsTrack/Features/Habits`) with co-located models, view models, and coordinators.
- Promote modularization (SPM/framework targets) that mirror the Domain/Data/Presentation/App layers so contracts live next to their collaborators and builds stay lean.
- Split code by responsibility: keep protocols/interfaces in their own files and place concrete implementations in separate files unless tight coupling makes that impossible.
- Keep SwiftUI view files focused; extract reusable components aggressively so screens stay small and composable.

## Build, Test, and Development Commands
- `xed .` opens the project in Xcode with the correct schemes.
- `xcodebuild -scheme KidsTrack -destination 'platform=iOS Simulator,name=iPhone 15' build` performs a headless build for CI and pre-PR checks.
- `xcodebuild test -scheme KidsTrack -destination 'platform=iOS Simulator,name=iPhone 15'` runs unit and UI suites; add `-only-testing KidsTrackTests/<Case>` to scope reruns.
- Run `swiftformat .` and `swiftlint` when configs are present; keep diffs lint-clean before committing or pushing.

## Coding Style & Naming Conventions
- Follow Swift 6 defaults with 4-space soft tabs and group modifiers by intent (layout, visuals, behavior).
- Target the latest Swift and SwiftUI capabilities available on iOS 26, preferring modern APIs before falling back to legacy approaches.
- Name every SwiftUI view struct with a `View` suffix and place it in a file that mirrors the type name (also ending in `View.swift`) unless a legacy file must be preserved.
- Use UpperCamelCase for types, lowerCamelCase for members, and suffix async functions with `Async` when they expose concurrency.
- Avoid introducing new types named `Task` to prevent clashes with Swift Concurrency.
- Localize user-facing strings via String Catalogs and reference generated keys instead of literals.

## State Management
- Prefer SwiftUI Observation (`@Observable` for models, `@Bindable` in views); legacy wrappers (`@StateObject`, `@ObservedObject`, `@Published`, `@EnvironmentObject`) require a short justification comment.
- Use `@State` strictly for local view state and `@Binding` when the parent owns the source of truth; avoid long binding chains.
- Inject dependencies via initializers (constructor injection) instead of relying on global singletons; leverage `Environment` only for app-wide concerns (theme, session, settings).
- Allow legacy reference types when dealing with third-party APIs, Combine, or `NSManagedObject`, but document why.

## Navigation
- Use `NavigationStack` with type-safe `Hashable` routes on iPhone/single-column flows and `NavigationSplitView` for iPad/macOS multi-column layouts.
- Implement `navigationDestination(for:)` for deep links and programmatic navigation.
- Keep navigation orchestration in coordinators or view models; do not mix business rules directly into views.

## Layout System
- Favor `Grid` for complex layouts, `ViewThatFits` for adaptive stacks, and `containerRelativeFrame()` for responsive sizing.
- Reach for the `Layout` protocol when VStack/HStack/ZStack are insufficient.
- Verify layouts under large Dynamic Type sizes; avoid fixed heights and use `fixedSize`/`layoutPriority` deliberately.

## Performance
- Mark UI-touching pathways with `@MainActor`.
- Launch async work via `.task`/`task(id:)`, consider `async let` for lightweight fan-out, and keep heavy calculations out of `body`.
- Use `LazyV*`/`LazyH*` with stable identifiers; never regenerate `UUID()` during every render.
- Profile with Instruments (Time Profiler, Allocations) before optimizing and cache expensive data when possible.

## UI Components
- Use `ScrollView` with `.scrollTargetBehavior()` when UX wins from targeted scrolling.
- Apply `.contentMargins()` for consistent internal spacing and `.containerShape()` to tune hit areas.
- Prefer SF Symbols with variable color/width glyphs and extract reusable styling via `ViewModifier`s.

## Interaction & Animation
- Use `.animation(_:value:)` scoped to the state you are animating; avoid implicit/global modifiers.
- Reach for `phaseAnimator` for staged transitions, `.symbolEffect()` for micro-interactions, and `.sensoryFeedback()` while respecting accessibility settings.
- Prefer SwiftUI gestures; wrap UIKit gestures only when strictly needed.

## Accessibility
- Ensure every interactive element exposes `.accessibilityLabel`, `.accessibilityHint`, and appropriate traits; group children when it improves readability.
- Test Dynamic Type at extra-large sizes, respect Reduce Motion/Transparency, and offer alternatives where necessary.
- Run manual checks (VoiceOver rotor, focus order) and stabilize UI tests with accessibility identifiers.

## App Architecture & Dependency Injection
- Lean on a Clean-ish MVVM + Coordinator approach (Domain/Data/Presentation/App) with protocols defining contracts and concrete implementations in Data.
- Create an app-level composition root (e.g., `AppContainer`) for dependency wiring and avoid global singletons; wrap unavoidable system singletons.

## Networking
- Use `URLSession` with `async/await`, configure `JSONDecoder`/`Encoder` strategies, and separate DTOs from domain models.
- Handle cancellation and retries (prefer exponential backoff) and respect ATS/certificate validation.
- Never log sensitive PII.

## Error Handling & Logging
- Model domain errors as enums conforming to `Error`; provide `localizedDescription` or user-facing messaging.
- Use `OSLog`/Unified Logging with categories and levels, and never log secrets.

## Testing Guidelines
- Add Swift Testing suites mirroring production targets, e.g., `KidsTrackTests/HabitsViewModelTests.swift`.
- Cover success/error paths, async flows, and boundary conditions; use protocol-driven mocks and `XCTExpectFailure` for acknowledged debt.
- Keep UI specs in `KidsTrackUITests`, disable animations via launch arguments, and stabilize selectors with accessibility identifiers.
- Introduce snapshot/UI testing where helpful and document tolerances.

## Localization & Theming
- Use String Catalogs for all human-facing text, support plurals/gender rules, and rely on `FormatStyle` for number/date formatting.
- Provide localized previews (e.g., `es-ES`) and smoke-test RTL layouts.
- Define design tokens for color, spacing, and typography; expose them through the environment or shared helpers while supporting light/dark/high-contrast modes.

## CI/CD & Quality Gates
- Enforce SwiftFormat/SwiftLint with no blocking warnings, ensure reproducible builds, and track coverage at a reasonable baseline.
- Automate CI to run tests and handle version bumps/release notes; re-run `xcodebuild test` before requesting review and note the simulator/device in PRs.

## Release Readiness
- Confirm all required privacy usage strings exist in `Info.plist`, UI permission prompts explain why, and assets/icons are audited.
- Review schemes, entitlements, Universal Links, and deep links before submission.
- Validate accessibility/localization, ensure Reduce Motion/Dynamic Type behave, and capture simulator screenshots for UI-facing PRs.

## Commit & Pull Request Guidelines
- Follow Conventional Commits (`feat:`, `fix:`, `test:`) with a scoped module or feature.
- Include a focused summary, linked issue, simulator screenshots for UI changes, and note accessibility/localization impacts when opening PRs.
