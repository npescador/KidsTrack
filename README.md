# KidsTrack

## 1. Vision and Principles

Goal: An iOS app for families that centralizes class schedules, extracurricular activities, a shared calendar, and their associated expenses.
Principles:
- Offline-first data model with secure sync (SwiftData or Firestore with local persistence).
- Clean separation between Presentation, Domain, Data, and App composition.
- One-glance UX so families immediately know what is next and how much they have spent this month.
- Scalable to multiple children and caretakers with granular permissions.
- Privacy by design: minimal data retention, COPPA/GDPR alignment, encryption in transit and at rest.

---

## 2. Recommended Architecture (Clean MVVM with a TCA-inspired Core)

### 2.1 Presentation Layer (SwiftUI)
- SwiftUI views + MVVM view models annotated with @Observable or @MainActor.
- Centralized router based on NavigationStack, NavigationPath, and typed routes.
- Critical states (sync, smart notifications, background tasks) can opt into a TCA-like Reducer/State/Action module bridged into MVVM for composable side effects and rigorous testing.

### 2.2 Domain Layer
- Pure use cases (interactors) with sync/async entry points and no UI or Firebase dependencies.
- Immutable entities (structs) with validation logic.
- Repositories declared as protocols to support dependency injection.

### 2.3 Data Layer
- Concrete repository implementations for SwiftData (with iCloud) or Firebase Firestore (offline cache + cloud sync).
- EventKitRepository for calendar reads/writes when granted.
- AuthRepository (Firebase Auth) and NotificationsRepository (UserNotifications + App Intents).
- DTO <-> Domain mappers with schema versioning and migrations.

### 2.4 Concurrency and Effects
- Swift 6 concurrency (async/await, Sendable), TaskGroup for fan-out work such as loading schedules, events, and expenses simultaneously.

### 2.5 Telemetry and Errors
- OSLog with per-feature categories.
- MetricKit or Crashlytics (if Firebase is present).
- Optional remote feature flags via Firebase Remote Config or similar.

---

## 3. Minimal Domain Model

```swift
struct Family: Identifiable { let id: String; var name: String; var members: [ChildID]; var owners: [UserID] }
struct Child: Identifiable { let id: String; var name: String; var birthdate: Date?; var avatarURL: URL?; var themeColor: String }
struct SchoolClass: Identifiable { let id: String; let childID: String; var title: String; var location: String?; var weekday: Int; var start: Date; var end: Date; var category: ClassCategory }
struct Activity: Identifiable { let id: String; let childID: String; var type: ActivityType; var weekday: Int; var start: Date; var end: Date; var notes: String? }
struct FamilyEvent: Identifiable { let id: String; let familyID: String; var title: String; var details: String?; var dateInterval: DateInterval; var location: String?; var attachments: [URL]?; var reminders: [Reminder] }
struct Expense: Identifiable { let id: String; let familyID: String; let childID: String?; let category: ExpenseCategory; let amount: Decimal; let date: Date; var notes: String?; var relatedIDs: [String]? }

enum ActivityType: String { case sport, music, languages, art, other }
enum ExpenseCategory: String { case schoolMaterials, books, monthlyFee, gear, oneOff }
```

Key relations:
- Family 1—* Child.
- Child 1—* SchoolClass and Activity.
- Family 1—* FamilyEvent and Expense.

Firestore indices: familyID, childID, date, weekday for fast week/month queries.

---

## 4. Persistence Decision Tree
- Only iOS for the next 12–18 months: SwiftData (reduced friction, easier Widgets and Watch support).
- Planning Android/Web or advanced real-time collaboration: Firestore.
- Abstract persistence behind repositories to keep both drivers viable.

---

## 5. Navigation Map (Textual Wireframe)
- Splash → Onboarding (1–4) → Authentication (Sign in/Sign up/Apple/Google).
- Home (TabView) with tabs: Today, Schedule, Calendar, Expenses, Family.
- Today: next class/activity/event plus month-to-date expense summary.
- Schedule: weekly per child with toggle between Classes and Extracurriculars.
- Calendar: day/week with child/type filters and event creation.
- Expenses: monthly list, Charts-based breakdowns, filters by child/category.
- Family: children, invitations, sync/export/notification settings.
- Modal/push flows for creating or editing classes, activities, events (attachments, reminders) and expenses (category picker, child link).
- Actions for duplicating schedules, importing templates, inviting guardians via Dynamic Link, and granting permissions (Calendar, Notifications, Photos/Files).

---

## 6. Suggested Folder Structure
```
App/
  AppMain.swift
  CompositionRoot/
    DIContainer.swift
    Environment+Dependencies.swift
  Router/
    AppRouter.swift
    Routes.swift
Features/
  Home/
    View/HomeView.swift
    VM/HomeViewModel.swift
  Schedule/
    View/ScheduleView.swift
    VM/ScheduleViewModel.swift
    TCA/ScheduleFeature.swift
  Calendar/
    View/CalendarView.swift
    VM/CalendarViewModel.swift
    Integrations/EventKitSync.swift
  Expenses/
    View/ExpensesView.swift
    VM/ExpensesViewModel.swift
    Charts/ExpensesChartsView.swift
  Family/
    View/FamilyView.swift
    VM/FamilyViewModel.swift
    Sharing/InviteLinkBuilder.swift
  Onboarding/
    View/OnboardingFlow.swift
  Auth/
    View/AuthView.swift
    VM/AuthViewModel.swift
Domain/
  Entities/*.swift
  UseCases/
    CreateClass.swift
    DuplicateSchedule.swift
    AddExpense.swift
    GetWeeklyPlan.swift
  Repositories/
    ScheduleRepository.swift
    ExpensesRepository.swift
    EventsRepository.swift
    FamilyRepository.swift
    AuthRepository.swift
Data/
  Firestore/
    Repositories/*.swift
    DTO/*.swift
    Mappers/*.swift
  SwiftData/
    Models/*.swift
    Repositories/*.swift
  EventKit/EventKitRepository.swift
  Auth/FirebaseAuthRepository.swift
Shared/
  DesignSystem/
    Colors.swift
    Typography.swift
    Icons.swift
    Components/(Pill, Tag, Avatar, Card, EmptyState).swift
  Utils/
    DateFormatting.swift
    MoneyFormatting.swift
    Validators.swift
    AttachmentsManager.swift
  Notifications/
    NotificationsService.swift
    AppIntents/
      AddEventIntent.swift
      QuickExpenseIntent.swift
  Widgets/NextItemsWidget.swift
  Localization/es.lproj, en.lproj
  Tests/Unit, Snapshot, UITests
```

---

## 7. Framework and Library Stack
- UI: SwiftUI (iOS 18) and Apple Charts for monthly/annual spending.
- Auth: Firebase Auth (Apple, Google, email).
- Data: SwiftData + iCloud or Firebase Firestore with offline cache and security rules.
- Calendar: EventKit (opt-in, read/write).
- Notifications: UNUserNotificationCenter + App Intents for quick actions.
- Widgets: WidgetKit for Home and Lock Screen.
- Push: Firebase Cloud Messaging (if Firestore) or direct APNs.
- Attachments: PhotosPicker, FileImporter, PDFKit previews.
- StoreKit 2 for subscriptions and Family Sharing.
- Observability: OSLog, MetricKit, Crashlytics.
- Testing: XCTest, SnapshotTesting, and swift-testing when ready.

---

## 8. Family-Centric UX Guidelines
- Guided first-run: concise onboarding with "Add child" and schedule templates per school stage.
- Color per child with category icons for quick comprehension.
- Dual density in the weekly schedule (compact chips vs detailed cards).
- Contextual add button for expenses/events/classes per tab.
- Helpful empty states with CTAs (e.g., "Add your first activity" + import button).
- Accessibility: Dynamic Type, high contrast, semantic VoiceOver labels such as "Music class today at 17:00".
- Light haptics on create/duplicate actions.
- Visible privacy messaging, opt-in banners for sharing controls.

---

## 9. Security and Privacy for Minors
- Data minimization (school names optional, location only if required).
- Verifiable guardian consent before sharing with other caretakers.
- TLS + encrypted storage; Firestore security rules scoped by familyID/owner.
- Access control with owner/guardian/viewer roles plus invitation revocation.
- Honest Privacy Nutrition Label; ATT likely unnecessary if no cross-app tracking.
- Data lifecycle: export (CSV/PDF), account/data deletion (GDPR Art. 17), explicit retention (e.g., 24 months).

## 10. Blueprint del Producto

### 10.1 Arquitectura
- Capas: Presentation (SwiftUI + Clean MVVM con `AppNavigationCoordinator` y rutas tipadas), Domain (casos de uso y entidades puras), Data (repositorios concretos SwiftData+iCloud o Firebase). Comunicación Presentation→Domain mediante ViewModels y casos de uso (`LoadWeeklyPlanUseCase`), Domain→Data vía protocolos (`ScheduleRepository`, `ExpensesRepository`, `EventsRepository`, `AuthRepository`, `ChildrenRepository`).
- Flujo textual: **Vista** → dispara acción → **ViewModel** → invoca **Use Case** → consulta **Repositorio** → persistencia SwiftData (sincronizada con CloudKit) → resultado vuelve al **ViewModel** que proyecta estado en la **Vista**.
- Clean MVVM se elige sobre TCA para reducir fricción en el MVP y mantener la opción de introducir módulos TCA en features críticas posteriores.

### 10.2 Navegación
- Estados del orquestador: `.splash`, `.onboardingPending`, `.needsAuth`, `.authenticated(AppShellState)`.
- Rutas principales: Splash → Onboarding (Welcome, AddChildren, Permissions) → Auth (SignIn, Register, PasswordReset) → Tab principal (TodayWeek, Calendar, Expenses, FamilyProfile). Subrutas: TodayWeek → ChildScheduleDetail; Calendar → EventDetail/CreateEvent; Expenses → ExpenseDetail/AddExpense; FamilyProfile → ChildProfile/Settings.
- Deep links propuestos: `kidsTrack://event/<id>`, `kidsTrack://expense/<id>`, `kidsTrack://child/<id>` y enlaces universales para invitaciones.

### 10.3 Modelos y Esquemas
- Domain structs: `Child`, `ClassSession`, `Activity`, `FamilyEvent`, `Expense`, `ExpenseCategory`, `ActivityType`. Restricciones: colores únicos por hijo dentro de la familia; validación de solapamiento horario antes de persistir.
- SwiftData: `@Model` con relaciones `@Relationship(deleteRule: .cascade)` y plan de migraciones versionadas con `ModelConfiguration`.
- Alternativa Firebase: colecciones `families/{familyId}/children|classes|activities|events|expenses` con reglas que limitan acceso a owners/guardians; índices por `familyID`, `childID`, `weekday`, `date`.

### 10.4 Casos de Uso
- Gestión hijos: `CreateChildProfile`, `UpdateChildProfile`, `LoadChildrenList`.
- Horarios: `CreateClassSession`, `UpdateClassSession`, `DeleteClassSession`, `DuplicateSchedule`, `LoadWeeklyPlan`.
- Actividades: `CreateActivity`, `UpdateActivity`.
- Eventos: `AddFamilyEvent`, `UpdateEvent`, `SyncEventToCalendar`.
- Gastos: `RegisterExpense`, `UpdateExpense`, `DeleteExpense`, `MonthlySummary`, `YearlySummary`, `ExportExpensesCSV/PDF` (fase 2).
- Sistema: `AuthenticateUser`, `SignOut`, `CheckOnboardingStatus`, `SyncDataUseCase`, `ManageNotifications`.

### 10.5 UI/UX
- Accesibilidad AA+, soporte Dynamic Type XL, VoiceOver con etiquetas “Niño + actividad + horario”.
- Colores familiares por hijo, tipografía SF Rounded para headings, tokens de espaciado 8/12/16/24.
- Estados vacíos con CTA (“No hay clases para Mateo esta semana. Añade la primera clase.”).
- Estrategia semanal: `Grid` + `ScrollView` horizontal para semana y `TimelineView` diario con `ScrollViewReader`.
- Conflictos: chips superpuestos con borde/alerta contextual y accesos rápidos para editar.

### 10.6 Roadmap
- MVP Sprints 1–2: Splash/Onboarding/Auth, CRUD hijos/clases/actividades, vista semanal, gastos básicos, almacenamiento SwiftData offline.
- MVP Sprints 3–4: Sincronización CloudKit/Firestore, calendario diario, estadísticas mensuales básicas, stub exportación CSV, mejoras accesibilidad y pruebas auth.
- Fase 2: Exportación PDF, estadísticas avanzadas con Charts, duplicado de horarios, recordatorios inteligentes, EventKit/App Intents, multiidioma, widgets.
- Fase 3: Notificaciones inteligentes, Apple Watch, resumen fin de curso, integraciones TokkApp/HealthKit, StoreKit 2 con planes familiares.

### 10.7 Estrategia de Pruebas
- XCTest/swift-testing para casos de uso y ViewModels con repositorios simulados.
- SnapshotTesting para vistas clave (Semana, Calendario, Gastos) en estados vacío/lleno/conflicto.
- UI Tests para onboarding/auth y creación de gastos.
- Focos especiales: solapamientos horarios, zonas horarias, sincronización offline, exportaciones y autenticación multi-proveedor.

### 10.8 Monetización
- Freemium: hasta 2 hijos, gestión básica de clases/actividades y gastos con estadísticas mensuales simples.
- Premium familiar (suscripción anual/mensual): hijos ilimitados, estadísticas anuales/comparativas, exportaciones CSV/PDF, recordatorios inteligentes, widgets avanzados, integraciones EventKit completas y multi-guardían. Sin anuncios; transparencia sobre privacidad y descuentos educativos.

### 10.9 Supuestos
- Target iOS 18 con Swift 6, priorizando SwiftData+iCloud como almacenamiento principal.
- Firebase se habilita sólo si se necesita multiplataforma; la capa de repositorios permite intercambiar drivers.
- Autenticación inicial: Email/Password y Sign in with Apple; Google se planifica para fase posterior.
- Internal audit trail for expense/event edits visible only to owners.

---

## 10. Ethical Monetization
- Free tier MVP: one family, two guardians, two children, 50 expenses/month, no exports.
- Premium Family subscription (monthly/annual): unlimited children, attachments, CSV/PDF exports, advanced templates, smart notifications, widgets, Apple Watch, end-of-year summaries.
- Optional one-time Pro Pack unlocking exports and templates for users who avoid subscriptions.
- Family Sharing discounts, 14-day trial, educational vouchers for parent associations.
- No ads or data resale.

---

## 11. Naming and Branding Ideas
- FamPlanner (explicit and clear).
- MiTiempo (warm, Spanish roots).
- KidsTrack (global, all-in tracking).
- ClanHora (family + time).
- Cuadra (from "cuadrar" schedules and budgets).
- Nido (nest/home organization).

---

## 12. Prioritized Roadmap

**MVP (6–8 focused weeks)**
1. Project setup, DI, base design system, Auth (Apple/Google/email).
2. Family & Children CRUD with color/avatar selection.
3. Schedule: class/extracurricular CRUD, weekly view, duplicate/template flows.
4. Calendar: day/week view with manual events and local reminders.
5. Expenses: CRUD, monthly charts, basic filters.
6. Multi-user management: invite link (Firestore) or shared iCloud + basic roles.
7. Onboarding, splash, minimal settings (language, per-child theme).
8. Unit tests for use cases + SwiftUI snapshot tests for three hero screens.

**Phase 2 (8–12 weeks)**
- Push notifications + smart reminders (e.g., "class in 30 minutes", "monthly fee due").
- Widgets (next items, monthly spend).
- Apple Watch companion (today view + attendance toggle).
- CSV/PDF exports (monthly/yearly and "End of school year" dossier).
- EventKit sync (opt-in read/write).
- Optional HealthKit integration for sport minutes.

**Future**
- On-device intelligence to suggest schedules/reminders.
- Messaging integrations when APIs open.
- Web companion (if Firestore).
- Advanced App Intents automation (voice-first expense capture).

---

## 13. Implementation Capsules

### 13.1 Repository Example
```swift
protocol ExpensesRepository {
    func expenses(familyID: String, month: Date) async throws -> [Expense]
    func add(_ expense: Expense) async throws
    func delete(id: String) async throws
}

final class FirestoreExpensesRepository: ExpensesRepository {
    func expenses(familyID: String, month: Date) async throws -> [Expense] { /* query by familyID + month range */ }
    func add(_ expense: Expense) async throws { /* set document with serverTimestamp */ }
    func delete(id: String) async throws { /* delete */ }
}
```

### 13.2 Use Case
```swift
struct GetMonthlyExpenses {
    let repo: ExpensesRepository
    func callAsFunction(familyID: String, month: Date) async throws -> [Expense] {
        try await repo.expenses(familyID: familyID, month: month)
    }
}
```

### 13.3 SwiftUI View Model
```swift
@MainActor
@Observable
final class ExpensesViewModel {
    private let getMonthlyExpenses: GetMonthlyExpenses
    var items: [Expense] = []
    var total: Decimal = 0

    init(getMonthlyExpenses: GetMonthlyExpenses) { self.getMonthlyExpenses = getMonthlyExpenses }

    func load(familyID: String, month: Date) {
        Task {
            let data = try await getMonthlyExpenses(familyID: familyID, month: month)
            items = data
            total = data.reduce(0) { $0 + $1.amount }
        }
    }
}
```

### 13.4 App Intent (Quick Expense)
```swift
struct QuickExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Add quick expense"
    @Parameter(title: "Amount") var amount: Double
    @Parameter(title: "Category") var category: String
    func perform() async throws -> some IntentResult {
        // call AddExpense use case with current family context
        return .result()
    }
}
```

---

## 14. Visual System Guidelines
- Typography: SF Pro with adaptive sizes (Title2 for section headers, Body for cells, Caption for time chips).
- Color: neutral base palette + auto-generated HSL palettes per child meeting WCAG AA contrast.
- Core components: ScheduleCell (time chip + category icon), EventCard (title, time, avatar, reminder CTA), ExpenseRow (category, localized amount, optional note), EmptyState with lightweight illustration.
- Status/error banners for "Offline" and "Saved" events.
- Gestures: swipe to delete/duplicate, confirmation dialogs for destructive actions.

---

## 15. Calendar Sync via EventKit (Optional)
- Mirror strategy: each FamilyEvent stores an EventKit identifier when available.
- Conflict resolution favors app data; overwrite EventKit when the guardian confirms.
- Granular toggles: write access is opt-in; without permission default to read-only or disabled.

---

## 16. Sharing and Roles
- Invitation via Dynamic Link carrying familyID + short-lived token and a consent screen.
- Roles: Owner (subscription + delete family), Guardian (full CRUD), Viewer (read-only).
- Revocation UI listing members with "Remove access" actions.

---

## 17. Testing Strategy
- 100% coverage on domain use cases.
- Fake repositories feeding view models.
- Snapshot tests for key SwiftUI screens (weekly schedule, calendar, expenses).
- Basic UI tests: onboarding → create child → create class → verify calendar → add expense.

---

## 18. KPIs and Analytics (Privacy-Safe)
- Activation: % creating at least one child and class on day one.
- Retention D7/D30: weekly usage of schedule/calendar.
- Feature adoption: % duplicating schedules, % adding ≥1 expense/week.
- Premium conversion after export or attachment attempts.

---

## 19. Decision Highlights
- Stack: SwiftUI + Clean MVVM with pure domain and repository abstractions, TCA where logic is complex.
- Data: SwiftData + iCloud if iOS-only; Firestore for real-time collaboration and multi-platform targets.
- UX: per-child theming, clear weekly view, fast actions, accessibility from day one.
- Privacy: minimal data, role-based access, export/delete flows, strict rules.
- Monetization: honest freemium with Premium Family tier and no advertising.
