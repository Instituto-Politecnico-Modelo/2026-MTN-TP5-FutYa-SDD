# Feature Specification: FutYa — Plataforma Integral de Gestión de Fútbol 5

**Feature Branch**: `001-futbol5ya-gestion-plataforma`

**Created**: 2026-06-09

**Status**: Draft

**Input**: Plataforma integral FutYa para la gestión de complejos de fútbol 5, incluyendo administración de canchas, configuración de turnos, reservas con integración de clima y pagos, y panel de administración con visibilidad global de usuarios y reservas.

---

## User Scenarios & Testing *(mandatory)*

<!--
  Historias de usuario priorizadas como journeys independientes y testeables.
  P1 = crítico para MVP, P7 = valor adicional.
-->

### User Story 1 — Autenticación y Control de Acceso (Priority: P1)

Un visitante accede a la plataforma, se registra como cliente o inicia sesión con su cuenta existente. El sistema emite un token de sesión que habilita el acceso a las funcionalidades correspondientes a su rol.

**Why this priority**: Sin autenticación y separación de roles ningún otro módulo es operativo. Todo el sistema depende de que este flujo funcione correctamente.

**Independent Test**: Registrar un usuario cliente, iniciar sesión, verificar que los endpoints protegidos son accesibles con token válido y rechazados sin él. Verificar que un cliente no puede acceder a rutas de administrador.

**Acceptance Scenarios**:

1. **Given** un visitante no registrado, **When** completa el formulario de registro con datos válidos (nombre, email, contraseña), **Then** se crea su cuenta con rol CLIENTE y es redirigido a su dashboard.
2. **Given** un usuario registrado, **When** ingresa credenciales válidas en el formulario de inicio de sesión, **Then** el sistema emite un token de sesión y le otorga acceso a las funcionalidades de su rol.
3. **Given** un usuario con rol CLIENTE autenticado, **When** intenta acceder a una ruta exclusiva de ADMINISTRADOR, **Then** el sistema rechaza el acceso con un mensaje claro de permisos insuficientes.
4. **Given** un usuario autenticado con sesión expirada, **When** intenta realizar cualquier operación protegida, **Then** el sistema le solicita iniciar sesión nuevamente sin perder el contexto de navegación.
5. **Given** un intento de inicio de sesión, **When** se ingresan credenciales incorrectas, **Then** el sistema muestra un mensaje de error genérico (sin revelar si el email existe) para prevenir enumeración de usuarios.

---

### User Story 2 — Gestión de Canchas (Priority: P2)

Un administrador accede al panel de gestión para dar de alta, modificar, activar, desactivar y eliminar canchas del complejo.

**Why this priority**: Sin canchas registradas y activas no existe disponibilidad que mostrar ni turnos que reservar. Es el segundo bloque crítico para el funcionamiento del sistema.

**Independent Test**: Crear una cancha desde el panel de administrador, verificar que aparece en la grilla de disponibilidad, desactivarla y confirmar que desaparece de la grilla. Intentar eliminar una cancha con reservas activas y verificar que el sistema lo impide.

**Acceptance Scenarios**:

1. **Given** un administrador autenticado en el panel de canchas, **When** completa el formulario de alta con nombre, tipo y estado inicial, **Then** la cancha queda registrada y, si está activa, aparece en la grilla de disponibilidad.
2. **Given** una cancha activa, **When** el administrador la desactiva, **Then** la cancha desaparece de la grilla de disponibilidad y no acepta nuevas reservas; las reservas futuras existentes son notificadas.
3. **Given** una cancha registrada, **When** el administrador modifica su nombre o tipo, **Then** los cambios se reflejan de inmediato en todos los módulos que la referencian.
4. **Given** una cancha sin reservas futuras activas, **When** el administrador la elimina, **Then** la cancha es removida permanentemente del sistema con confirmación explícita del administrador.
5. **Given** una cancha con reservas futuras activas, **When** el administrador intenta eliminarla, **Then** el sistema impide la eliminación y muestra el listado de reservas en conflicto.

---

### User Story 3 — Configuración de Turnos Base (Priority: P3)

Un administrador define los bloques horarios disponibles por día de la semana para cada cancha activa.

**Why this priority**: Sin bloques horarios configurados no hay grilla de disponibilidad. Los clientes no pueden visualizar ni reservar turnos.

**Independent Test**: Configurar bloques horarios para una cancha en un día específico y verificar que esos bloques aparecen correctamente en la grilla de disponibilidad para las fechas futuras correspondientes a ese día de la semana.

**Acceptance Scenarios**:

1. **Given** una cancha activa, **When** el administrador define un bloque horario (día de semana, hora inicio, hora fin), **Then** ese bloque aparece como disponible en la grilla para todas las semanas futuras aplicables.
2. **Given** bloques horarios configurados sin reservas asociadas, **When** el administrador los modifica o elimina, **Then** los cambios se reflejan en la grilla a partir de la próxima ocurrencia semanal.
3. **Given** un bloque horario con reservas activas futuras, **When** el administrador intenta modificarlo o eliminarlo, **Then** el sistema impide la operación e indica las reservas en conflicto.
4. **Given** un día de la semana sin bloques configurados para una cancha, **When** un cliente visualiza la grilla, **Then** ese día-cancha aparece como no disponible.

---

### User Story 4 — Visualización de Grilla de Disponibilidad (Priority: P4)

Un cliente autenticado visualiza la grilla de disponibilidad de canchas por fecha, con información en tiempo real sobre qué turnos están libres u ocupados.

**Why this priority**: La grilla es la interfaz principal de decisión del cliente. Sin ella no puede existir ningún proceso de reserva.

**Independent Test**: Acceder a la grilla con un usuario CLIENTE, verificar que se muestran correctamente los turnos disponibles y ocupados para distintas fechas. Realizar una reserva en paralelo y verificar que el estado del turno se actualiza.

**Acceptance Scenarios**:

1. **Given** un cliente autenticado, **When** accede a la grilla del día actual, **Then** visualiza todas las canchas activas con sus bloques horarios, diferenciando visualmente los turnos libres de los ocupados.
2. **Given** la grilla visible con un turno disponible, **When** ese turno es reservado por otro usuario, **Then** el estado del turno refleja el cambio al recargar o navegar nuevamente la grilla; el cliente puede actualizar manualmente la vista para ver la disponibilidad más reciente.
3. **Given** una fecha futura seleccionada en la grilla, **When** todos los turnos de una cancha están ocupados para esa fecha, **Then** la cancha aparece como completa y sus turnos no son seleccionables.
4. **Given** una cancha desactivada por el administrador, **When** el cliente visualiza la grilla, **Then** esa cancha no aparece en ninguna fecha de la grilla.

---

### User Story 5 — Reserva de Turno con Clima y Pago (Priority: P5)

Un cliente selecciona un turno disponible, visualiza las condiciones del clima previstas para ese momento y completa el proceso de pago para confirmar la reserva.

**Why this priority**: La reserva es la transacción central de la plataforma. Integra disponibilidad, clima y pago en un flujo de alto valor para el negocio.

**Independent Test**: Completar el flujo completo: seleccionar turno → visualizar clima → ingresar datos de pago → recibir confirmación y notificación. También probar el flujo con pago rechazado.

**Acceptance Scenarios**:

1. **Given** un turno disponible seleccionado por el cliente, **When** inicia el proceso de reserva, **Then** el sistema muestra las condiciones meteorológicas previstas para la fecha y hora del turno antes de solicitar el pago.
2. **Given** que el servicio de clima no está disponible en el momento, **When** el cliente inicia la reserva, **Then** el sistema permite continuar el flujo informando que la información meteorológica no está disponible temporalmente.
3. **Given** la información de clima mostrada, **When** el cliente confirma y completa el pago exitosamente, **Then** el turno queda reservado a su nombre, la grilla se actualiza y el cliente recibe una notificación de confirmación.
4. **Given** un proceso de pago iniciado, **When** la pasarela externa rechaza el pago, **Then** el turno permanece disponible, la reserva no se confirma y se informa al cliente con opciones de reintento.
5. **Given** un proceso de pago iniciado, **When** la pasarela externa no responde dentro del tiempo máximo, **Then** la reserva queda en estado "pendiente de pago" y el turno se libera automáticamente si el pago no se confirma dentro del período configurable.
6. **Given** dos clientes intentando reservar el mismo turno simultáneamente, **When** ambos inician el proceso al mismo tiempo, **Then** solo uno logra confirmar la reserva; el otro recibe un mensaje claro indicando que el turno ya no está disponible.

---

### User Story 6 — Gestión de Reservas Propias del Cliente (Priority: P6)

Un cliente visualiza sus reservas activas y pasadas, puede modificar una reserva futura dentro del plazo permitido y cancelar una reserva con la antelación requerida.

> Nota de alcance MVP (TP): en la entrega MVP se implementan visualización y cancelación de reservas. La modificación de reservas queda planificada para una iteración posterior.

**Why this priority**: La auto-gestión reduce la carga operacional del administrador y mejora la experiencia del cliente al darle control sobre sus compromisos.

**Independent Test**: Acceder al panel de reservas de un cliente, modificar la fecha de una reserva futura válida y cancelar otra dentro del plazo, verificando que la grilla se actualiza correctamente en ambos casos.

**Acceptance Scenarios**:

1. **Given** un cliente autenticado con reservas, **When** accede a su sección de reservas, **Then** visualiza un listado de reservas futuras y pasadas con fecha, cancha, estado y monto.
2. **Given** una reserva futura dentro del plazo de modificación (post-MVP), **When** el cliente elige un nuevo turno disponible, **Then** el turno anterior se libera y el nuevo queda reservado, emitiendo notificación del cambio.
3. **Given** una reserva futura con más de 24 horas de anticipación al horario del turno, **When** el cliente la cancela, **Then** el turno se libera, se procesa el reembolso completo al método de pago original y se envía notificación de cancelación con el detalle del reembolso.
4. **Given** una reserva futura con menos de 24 horas de anticipación al horario del turno, **When** el cliente intenta cancelarla, **Then** el sistema informa que no aplica reembolso en ese plazo; si el cliente confirma la cancelación, el turno se libera sin reembolso y se envía notificación.
5. **Given** una reserva pasada o cuyo turno ya ha ocurrido, **When** el cliente intenta modificarla o cancelarla, **Then** el sistema deniega la operación con un mensaje explicativo.
6. **Given** una reserva activa, **When** el cliente accede al detalle, **Then** puede visualizar el comprobante de pago asociado.

---

### User Story 7 — Panel Administrativo: Usuarios y Reservas (Priority: P7)

Un administrador visualiza todos los usuarios registrados, sus reservas, y puede gestionar cancelaciones con notificación al cliente afectado.

**Why this priority**: Proporciona visibilidad operacional global y herramientas de soporte para el staff del complejo. Completa el ciclo de administración del sistema.

**Independent Test**: Acceder al panel de administración, listar todos los usuarios con sus reservas, aplicar filtros por fecha y cancha, y cancelar una reserva en nombre de un cliente verificando que recibe notificación.

**Acceptance Scenarios**:

1. **Given** un administrador autenticado, **When** accede al panel de gestión de usuarios, **Then** visualiza el listado completo de clientes registrados con nombre, email y cantidad de reservas activas.
2. **Given** el panel de reservas del administrador, **When** aplica filtros por fecha, cancha o usuario, **Then** el sistema muestra únicamente las reservas que coinciden con los criterios seleccionados.
3. **Given** una reserva activa de cualquier cliente, **When** el administrador la cancela ingresando un motivo obligatorio, **Then** el turno se libera, el cliente recibe notificación con el motivo y la operación queda registrada en el historial.
4. **Given** el panel de administración, **When** el administrador consulta el historial de reservas de un cliente específico, **Then** visualiza todas sus reservas (activas, modificadas, canceladas y pasadas) con estado y detalle de pago.

---

### Edge Cases

- **Reserva simultánea**: Si dos clientes intentan reservar el mismo turno al mismo tiempo, el sistema debe garantizar que solo una reserva se confirma (integridad de datos). El segundo usuario recibe un mensaje de turno no disponible.
- **Clima no disponible**: Si el servicio de clima externo no responde, el sistema muestra un aviso informativo y permite continuar con la reserva sin bloquear al usuario.
- **Timeout en pago**: Si la pasarela de pagos no responde dentro del tiempo máximo configurado, la reserva queda en estado "pendiente" y el turno se libera automáticamente tras ese período.
- **Pago rechazado en modificación**: Si un cliente modifica una reserva y el nuevo pago (si aplica diferencia) es rechazado, el sistema debe decidir si revertir al turno original o cancelar la modificación; la reserva original debe quedar intacta.
- **Cancelación de cancha con reservas activas**: Si el administrador desactiva una cancha con reservas futuras, el sistema debe notificar a todos los clientes afectados.
- **Sesión expirada durante pago**: Si el token del cliente expira mientras está en el flujo de pago, el turno debe liberarse y no quedar bloqueado indefinidamente.
- **Bloque horario sin instancias futuras**: Si se configura un bloque horario con una fecha de inicio en el futuro lejano, el sistema solo muestra turnos para fechas dentro de un rango razonable (ej: próximas 4 semanas).
- **Modificación de turno a un horario que tiene conflicto de pago**: Si cambiar un turno implica un monto diferente, el flujo debe gestionar el cobro de la diferencia o el reembolso parcial de forma explícita.

---

## Requirements *(mandatory)*

### Functional Requirements

#### Autenticación y Autorización

- **FR-001**: El sistema DEBE requerir autenticación en todos los endpoints protegidos; las solicitudes sin token válido DEBEN ser rechazadas con código de estado apropiado.
- **FR-002**: El sistema DEBE implementar exactamente dos roles: CLIENTE y ADMINISTRADOR. No se permiten roles adicionales sin enmienda formal.
- **FR-003**: El sistema DEBE impedir que un usuario con rol CLIENTE acceda a funcionalidades exclusivas de ADMINISTRADOR, y viceversa.
- **FR-004**: El sistema DEBE permitir el registro de nuevos usuarios asignando el rol CLIENTE por defecto; no debe existir un flujo de autoregistro como ADMINISTRADOR.
- **FR-005**: Los tokens de sesión DEBEN tener un tiempo de expiración definido; tras la expiración, el usuario DEBE re-autenticarse para continuar.
- **FR-006**: Los mensajes de error en el inicio de sesión NO DEBEN revelar si el email existe o no en el sistema (prevención de enumeración de usuarios).

#### Gestión de Canchas (Administrador)

- **FR-007**: El sistema DEBE permitir al ADMINISTRADOR crear canchas especificando nombre, tipo y estado inicial (activa/inactiva).
- **FR-008**: El sistema DEBE permitir al ADMINISTRADOR modificar nombre, tipo y estado de una cancha existente.
- **FR-009**: El sistema DEBE permitir al ADMINISTRADOR activar o desactivar una cancha; una cancha inactiva NO DEBE aparecer en la grilla de disponibilidad ni aceptar nuevas reservas.
- **FR-010**: El sistema DEBE impedir la eliminación de una cancha que tenga reservas futuras activas, mostrando las reservas en conflicto.
- **FR-011**: El sistema DEBE permitir la eliminación permanente de canchas sin reservas futuras activas, requiriendo confirmación explícita.

#### Configuración de Turnos Base (Administrador)

- **FR-012**: El sistema DEBE permitir al ADMINISTRADOR definir bloques horarios por cancha y día de la semana (hora de inicio y hora de fin).
- **FR-013**: Los bloques horarios configurados DEBEN aplicarse recurrentemente de forma semanal para todas las fechas futuras.
- **FR-014**: El sistema DEBE impedir la modificación o eliminación de bloques horarios que tengan reservas activas asociadas, indicando los conflictos.

#### Disponibilidad en Tiempo Real

- **FR-015**: El sistema DEBE mostrar una grilla de disponibilidad por fecha y cancha que refleje el estado actual de los turnos (disponible/ocupado/no disponible).
- **FR-016**: Los turnos ocupados DEBEN ser visualmente distinguibles de los disponibles en la grilla.
- **FR-017**: Solo los turnos pertenecientes a canchas activas y bloques horarios configurados DEBEN aparecer en la grilla.

#### Reservas (Cliente)

- **FR-018**: El sistema DEBE implementar un flujo de reserva que incluya: selección de turno disponible, visualización de condiciones del clima, y confirmación con pago.
- **FR-019**: El sistema DEBE consultar un servicio externo de clima para la fecha y ubicación del turno; si el servicio no responde, DEBE informar al cliente y permitir continuar.
- **FR-020**: El sistema DEBE integrarse con una pasarela de pago externa para procesar el cobro al confirmar cada reserva.
- **FR-021**: Ante rechazo del pago, el sistema DEBE mantener el turno como disponible y presentar al cliente opciones de reintento.
- **FR-022**: Ante timeout de la pasarela de pagos, la reserva DEBE quedar en estado "pendiente de pago" y el turno DEBE liberarse automáticamente si el pago no se confirma dentro de un período máximo configurable.
- **FR-023**: El sistema DEBE garantizar que ante reservas simultáneas del mismo turno, solo una se confirme exitosamente (control de concurrencia).
- **FR-024**: El sistema DEBE enviar una notificación de confirmación al cliente dentro de los 30 segundos posteriores a una reserva exitosa. **(Post-MVP)**
- **FR-025**: El sistema DEBE permitir al CLIENTE modificar una reserva futura dentro del plazo permitido, requiriendo selección de un nuevo turno disponible. **(Post-MVP)**
- **FR-026**: El sistema DEBE permitir al CLIENTE cancelar una reserva futura dentro del plazo de cancelación definido, gestionando el reembolso según la política vigente.
- **FR-027**: El sistema DEBE impedir modificaciones o cancelaciones sobre reservas pasadas o fuera del plazo permitido.
- **FR-028**: El sistema DEBE generar y mantener accesible un comprobante de pago por cada reserva confirmada.

#### Panel de Administración

- **FR-029**: El sistema DEBE permitir al ADMINISTRADOR visualizar el listado completo de usuarios registrados con datos de contacto y cantidad de reservas activas.
- **FR-030**: El sistema DEBE permitir al ADMINISTRADOR filtrar reservas por fecha, cancha y usuario.
- **FR-031**: El sistema DEBE permitir al ADMINISTRADOR cancelar cualquier reserva activa, requiriendo un motivo obligatorio y enviando notificación automática al cliente afectado.
- **FR-032**: El sistema DEBE registrar en el historial todas las operaciones de cancelación realizadas por el administrador (quién, cuándo, sobre qué reserva y con qué motivo).

### Non-Functional Requirements

- **NFR-001 — Arquitectura**: El frontend DEBE ser una Single Page Application (SPA); el backend DEBE exponer una API REST.
- **NFR-002 — Responsividad**: La interfaz web DEBE ser completamente funcional y usable en dispositivos de escritorio y móviles (diseño responsivo).
- **NFR-003 — Servidor web**: NGINX es el único servidor web y reverse proxy permitido. Apache u otras alternativas NO DEBEN configurarse, mencionarse ni utilizarse en ningún contexto del proyecto.
- **NFR-004 — Seguridad**: Todos los endpoints que expongan datos sensibles (reservas, usuarios, pagos) DEBEN requerir validación de rol en el backend; la validación solo en el frontend es una deficiencia de seguridad.
- **NFR-005 — Rendimiento**: La grilla de disponibilidad DEBE cargar completamente en menos de 2 segundos bajo carga nominal.
- **NFR-006 — Disponibilidad**: Los servicios de terceros (clima, pagos) DEBEN tener manejo de fallos que no interrumpa el flujo principal del usuario.
- **NFR-007 — Accesibilidad**: La interfaz DEBE cumplir los criterios de conformidad WCAG 2.1 nivel AA como mínimo.

### Key Entities

- **Usuario**: Persona registrada en la plataforma. Atributos: identificador único, nombre, email, contraseña (almacenada con hash), rol (CLIENTE | ADMINISTRADOR), estado de cuenta (activa/inactiva), fecha de registro.
- **Cancha**: Espacio físico de juego. Atributos: identificador, nombre, tipo de cancha, estado (activa/inactiva). Relación: tiene muchos Turnos.
- **Turno**: Plantilla recurrente de disponibilidad. Atributos: cancha asociada, día de la semana, hora de inicio, hora de fin, estado de habilitación. No representa una fecha concreta.
- **Reserva**: Instancia concreta de un Turno para una fecha específica y asociación con un Cliente. Atributos: cliente, turno, fecha, fecha de creación, estado (pendiente de pago/activa/cancelada), referencia al pago, motivo de cancelación (si aplica).
- **Pago**: Registro del cobro de una Reserva. Atributos: reserva asociada, monto, moneda, estado (pendiente/confirmado/rechazado/reembolsado), referencia externa de la pasarela, fecha de transacción.
- **Notificación**: Mensaje enviado a un usuario en un evento del sistema. Atributos: destinatario, tipo de evento (confirmación/modificación/cancelación/etc.), contenido, fecha de envío, estado de entrega. **(Post-MVP)**

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Un cliente puede completar el flujo completo de reserva (selección → clima → pago → confirmación) en menos de 3 minutos desde el inicio hasta recibir la notificación.
- **SC-002**: La grilla de disponibilidad se carga completamente en menos de 2 segundos en condiciones de carga nominal (hasta 100 usuarios concurrentes).
- **SC-003**: El 100% de los intentos de reserva simultánea del mismo turno resultan en, como máximo, una reserva confirmada (integridad garantizada sin duplicados).
- **SC-004**: Las notificaciones de confirmación de reserva son entregadas al cliente en menos de 30 segundos tras la confirmación del pago. **(Post-MVP)**
- **SC-005**: El sistema soporta al menos 100 usuarios concurrentes visualizando la grilla sin degradación perceptible del tiempo de respuesta.
- **SC-006**: El 95% de las operaciones de reserva y cancelación se completan en menos de 5 segundos de extremo a extremo.
- **SC-007**: Los administradores pueden localizar cualquier reserva aplicando filtros disponibles en menos de 10 segundos.
- **SC-008**: La tasa de éxito en el flujo de reserva (usuarios que inician y completan el pago) es igual o superior al 85%.

---

## Assumptions

- La primera cuenta de ADMINISTRADOR se crea mediante un proceso de inicialización del sistema (seed de datos o configuración inicial); no existe un flujo de autoregistro como administrador expuesto al público.
- Los pagos se procesan en moneda local (ARS) a través de la pasarela de referencia (Mercado Pago); otras monedas o pasarelas están fuera del alcance inicial.
- Cada turno es de uso exclusivo: un único cliente puede reservar un bloque horario determinado en una cancha específica para una fecha concreta.
- El complejo opera en un único huso horario; no se requiere soporte multi-zona horaria en esta versión.
- Las notificaciones de confirmación se envían por correo electrónico al email registrado; canales adicionales (SMS, push notifications) están fuera del alcance inicial.
- La información del clima se consulta por fecha y por la ubicación geográfica del complejo; esta ubicación es un parámetro de configuración del sistema.
- Se asume acceso estable a internet por parte de los clientes para completar el flujo de reserva y pago.
- **Política de cancelación y reembolso**: La cancelación con más de 24 horas de anticipación al horario del turno otorga reembolso completo. La cancelación con menos de 24 horas no genera reembolso. Esta política es fija en la versión inicial; configurabilidad por el administrador está fuera de alcance.
- La modificación de una reserva futura se considera una cancelación seguida de una nueva reserva a efectos del cálculo del plazo de cancelación; se aplica la misma regla de las 24 horas.

---

## Out of Scope

Los siguientes elementos están explícitamente excluidos del alcance de esta especificación y no deben considerarse en el diseño ni en la implementación:

- Grabación física, administración y/o reproducción de videos del complejo.
- Organización, gestión y soporte de torneos o ligas (brackets, tablas de posiciones, resultados).
- Desarrollo de aplicación móvil nativa para iOS o Android.
- Subida de archivos multimedia (imágenes, videos, documentos) por parte de los usuarios.
- Implementación de tienda online de camisetas u otros productos del complejo.
- Soporte para múltiples zonas horarias o múltiples sedes en esta versión inicial.
- Notificaciones push o SMS; solo se contempla correo electrónico.

### Out of Scope del MVP (TP)

- Implementación de notificaciones automáticas por email (FR-024, FR-031, SC-004) en esta entrega MVP.
- Modificación de reservas por el cliente (FR-025 y escenario 2 de US6) en esta entrega MVP.
