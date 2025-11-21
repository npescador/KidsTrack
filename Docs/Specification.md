# Specification (Historias de Usuario)

## 1. Contexto
KidsTrack ya cuenta con módulos App/Domain/Data/Presentation iniciales y estructuras de carpetas alineadas con Clean MVVM. Existen seeds de vistas y modelos, pero necesitamos un backlog accionable que consolide los próximos incrementos sin imponer procesos adicionales.

## 2. Supuestos de Estado Actual
- `KidsTrackApp` y la navegación básica están creadas; falta madurar coordinadores y estados.
- Modelos domain y contratos de repositorios existen en forma inicial (pueden ser stubs).
- SwiftData está configurado como almacenamiento local, aún sin sincronización CloudKit.
- Flujo de auth y onboarding parcialmente implementado (UI/esqueletos presentes, lógica incompleta).

## 3. Prioridades y Etiquetas
- **P0**: Bloqueantes para usar el MVP internamente.
- **P1**: Valor diferencial del MVP antes de beta cerrada.
- **P2**: Preparación para fase pública o funcionalidades extendidas.

## 4. Historias de Usuario con Subtareas

### P0-H1 Autenticación fiable
**Historia**: Como tutor, quiero iniciar sesión/registrarme con email y Apple ID para acceder desde distintos dispositivos.
- [ ] (T1) Completar `AuthRepository` con flujos Email/Password, Sign in with Apple y Sign in with Google, reutilizando `FirebaseAuth` si ya está enlazado o implementando stub seguro.
- [ ] (T2) Conectar `LoginViewModel` al repositorio y manejar estados `loading`, `error`, `success`.
- [ ] (T3) Ajustar `AppNavigationCoordinator` para reaccionar a `.didAuthenticate` y `.logout`, limpiando rutas.
- [ ] (T4) Tests unitarios de `LoginViewModel` y pruebas UI happy-path + error.
**Criterio**: Tras login válido la app muestra el shell autenticado; logout vuelve al login sin fugas de estado.

### P0-H2 Onboarding persistente
**Historia**: Como nuevo usuario, quiero que la app recuerde si completé el onboarding para no repetirlo.
- [ ] (T1) Introducir `OnboardingStateStore` (AppStorage o repositorio ligero) con reset para builds de desarrollo.
- [ ] (T2) Coordinar `AppNavigationCoordinator` para leer/escribir el flag y elegir root (`onboarding` vs `auth` vs `tabs`).
- [ ] (T3) Añadir pruebas unitarias del store y snapshot de pantallas clave con estados vacío/completo.
**Criterio**: Tras finalizar onboarding, al relanzar la app se entra directamente a auth/home según corresponda.

### P0-H3 Shell post-auth con tabs
**Historia**: Como tutor autenticado, necesito una estructura de pestañas (Hoy, Calendario, Gastos, Familia) para navegar rápidamente.
- [ ] (T1) Crear `AppShellView` con `TabView`/`NavigationStack` y rutas hashables.
- [ ] (T2) Implementar vistas stub (`TodayWeekView`, `CalendarView`, `ExpensesView`, `FamilyProfileView`) con estados vacíos accesibles.
- [ ] (T3) Inyectar view models fake/dummy para permitir demos sin backend.
**Criterio**: Desde login exitoso se muestra el TabView con pestañas navegables y cada una representa un estado vacío claro.

### P0-H4 Gestión básica de hijos y clases
**Historia**: Como tutor, quiero registrar hijos y sus clases semanales para visualizar horarios.
- [ ] (T1) Finalizar modelos domain (`Child`, `ClassSession`) y `SwiftData` equivalentes con validaciones de color único por familia.
- [ ] (T2) Implementar casos de uso `CreateChildProfile`, `CreateClassSession`, `LoadWeeklyPlan`.
- [ ] (T3) Construir `ChildListView` + `ChildDetailView` con formularios accesibles y detección de campos obligatorios.
- [ ] (T4) Mostrar vista semanal (`WeekScheduleView`) para un hijo con chips coloreados y aviso de conflictos.
- [ ] (T5) Tests: validación de solapamientos y snapshot de la vista semanal.
**Criterio**: Se puede crear un hijo, añadir clases y ver su horario semanal correctamente ordenado.

### P1-H5 Registro de actividades extraescolares
**Historia**: Como tutor, quiero registrar actividades (música, deporte, etc.) aparte de las clases.
- [ ] (T1) Extender modelos/casos de uso para `Activity`.
- [ ] (T2) UI de formulario y listados agrupados por hijo/día.
- [ ] (T3) Integrar actividades en la vista semanal y en Today.
**Criterio**: Actividades aparecen con iconografía de tipo y respetan validaciones de solapamiento.

### P1-H6 Gestión de eventos y calendario diario
**Historia**: Quiero crear eventos puntuales (médico, excursión) y verlos en un calendario día/semana.
- [ ] (T1) Implementar `FamilyEvent` repositorio + casos de uso (CRUD + recordatorios).
- [ ] (T2) Crear `CalendarView` con `TimelineView` diario y `LazyHGrid` semanal; integrar filtros por hijo/tipo.
- [ ] (T3) Añadir sincronización opcional con EventKit (escritura condicionada al permiso).
**Criterio**: Los eventos se muestran en calendario, se pueden crear/editar y opcionalmente sincronizar con Calendario nativo.

### P1-H7 Registro de gastos y estadísticas mensuales
**Historia**: Como tutor, quiero agregar gastos por categorías y ver el total del mes.
- [ ] (T1) Completar `Expense` modelos + `ExpenseRepository` (SwiftData) y mapear enums `ExpenseCategory`.
- [ ] (T2) Formularios para añadir/editar gastos vinculados a hijo y categoría.
- [ ] (T3) Vista `ExpensesView` con lista y resumen mensual (suma + gráfico simple con Charts).
- [ ] (T4) Caso de uso `MonthlySummary` y tests de cálculo.
**Criterio**: Puedo registrar gastos y ver totales por mes/hijo con gráficos accesibles.

### P1-H8 Exportación básica CSV
**Historia**: Quiero exportar los gastos a CSV para compartirlos.
- [ ] (T1) Caso de uso `ExportExpensesCSV` generando archivo temporal.
- [ ] (T2) UI con botón de exportación y `ShareLink`.
- [ ] (T3) Tests que validen encabezados y formato decimal/localización.
**Criterio**: Desde la vista de gastos se puede generar un CSV y compartirlo correctamente.

### P2-H9 Notificaciones y recordatorios
**Historia**: Deseo recibir recordatorios de clases/eventos próximos.
- [ ] (T1) Servicio `NotificationsScheduler` con UserNotifications y permisos.
- [ ] (T2) UI para activar/desactivar recordatorios por niño/actividad.
- [ ] (T3) Integración con casos de uso (al crear evento/clase se programa recordatorio).
**Criterio**: Al crear un evento con recordatorio se agenda una notificación local validada.

### P2-H10 Widgets y App Intents
**Historia**: Quiero ver próximos eventos y gastos desde la pantalla de inicio o atajo.
- [ ] (T1) Widgets (WidgetKit) mostrando la próxima clase/actividad y gasto del mes.
- [ ] (T2) App Intent para añadir gasto rápido.
- [ ] (T3) Pruebas de snapshot/widget y documentación de accesibilidad.
**Criterio**: Widgets refrescan datos reales y App Intent permite añadir un gasto sin abrir la app.

## 5. Dependencias/Secuencia Recomendada
1. Completar autenticación/onboarding (P0-H1, P0-H2) para poder probar flujos completos.
2. Montar shell de tabs (P0-H3) que servirá de marco para el resto de vistas.
3. Terminar gestión hijos/clases (P0-H4) para disponer de datos base.
4. Añadir actividades, eventos y gastos (P1-H5 a P1-H7) en paralelo según capacidad.
5. Exportación y sincronizaciones externas (P1-H8, P1-H6 EventKit).
6. Funciones avanzadas (P2-H9, P2-H10) cuando el MVP esté estable.

## 6. Criterios Globales de Calidad
- Todas las vistas tienen estados vacío/lleno y cumplen AA de contraste.
- Pruebas unitarias cubren casos de uso críticos (auth, horarios, gastos, exportación).
- Snapshot tests para vistas Calendario/Semana/Gastos.
- Trazabilidad: cada historia enlaza con commits/PRs siguiendo Conventional Commits.
