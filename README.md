1) Visión y principios

Objetivo: Una app iOS para familias que centraliza horarios (clase/extraescolares), calendario familiar y gastos asociados.
Principios:
	•	Offline-first + sync seguro (SwiftData o Firestore con persistencia local).
	•	Arquitectura limpia (separación Presentation/Domain/Data).
	•	UX “one-glance”: la familia ve lo próximo y el gasto del mes sin fricción.
	•	Escalable multi-hijo/multi-tutor con permisos.
	•	Privacidad by-design (COPPA/GDPR, mínimos datos, cifrado en tránsito/descanso).

⸻

2) Arquitectura recomendada (Clean MVVM con “núcleo TCA”)

2.1 Capa Presentation (SwiftUI)
	•	MVVM para pantallas (View + ViewModel @Observable o @MainActor).
	•	Router/Navigator con NavigationStack + NavigationPath y Router central.
	•	Estados críticos (p. ej., sincronización, notificaciones inteligentes) en features TCA: Reducer + State + Action, integrados en MVVM mediante un “Adapter” (facilita testeo y efectos asíncronos complejos).

2.2 Capa Domain
	•	Casos de uso (interactors) puros, síncronos/asíncronos, sin dependencias de UI ni Firebase.
	•	Entidades inmutables (struct) con validaciones.
	•	Repositorios como protocolos (inyección de dependencias).

2.3 Capa Data
	•	Implementaciones de repositorios:
	•	SwiftData (iCloud sync) o Firestore (offline cache + Cloud).
	•	EventKitRepository para lectura/escritura en Calendario (si el usuario lo permite).
	•	AuthRepository (Firebase Auth).
	•	NotificationsRepository (UserNotifications + App Intents).
	•	DTO ↔ Domain mappers, control de versiones de esquema y migraciones.

2.4 Concurrencia y efectos
	•	Swift 6 Concurrency (async/await, Sendable), TaskGroup para sincronías múltiples (ej. cargar horarios+eventos+gastos).

2.5 Telemetría y errores
	•	OSLog con categorías por feature.
	•	Crashlytics (si se usa Firebase) o MetricKit.
	•	Feature flags (Remote Config opcional).

⸻

3) Modelo de dominio (mínimo útil)

// Núcleo
struct Family: Identifiable { let id: String; var name: String; var members: [ChildID]; var owners: [UserID] }
struct Child: Identifiable { let id: String; var name: String; var birthdate: Date?; var avatarURL: URL?; var themeColor: String }
struct SchoolClass: Identifiable { let id: String; let childID: String; var title: String; var location: String?; var weekday: Int; var start: Date; var end: Date; var category: ClassCategory } // e.g., Math, Language
struct Activity: Identifiable { let id: String; let childID: String; var type: ActivityType; var weekday: Int; var start: Date; var end: Date; var notes: String? }
struct FamilyEvent: Identifiable { let id: String; let familyID: String; var title: String; var details: String?; var dateInterval: DateInterval; var location: String?; var attachments: [URL]?; var reminders: [Reminder] }
struct Expense: Identifiable { let id: String; let familyID: String; let childID: String?; let category: ExpenseCategory; let amount: Decimal; let date: Date; var notes: String?; var relatedIDs: [String]? /* class/activity/event */ }

// Enums
enum ActivityType: String { case sport, music, languages, art, other }
enum ExpenseCategory: String { case schoolMaterials, books, monthlyFee, gear, oneOff }

Relaciones clave:
	•	Family 1—* Child
	•	Child 1—* SchoolClass, Child 1—* Activity
	•	Family 1—* FamilyEvent, Family 1—* Expense

Indices (Firestore): por familyID, childID, date, weekday para consultas rápidas (semana/mes).

⸻

4) Persistencia: SwiftData vs Firestore (cómo decidir)
Recomendación práctica:
	•	Si solo iOS en próximos 12–18 meses → SwiftData (menos fricción, Widgets/Watch sencillos).
	•	Si prevés Android/Web o compartición avanzada en tiempo real → Firestore.

(Puedes abstraer con repositorios y mantener ambos “drivers” con el mismo dominio.)

5) Mapa de navegación (wireframe textual)
	•	[Splash] → [Onboarding 1-4] → [Auth] (Sign in / Sign up / Apple / Google)
	•	[Home (TabView)]
	•	Hoy: próximos (clase/actividad/evento) + resumen gasto mes
	•	Horario: vista semanal por hijo (toggle: Clases / Extraescolares)
	•	Calendario: día/semana con filtros (hijo, tipo) + crear evento
	•	Gastos: lista por mes, gráficos (Charts), filtros (hijo/categoría)
	•	Familia: hijos, invitaciones, ajustes (sync, exportar, notifs)
	•	Flujos modales/push
	•	Crear/editar Clase, Actividad, Evento (con adjuntos y recordatorios)
	•	Crear Gasto (picker de categoría, asignar hijo/actividad)
	•	Duplicar horarios / usar plantilla
	•	Invitar tutor (Dynamic Link)
	•	Permisos (Calendario, Notifs, Fotos/Files)

(Si te ayuda, puedo pasarlo a un diagrama Mermaid en otro paso.)

6) Estructura de carpetas (ejemplo)

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
    TCA/ScheduleFeature.swift  // Reducer/State/Action opcional
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
  Entities/ *.swift
  UseCases/
    CreateClass.swift
    DuplicateSchedule.swift
    AddExpense.swift
    GetWeeklyPlan.swift
    ...
  Repositories/
    ScheduleRepository.swift
    ExpensesRepository.swift
    EventsRepository.swift
    FamilyRepository.swift
    AuthRepository.swift

Data/
  Firestore/
    Repositories/ *.swift
    DTO/ *.swift
    Mappers/ *.swift
  SwiftData/
    Models/ *.swift
    Repositories/ *.swift
  EventKit/
    EventKitRepository.swift
  Auth/
    FirebaseAuthRepository.swift

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
  Widgets/
    NextItemsWidget.swift
  Localization/
    es.lproj, en.lproj
  Tests/
    Unit/, Snapshot/, UITests/


7) Frameworks y librerías
	•	UI: SwiftUI (iOS 18), Charts (Apple) para gasto mensual/anual.
	•	Auth: Firebase Auth (Apple, Google, email).
	•	Datos:
	•	SwiftData (+ iCloud) o Firebase Firestore (offline cache, reglas de seguridad).
	•	Calendario: EventKit (opcional; lectura/escritura con consentimiento).
	•	Notificaciones: UNUserNotificationCenter + App Intents para acciones rápidas (añadir gasto/evento).
	•	Widgets: WidgetKit (Lock Screen/Home).
	•	Push: Firebase Cloud Messaging (si Firestore) o APNs directo.
	•	Archivos/adjuntos: PhotosPicker, FileImporter, PDFKit (vista previa).
	•	StoreKit 2: suscripciones, Family Sharing.
	•	Observabilidad: OSLog, MetricKit, Crashlytics (si Firebase).
	•	Testing: XCTest, SnapshotTesting (point-in-time de SwiftUI), swift-testing si adoptas nuevo paquete.

⸻

8) UX/UI para apps familiares (rápido y efectivo)
	•	Primer uso guiado: onboarding corto con “Add child” y plantilla de horario (por ciclo: infantil/primaria/secundaria).
	•	Color por hijo + iconos por categoría → comprensión instantánea.
	•	Doble densidad en “Horario semanal”: modo compacto (chips) y modo detallado (cards).
	•	Acciones rápidas: FAB/Toolbar “+” contextual (gasto/evento/clase según tab).
	•	Empty states útiles con CTA: “Añade tu primera actividad” + botón importar desde plantilla.
	•	Accesibilidad: Dynamic Type, alto contraste, VoiceOver labels semánticos (“Clase de Música, hoy 17:00”).
	•	Feedback inmediato: Haptics ligeros al crear/duplicar.
	•	Privacidad visible: banner de control de datos, consentimiento de compartir perfil.

⸻

9) Seguridad y privacidad (menores)
	•	Minimización: evita datos sensibles (colegio exacto opcional; ubicación solo si imprescindible).
	•	Consentimiento verificable (tutor principal) para compartir con otros tutores.
	•	Cifrado en tránsito (TLS) y en reposo; si Firestore, usa Reglas por familyID/owner.
	•	Controles de acceso: roles (owner, guardian, viewer); revocación de invitaciones.
	•	Privacy Nutrition Label honesto; App Tracking Transparency: probablemente no necesaria si no hay tracking cross-app.
	•	Data lifecycle: exportar (CSV/PDF), borrar cuenta/datos (GDPR Art. 17), retención definida (p. ej. 24 meses).
	•	Auditoría: log interno de cambios en gastos/eventos (solo visible a owners).

⸻

10) Monetización ética
	•	Free (MVP): 1 familia, 2 tutores, 2 hijos, 50 gastos/mes, sin exportación.
	•	Premium Familiar (Suscripción anual o mensual): hijos ilimitados, adjuntos, exportar CSV/PDF, plantillas avanzadas, notifs inteligentes, widgets, Apple Watch, “Fin de curso”.
	•	Compra única “Pro Pack” (si prefieres no-subs) para exportaciones + plantillas.
	•	Descuentos Family Sharing, prueba 14 días, edu voucher para AMPAs.
	•	Sin anuncios, sin venta de datos.

⸻

11) Nombres/marca (con concepto)
	•	FamPlanner (claro, directo)
	•	MiTiempo (cálido, español)
	•	KidsTrack (anglo, tracking integral)
	•	ClanHora (familiar + tiempo)
	•	Cuadra (de “cuadrar”: horarios y gastos)
	•	Nido (hogar/organización; logo simple)

⸻

12) Roadmap priorizado

MVP (6–8 semanas de esfuerzo concentrado)
	1.	Fundación: proyecto, DI, Design System base, Auth (Apple/Google/email).
	2.	Familia & Hijos: CRUD hijo, color/avatar.
	3.	Horario: clases/extraescolares (CRUD) + vista semanal + duplicar/plantilla.
	4.	Calendario: día/semana + crear evento manual con recordatorios locales.
	5.	Gastos: CRUD + gráficos (mes) + filtros básicos.
	6.	Gestión multiusuario: invitación por enlace (si Firestore) o compartir iCloud (limitado) + roles básicos.
	7.	Onboarding + Splash + Ajustes mínimos (idioma, tema por hijo).
	8.	Tests unitarios de casos de uso + snapshots de 3 pantallas clave.

Fase 2 (8–12 semanas)
	•	Notifs push + recordatorios inteligentes (heurísticas: “clase en 30 min”, “cuota mensual vence”).
	•	Widgets (próximos eventos, gasto del mes).
	•	Apple Watch app (próximos del día + marcar “asistido”).
	•	Exportar CSV/PDF (resumen por mes/año y “Fin de curso”).
	•	EventKit Sync (opt-in): escribir/leer al calendario del sistema.
	•	HealthKit (opcional): si quieres registrar minutos de actividad física (deporte).

Futuro
	•	IA ligera on-device: sugerir horarios/recordatorios en base a patrones.
	•	TokkApp u otras integraciones de mensajería (si abren API).
	•	Web companion (si Firestore).
	•	Automations: App Intents avanzados (“Añadir gasto rápido por voz”).

⸻

13) Detalles de implementación (píldoras)

13.1 Repositorio (ejemplo)

protocol ExpensesRepository {
    func expenses(familyID: String, month: Date) async throws -> [Expense]
    func add(_ expense: Expense) async throws
    func delete(id: String) async throws
}

final class FirestoreExpensesRepository: ExpensesRepository {
    // init(db: Firestore, mapper: ExpenseMapper) ...
    func expenses(familyID: String, month: Date) async throws -> [Expense] { /* query by familyID + month range */ }
    func add(_ expense: Expense) async throws { /* set document with serverTimestamp */ }
    func delete(id: String) async throws { /* delete */ }
}

13.2 Caso de uso

struct GetMonthlyExpenses {
    let repo: ExpensesRepository
    func callAsFunction(familyID: String, month: Date) async throws -> [Expense] {
        try await repo.expenses(familyID: familyID, month: month)
    }
}

13.3 ViewModel (SwiftUI)

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
            self.items = data
            self.total = data.reduce(0) { $0 + $1.amount }
        }
    }
}

13.4 App Intent (gasto rápido)

struct QuickExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Añadir gasto rápido"
    @Parameter(title: "Cantidad") var amount: Double
    @Parameter(title: "Categoría") var category: String
    func perform() async throws -> some IntentResult {
        // llamar a caso de uso AddExpense con family actual
        return .result()
    }
}


⸻

14) Diseño del sistema visual
	•	Tipografía: SF Pro, tamaños adaptativos (Title2 para encabezados de lista; Body para celdas; Caption para chips de hora).
	•	Color: paleta base neutra + paletas hijo autogeneradas (HSL con contraste WCAG AA).
	•	Componentes reutilizables:
	•	ScheduleCell (chip horario con icono/categoría)
	•	EventCard (título, hora, avatar hijo, “Añadir recordatorio”)
	•	ExpenseRow (categoría, importe con formato local, nota opcional)
	•	EmptyState con ilustración ligera
	•	Estados/errores: banners claros (“Sin conexión”, “Guardado”).
	•	Gestos: deslizamiento para borrar/duplicar, confirmationDialog para acciones destructivas.

⸻

15) Sincronización con Calendario (EventKit) — opcional
	•	Estrategia “espejo”: cada FamilyEvent puede tener eventIdentifier de EventKit.
	•	Conflictos: prioriza cambios en la app y reescribe en EventKit si el usuario lo decide.
	•	Permisos granulares: toggle “Escribir en Calendario”; sin permisos, solo lectura o nada.

⸻

16) Compartición y roles
	•	Invitación: Dynamic Link con familyID + token corto; pantalla previa con consentimiento.
	•	Roles:
	•	Owner (gestiona suscripción, borra familia)
	•	Guardian (CRUD contenido)
	•	Viewer (solo lectura)
	•	Revocación: lista de miembros y botón “Quitar acceso”.

⸻

17) Estrategia de tests
	•	Domain 100% (casos de uso puros).
	•	Repos fakes para ViewModels.
	•	Snapshot de UI (horario semanal, calendario, gastos).
	•	UITests básicos: onboarding → crear hijo → crear clase → ver en calendario → añadir gasto.

⸻

18) KPIs y analítica (sin invadir privacidad)
	•	Activación: % que crean ≥1 hijo y ≥1 clase el día 1.
	•	Retención D7/ D30: uso semanal del horario/calendario.
	•	Feature adoption: % que usa duplicar horario; % que crea ≥1 gasto/semana.
	•	Conversión Premium: tras evento “exportar” o “añadir adjunto”.

⸻

19) Resumen de decisiones clave
	•	Stack: SwiftUI + Clean MVVM, domain puro + repos; TCA donde haya lógica compleja.
	•	Datos: SwiftData (iCloud) si solo iOS; Firestore si buscas tiempo real/Android/Web.
	•	UX: color por hijo, vista semanal clara, acciones rápidas, accesibilidad fuerte.
	•	Privacidad: mínimos datos, roles, exportar/borrar, reglas estrictas.
	•	Monetización: Freemium honesto + Premium Familiar sin anuncios.

⸻


