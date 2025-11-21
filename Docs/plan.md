# KidsTrack – Execution Plan

Living document enumerating the agreed next steps. Update status inline as we knock tasks off.

## Workflow Reminder
- Work item by item from `Docs/# Backlog.KidsTrack.md`: one user story per branch, complete the full scope, and raise a PR tied to that US before merging. Avoid mixing multiple US in a single branch/PR.

## Ready

1. **Auth Flow Integration**
   - Wire `LoginView` and `AppNavigationCoordinator` so successful login/registration triggers `.didAuthenticate` and logout resets to `.login`.
   - Expose callbacks from `LoginView` -> coordinator; bubble up `AuthState` updates from `LoginViewModel`.
   - Document testing approach (unit + manual) before marking complete.

2. **Onboarding Completion Toggle**
   - Add lightweight persistence (e.g., `AppStorage` flag or repository) to remember if the welcome screen was completed.
   - Update `AppNavigationCoordinator` root selection to respect the stored value.
   - Include migration/reset strategy for development builds.

3. **Post-Auth Shell**
   - Scaffold the authenticated “home” container (tabs for Today/Schedule/Calendar/Expenses/Family) with placeholder views to unblock dependent UI work.
   - Ensure navigation routing accommodates typed destinations for new sections.

4. **Auth Feature Tests**
   - Add unit tests in `PresentationTests` for `LoginViewModel` covering success/error/reset paths with mocked `AuthRepository`.
   - Add smoke UI test for login flow (use accessibility identifiers already in place or add as part of this work).

## Backlog / To Refine

- Define design tokens for spacing/typography beyond colors and expose them via environment helpers.
- Introduce data persistence abstraction (SwiftData vs Firestore) for schedules/expenses, keeping repositories protocol-first.
- Prepare CI recipe (xcodebuild build/test + SwiftLint/SwiftFormat hooks).
