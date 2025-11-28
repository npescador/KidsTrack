# Avance y Próximos Pasos

## Avance Completado
- Integración del blueprint Fase 1 en `README.md`, consolidando arquitectura, navegación, modelos, casos de uso, UX, roadmap, pruebas, monetización y supuestos del prompt.
- Actualización de `AGENTS.md` para reflejar el flujo de trabajo en tres fases (plan → propuesta → escritura) requerido para nuevas contribuciones.
- Creación de `Docs/Specification.md` siguiendo Spec Driven Development con tareas y subtareas priorizadas para el MVP.
- US-01 (Registro Email/Password) completada: validación de email y longitud mínima de contraseña en `LoginViewModel`, botones deshabilitados cuando el formulario es inválido o está cargando, callback de `LoginView` al autenticarse y tests de presentación extendidos.
- US-02 (Recuperación de contraseña) implementada: pantalla dedicada `PasswordResetView` con validación de email, estados de carga, mensajes genéricos “si existe la cuenta…”, navegación desde login, y tests de view model (éxito/error/validación). Ajustado `Info.plist` para priorizar localización en español/inglés.
- US-03 (Logout robusto) implementada: contrato `SessionResetting` para limpiar listeners/estado al cerrar sesión, coordinador navega a login tras logout, alerta de error mantenida, y tests de coordinador cubriendo éxito/fallo.
- US-06 (Crear familia) implementada: contrato Domain/Data con repositorio y store de familia activa, flujo de creación en SwiftUI con validación/banners, persistencia en UserDefaults y visualización de familia activa en el placeholder autenticado.
- US-07 (Seleccionar familia activa) completada: listado de familias del usuario, selección con persistencia de familia activa, listeners reconfigurados al cambiar y UI deshabilita acciones sin familia.
- US-08 (Invitar adulto) completada: flujo de invitación con validación de email, estado pendiente deduplicado, banners de éxito/error localizados y gating del CTA a tener familia activa (backend in-memory temporal).
- US-09 (Aceptar/Rechazar invitaciones) implementada: banner de invitaciones pendientes al iniciar sesión, hoja para aceptar o rechazar con feedback localizado, actualización del listado de familias al aceptar y acciones in-memory para estado de invitaciones.

## Próximo Paso Inmediato
- Definir e implementar data source real para invitaciones (persistencia/sincronización) y cablear backend; pendiente de priorización.

## Notas de referencia
- No revisar ni mantener `Docs/Specification.md` como fuente activa; guiarse únicamente por `Docs/# Backlog.KidsTrack.md` y este `Docs/Progress.md` para prioridades y seguimiento.
- US-04 (Sign in with Apple) se pospone al final del proyecto para priorizar el resto de flujos del MVP.
