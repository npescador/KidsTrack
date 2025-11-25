# Avance y Próximos Pasos

## Avance Completado
- Integración del blueprint Fase 1 en `README.md`, consolidando arquitectura, navegación, modelos, casos de uso, UX, roadmap, pruebas, monetización y supuestos del prompt.
- Actualización de `AGENTS.md` para reflejar el flujo de trabajo en tres fases (plan → propuesta → escritura) requerido para nuevas contribuciones.
- Creación de `Docs/Specification.md` siguiendo Spec Driven Development con tareas y subtareas priorizadas para el MVP.
- US-01 (Registro Email/Password) completada: validación de email y longitud mínima de contraseña en `LoginViewModel`, botones deshabilitados cuando el formulario es inválido o está cargando, callback de `LoginView` al autenticarse y tests de presentación extendidos.
- US-02 (Recuperación de contraseña) implementada: pantalla dedicada `PasswordResetView` con validación de email, estados de carga, mensajes genéricos “si existe la cuenta…”, navegación desde login, y tests de view model (éxito/error/validación). Ajustado `Info.plist` para priorizar localización en español/inglés.
- US-03 (Logout robusto) implementada: contrato `SessionResetting` para limpiar listeners/estado al cerrar sesión, coordinador navega a login tras logout, alerta de error mantenida, y tests de coordinador cubriendo éxito/fallo.

## Próximo Paso Inmediato
- US-04 (Sign in with Apple): botón y flujo de Apple ID integrado con Firebase Auth, manejo de cancelación/errores y navegación hacia selección/creación de familia tras éxito.

## Notas de referencia
- No revisar ni mantener `Docs/Specification.md` como fuente activa; guiarse únicamente por `Docs/# Backlog.KidsTrack.md` y este `Docs/Progress.md` para prioridades y seguimiento.
