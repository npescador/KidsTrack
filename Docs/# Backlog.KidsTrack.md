# Backlog MVP KidsTrack  
## Historias de usuario + Criterios de aceptación  
_Renumerado y ordenado según dependencias (auth → familias → hijos → horarios → actividades → vista combinada → gastos → calendario → revisiones)._

---

## ÉPICA 1 — Autenticación y sesión

### US-01 — Inicio de sesión con Email/Password (RF-02)

**Como** usuario registrado,  
**quiero** iniciar sesión con mi email y mi contraseña,  
**para** acceder a mis familias y datos.

**Criterios de aceptación**

- El formulario debe tener campos:
  - Email (obligatorio, formato válido).
  - Password (obligatorio).
- Si las credenciales son incorrectas muestra un mensaje de error.
- Los errores de red muestran un mensaje e invitan a reintentar.
- Mientras se valida el login se muestra indicador de carga.
- Tras un login correcto se cargan las familias del usuario y se navega a “Selección de familia”.
- Si el usuario solo pertenece a una familia, la app puede navegar directamente a esa familia (decisión de producto).

---

### US-02 — Recuperación de contraseña (RF-03)

**Como** usuario,  
**quiero** solicitar un enlace de recuperación de contraseña por email,  
**para** poder recuperar el acceso si la olvido.

**Criterios de aceptación**

- La pantalla de recuperación tiene un único campo email.
- Tras enviar:
  - Se muestra mensaje tipo “Si existe una cuenta asociada, recibirás un correo”.
  - No se indica si el email está o no registrado.
- Errores de red se muestran con un mensaje y permiten reintentar.
- El botón de enviar se desactiva mientras se procesa la petición.

---

### US-03 — Cierre de sesión (RF-04)

**Como** usuario,  
**quiero** cerrar sesión,  
**para** poder cambiar de cuenta o dejar la app protegida.

**Criterios de aceptación**

- Al cerrar sesión:
  - Se cierran los listeners de Firestore asociados.
  - Se limpia el estado local (familia activa, hijos, etc.).
  - Se vuelve a la pantalla de login.
- Si ocurre un error al cerrar sesión se muestra un mensaje pero no se dejan credenciales en memoria.

---

### US-04 — Inicio de sesión con Apple (RF-05)

**Como** usuario de iOS,  
**quiero** iniciar sesión con mi Apple ID,  
**para** no tener que gestionar una contraseña adicional.

**Criterios de aceptación**

- Hay un botón “Sign in with Apple” que cumple las guías de Apple (tamaño, estilo).
- Si es la primera vez que el usuario inicia sesión, se crea una cuenta en Firebase Auth.
- Tras el login correcto se accede a “Selección/Creación de familia”.
- Los errores de autenticación o cancelación del usuario se muestran con mensajes claros.
- Se soporta el caso de email privado de Apple (relay).

---

### US-05 — Inicio de sesión con Google (RF-06)

**Como** usuario con cuenta de Google,  
**quiero** iniciar sesión usando Google,  
**para** acceder rápidamente sin recordar otra contraseña.

**Criterios de aceptación**

- Hay un botón de “Sign in with Google” visible en la pantalla de login.
- El flujo se integra con Firebase Auth (Google provider).
- Si es la primera vez se crea el usuario en Firebase.
- Tras el login correcto se navega a “Selección/Creación de familia”.
- Los errores (cancelación, red, configuración) muestran mensajes adecuados.

---

## ÉPICA 2 — Familias compartidas

### US-06 — Crear familia (RF-15)

**Como** usuario autenticado,  
**quiero** crear una familia con un nombre,  
**para** agrupar a mis hijos, horarios y gastos.

**Criterios de aceptación**

- Formulario con:
  - Nombre de la familia (obligatorio).
- El usuario que crea la familia queda marcado como Owner.
- La nueva familia queda marcada como familia activa.
- La familia se almacena en Firestore con relación al userId.
- Si ocurre un error al crear la familia se muestra un mensaje y el usuario puede reintentar.

---

### US-07 — Seleccionar familia activa (RF-16)

**Como** usuario que pertenece a varias familias,  
**quiero** seleccionar con qué familia trabajar,  
**para** ver solo los hijos y datos correspondientes.

**Criterios de aceptación**

- Se muestra una lista de familias donde el usuario es miembro.
- Al seleccionar una familia:
  - Se actualiza la familia activa en el estado de la app.
  - Se reconfiguran los listeners de Firestore para ese familyId.
- La app debe recordar la última familia activa entre sesiones (p. ej. en almacenamiento local).
- Si el usuario deja de ser miembro de una familia (caso futuro), no debe aparecer en la lista.

---

### US-08 — Invitar a otro adulto a la familia (RF-17)

**Como** Owner de una familia,  
**quiero** invitar a otro adulto por email,  
**para** compartir la gestión de hijos, horarios y gastos.

**Criterios de aceptación**

- Formulario con:
  - Email del invitado (obligatorio, formato válido).
- Al confirmar:
  - Se crea un registro de invitación asociado a:
    - familyId
    - email invitado
    - estado (pendiente, aceptada, rechazada)
- Se muestra un mensaje de confirmación: “Invitación enviada”.
- Si ya existe una invitación pendiente para ese email y familia, se evita duplicarla o se informa al usuario.
- Los errores de red se manejan con mensaje y opción de reintentar.

---

### US-09 — Aceptar o rechazar invitación (RF-18)

**Como** adulto invitado,  
**quiero** ver mis invitaciones y aceptarlas o rechazarlas,  
**para** unirme a la familia si lo deseo.

**Criterios de aceptación**

- Al iniciar sesión, si hay invitaciones vinculadas a mi email:
  - La app debe mostrar una pantalla o banner informando de ellas.
- Para cada invitación:
  - Aceptar:
    - Me añade como FamilyMember de esa familia.
    - Cambia el estado de la invitación a “aceptada” o se elimina.
  - Rechazar:
    - Se marca como “rechazada” o se elimina.
- Tras aceptar, la familia aparece en la lista de familias del usuario.
- Los errores (por ejemplo, invitación caducada o familia eliminada) deben mostrarse de forma clara.

---

### US-10 — Sincronización en tiempo real de datos familiares (RF-19)

**Como** miembro de una familia,  
**quiero** que los cambios en hijos, horarios, actividades y gastos se reflejen en tiempo real,  
**para** tener siempre la misma información que el resto de adultos.

**Criterios de aceptación**

- Si un miembro crea, edita o elimina:
  - Hijos
  - SchoolSlots (horario escolar)
  - Actividades extraescolares
  - Gastos
  estos cambios se ven automáticamente en ≤ 5 segundos en otros dispositivos conectados.
- La suscripción a los cambios debe estar ligada al familyId activo.
- Si se pierde la conexión:
  - La app debe reconectar automáticamente los listeners cuando vuelva la red.
- No deben producirse duplicados visuales ni inconsistencias evidentes en la UI.

---

## ÉPICA 3 — Gestión de hijos

### US-11 — Ver listado de hijos (RF-10)

**Como** miembro de una familia,  
**quiero** ver la lista de hijos de la familia activa,  
**para** acceder a su información, horarios y actividades.

**Criterios de aceptación**

- Se muestran todos los hijos asociados al familyId activo.
- Para cada hijo se visualiza al menos:
  - Nombre
  - Avatar/color
  - Curso (si se ha rellenado)
- La lista se alimenta de datos en tiempo real (FamilyRealtimeSnapshot) y refleja altas/bajas/ediciones en ≤ 5 segundos sin recargar manualmente.
- Al cambiar de familia activa, la vista se actualiza al nuevo snapshot.
- Si no hay hijos:
  - Se muestra un estado vacío con texto explicativo.
  - Se muestra un botón “Añadir hijo”.

---

### US-12 — Crear hijo (RF-11)

**Como** miembro de una familia,  
**quiero** crear un hijo dentro de la familia,  
**para** poder definir su horario y actividades.

**Criterios de aceptación**

- Formulario con:
  - Nombre (obligatorio)
  - Fecha de nacimiento (opcional)
  - Curso (opcional)
  - Color/Avatar (opcional)
- El hijo queda asociado al familyId activo.
- Al guardar:
  - El nuevo hijo aparece en la lista inmediatamente.
  - Se sincroniza en tiempo real con los demás miembros.
  - La UI se actualiza desde el snapshot sin recarga manual.
- Si el nombre está vacío, el formulario no se puede enviar.

---

### US-13 — Editar hijo (RF-12)

**Como** miembro de la familia,  
**quiero** editar los datos de un hijo,  
**para** mantener su información actualizada.

**Criterios de aceptación**

- Se puede abrir una pantalla o modal con los datos del hijo.
- Campos editables:
  - Nombre
  - Curso
  - Fecha de nacimiento
  - Color/Avatar
- Al guardar:
  - Los cambios se reflejan en las vistas que muestren los datos del hijo.
  - Se sincronizan en tiempo real para otros miembros.
  - La UI se actualiza desde el snapshot sin recarga manual.
- Si hay errores (red, permisos), se muestra mensaje y no se pierde la edición actual.

---

### US-14 — Eliminar hijo (RF-13)

**Como** miembro con permisos,  
**quiero** eliminar un hijo,  
**para** mantener solo la información relevante en la app.

**Criterios de aceptación**

- Al solicitar la eliminación:
  - Se muestra un cuadro de diálogo de confirmación con texto claro del impacto.
- Si se confirma:
  - Se elimina el hijo.
  - Se eliminan también:
    - Horarios escolares asociados.
    - Actividades extraescolares asociadas.
    - Gastos asociados.
- La eliminación se refleja en tiempo real en otros dispositivos.
- Si hay un fallo (por ejemplo, error de red), se notifica y no se debe quedar en un estado inconsistente a medias.

---

## ÉPICA 4 — Horario escolar

### US-15 — Crear franja de horario escolar (RF-20)

**Como** miembro de la familia,  
**quiero** añadir una franja de clase al horario escolar de un hijo,  
**para** reflejar su horario lectivo.

**Criterios de aceptación**

- Formulario de creación con:
  - Hijo (si no viene ya seleccionado)
  - Día de la semana
  - Hora de inicio
  - Hora de fin
  - Asignatura / descripción
  - Aula (opcional)
- La franja queda vinculada al childId.
- Al guardar:
  - Aparece en la vista semanal escolar del hijo.
  - Se sincroniza en tiempo real.
  - La UI se actualiza desde el snapshot sin recarga manual.
- Validaciones:
  - La hora fin debe ser posterior a la hora inicio.
  - No se permite un campo obligatorio vacío.
- El acceso rápido “Horarios” de Home abre este formulario de creación de franja escolar.

---

### US-16 — Ver horario escolar semanal (RF-21)

**Como** miembro de la familia,  
**quiero** ver el horario escolar de un hijo en formato semanal,  
**para** entender fácilmente cómo se distribuye su semana lectiva.

**Criterios de aceptación**

- La vista semanal muestra:
  - Días de la semana (L–V, o L–D si se decide así).
  - Las franjas en su posición según día y hora.
- Se diferencian las franjas por color, asignatura o ambos.
- Cambios en SchoolSlot se reflejan automáticamente sin recargar manualmente la pantalla.
- Al cambiar de familia activa o hijo seleccionado, la vista se rehidrata desde el snapshot en vivo correspondiente.
- Scroll o navegación cómoda si hay muchas franjas.
- Pendiente: conectar el acceso rápido “Horarios” de Home a esta vista semanal cuando se implemente.

---

### US-17 — Editar o eliminar franjas escolares (RF-22)

**Como** miembro,  
**quiero** poder editar o eliminar una franja escolar desde la vista del horario,  
**para** corregir cambios en el horario del colegio.

**Criterios de aceptación**

- Tap sobre una franja escolar:
  - Abre detalle con opción de editar o eliminar.
- Editar:
  - Permite cambiar día, horas, asignatura, aula.
  - Validaciones iguales que en creación.
  - Cambios en tiempo real.
  - La UI se actualiza desde el snapshot sin recarga manual.
- Eliminar:
  - Requiere confirmación.
  - Elimina la franja y la hace desaparecer de la vista de todos los miembros.
- Pendiente: conectar el acceso rápido “Horarios” de Home con la experiencia de edición/eliminación cuando esté lista.

---

## ÉPICA 5 — Actividades extraescolares

### US-18 — Crear actividad extraescolar (RF-30)

**Como** miembro,  
**quiero** crear una actividad extraescolar asociada a un hijo,  
**para** organizar sus tardes y actividades complementarias.

**Criterios de aceptación**

- Formulario con:
  - Hijo (si no viene preseleccionado).
  - Nombre de la actividad (obligatorio).
  - Categoría (deporte, música, idiomas, otros).
  - Días de la semana en que se realiza (uno o varios).
  - Hora de inicio y hora de fin.
  - Localización (texto libre).
  - Coste recurrente (opcional).
  - Tipo de recurrencia (mensual/trimestral/anual, opcional).
- Validaciones:
  - Nombre no vacío.
  - Hora fin posterior a hora inicio.
- Al guardar:
  - La actividad aparece en la lista de actividades del hijo.
  - La actividad aparece en la vista semanal combinada.
  - Se sincroniza en tiempo real con otros miembros.
  - La UI se alimenta del snapshot en vivo (lista y vista semanal).
- Pendiente: activar la navegación desde Home (CTA contextual “Crear actividad” y acceso rápido “Actividades”) hacia esta creación cuando se libere.

---

### US-19 — Ver listado de actividades extraescolares por hijo (RF-31)

**Como** miembro,  
**quiero** ver una lista de las actividades extraescolares de un hijo,  
**para** gestionarlas de forma rápida y saber qué hace cada día.

**Criterios de aceptación**

- La lista muestra:
  - Nombre de la actividad.
  - Categoría (icono o etiqueta).
  - Días y horario.
  - Coste recurrente (si está definido).
- Tocar una actividad lleva a detalle/edición.
- Lista actualizada en tiempo real si alguien añade, edita o elimina actividades.
- Al cambiar de familia activa o hijo seleccionado, la lista se rehidrata desde el snapshot en vivo.
- Pendiente: enlazar el acceso rápido “Actividades” de Home a esta lista al implementarla.

---

### US-20 — Editar actividad extraescolar (RF-32)

**Como** miembro,  
**quiero** editar una actividad extraescolar,  
**para** actualizar sus horarios, datos o costes cuando cambian.

**Criterios de aceptación**

- Desde el detalle de actividad se puede:
  - Modificar nombre, categoría, días, horas, localización, coste, recurrencia.
- Validaciones:
  - Nombre no vacío.
  - Horarios válidos.
- Al guardar:
  - Los cambios se reflejan en la lista y la vista semanal combinada.
  - Se sincronizan en tiempo real con otros dispositivos.
  - La UI se alimenta del snapshot sin recarga manual.
- Pendiente: enlazar el acceso rápido “Actividades” de Home a esta edición cuando se implemente.

---

### US-21 — Eliminar actividad extraescolar (RF-33)

**Como** miembro,  
**quiero** eliminar una actividad extraescolar,  
**para** mantener solo las actividades actuales.

**Criterios de aceptación**

- El botón de eliminación:
  - Muestra un diálogo de confirmación.
- Si se confirma:
  - La actividad se borra.
  - Desaparece de la lista y la vista semanal.
- Se sincroniza en tiempo real con todos los miembros.
  - La UI se alimenta del snapshot en vivo (lista y vista semanal) sin recarga manual.
- Si hay gastos asociados, se puede definir la estrategia:
  - MVP: mantener gastos históricos asociados a una actividad eliminada o borrarlos (decisión de producto documentada).
- Pendiente: enlazar el acceso rápido “Actividades” de Home con el flujo de detalle/edición/eliminación cuando esté disponible.

---

## ÉPICA 6 — Vista semanal combinada

### US-22 — Ver vista semanal combinada (RF-40)

**Como** miembro,  
**quiero** ver en una sola vista las clases y actividades extraescolares de un hijo,  
**para** tener una visión global de su semana.

**Criterios de aceptación**

- La vista muestra, para el hijo seleccionado:
  - SchoolSlots (clases escolares).
  - Actividades extraescolares.
- Las clases y actividades se diferencian claramente:
  - Por color, icono o estilo visual.
- La vista se actualiza automáticamente cuando:
  - Se añade, edita o borra una franja escolar.
  - Se añade, edita o borra una actividad extraescolar.
- La vista soporta desplazamiento/zoom si hay muchas actividades.
- Pendiente: decidir a qué pantalla de horarios lleva el acceso rápido de Home y cablearlo al implementar esta vista combinada.

---

### US-23 — Cambiar rápidamente de hijo en vista semanal (RF-41)

**Como** miembro,  
**quiero** cambiar de hijo desde la vista semanal combinada,  
**para** consultar rápidamente la semana completa de cada uno.

**Criterios de aceptación**

- En la vista semanal hay un control de selección de hijo:
  - Tabs, Segmented control, carrusel o equivalente.
- Al seleccionar otro hijo:
  - Se recarga la vista con su horario escolar y extraescolar.
- Debe recordarse el último hijo seleccionado (por ejemplo, en la sesión actual).
- Pendiente: cablear la navegación desde Home hacia la vista combinada contemplando este selector de hijo.

---

## ÉPICA 7 — Control de gastos

### US-24 — Registrar gasto recurrente por actividad (RF-50)

**Como** miembro,  
**quiero** indicar el coste recurrente de una actividad extraescolar,  
**para** saber cuánto gasto al mes (u otro periodo) en ella.

**Criterios de aceptación**

- En el formulario de actividad o en una sección de gastos se pueden definir:
  - Importe.
  - Tipo de recurrencia (mensual, trimestral, anual).
  - Fecha de inicio de pago.
- El coste recurrente se usa en los resúmenes de gastos por hijo y por actividad.
- Cambios se reflejan en tiempo real en los resúmenes alimentados por el snapshot.
- Si se deja vacío, la actividad se considera sin coste recurrente.
- Pendiente: conectar el acceso rápido “Gastos” de Home hacia la sección donde se configuran costes recurrentes.

---

### US-25 — Registrar gasto puntual (RF-51)

**Como** miembro,  
**quiero** registrar gastos puntuales relacionados con un hijo (material, equipación, etc.),  
**para** conocer el coste real de sus actividades.

**Criterios de aceptación**

- Formulario con:
  - Hijo (obligatorio).
  - Actividad (opcional).
  - Importe (obligatorio).
  - Concepto o descripción (obligatorio).
  - Fecha (obligatorio, por defecto fecha actual).
- Al guardar:
  - El gasto queda asociado al hijo y, si se ha seleccionado, a la actividad.
- El gasto aparece en los resúmenes correspondientes y se sincroniza en tiempo real (snapshot) para otros miembros.
- Pendiente: conectar el acceso rápido “Gastos” de Home a la vista de alta/listado de gastos puntuales al implementarla.

---

### US-26 — Ver resumen de gastos por hijo (RF-52)

**Como** adulto responsable,  
**quiero** ver un resumen mensual de los gastos por hijo,  
**para** entender mejor el coste económico de sus actividades.

**Criterios de aceptación**

- Se puede seleccionar mes y año.
- Para el hijo seleccionado se muestra:
  - Total de gastos recurrentes estimados en ese periodo.
  - Total de gastos puntuales en ese periodo.
- Puede haber un desglose por actividad y/o listado de gastos.
- Resumen alimentado por snapshot para reflejar altas/bajas/ediciones de gastos en ≤ 5 segundos.
- Pendiente: enlazar el acceso rápido “Gastos” de Home con esta vista de resumen cuando exista.

---

### US-27 — Ver resumen de gastos por actividad (RF-53)

**Como** adulto,  
**quiero** ver el coste mensual estimado por actividad,  
**para** tomar decisiones sobre continuar o ajustar actividades.

**Criterios de aceptación**

- Lista de actividades con:
  - Nombre.
  - Coste recurrente (normalizado al mes).
  - Suma de gastos puntuales asociados en el periodo seleccionado (opcional).
- Opción de ordenar por coste total estimado.
- Resumen alimentado por snapshot para reflejar altas/bajas/ediciones de gastos en ≤ 5 segundos.
- Pendiente: enlazar el acceso rápido “Gastos” de Home con esta vista de resumen cuando exista.

---

## ÉPICA 8 — Exportación a Calendario del iPhone

### US-28 — Solicitar permisos de Calendario (RF-80)

**Como** usuario,  
**quiero** conceder permisos de acceso al Calendario del sistema cuando vaya a exportar horarios,  
**para** que la app pueda crear eventos.

**Criterios de aceptación**

- Al intentar exportar por primera vez:
  - Se solicita permiso de acceso al Calendario mediante EventKit.
- Si el usuario deniega el permiso:
  - Se muestra un mensaje explicando que no se podrá exportar hasta activarlo en Ajustes.
- Si el permiso ya fue concedido, no se vuelve a mostrar el diálogo del sistema.

---

### US-29 — Exportar horario escolar de un hijo (RF-81)

**Como** usuario,  
**quiero** exportar el horario escolar de un hijo a mi Calendario,  
**para** ver sus clases integradas con mis eventos personales.

**Criterios de aceptación**

- Debe haber una opción “Exportar horario escolar” en la vista del hijo o en una sección de calendario.
- Al exportar:
  - Se crea (o reutiliza) un calendario llamado, por ejemplo, “Horarios KidsTrack – [Nombre Hijo]”.
  - Por cada SchoolSlot se crea un evento recurrente semanal:
    - Con día, hora inicio, hora fin, nombre de asignatura y, si existe, aula.
    - Fecha de inicio: la primera fecha futura coherente (por ejemplo, próximo lunes o según configuración).
- No se requiere (en MVP) sincronización automática al editar horarios (se usa la opción de re-exportar para actualizar).

---

### US-30 — Exportar actividades extraescolares de un hijo (RF-82)

**Como** usuario,  
**quiero** exportar las actividades extraescolares de un hijo a mi Calendario,  
**para** tener todas las actividades visibles en el calendario del dispositivo.

**Criterios de aceptación**

- Debe existir una opción de exportar extraescolares (puede estar combinada con la anterior o separada).
- Las actividades se exportan como eventos recurrentes semanales al mismo calendario del hijo.
- Cada evento incluye:
  - Nombre de la actividad.
  - Día(s) de la semana.
  - Horas.
  - Localización (si está definida).

---

### US-31 — Reexportar eventos actualizados (RF-84)

**Como** usuario,  
**quiero** poder reexportar los horarios al Calendario cuando haya cambios significativos,  
**para** mantener el calendario de iOS actualizado sin gestionar a mano cada evento.

**Criterios de aceptación**

- Botón “Exportar de nuevo” para un hijo o para la familia.
- Estrategia MVP:
  - Borrar los eventos previamente creados por la app en el calendario del hijo.
  - Volver a crearlos con la información actual.
- No es necesario detectar cambios individuales en eventos ya existentes (se recrean todos).

---

### US-32 — Evitar calendarios duplicados (RF-85)

**Como** usuario,  
**quiero** que la app no cree múltiples calendarios con el mismo nombre para un hijo,  
**para** mantener orden en la app Calendario.

**Criterios de aceptación**

- Antes de crear un calendario, la app comprueba si ya existe un calendario “Horarios KidsTrack – [Nombre Hijo]”.
- Si existe, se utiliza ese calendario, no se crea uno nuevo.
- Solo se crea un calendario nuevo si:
  - El anterior ha sido eliminado manualmente por el usuario.
  - O se decide que no es posible reutilizarlo (por ejemplo, por permisos o errores) y se informa de forma adecuada.

---

### US-33 — Exportar todos los hijos de una familia (RF-83) [Opcional MVP]

**Como** usuario,  
**quiero** exportar de una vez los horarios de todos mis hijos al Calendario,  
**para** ahorrar tiempo y tener una visión de toda la familia.

**Criterios de aceptación**

- Desde una sección de Calendario o Ajustes de la familia se ofrece “Exportar todos los horarios”.
- El sistema recorre todos los hijos de la familia:
  - Exporta horario escolar y extraescolar usando las reglas anteriores.
- Se reutilizan calendarios existentes por hijo.

---

## ÉPICA 9 — Calidad, accesibilidad, seguridad y rendimiento

### US-34 — Revisión y corrección de accesibilidad (Sección 9.1)

**Como** equipo de desarrollo,  
**quiero** revisar y corregir aspectos de accesibilidad,  
**para** que la app sea usable por el mayor número de personas posible.

**Criterios de aceptación**

- Soporte de Dynamic Type revisado en:
  - Login
  - Selección de familia
  - Listados de hijos
  - Vista semanal
  - Listados de actividades
- Contraste de colores verificado para temas claro y oscuro.
- Todos los botones y elementos interactivos importantes tienen `accessibilityLabel` significativo.
- Navegación con VoiceOver probada en los flujos principales.
- Tamaño mínimo de objetivos táctiles respetado (≈44x44 pt).

---

### US-35 — Revisión y corrección de seguridad (Sección 9.2)

**Como** equipo,  
**quiero** revisar la seguridad de la app y de los datos en Firebase,  
**para** proteger la información de las familias.

**Criterios de aceptación**

- Reglas de seguridad en Firestore revisadas para:
  - Limitar lectura/escritura a familias de las que el usuario es miembro.
  - Evitar accesos directos a datos de otras familias.
- Revisión de cómo se almacenan datos locales:
  - No guardar tokens sensibles en claro en UserDefaults.
  - Uso de Keychain cuando sea necesario.
- Revisar que no se registran en log tokens ni datos personales sensibles.
- Generar un pequeño informe con posibles vulnerabilidades encontradas y correcciones aplicadas.

---

### US-36 — Revisión y corrección de rendimiento (Sección 9.3)

**Como** equipo,  
**quiero** optimizar el rendimiento de la app,  
**para** garantizar una experiencia fluida.

**Criterios de aceptación**

- Medición de:
  - Tiempo de carga de pantalla inicial/login.
  - Tiempo de carga de selección de familia.
  - Fluidez en vista semanal con varios hijos y actividades.
- Verificación de que:
  - Las consultas a Firestore están paginadas/optimizadas cuando proceda.
  - No hay listeners innecesarios o duplicados.
  - Operaciones pesadas se ejecutan fuera del hilo principal.
- Se aplican optimizaciones básicas (uso correcto de `@StateObject`, `@ObservedObject`, etc. en SwiftUI).

---

### US-37 — Revisión de UI/UX y mejoras (Sección 9.4)

**Como** equipo,  
**quiero** revisar la interfaz y la experiencia de usuario,  
**para** mejorar la claridad y consistencia del diseño.

**Criterios de aceptación**

- Revisión de:
  - Tipografías y tamaños.
  - Colores y espaciados.
  - Coherencia entre pantallas.
- Estados vacíos definidos en:
  - Sin familias.
  - Sin hijos.
  - Sin actividades.
  - Sin gastos.
- Mensajes de error y éxito revisados para sean claros y útiles.
- Se elabora una lista de mejoras UI/UX:
  - “Quick wins” aplicados en el MVP.
  - Mejoras mayores documentadas en backlog futuro.

---

## ÉPICA 10 — Shell post-autenticación y Home

### US-38 — Pantalla principal post-login (Home)

**Como** usuario autenticado con familia activa,  
**quiero** aterrizar en una pantalla principal que resuma el día y me permita saltar rápido a horarios, actividades y gastos,  
**para** no tener que navegar por varias pestañas cada vez que entro.

**Criterios de aceptación**

- Al completar login y selección de familia, la app muestra la Home por defecto (en lugar de quedarse en la lista de hijos).
- La Home refleja el contexto actual:
  - Si no hay familia activa, muestra estado vacío con CTA a crear/seleccionar familia.
  - Si hay familia activa pero sin hijos, muestra estado vacío con CTA “Añadir hijo”.
  - Con hijos, muestra un bloque de “Hoy” con las próximas clases/actividades del snapshot en tiempo real y accesos a cada hijo.
- Incluye accesos rápidos a las secciones clave (horarios/actividades/gastos/familia) y un CTA primario contextual:
  - El CTA debe ser “Añadir hijo” cuando no hay hijos y “Crear actividad” u otra acción relevante cuando sí los hay.
  - Los accesos rápidos navegan efectivamente a las vistas de horarios/actividades/gastos en cuanto estén disponibles.
- Actualiza los datos en ≤ 5 segundos ante cambios del `familyRealtimeSnapshot` (hijos, schoolSlots, actividades).
- Tras seleccionar o crear familia desde el flujo de selección, la navegación vuelve a Home sin quedarse en la pantalla intermedia.
- Gestiona modos de carga/error con mensajes y permite reintentar sin bloquear la navegación principal.
- Pendiente: cablear los accesos rápidos y el CTA contextual (p. ej. “Crear actividad” con hijos) a las pantallas de horarios/actividades/gastos cuando estén listas.
