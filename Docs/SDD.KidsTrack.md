# SDD – App de gestión de horarios y gastos familiares (versión 1.1.1)

## 0. Metadatos del documento

- Proyecto: App iOS de gestión de horarios escolares/extraescolares y gastos
- Versión del SDD: 1.1.1
- Plataforma: iOS (iPhone, soporte inicial)
- Tecnologías objetivo:
  - Swift, SwiftUI
  - Clean Architecture + MVVM
  - Módulos: Data, Domain, Presentation, Shared
  - Backend inicial: Firebase (Auth + Firestore)
  - Integraciones iOS: Sign in with Apple, Sign in with Google, Calendario (EventKit)

---

## 1. Visión y objetivos

### 1.1 Visión

Crear una aplicación para iOS que permita a las familias organizar horarios escolares y extraescolares de sus hijos, junto con el control de los gastos, compartidos entre varios adultos (p.ej. padre y madre) con sincronización en tiempo real y opción de exportar los horarios al calendario nativo del iPhone.

---

## 2. Alcance del MVP

El MVP cubre:

1. Login / Registro:
   - Email/Password
   - Sign in with Apple
   - Sign in with Google

2. Modelo de familia compartida:
   - Una o varias “familias” por usuario.
   - Varios adultos pueden estar en la misma familia (padre, madre, etc.).
   - Sincronización en tiempo real de datos de la familia entre todos los miembros.

3. Gestión de hijos (crear, editar, eliminar) dentro de una familia.

4. Gestión de horarios escolares por hijo.

5. Gestión de actividades extraescolares.

6. Control de gastos básico por actividad e hijo.

7. Vista semanal combinada escolar + extraescolares.

8. Exportación de horarios al Calendario del iPhone (escolar y extraescolar).

### Fuera de alcance del MVP (para futuras fases)

- Roles avanzados (p.ej. permisos distintos para “viewer/editor”).
- Sincronización automática bidireccional con el Calendario (en MVP será de la app → Calendario).
- Widgets, Apple Watch, etc.

---

## 3. Stakeholders y usuarios

Sin cambios de fondo, pero ahora explícitamente:

- Progenitores y adultos responsables: pueden compartir la misma familia con acceso completo en tiempo real.
- Niños/adolescentes: podrán consultar la información desde sus propios dispositivos si se les invita como miembros (opcional en fases futuras).

---

## 4. Requisitos funcionales (RF)

### 4.1 Autenticación y cuenta

**RF-01 – Registro de usuario con Email/Password**

- Igual que antes, pero se asume ya integrado con Firebase Auth.

**RF-02 – Inicio de sesión con Email/Password**

- Igual que antes.

**RF-03 – Recuperación de contraseña**

- Igual que antes (flujo Firebase).

**RF-04 – Cierre de sesión**

- Igual que antes.

**RF-05 – Sign in with Apple**

- El usuario puede autenticarse usando su Apple ID.

Requisitos:
- Integrar Sign in with Apple siguiendo las guías de Apple.
- Soportar la creación de cuenta si es la primera vez que inicia sesión con Apple.

Criterios de aceptación:
- Tras un login correcto, el usuario aterriza en la pantalla de selección/creación de familia.

**RF-06 – Sign in with Google**

- El usuario puede autenticarse usando su cuenta de Google.

Requisitos:
- Integración con Google Sign-In + Firebase Auth.
- Creación de usuario si es primera vez.

**RF-07 – Unificación de cuentas por email (opcional)**

- Si un usuario entra con un método diferente (email, Apple, Google) pero con la misma dirección de correo verificada, se deberá evitar duplicados en la medida de lo posible.
- En MVP se puede permitir duplicidad siempre que no rompa la experiencia, y refinar este punto en v2.

---

### 4.2 Gestión de familia y multiusuario

Nueva sección clave para lo que se quiere (padre/madre compartiendo todo).

**RF-15 – Crear familia**

- Tras el primer login, el usuario puede:
  - Crear una nueva familia (p.ej. “Familia Pescador Ruiz”).
- Campos: nombre de la familia (obligatorio).
- El usuario que la crea pasa a ser Owner de la familia.

**RF-16 – Selección de familia**

- Si el usuario pertenece a varias familias, al entrar puede elegir con cuál trabajar (o cambiar de familia desde Ajustes).

**RF-17 – Invitar a otro adulto a la familia**

- El Owner (y opcionalmente otros miembros con permisos) puede invitar a otros adultos:
  - Por email (campo email).

Flujo MVP propuesto:
- Se genera una relación “invitation” asociada a la familia y al email.
- Cuando ese email se registre / inicie sesión, verá una pantalla de “Tienes invitaciones pendientes: ¿quieres unirte a la familia X?”.

**RF-18 – Aceptar invitación a familia**

- El usuario invitado puede aceptar o rechazar la invitación.
- Al aceptarla: se añade como FamilyMember y ya ve los hijos, horarios, actividades y gastos de esa familia.

**RF-19 – Sincronización en tiempo real de familia (multi-cuenta / multi-dispositivo)**

Cualquier cambio en:
- Hijos
- Horario escolar
- Actividades extraescolares
- Gastos

asociado a una familia debe reflejarse en tiempo real (en segundos) en todos los dispositivos conectados a esa familia.

Implementación:
- Listeners de Firestore (o similar) suscritos a la familia activa.

Criterio de aceptación:
- Si el padre añade una actividad en su móvil, la madre la ve aparecer en la vista correspondiente sin necesidad de refrescar manualmente (tras un pequeño delay normal de red).

---

### 4.3 Gestión de hijos

Igual que antes, pero el vínculo ya no es userId, sino familyId.

**RF-10 – Listado de hijos de una familia**

- Muestra los hijos asociados a la familia activa.

**RF-11 – Crear hijo**  
**RF-12 – Editar hijo**  
**RF-13 – Eliminar hijo**

- Misma semántica, pero siempre dentro de la familia activa.

---

### 4.4 Horario escolar

RF-20, 21, 22 se mantienen como antes, pero conceptualmente:

- Las franjas SchoolSlot están asociadas a childId → familyId (vía el hijo).
- Cualquier modificación se sincroniza en tiempo real para todos los miembros de la familia (por RF-19).

---

### 4.5 Actividades extraescolares

RF-30, 31, 32, 33 igual que antes, con la misma lógica de familia y sincronización en tiempo real.

---

### 4.6 Vista semanal combinada

**RF-40 – Vista semanal total por hijo**

- Igual que antes, pero debe reflejar cambios en tiempo real.

**RF-41 – Cambio rápido de hijo**

- Igual.

---

### 4.7 Control de gastos

RF-50, 51, 52, 53 se mantienen, pero ahora:

- Los gastos están asociados a la familia vía childId / familyId.
- Cualquier nuevo gasto, edición o eliminación se sincroniza en tiempo real con el resto de miembros.

---

### 4.8 Notificaciones (MVP sencillo)

- RF-60 queda como opcional, igual que antes.

---

### 4.9 Exportación a Calendario del iPhone

Nueva sección para la integración con Calendario.

**RF-80 – Solicitud de permisos de Calendario**

- La primera vez que el usuario intente exportar horarios al Calendario:
  - La app solicitará permiso de acceso al Calendario (EventKit).
  - Si el usuario lo deniega, se muestra un mensaje claro explicando que no se podrá exportar hasta que habilite permisos en Ajustes.

**RF-81 – Exportar calendario escolar de un hijo**

- En la vista de un hijo o en ajustes de ese hijo, el usuario puede seleccionar “Exportar horario escolar al Calendario”.

Comportamiento propuesto MVP:
- Se crea (o se reutiliza si ya existe) un calendario interno de la app, p.ej. “Horarios KidsTrack – [Nombre Hijo]”.
- Se generan eventos recurrentes para cada franja escolar (SchoolSlot):
  - Repetición semanal.
  - Fecha de inicio: siguiente lunes (o la fecha configurada).
  - Sin fecha de fin en MVP, o fin a X meses vista (según se defina).

**RF-82 – Exportar actividades extraescolares de un hijo**

- Similar a RF-81, pero para actividades extraescolares:
  - También se crean como eventos recurrentes en el calendario de ese hijo, o en otro calendario único de la app (decisión de diseño: en MVP puede ser el mismo calendario).

**RF-83 – Exportar todos los hijos de una familia**

- Opcional en MVP, pero recomendable:
  - Desde una sección de “Calendario” o Ajustes, botón “Exportar todos los horarios de la familia al Calendario”.
  - Itera por todos los hijos y crea/actualiza eventos.

**RF-84 – Actualización de eventos exportados**

- En MVP, la aproximación sencilla:
  - Cada vez que el usuario pulse “Exportar de nuevo”, se regeneran los eventos correspondientes (se podría borrar primero los eventos de ese calendario y recrearlos).
  - No se requiere sincronización automática en segundo plano cada vez que se edite una franja (quedaría para una v2 con más lógica).

**RF-85 – No duplicar calendarios**

- Si ya existe un calendario “Horarios KidsTrack – [Nombre Hijo]”, se reutiliza.
- Evitar crear calendarios duplicados cada vez que se exporta.

---

## 5. Requisitos no funcionales (RNF)

**RNF-01 – Rendimiento y fluidez**

- La app debe sentirse rápida y fluida:
  - Tiempo de arranque en frío dentro de umbral razonable (p.ej. < 3–4 segundos en dispositivos objetivo).
  - Scroll fluido en listas de horarios/actividades (objetivo 60 fps).
  - Operaciones de red y escritura/lectura de Firestore realizadas en background sin bloquear la UI.
- Se deben identificar y eliminar cuellos de botella evidentes (renderizados innecesarios, consultas redundantes, etc.).

**RNF-02 – Usabilidad y accesibilidad**

- La app se diseñará con especial atención a accesibilidad:
  - Soporte de Dynamic Type (tamaños de texto del sistema).
  - Contraste suficiente entre texto y fondo en tema claro y oscuro.
  - Elementos interactivos con tamaño mínimo de toque adecuado.
  - Etiquetas de VoiceOver significativas en botones, iconos y elementos clave.
  - Navegación clara y predecible en los flujos principales (login, selección de familia, vista semanal).
- Se realizará una revisión de accesibilidad específica (ver sección 9.1).

**RNF-03 – Seguridad**

- Gestión adecuada de tokens y credenciales de Apple/Google/Firebase:
  - No persistir información sensible en claro.
  - Uso de Keychain para cualquier secreto local si fuese necesario.
- Reglas de seguridad de Firestore configuradas para:
  - Asegurar que un usuario solo puede leer/escribir datos de las familias a las que pertenece.
  - Proteger datos de otros usuarios/familias.
- Valorar medidas adicionales (p.ej. validaciones en servidor, limitación de intentos de login abusivo).
- Se realizará una revisión de seguridad específica (ver sección 9.2).

**RNF-04 – Escalabilidad**

- Arquitectura preparada para:
  - Multi-familia por usuario.
  - Más miembros por familia.
  - Futura extensión a otras plataformas (iPad, macOS).

**RNF-05 – Testeabilidad**

- Sin cambios, pero se recomienda:
  - Tests unitarios de casos de uso clave (creación de familia, invitaciones, exportación a calendario).
  - Tests de integración básicos de repositorios (Firebase / EventKit con dobles de prueba cuando proceda).

**RNF-06 – Sincronización en tiempo real**

- Los cambios hechos a nivel de familia deben propagarse a través de listeners de base de datos (p.ej. Firestore).
- La capa Domain no debe depender directamente de Firestore; la lógica de sync se encapsula en los repositorios del módulo Data.

**RNF-07 – Calidad de UI/UX**

- La interfaz debe ser consistente, limpia y alineada con las guías de diseño de iOS:
  - Uso coherente de tipografías, tamaños y espaciados.
  - Jerarquía visual clara (qué es primario, qué es secundario).
  - Estados claros para elementos interactivos (cargando, deshabilitado, error, éxito).
- Se planifica una revisión específica de UI/UX para detectar posibles mejoras (ver sección 9.4).

---

## 6. Modelo de datos (conceptual) – Actualizado

### 6.1 Entidades principales

**User**
- id
- email
- displayName (opcional)
- providerData (email/password, apple, google)

**Family**
- id
- nombre
- createdAt
- ownerUserId

**FamilyMember**
- id
- familyId
- userId
- rol (owner, member)

**Child (Hijo)**
- id
- familyId   ← Antes era userId
- nombre
- fechaNacimiento (opcional)
- curso (opcional)
- colorId / avatar

**SchoolSlot (Franja Escolar)**
- id
- childId
- diaSemana (L–D)
- horaInicio
- horaFin
- asignatura / descripción
- aula (opcional)

**Activity (Actividad Extraescolar)**
- id
- childId
- nombre
- categoria (deporte/música/idiomas/otro)
- diasSemana [array]
- horaInicio
- horaFin
- localizacion
- costeRecurrente (opcional)
- tipoRecurrencia (mensual/trimestral/anual) (opcional)
- fechaInicioPago (opcional)

**Expense (Gasto)**
- id
- childId
- activityId (opcional)
- importe
- concepto
- fecha

> Opcional futuro: `CalendarExportConfig` para guardar info de qué hijos ya se han exportado, id del calendario creado, etc.

---

## 7. Arquitectura y módulos – Ajustes

### 7.1 Módulos

**Shared**
- Tipos comunes (Money, AppError, helpers de fechas, etc.).

**Domain**
- Entidades de dominio (User, Family, FamilyMember, Child, Activity, Expense).
- Repositorios (protocols):
  - AuthRepository (email, Apple, Google)
  - FamilyRepository
  - ChildrenRepository
  - ScheduleRepository
  - ExpensesRepository
  - CalendarExportRepository (abstracción sobre EventKit).
- Use cases:
  - CreateFamilyUseCase
  - InviteMemberUseCase
  - AcceptInvitationUseCase
  - GetFamilyRealtimeUpdatesUseCase (o similar)
  - ExportChildScheduleToCalendarUseCase, etc.

**Data**
- Implementaciones Firebase de los repositorios.
- Lógica de listeners en tiempo real por familia.
- Implementación de CalendarExportRepository usando EventKit.

**Presentation**
- SwiftUI Views + ViewModels, orquestando:
  - Flujos de auth (incluyendo Apple + Google)
  - Selección de familia
  - Gestión de hijos, horarios, actividades, gastos
  - Pantalla/acciones para exportar al Calendario

---

## 8. Flujos clave añadidos

### 8.1 Padre y madre compartiendo familia

1. Padre crea cuenta (Apple, Google o email) → crea “Familia X”.
2. Padre invita por email a madre.
3. Madre se registra/inicia sesión con el mismo email al que se envió la invitación (Apple, Google o email/password).
4. Madre ve pantalla “Has sido invitado a la familia X” → Aceptar.
5. Ambos ven los mismos hijos, horarios y gastos, con cambios sincronizados en tiempo real.

### 8.2 Exportar horario de un hijo al Calendario

1. Usuario entra en detalle de un hijo → botón “Exportar al Calendario”.
2. Si no hay permisos de Calendario, se solicitan.
3. Se crea o reutiliza el calendario de la app para ese hijo.
4. Se generan los eventos recurrentes (escolares + extraescolares, según la acción).

---

## 9. Revisiones específicas de calidad

Esta sección recoge explícitamente las tareas de revisión/corrección que se deberán realizar sobre la base del producto funcional.

### 9.1 Revisión y corrección de accesibilidad

Objetivo: asegurar que la app es utilizable por el mayor número posible de usuarios, incluyendo personas con diversidad funcional.

Checklist mínima:
- Verificar soporte de Dynamic Type en pantallas principales (login, listado de hijos, vista semanal, detalle de actividades).
- Comprobar contraste de colores en tema claro/oscuro.
- Asegurar que todos los botones e iconos críticos tienen `accessibilityLabel` adecuado.
- Comprobar navegación con VoiceOver en los flujos principales.
- Revisar tamaño mínimo de objetivos táctiles.

Resultado esperado:
- Lista de hallazgos de accesibilidad.
- Correcciones aplicadas o backlog creado con prioridad para las pendientes.

### 9.2 Revisión y corrección de seguridad

Objetivo: minimizar riesgos asociados al manejo de datos personales y familiares.

Checklist mínima:
- Revisar implementación de Firebase Auth (manejo de errores, flujos de login social, logout).
- Revisar reglas de seguridad de Firestore:
  - Acceso restringido por `familyId` y `userId`.
  - Prohibir operaciones de escritura fuera del ámbito del usuario.
- Revisar almacenamiento local (Keychain, UserDefaults) para evitar guardar datos sensibles en claro.
- Revisar uso de tokens y credenciales (no logear datos sensibles, no exponer claves en el cliente).

Resultado esperado:
- Informe breve con posibles vulnerabilidades y correcciones aplicadas.
- Ajuste de reglas de Firestore y configuración de Auth según sea necesario.

### 9.3 Revisión y corrección de rendimiento (performance)

Objetivo: garantizar que la app es lo más rápida y fluida posible.

Checklist mínima:
- Medir tiempos de carga de:
  - Pantalla inicial / login.
  - Selección de familia.
  - Vista semanal.
- Revisar que las consultas a Firestore están indexadas y paginadas cuando proceda.
- Evitar recomputaciones costosas en SwiftUI (uso adecuado de `@State`, `@StateObject`, `@ObservedObject`, `@EnvironmentObject`).
- Comprobar que las operaciones pesadas (red, parseos, etc.) no bloquean el hilo principal.

Resultado esperado:
- Identificación de puntos de mejora (si los hay).
- Optimización aplicada o tareas abiertas con prioridades.

### 9.4 Revisión de UI y posibilidades de mejora

Objetivo: elevar la calidad visual y de interacción de la app.

Checklist mínima:
- Revisar consistencia visual:
  - Tipografías, colores, espaciados.
  - Estilo de botones, tarjetas, ítems de lista.
- Comprobar que la jerarquía visual es clara:
  - Elementos principales destacados.
  - Acciones secundarias menos prominentes.
- Evaluar flujo de usuario:
  - Número de pasos para tareas frecuentes (ver horario de un hijo, añadir actividad, ver gastos).
  - Posibles atajos o mejoras en la navegación.
- Valorar incorporación futura de:
  - Estados vacíos (empty states) más explicativos.
  - Mensajes de error/éxito más claros.

Resultado esperado:
- Lista de mejoras UI/UX priorizadas.
- Aplicación de quick wins en este MVP y backlog para mejoras mayores.

---