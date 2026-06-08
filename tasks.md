# 📋 tasks.md — Plan de Ejecución Atómico: Futbol5Ya Backend

> **Contexto base ya implementado:** Spring Boot, MySQL, JWT (JwtUtil, JwtAuthFilter, SecurityConfig), GlobalExceptionHandler, CRUD completo de Usuario (entidad, repositorio, DTOs, servicio, controller, tests).
>
> **Convenciones:**
> - `[P]` → Tarea paralelizable (puede desarrollarse en simultáneo con otras del mismo nivel sin romper la aplicación).
> - `Depende de` → Tareas que deben estar completadas antes de iniciar esta.
> - Los archivos se referencian desde `backEnd/src/main/java/com/example/backEnd/`.

---

## 🔵 FASE 1 — Dominio y Persistencia

---

### T001 — Crear enum `DiaSemana` [P]
- **Archivos a crear:**
  - `Entidad/DiaSemana.java`
- **Descripción:** Enum con los valores `LUNES`, `MARTES`, `MIERCOLES`, `JUEVES`, `VIERNES`, `SABADO`, `DOMINGO`.
- **Depende de:** Ninguna.

---

### T002 — Crear enum `EstadoReserva` [P]
- **Archivos a crear:**
  - `Entidad/EstadoReserva.java`
- **Descripción:** Enum con los valores `PENDIENTE`, `CONFIRMADA`, `CANCELADA`.
- **Depende de:** Ninguna.

---

### T003 — Crear entidad `Turno` [P]
- **Archivos a crear:**
  - `Entidad/Turno.java`
- **Descripción:** Entidad JPA mapeada a la tabla `turnos`. Campos: `id` (PK, auto), `diaSemana` (enum `DiaSemana`, persistido como STRING), `horaInicio` (`LocalTime`), `horaFin` (`LocalTime`), `disponible` (`Boolean`, default `true`). Relación `@ManyToOne @JoinColumn(name = "cancha_id")` hacia `Cancha`. Incluir constructor completo, constructor vacío y todos los getters/setters.
- **Depende de:** T001.

---

### T004 — Crear entidad `Reserva` [P]
- **Archivos a crear:**
  - `Entidad/Reserva.java`
- **Descripción:** Entidad JPA mapeada a la tabla `reservas`. Campos: `id` (PK, auto), `fecha` (`LocalDate`), `estado` (enum `EstadoReserva`, persistido como STRING, default `PENDIENTE`). Relación `@ManyToOne @JoinColumn(name = "usuario_id")` hacia `Usuario`. Relación `@ManyToOne @JoinColumn(name = "turno_id")` hacia `Turno`. Incluir constructor completo, constructor vacío y todos los getters/setters.
- **Depende de:** T002, T003.

---

### T005 — Crear `TurnoRepository` [P]
- **Archivos a crear:**
  - `Repository/TurnoRepository.java`
- **Descripción:** Interface que extiende `JpaRepository<Turno, Long>`. Métodos: `List<Turno> findByCanchaId(Long canchaId)`, `boolean existsByCanchaId(Long canchaId)`, `boolean existsByDiaSemanaAndHoraInicioAndCanchaId(DiaSemana dia, LocalTime horaInicio, Long canchaId)`.
- **Depende de:** T003.

---

### T006 — Crear `ReservaRepository` [P]
- **Archivos a crear:**
  - `Repository/ReservaRepository.java`
- **Descripción:** Interface que extiende `JpaRepository<Reserva, Long>`. Métodos: `List<Reserva> findByUsuarioId(Long usuarioId)`, `Optional<Reserva> findByTurnoIdAndFecha(Long turnoId, LocalDate fecha)`, `List<Reserva> findByTurnoIdAndFechaAndEstadoNot(Long turnoId, LocalDate fecha, EstadoReserva estado)`, `boolean existsByTurnoIdAndEstadoIn(Long turnoId, List<EstadoReserva> estados)`.
- **Depende de:** T004.

---

## 🟡 FASE 2 — Transferencia de Datos (DTOs)

---

### T007 — Crear DTOs de `Cancha` [P]
- **Archivos a crear:**
  - `DTO/CanchaRequestDTO.java`
  - `DTO/CanchaResponseDTO.java`
- **Descripción:**
  - `CanchaRequestDTO`: campos `nombre` (String), `tipo` (TipoCancha), `descripcion` (String), `activa` (Boolean). Constructor vacío y getters/setters.
  - `CanchaResponseDTO`: campos `id` (Long), `nombre`, `tipo`, `descripcion`, `activa`. Constructor completo, constructor vacío y getters.
- **Depende de:** Ninguna (las entidades necesarias ya existen).

---

### T008 — Crear DTOs de `Turno` [P]
- **Archivos a crear:**
  - `DTO/TurnoRequestDTO.java`
  - `DTO/TurnoResponseDTO.java`
- **Descripción:**
  - `TurnoRequestDTO`: campos `diaSemana` (DiaSemana), `horaInicio` (LocalTime), `horaFin` (LocalTime), `disponible` (Boolean), `canchaId` (Long). Constructor vacío y getters/setters.
  - `TurnoResponseDTO`: campos `id` (Long), `diaSemana`, `horaInicio`, `horaFin`, `disponible`, `canchaId` (Long), `nombreCancha` (String). Constructor completo, constructor vacío y getters.
- **Depende de:** T001, T003.

---

### T009 — Crear DTOs de `Reserva` [P]
- **Archivos a crear:**
  - `DTO/ReservaRequestDTO.java`
  - `DTO/ReservaResponseDTO.java`
- **Descripción:**
  - `ReservaRequestDTO`: campos `turnoId` (Long), `fecha` (LocalDate). Constructor vacío y getters/setters.
  - `ReservaResponseDTO`: campos `id` (Long), `fecha`, `estado` (EstadoReserva), `turnoId`, `diaSemana`, `horaInicio`, `horaFin`, `nombreCancha`, `usuarioId`, `nombreUsuario`, `apellidoUsuario`. Constructor completo, constructor vacío y getters.
- **Depende de:** T002, T004.

---

## 🟠 FASE 3 — Servicios de Aplicación

---

### T010 — Crear `CanchaService`
- **Archivos a crear:**
  - `Service/CanchaService.java`
- **Descripción:** Clase `@Service` con los siguientes métodos:
  - `crearCancha(CanchaRequestDTO dto)`: valida que el nombre no exista (usando `existsByNombreIgnoreCase`), lanza `IllegalArgumentException` si está duplicado. Crea y persiste la entidad. Retorna `CanchaResponseDTO`.
  - `obtenerTodas()`: retorna `List<CanchaResponseDTO>` con todas las canchas.
  - `obtenerPorId(Long id)`: retorna `CanchaResponseDTO` o lanza `RuntimeException` si no existe.
  - `actualizarCancha(Long id, CanchaRequestDTO dto)`: busca la cancha, actualiza nombre, tipo, descripcion y activa. Retorna `CanchaResponseDTO`.
  - `eliminarCancha(Long id)`: verifica existencia. Si la cancha tiene turnos asociados (`turnoRepository.existsByCanchaId(id)`), lanza `IllegalArgumentException("No se puede eliminar la cancha porque tiene turnos asociados. Elimine los turnos primero.")`. Si no tiene turnos, elimina. Retorna `RuntimeException` si no existe.
  - **Decisión eliminación cancha:** No se usa cascada. Si tiene turnos, se bloquea. El admin debe eliminar los turnos manualmente primero.
  - `cambiarEstado(Long id, Boolean activa)`: busca la cancha, asigna el valor de `activa` y guarda. Los turnos de la cancha NO se modifican; la cancha inactiva simplemente no aparecerá en la grilla de disponibilidad. Retorna `CanchaResponseDTO`.
  - **Decisión desactivar cancha:** Los turnos mantienen su propio estado `disponible`. La grilla filtrará por `cancha.activa = true` para no mostrar sus turnos.
  - Método privado `toDTO(Cancha cancha)` que mapea entidad a `CanchaResponseDTO`.
- **Depende de:** T005, T007.

---

### T011 — Crear `TurnoService`
- **Archivos a crear:**
  - `Service/TurnoService.java`
- **Descripción:** Clase `@Service` con los siguientes métodos:
  - `crearTurno(TurnoRequestDTO dto)`: verifica que la cancha con `canchaId` exista (lanza `RuntimeException` si no). Crea y persiste el turno. Retorna `TurnoResponseDTO`.
  - `obtenerPorCancha(Long canchaId)`: retorna `List<TurnoResponseDTO>` con todos los turnos de una cancha.
  - `actualizarTurno(Long id, TurnoRequestDTO dto)`: busca el turno, actualiza `diaSemana`, `horaInicio`, `horaFin`. Retorna `TurnoResponseDTO`.
  - `eliminarTurno(Long id)`: verifica existencia. Si el turno tiene reservas activas (estado `PENDIENTE` o `CONFIRMADA`) usando `reservaRepository.existsByTurnoIdAndEstadoIn(id, List.of(PENDIENTE, CONFIRMADA))`, lanza `IllegalArgumentException("No se puede eliminar el turno porque tiene reservas activas.")`. Si no tiene reservas activas, elimina. Lanza `RuntimeException` si el turno no existe.
  - **Decisión eliminación turno:** No se usa cascada. Si tiene reservas activas, se bloquea la eliminación.
  - `cambiarDisponibilidad(Long id, Boolean disponible)`: busca el turno, asigna `disponible` y guarda. Retorna `TurnoResponseDTO`.
  - Método privado `toDTO(Turno turno)` que mapea entidad a `TurnoResponseDTO`.
- **Depende de:** T005, T008.

---

### T012 — Crear `ReservaService`
- **Archivos a crear:**
  - `Service/ReservaService.java`
- **Descripción:** Clase `@Service` con los siguientes métodos:
  - `realizarReserva(ReservaRequestDTO dto, String emailUsuario)`: busca el turno por `turnoId` (lanza excepción si no existe o si `disponible = false`). Verifica que no exista una reserva en estado distinto a `CANCELADA` para ese turno y esa fecha usando `findByTurnoIdAndFechaAndEstadoNot`. Si ya existe, lanza `IllegalArgumentException("El turno ya está reservado para esa fecha.")`. Busca el usuario por email. Crea la reserva con estado `PENDIENTE`. Retorna `ReservaResponseDTO`.
  - **Decisión estado:** La reserva nace en estado `PENDIENTE`. En el futuro, la confirmación automática se realizará al completar el pago mediante la integración con Mercado Pago (fuera del alcance actual).
  - **Decisión fecha/día:** El backend NO valida que la fecha coincida con el `diaSemana` del turno. Esa responsabilidad recae en el frontend, que mostrará solo las combinaciones válidas en la grilla.
  - **Decisión fecha pasada:** El backend valida que `fecha >= LocalDate.now()`. Si la fecha es anterior a hoy, lanza `IllegalArgumentException("No se puede reservar para una fecha pasada.")`.
  - `obtenerMisReservas(String emailUsuario)`: busca el usuario por email, retorna `List<ReservaResponseDTO>` con sus reservas ordenadas por fecha.
  - `cancelarReserva(Long id, String emailUsuario)`: busca la reserva. Verifica que el `usuario.email` de la reserva coincida con `emailUsuario`, lanza `SecurityException` si no. Si el estado ya es `CANCELADA`, lanza `IllegalArgumentException`. Actualiza el estado a `CANCELADA` y guarda. Retorna `ReservaResponseDTO`.
  - **Decisión:** No hay restricción de fecha ni hora para cancelar. Se puede cancelar en cualquier momento mientras el estado no sea ya `CANCELADA`.
  - `obtenerReservasPorUsuario(Long usuarioId)`: retorna `List<ReservaResponseDTO>` con todas las reservas de un usuario dado su ID. Lanza `RuntimeException` si el usuario no existe.
  - `obtenerDisponibilidad(LocalDate fecha, Long canchaId)`: si `canchaId` es informado, obtiene los turnos de esa cancha (solo si `cancha.activa = true`). Si `canchaId` es `null`, obtiene los turnos de **todas las canchas activas**. Para cada turno, verifica si existe una reserva no cancelada para esa fecha. Retorna `List<TurnoResponseDTO>` donde el campo `disponible` refleja la disponibilidad real para esa fecha concreta (turno habilitado Y sin reserva activa).
  - **Decisión disponibilidad:** `canchaId` es opcional. Si se omite, devuelve la grilla de todas las canchas activas. Solo se muestran turnos de canchas con `activa = true`.
  - Método privado `toDTO(Reserva reserva)` que mapea entidad a `ReservaResponseDTO`.
- **Depende de:** T006, T009, T011.

---

## 🔴 FASE 4 — Exposición de API (Controllers)

---

### T013 — Crear `CanchaController`
- **Archivos a crear:**
  - `Controller/CanchaController.java`
- **Descripción:** `@RestController` en `/api/canchas` con anotaciones Swagger `@Tag` y `@Operation`. Endpoints:
  - `POST /api/canchas` → llama a `canchaService.crearCancha(dto)`. Retorna `201 Created`.
  - `GET /api/canchas` → llama a `canchaService.obtenerTodas()`. Retorna `200 OK`.
  - `GET /api/canchas/{id}` → llama a `canchaService.obtenerPorId(id)`. Retorna `200 OK`.
  - `PUT /api/canchas/{id}` → llama a `canchaService.actualizarCancha(id, dto)`. Retorna `200 OK`.
  - `DELETE /api/canchas/{id}` → llama a `canchaService.eliminarCancha(id)`. Retorna `204 No Content`.
  - `PATCH /api/canchas/{id}/estado?activa={true|false}` → llama a `canchaService.cambiarEstado(id, activa)`. Retorna `200 OK`.
- **Depende de:** T010.

---

### T014 — Crear `TurnoController`
- **Archivos a crear:**
  - `Controller/TurnoController.java`
- **Descripción:** `@RestController` con anotaciones Swagger `@Tag` y `@Operation`. Endpoints:
  - `POST /api/turnos` → llama a `turnoService.crearTurno(dto)`. Retorna `201 Created`.
  - `GET /api/canchas/{id}/turnos` → llama a `turnoService.obtenerPorCancha(id)`. Retorna `200 OK`.
  - `PUT /api/turnos/{id}` → llama a `turnoService.actualizarTurno(id, dto)`. Retorna `200 OK`.
  - `DELETE /api/turnos/{id}` → llama a `turnoService.eliminarTurno(id)`. Retorna `204 No Content`.
  - `PATCH /api/turnos/{id}/disponibilidad?disponible={true|false}` → llama a `turnoService.cambiarDisponibilidad(id, disponible)`. Retorna `200 OK`.
- **Depende de:** T011.

---

### T015 — Crear `ReservaController`
- **Archivos a crear:**
  - `Controller/ReservaController.java`
- **Descripción:** `@RestController` en `/api/reservas` con anotaciones Swagger `@Tag` y `@Operation`. El email del usuario autenticado se extrae del `SecurityContextHolder` (principal). Endpoints:
  - `POST /api/reservas` → llama a `reservaService.realizarReserva(dto, emailUsuario)`. Retorna `201 Created`.
  - `GET /api/reservas/mis-reservas` → llama a `reservaService.obtenerMisReservas(emailUsuario)`. Retorna `200 OK`.
  - `PATCH /api/reservas/{id}/cancelar` → llama a `reservaService.cancelarReserva(id, emailUsuario)`. Retorna `200 OK`.
  - `GET /api/reservas/disponibilidad?fecha={fecha}&canchaId={id}` → llama a `reservaService.obtenerDisponibilidad(fecha, canchaId)`. `canchaId` es **opcional**: si se omite, devuelve disponibilidad de todas las canchas activas. Retorna `200 OK`.
  - `GET /api/usuarios/{id}/reservas` → llama a `reservaService.obtenerReservasPorUsuario(id)`. Retorna `200 OK`.
- **Depende de:** T012.

---

## 🟣 FASE 5 — Seguridad Estricta de Roles

---

### T016 — Habilitar `@EnableMethodSecurity` en `SecurityConfig`
- **Archivos a modificar:**
  - `config/SecurityConfig.java`
- **Descripción:** Agregar la anotación `@EnableMethodSecurity(prePostEnabled = true)` a la clase `SecurityConfig`. Esto habilita el uso de `@PreAuthorize` y `@PostAuthorize` en los controllers y services.
- **Depende de:** Ninguna (puede aplicarse en cualquier momento antes de T017–T021).

---

### T017 — Aplicar `@PreAuthorize` en `UsuarioController` [P]
- **Archivos a modificar:**
  - `Controller/UsuarioController.java`
- **Descripción:**
  - `obtenerTodos()` (`GET /api/usuarios`) → solo `ADMINISTRADOR`.
  - `eliminar()` (`DELETE /api/usuarios/{id}`) → solo `ADMINISTRADOR`.
  - `obtenerPorId()` (`GET /api/usuarios/{id}`) → accesible para `ADMINISTRADOR` siempre. Un `CLIENTE` solo puede acceder si el `id` del path coincide con el ID del usuario autenticado (verificar en el service recuperando el usuario por email del token y comparando IDs; lanzar `SecurityException` si no coincide).
  - `actualizar()` (`PUT /api/usuarios/{id}`) → misma lógica que `obtenerPorId`: `ADMINISTRADOR` puede editar cualquiera, `CLIENTE` solo puede editar su propio perfil.
- **Decisión:** El CLIENTE puede ver y modificar únicamente su propio perfil. El ADMIN gestiona todos los usuarios.
- **Depende de:** T016.

---

### T018 — Aplicar `@PreAuthorize` en `CanchaController` [P]
- **Archivos a modificar:**
  - `Controller/CanchaController.java`
- **Descripción:** Agregar `@PreAuthorize("hasRole('ADMINISTRADOR')")` en los métodos: `crear`, `actualizar`, `eliminar`, `cambiarEstado`. El endpoint `GET` (listar y por ID) queda accesible para cualquier usuario autenticado (sin `@PreAuthorize` adicional).
- **Depende de:** T013, T016.

---

### T019 — Aplicar `@PreAuthorize` en `TurnoController` [P]
- **Archivos a modificar:**
  - `Controller/TurnoController.java`
- **Descripción:** Agregar `@PreAuthorize("hasRole('ADMINISTRADOR')")` en los métodos: `crearTurno`, `actualizarTurno`, `eliminarTurno`, `cambiarDisponibilidad`. El endpoint `GET /api/canchas/{id}/turnos` queda accesible para cualquier usuario autenticado.
- **Depende de:** T014, T016.

---

### T020 — Aplicar `@PreAuthorize` en `ReservaController` para endpoints de CLIENTE y ADMIN [P]
- **Archivos a modificar:**
  - `Controller/ReservaController.java`
- **Descripción:** Los endpoints `realizarReserva`, `obtenerMisReservas` y `cancelarReserva` son accesibles tanto para `CLIENTE` como para `ADMINISTRADOR`. Usar `@PreAuthorize("hasAnyRole('CLIENTE', 'ADMINISTRADOR')")` en esos métodos. El endpoint de disponibilidad queda accesible para cualquier usuario autenticado.
- **Decisión:** El ADMINISTRADOR puede realizar, ver y cancelar sus propias reservas igual que un CLIENTE.
- **Depende de:** T015, T016.

---

### T021 — Aplicar `@PreAuthorize` en `ReservaController` para endpoints de ADMIN [P]
- **Archivos a modificar:**
  - `Controller/ReservaController.java`
- **Descripción:** Agregar `@PreAuthorize("hasRole('ADMINISTRADOR')")` en el método `obtenerReservasPorUsuario` (`GET /api/usuarios/{id}/reservas`).
- **Depende de:** T015, T016.

---

## ⚪ FASE 6 — Testing

---

### T022 — Crear `CanchaServiceTest` [P]
- **Archivos a crear:**
  - `test/.../CanchaServiceTest.java`
- **Descripción:** Clase de tests unitarios con Mockito que cubre:
  - `testCrearCanchaExitosa()`: mock retorna `false` en `existsByNombreIgnoreCase`, verifica llamada a `save` y DTO correcto.
  - `testCrearCanchaNombreDuplicado()`: mock retorna `true` en `existsByNombreIgnoreCase`, verifica `IllegalArgumentException`.
  - `testObtenerTodas()`: mock retorna lista con una cancha, verifica tamaño y datos del DTO.
  - `testObtenerPorIdExistente()`: mock retorna `Optional.of(cancha)`, verifica DTO retornado.
  - `testObtenerPorIdNoExistente()`: mock retorna `Optional.empty()`, verifica `RuntimeException`.
  - `testActualizarCancha()`: verifica que los campos se actualicen correctamente.
  - `testEliminarCanchaExistente()`: mock `existsById=true`, `existsByCanchaId=false`, verifica llamada a `deleteById`.
  - `testEliminarCanchaCon TurnosAsociados()`: mock `existsByCanchaId=true`, verifica `IllegalArgumentException`.
  - `testEliminarCanchaNoExistente()`: mock `existsById=false`, verifica `RuntimeException`.
  - `testCambiarEstadoActiva()`: verifica que `activa` quede en `true`.
  - `testCambiarEstadoDesactiva()`: verifica que `activa` quede en `false` y que los turnos NO se modifiquen.
- **Depende de:** T010.

---

### T023 — Crear `TurnoServiceTest` [P]
- **Archivos a crear:**
  - `test/.../TurnoServiceTest.java`
- **Descripción:** Clase de tests unitarios con Mockito que cubre:
  - `testCrearTurnoExitoso()`: mock retorna la cancha, verifica llamada a `save` y DTO retornado.
  - `testCrearTurnoCanchaNoExistente()`: mock retorna `Optional.empty()`, verifica `RuntimeException`.
  - `testObtenerPorCancha()`: mock retorna lista de turnos, verifica tamaño y datos.
  - `testActualizarTurno()`: verifica que los campos se actualicen correctamente.
  - `testEliminarTurnoExistente()`: mock `existsById=true`, `existsByTurnoIdAndEstadoIn=false`, verifica llamada a `deleteById`.
  - `testEliminarTurnoConReservasActivas()`: mock `existsByTurnoIdAndEstadoIn=true`, verifica `IllegalArgumentException`.
  - `testEliminarTurnoNoExistente()`: mock `existsById=false`, verifica `RuntimeException`.
  - `testCambiarDisponibilidadHabilita()`: verifica que `disponible` quede en `true`.
  - `testCambiarDisponibilidadDeshabilita()`: verifica que `disponible` quede en `false`.
- **Depende de:** T011.

---

### T024 — Crear `ReservaServiceTest` [P]
- **Archivos a crear:**
  - `test/.../ReservaServiceTest.java`
- **Descripción:** Clase de tests unitarios con Mockito que cubre:
  - `testRealizarReservaExitosa()`: turno disponible, sin reserva activa para esa fecha, fecha futura; verifica reserva guardada con estado `PENDIENTE`.
  - `testRealizarReservaTurnoNoDisponible()`: turno con `disponible = false`; verifica `IllegalArgumentException`.
  - `testRealizarReservaFechaOcupada()`: reserva activa existente para mismo turno y fecha; verifica `IllegalArgumentException`.
  - `testRealizarReservaFechaPasada()`: fecha anterior a hoy; verifica `IllegalArgumentException`.
  - `testObtenerMisReservas()`: mock retorna lista de reservas por usuario, verifica tamaño y datos del DTO.
  - `testCancelarReservaExitosa()`: reserva pertenece al usuario, estado no `CANCELADA`; verifica estado `CANCELADA` sin restricción de fecha.
  - `testCancelarReservaDeOtroUsuario()`: email no coincide; verifica `SecurityException`.
  - `testCancelarReservaYaCancelada()`: estado ya `CANCELADA`; verifica `IllegalArgumentException`.
  - `testObtenerReservasPorUsuario()`: mock retorna lista, verifica DTO.
  - `testObtenerDisponibilidadTurnoLibre()`: turno sin reserva activa → `disponible = true`.
  - `testObtenerDisponibilidadTurnoOcupado()`: turno con reserva activa → `disponible = false`.
  - `testObtenerDisponibilidadSinCanchaId()`: `canchaId = null`, verifica que se consulten todas las canchas activas.
- **Depende de:** T012.

---

### T025 — Crear `CanchaControllerTest` [P]
- **Archivos a crear:**
  - `test/.../CanchaControllerTest.java`
- **Descripción:** Tests de integración con `@WebMvcTest(CanchaController.class)` y `MockMvc`. Cubre:
  - `POST /api/canchas` con token de ADMIN → verifica `201 Created`.
  - `POST /api/canchas` con token de CLIENTE → verifica `403 Forbidden`.
  - `GET /api/canchas` con token válido → verifica `200 OK` y lista.
  - `PUT /api/canchas/{id}` con token de ADMIN → verifica `200 OK`.
  - `DELETE /api/canchas/{id}` con token de ADMIN → verifica `204 No Content`.
  - `PATCH /api/canchas/{id}/estado` con token de ADMIN → verifica `200 OK`.
- **Depende de:** T013, T016.

---

### T026 — Crear `TurnoControllerTest` [P]
- **Archivos a crear:**
  - `test/.../TurnoControllerTest.java`
- **Descripción:** Tests de integración con `@WebMvcTest(TurnoController.class)` y `MockMvc`. Cubre:
  - `POST /api/turnos` con token de ADMIN → verifica `201 Created`.
  - `POST /api/turnos` con token de CLIENTE → verifica `403 Forbidden`.
  - `GET /api/canchas/{id}/turnos` con token válido → verifica `200 OK` y lista.
  - `PUT /api/turnos/{id}` con token de ADMIN → verifica `200 OK`.
  - `DELETE /api/turnos/{id}` con token de ADMIN → verifica `204 No Content`.
  - `PATCH /api/turnos/{id}/disponibilidad` con token de ADMIN → verifica `200 OK`.
- **Depende de:** T014, T016.

---

### T027 — Crear `ReservaControllerTest` [P]
- **Archivos a crear:**
  - `test/.../ReservaControllerTest.java`
- **Descripción:** Tests de integración con `@WebMvcTest(ReservaController.class)` y `MockMvc`. Cubre:
  - `POST /api/reservas` con token de CLIENTE → verifica `201 Created`.
  - `POST /api/reservas` sin token → verifica `403 Forbidden`.
  - `GET /api/reservas/mis-reservas` con token de CLIENTE → verifica `200 OK`.
  - `PATCH /api/reservas/{id}/cancelar` con token de CLIENTE → verifica `200 OK`.
  - `GET /api/reservas/disponibilidad?fecha={fecha}` con token válido → verifica `200 OK`.
  - `GET /api/usuarios/{id}/reservas` con token de ADMIN → verifica `200 OK`.
  - `GET /api/usuarios/{id}/reservas` con token de CLIENTE → verifica `403 Forbidden`.
- **Depende de:** T015, T016.

---

## 📊 Resumen de Dependencias

```
T001 ──────────────────► T003 ──► T005 ──► T010 ──► T013 ──► T018
                          │                  │                  │
T002 ──► T004 ──► T006   │       T008 ──► T011 ──► T014 ──► T019   T016
          │               │                  │                  │     │
          └──────────────►└──► T009 ──► T012 ──► T015 ──► T020 ─┘    │
                                               │         T021         │
T007 ──────────────────────────────────────────┘                      │
                                                                       │
T017 ◄──── UsuarioController (ya existe) ◄────────────────────────────┘
```

---

## 📌 Orden de Implementación Sugerido (con paralelismo)

| Ronda | Tareas paralelizables |
|---|---|
| 1 | T001, T002 |
| 2 | T003 (depende T001), T007 |
| 3 | T004 (depende T002+T003), T005 (depende T003), T008 (depende T001+T003) |
| 4 | T006 (depende T004), T009 (depende T002+T004) |
| 5 | T010 (depende T005+T007), T011 (depende T005+T008) |
| 6 | T012 (depende T006+T009+T011) |
| 7 | T013 (depende T010), T014 (depende T011) |
| 8 | T015 (depende T012) |
| 9 | T016 |
| 10 | T017, T018 (depende T013+T016), T019 (depende T014+T016), T020, T021 (depende T015+T016) |
| 11 | T022 (depende T010), T023 (depende T011), T024 (depende T012), T025 (depende T013+T016), T026 (depende T014+T016), T027 (depende T015+T016) |

---

## ✅ Decisiones de Negocio Registradas

| # | Decisión |
|---|---|
| D1 | El ADMINISTRADOR puede realizar, ver y cancelar sus propias reservas igual que un CLIENTE. |
| D2 | El CLIENTE puede ver y modificar únicamente su propio perfil. El ADMIN gestiona todos los usuarios. |
| D3 | La reserva nace en estado `PENDIENTE`. La confirmación automática es futura (Mercado Pago). |
| D4 | No hay restricción de tiempo para cancelar. Se puede cancelar en cualquier momento mientras no esté ya `CANCELADA`. |
| D5 | El backend NO valida que la fecha coincida con el `diaSemana` del turno. Lo controla el frontend. |
| D6 | El backend SÍ valida que `fecha >= hoy`. Fecha pasada lanza excepción. |
| D7 | No se puede eliminar una cancha si tiene turnos asociados. El admin debe eliminar los turnos primero. |
| D8 | No se puede eliminar un turno si tiene reservas activas (`PENDIENTE` o `CONFIRMADA`). |
| D9 | Desactivar una cancha NO deshabilita sus turnos. La grilla simplemente filtra canchas con `activa = true`. |
| D10 | El parámetro `canchaId` en `/disponibilidad` es opcional. Si se omite, devuelve todas las canchas activas. |
| D11 | La grilla de disponibilidad solo muestra turnos de canchas con `activa = true`. |
| D12 | El `DataSeeder` solo crea el admin por defecto. No se agregan datos de ejemplo de canchas ni turnos. |
| D13 | Testing incluye: services unitarios (Mockito) + controllers de integración (`@WebMvcTest`). |
