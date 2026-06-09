# Tasks: FutYa — Plataforma Integral de Gestión de Fútbol 5

**Input**: Design documents from `specs/001-futbol5ya-gestion-plataforma/`

**Prerequisites**: [plan.md](plan.md) ✅ · [spec.md](spec.md) ✅ · [research.md](research.md) ✅ · [data-model.md](data-model.md) ✅ · [contracts/openapi.yaml](contracts/openapi.yaml) ✅ · [quickstart.md](quickstart.md) ✅

**Tests**: Incluidos en Phase 6 según requerimiento explícito del usuario.

**Trazabilidad**: Cada tarea referencia los CUs de openapi.yaml y las USs de spec.md.

---

## Checklist Format

```
- [ ] T### [P?] [US?] Descripción — archivo/ruta exacta
```

- **`[P]`**: Tarea paralelizable con otras marcadas `[P]` en la misma fase (archivos distintos, sin dependencias entre sí)
- **`[US?]`**: Historia de usuario de spec.md (US1–US7); omitido en fases de setup, tests y DevOps

---

## Phase 1: Setup del Backend — Configuración Inicial

**Propósito**: Configuración inicial del proyecto Spring Boot: dependencias Maven, entorno, estructura de paquetes DTO, seeder de datos, manejo global de excepciones y linting.

**⚠️ BLOQUEO**: Esta fase debe completarse antes de cualquier otra fase backend.

- [ ] T001 Actualizar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/pom.xml` — agregar dependencias faltantes: `spring-boot-starter-security`, `jjwt-api` + `jjwt-impl` + `jjwt-jackson` (io.jsonwebtoken), `spring-boot-starter-webflux` (WebClient), `com.mercadopago:sdk-java`, `spring-boot-starter-validation`, `spring-boot-devtools`; agregar plugin `maven-checkstyle-plugin`
- [ ] T002 Actualizar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/resources/application.properties` — agregar configuración: JWT (`jwt.secret`, `jwt.expiration-ms`), OpenWeatherMap (`clima.openweathermap.api-key`, `base-url`, `lat`, `lon`, `timeout-ms`), Mercado Pago (`mercadopago.access-token`, `webhook-secret`, URLs de retorno), `reserva.pago.timeout-minutos=15`
- [ ] T003 [P] Crear subdirectorios de paquetes DTO en `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/DTO/` — subcarpetas: `auth/`, `cancha/`, `turno/`, `reserva/`, `usuario/`, `pago/`, `disponibilidad/`, `clima/`
- [ ] T004 [P] Actualizar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/config/DataSeeder.java` — seed del administrador inicial (`admin@futya.com` / `Admin1234!` con BCrypt) y datos de demo: 3 canchas activas + turnos de ejemplo (bloques horarios LUNES–VIERNES, 18:00–21:00); ejecutar solo en perfil `dev` con `@Profile("dev")`
- [ ] T005 [P] Actualizar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Exception/GlobalExceptionHandler.java` — manejar: `ResourceNotFoundException` → 404, `DataIntegrityViolationException` → 409 con lista de conflictos, `AccessDeniedException` → 403, `BadCredentialsException` → 401 (mensaje genérico), `MethodArgumentNotValidException` → 400 con detalles de campo, `WebClientException` → capturado localmente en `ClimaService` (no propagado)
- [ ] T006 [P] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/checkstyle.xml` — reglas de Google Java Style adaptadas al proyecto; registrar plugin `maven-checkstyle-plugin` en `pom.xml` con `failOnViolation=true` en fase `validate`

**Checkpoint**: `./mvnw compile` exitoso sin errores. Estructura de paquetes DTO lista. Checkstyle pasa con cero violaciones.

---

## Phase 2: Modelo de Dominio — Entidades JPA y ENUMs

**Propósito**: Definición de todos los ENUMs y entidades JPA del dominio según el esquema físico de `data-model.md`.

**⚠️ BLOQUEO**: Debe completarse antes de Phase 3 (repositorios no pueden compilar sin entidades).

- [ ] T007 [P] Verificar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Entidad/Rol.java` — debe contener exactamente `ADMINISTRADOR, CLIENTE`; confirmar `@Enumerated(EnumType.STRING)` en `Usuario.rol` (ya existe; verificar integridad)
- [ ] T008 [P] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Entidad/EstadoReserva.java` — ENUM: `PENDIENTE, CONFIRMADA, CANCELADA`
- [ ] T009 [P] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Entidad/DiaSemana.java` — ENUM: `LUNES, MARTES, MIERCOLES, JUEVES, VIERNES, SABADO, DOMINGO`
- [ ] T010 [P] Verificar/actualizar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Entidad/TipoCancha.java` — debe contener `FUTBOL_5, FUTBOL_7, FUTBOL_11`; ajustar si existe con valores distintos
- [ ] T011 Actualizar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Entidad/Usuario.java` — agregar campos: `dni` (VARCHAR 20), `apellido` (VARCHAR 100), `telefono` (VARCHAR 20, nullable), `activo` (boolean, default true), `fechaRegistro` (Timestamp, auto); agregar `@Table(uniqueConstraints = {@UniqueConstraint(columnNames="email"), @UniqueConstraint(columnNames="dni")})`; `@Enumerated(EnumType.STRING)` en `rol`
- [ ] T012 [P] Actualizar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Entidad/Cancha.java` — verificar campos completos: `nombre`, `tipo` (`TipoCancha`, `@Enumerated STRING`), `descripcion` (Text, nullable), `activa` (boolean); ajustar `@Table` si es necesario
- [ ] T013 Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Entidad/Turno.java` — entidad JPA: `id` (PK auto), `diaSemana` (`@Enumerated DiaSemana`), `horaInicio` (Time), `horaFin` (Time), `disponible` (boolean, default true), `@ManyToOne(fetch=LAZY) cancha`; `@Table` con índice en `(cancha_id, dia_semana)`
- [ ] T014 Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Entidad/Reserva.java` — entidad JPA: `id`, `fecha` (LocalDate), `estado` (`@Enumerated EstadoReserva`, default PENDIENTE), `motivoCancelacion` (VARCHAR 500, nullable), `canceladoPorAdmin` (boolean, default false), `fechaCreacion` (Timestamp auto), `fechaModificacion` (Timestamp, nullable); `@ManyToOne(LAZY) usuario`, `@ManyToOne(LAZY) turno`, `@OneToOne(mappedBy="reserva") pago`; `@Table(uniqueConstraints = @UniqueConstraint(columnNames={"turno_id","fecha"}))` — garantiza SC-003
- [ ] T015 Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Entidad/Pago.java` — entidad JPA: `id`, `@OneToOne(fetch=LAZY) reserva`, `monto` (BigDecimal 10,2), `moneda` (VARCHAR 3, default "ARS"), `estado` (`@Enumerated EstadoPago`), `referenciaExterna` (VARCHAR 255, nullable), `preferenceId` (VARCHAR 255, nullable), `fechaTransaccion` (Timestamp, nullable); `@Table(uniqueConstraints = @UniqueConstraint(columnNames="reserva_id"))`

**Checkpoint**: `./mvnw compile` exitoso. Con `spring.jpa.hibernate.ddl-auto=create-drop` en test, Hibernate genera correctamente las 5 tablas y el constraint `uq_reservas_turno_fecha`.

---

## Phase 3: Repositorios y Persistencia

**Propósito**: Interfaces Spring Data JPA con consultas JPQL personalizadas según las queries críticas definidas en `data-model.md`.

**Depende de**: Phase 2 completa (todas las entidades deben existir para que los repositorios compilen).

- [ ] T016 [P] Actualizar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Repository/UsuarioRepository.java` — agregar: `Optional<Usuario> findByEmail(String)`, `Optional<Usuario> findByDni(String)`, `boolean existsByEmail(String)`, `boolean existsByDni(String)`, `Page<Usuario> findByRol(Rol, Pageable)` para listado paginado de clientes
- [ ] T017 [P] Actualizar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Repository/CanchaRepository.java` — agregar: `List<Cancha> findByActivaTrue()`, `List<Cancha> findByActiva(boolean)`
- [ ] T018 [P] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Repository/TurnoRepository.java` — métodos: `List<Turno> findByCanchaId(Long)`, `List<Turno> findByCanchaIdAndDisponibleTrue(Long)`, `@Query("SELECT CASE WHEN COUNT(r) > 0 THEN true ELSE false END FROM Reserva r WHERE r.turno.id = :turnoId AND r.estado IN ('PENDIENTE','CONFIRMADA') AND r.fecha >= CURRENT_DATE") boolean existsReservaActivaByTurnoId(@Param("turnoId") Long)`
- [ ] T019 Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Repository/ReservaRepository.java` — con `@Query` JPQL: `getGrilla(LocalDate fecha)` join fetch turno+cancha+reservas para `data-model.md§Queries críticas§Grilla`; `List<Reserva> findByUsuarioIdOrderByFechaDesc(Long)` con `@EntityGraph` cargando turno+cancha+pago; `Optional<Reserva> findByTurnoIdAndFecha(Long, LocalDate)`; `List<Reserva> findByEstadoAndFechaCreacionBefore(EstadoReserva, Timestamp)` para job de timeout; `Page<Reserva> findWithFilters(Long canchaId, Long usuarioId, EstadoReserva estado, Pageable)` con `@Query` JPQL dinámico
- [ ] T020 [P] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Repository/PagoRepository.java` — métodos: `Optional<Pago> findByReservaId(Long)`, `Optional<Pago> findByReferenciaExterna(String)`, `Optional<Pago> findByPreferenceId(String)`

**Checkpoint**: Repositorios compilan. Tests `@DataJpaTest` mínimos pasan para verificar constraints (especialmente `uq_reservas_turno_fecha`).

---

## Phase 4: Servicios de Aplicación y Seguridad JWT

**Propósito**: Configuración de Spring Security con JWT y todos los servicios de aplicación que encapsulan la lógica de negocio.

**Depende de**: Phase 2 (entidades) y Phase 3 (repositorios).

- [ ] T021 Actualizar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/config/SecurityConfig.java` — configurar `SecurityFilterChain`: `csrf().disable()`, `sessionManagement(STATELESS)`, `authorizeHttpRequests`: `permitAll` para `POST /api/auth/**` y `POST /api/pagos/webhook`, `authenticated` para el resto; agregar `JwtAuthFilter` antes de `UsernamePasswordAuthenticationFilter`; exponer `AuthenticationManager` bean; `PasswordEncoder` BCrypt bean
- [ ] T022 Actualizar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Security/JwtUtil.java` — agregar: claim de rol en `generateToken(email, rol)`, método `validateToken(token, email)`, método `extractRole(token)`, leer `jwt.secret` y `jwt.expiration-ms` desde `@Value` en `application.properties`
- [ ] T023 Actualizar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Security/JwtAuthFilter.java` — extraer email y rol del token via `JwtUtil`; construir `UsernamePasswordAuthenticationToken` con `GrantedAuthority` de rol; establecer en `SecurityContextHolder`; manejar `ExpiredJwtException` y `MalformedJwtException` retornando 401 sin lanzar excepción no controlada
- [ ] T024 [US1] Actualizar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Service/UsuarioService.java` — implementar `UserDetailsService.loadUserByUsername(email)`; método `registrar(RegistroRequestDTO)`: valida unicidad de email y DNI, codifica contraseña con BCrypt, asigna rol CLIENTE; método `login(LoginRequestDTO)`: autentica via `AuthenticationManager`, genera JWT con rol, retorna `AuthResponseDTO`
- [ ] T025 [US2] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Service/CanchaService.java` — CRUD completo (crear, buscarTodos, buscarPorId, actualizar, eliminar); `eliminar(id)`: lanza `ConflictoReservasException` si existen reservas futuras PENDIENTE o CONFIRMADA; `cambiarEstado(id, activa)`: si desactiva, lista reservas futuras afectadas; retorna `CanchaResponseDTO`
- [ ] T026 [US3] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Service/TurnoService.java` — CRUD por cancha; `eliminar(id)` y `actualizar(id, dto)`: llaman `TurnoRepository.existsReservaActivaByTurnoId` y lanzan excepción si hay conflicto; `cambiarDisponibilidad(id, disponible)`: retorna `TurnoResponseDTO`
- [ ] T027 [US4] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Service/DisponibilidadService.java` — `getGrilla(LocalDate fecha, Long canchaId)`: calcula `DiaSemana` desde la fecha, ejecuta `ReservaRepository.getGrilla(fecha)` con JOIN FETCH turno+cancha, filtra por `canchaId` si presente, mapea a `List<DisponibilidadItemDTO>` marcando `reservado=true` si existe reserva PENDIENTE o CONFIRMADA para esa fecha
- [ ] T028 [US5][US6] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Service/ReservaService.java` — `crearReserva(turnoId, fecha, usuarioId)`: verifica disponibilidad, crea `Reserva` (PENDIENTE) + `Pago` (PENDIENTE) atómicamente en `@Transactional`; `cancelarReserva(reservaId, usuarioId)`: valida propiedad + fecha no pasada; si anticipación > 24h llama `PagoService.reembolsar()` y marca REEMBOLSADO; si < 24h solo cancela sin reembolso; `cancelarReservaAdmin(reservaId, motivo, adminId)`: sin restricción de plazo; `@Scheduled(fixedRate=300000) liberarReservasPendientes()`: busca PENDIENTE con `fechaCreacion < ahora - timeout` y las cancela
- [ ] T029 [US5] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Service/ClimaService.java` — `getClima(LocalDate fecha, String hora)`: llama `api.openweathermap.org/data/2.5/forecast` via `WebClient` con timeout de 3000ms; mapea el slot de pronóstico más cercano a `ClimaResponseDTO`; captura `WebClientException` o timeout y retorna `ClimaResponseDTO{disponible=false}` sin propagar excepción
- [ ] T030 [US5] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Service/PagoService.java` — `iniciarPago(reservaId)`: usa `MercadoPago.preference().create(...)` con `back_urls` y `notification_url` desde `application.properties`; persiste `preferenceId` en `Pago`; retorna `PagoIniciarResponseDTO{redirectUrl=init_point}`; `procesarWebhook(WebhookNotification)`: valida firma HMAC `x-signature`, busca pago por `referenciaExterna`, actualiza estado según `status` de MP; `reembolsar(pagoId)`: llama `MercadoPago.refund().create(paymentId)` y actualiza estado a REEMBOLSADO
- [ ] T031 [US7] Ampliar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Service/UsuarioService.java` — agregar métodos admin: `findAllClientes(Pageable)` retorna `Page<UsuarioResponseDTO>`; `findReservasByUsuarioId(Long usuarioId)` usa `ReservaRepository` con EntityGraph; `cancelarReservaAdmin(Long reservaId, String motivo, Long adminId)` delega a `ReservaService.cancelarReservaAdmin`

**Checkpoint**: `./mvnw compile` exitoso. Spring context arranca sin errores. `SecurityConfig` carga correctamente. JWT generado y validado en prueba manual.

---

## Phase 5: API REST — Controladores y DTOs

**Propósito**: Implementación de los 17 casos de uso REST según contratos en `contracts/openapi.yaml`.

**Depende de**: Phase 4 (todos los servicios deben existir).

### DTOs (todos paralelos entre sí)

- [ ] T032 [P] Crear en `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/DTO/auth/` — `RegistroRequestDTO.java` (@NotBlank dni, nombre, apellido, email @Email, password @Size(min=8), telefono nullable), `AuthResponseDTO.java` (token, tipo="Bearer", email, rol); actualizar `LoginRequestDTO.java` si está incompleto (email @Email, password @NotBlank)
- [ ] T033 [P] Crear en `DTO/cancha/` — `CanchaRequestDTO.java` (@NotBlank nombre, tipo TipoCancha @NotNull, descripcion nullable, activa boolean default true), `CanchaResponseDTO.java` (id, nombre, tipo, descripcion, activa), `EstadoCanchaRequestDTO.java` (activa @NotNull boolean)
- [ ] T034 [P] Crear en `DTO/turno/` — `TurnoRequestDTO.java` (@NotNull diaSemana DiaSemana, horaInicio/horaFin @NotNull LocalTime, disponible boolean, canchaId @NotNull Long), `TurnoResponseDTO.java` (id, diaSemana, horaInicio, horaFin, disponible, cancha CanchaResponseDTO), `DisponibilidadTurnoRequestDTO.java` (disponible @NotNull boolean)
- [ ] T035 [P] Crear en `DTO/reserva/` — `ReservaRequestDTO.java` (turnoId @NotNull Long, fecha @NotNull @Future LocalDate), `ReservaResponseDTO.java` (id, fecha, estado, motivoCancelacion, canceladoPorAdmin, fechaCreacion, fechaModificacion, turno TurnoResponseDTO, usuario UsuarioResponseDTO, pago PagoResponseDTO nullable), `ReservaConPagoResponseDTO.java` (extiende ReservaResponseDTO + pagoRedirectUrl String), `CancelacionAdminRequestDTO.java` (motivo @NotBlank @Size(min=10, max=500))
- [ ] T036 [P] Actualizar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/DTO/UsuarioResponseDTO.java` — agregar campos faltantes: `dni`, `apellido`, `telefono`, `rol Rol`, `activo boolean`
- [ ] T037 [P] Crear en `DTO/pago/` — `PagoResponseDTO.java` (id, monto, moneda, estado EstadoPago, referenciaExterna nullable, fechaTransaccion nullable), `PagoIniciarRequestDTO.java` (reservaId @NotNull Long), `PagoIniciarResponseDTO.java` (preferenceId, redirectUrl)
- [ ] T038 [P] Crear `DTO/disponibilidad/DisponibilidadItemDTO.java` — campos: turnoId, canchaId, canchaNombre, canchaTipo TipoCancha, diaSemana DiaSemana, horaInicio LocalTime, horaFin LocalTime, reservado boolean
- [ ] T039 [P] Crear `DTO/clima/ClimaResponseDTO.java` — campos: disponible boolean, fecha LocalDate nullable, hora String nullable, temperatura Double nullable, descripcion String nullable, iconoCodigo String nullable, probabilidadLluvia Double nullable

### Controladores

- [ ] T040 [US1] Actualizar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Controller/AuthController.java` — `POST /api/auth/registro` (CU1) → retorna 201 + `UsuarioResponseDTO`; `POST /api/auth/login` (CU2) → retorna 200 + `AuthResponseDTO` con JWT; `POST /api/auth/logout` (CU3) → retorna 204 (invalidación client-side); anotaciones `@Valid` en request bodies
- [ ] T041 [US4] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Controller/DisponibilidadController.java` — `GET /api/disponibilidad` (CU4) con params `fecha @DateTimeFormat` (required) y `canchaId` (optional) → retorna 200 + `List<DisponibilidadItemDTO>`; requiere JWT (cualquier rol)
- [ ] T042 [US5][US6] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Controller/ReservaController.java` — `POST /api/reservas` (CU5) → 201 + `ReservaConPagoResponseDTO`; `GET /api/reservas/mis-reservas` (CU6) con param `estado` opcional → 200 + `List<ReservaResponseDTO>`; `PATCH /api/reservas/{id}/cancelar` (CU7) → 200 + `ReservaResponseDTO`; todos con `@PreAuthorize("hasRole('CLIENTE')")`; extraer `usuarioId` del `SecurityContext`
- [ ] T043 [US2] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Controller/CanchaController.java` — `GET /api/admin/canchas` (CU8) → 200 lista; `POST /api/admin/canchas` (CU8) → 201; `PUT /api/admin/canchas/{id}` (CU9) → 200; `DELETE /api/admin/canchas/{id}` (CU10) → 204 o 409 con `ErrorConReservasResponse`; `PATCH /api/admin/canchas/{id}/estado` (CU11) → 200; todos con `@PreAuthorize("hasRole('ADMINISTRADOR')")`
- [ ] T044 [US3] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Controller/TurnoController.java` — `GET /api/admin/turnos` (CU12) con param `canchaId` opcional → 200; `POST /api/admin/turnos` (CU12) → 201; `PUT /api/admin/turnos/{id}` (CU13) → 200; `DELETE /api/admin/turnos/{id}` (CU14) → 204 o 409; `PATCH /api/admin/turnos/{id}/disponibilidad` (CU15) → 200; todos con `@PreAuthorize("hasRole('ADMINISTRADOR')")`
- [ ] T045 [US7] Actualizar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Controller/UsuarioController.java` — `GET /api/admin/usuarios` (CU16) paginado → 200 + `Page<UsuarioResponseDTO>`; `GET /api/admin/usuarios/{id}/reservas` (CU17) → 200 lista; `GET /api/admin/reservas` con filtros fecha/canchaId/usuarioId/estado paginado → 200; `PATCH /api/admin/reservas/{id}/cancelar` con `CancelacionAdminRequestDTO` → 200; todos con `@PreAuthorize("hasRole('ADMINISTRADOR')")`
- [ ] T046 Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Controller/PagoController.java` — `POST /api/pagos/iniciar` → 200 + `PagoIniciarResponseDTO` (requiere JWT CLIENTE); `POST /api/pagos/webhook` → 200 (sin JWT; valida firma HMAC del header `x-signature` en `PagoService.procesarWebhook`)
- [ ] T047 [P] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/Controller/ClimaController.java` — `GET /api/clima` con params `fecha` y `hora` → 200 + `ClimaResponseDTO`; si `disponible=false`, retorna 200 (no 503) para no bloquear el flujo de reserva; requiere JWT

**Checkpoint**: `./mvnw spring-boot:run` arranca sin errores. CU1–CU4 verificados manualmente con `curl` según `quickstart.md§Paso 6`. Swagger UI funcional en `/swagger-ui.html` si se agrega `springdoc-openapi`.

---

## Phase 6: Tests Backend — Unitarios e Integración

**Propósito**: Cobertura ≥ 80% en código nuevo. `ReservaService` y `PagoService` al 100% (crítico por lógica de negocio y pagos).

**Depende de**: Phase 4 (servicios) y Phase 5 (controladores).

- [ ] T048 [P][US1] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/test/java/com/example/backEnd/Service/UsuarioServiceTest.java` — tests con Mockito: `should_register_user_when_valid_data`, `should_throw_when_email_already_exists`, `should_throw_when_dni_already_exists`, `should_return_jwt_when_credentials_valid`, `should_throw_when_credentials_invalid`
- [ ] T049 [P][US2] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/test/java/com/example/backEnd/Service/CanchaServiceTest.java` — tests: `should_create_cancha_successfully`, `should_deactivate_cancha_successfully`, `should_throw_when_deleting_cancha_with_active_reservations`, `should_delete_cancha_without_active_reservations`
- [ ] T050 [P][US3] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/test/java/com/example/backEnd/Service/TurnoServiceTest.java` — tests: CRUD básico, `should_throw_when_modifying_turno_with_active_reservations`, `should_enable_disable_turno_correctly`
- [ ] T051 [US5][US6] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/test/java/com/example/backEnd/Service/ReservaServiceTest.java` — cobertura 100%; tests: `should_create_reserva_in_pending_state`, `should_throw_when_turno_already_reserved_for_date`, `should_cancel_with_full_refund_when_more_than_24h_advance`, `should_cancel_without_refund_when_less_than_24h_advance`, `should_not_cancel_past_reserva`, `should_release_pending_reservas_on_scheduled_job`
- [ ] T052 [P][US5] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/test/java/com/example/backEnd/Service/ClimaServiceTest.java` — tests: `should_return_clima_data_when_openweathermap_available`, `should_return_unavailable_when_service_throws_exception`, `should_return_unavailable_when_service_times_out`
- [ ] T053 [P][US5] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/test/java/com/example/backEnd/Service/PagoServiceTest.java` — cobertura 100%; tests: `should_create_mp_preference_and_return_redirect_url`, `should_update_reserva_to_confirmed_when_webhook_approved`, `should_update_reserva_pending_when_webhook_in_process`, `should_process_refund_when_cancel_more_than_24h`, `should_throw_when_webhook_signature_invalid`
- [ ] T054 [US1] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/test/java/com/example/backEnd/Controller/AuthControllerIntegrationTest.java` — MockMvc con `@SpringBootTest` + H2: `POST /api/auth/registro` → 201, `POST /api/auth/login` → 200 con token, `GET` endpoint protegido sin token → 401, `GET` endpoint ADMIN con token CLIENTE → 403
- [ ] T055 [US4] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/test/java/com/example/backEnd/Controller/DisponibilidadControllerIntegrationTest.java` — MockMvc: `GET /api/disponibilidad?fecha=...` → 200 con lista, sin token → 401, filtro por canchaId funciona correctamente
- [ ] T056 [US5] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/test/java/com/example/backEnd/Controller/ReservaControllerIntegrationTest.java` — MockMvc: `POST /api/reservas` → 201, `POST /api/reservas` mismo turno+fecha → 409 (verifica SC-003), `GET /api/reservas/mis-reservas` → 200, `PATCH /api/reservas/{id}/cancelar` con token CLIENTE válido → 200
- [ ] T057 [US2] Crear `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/test/java/com/example/backEnd/Controller/CanchaControllerIntegrationTest.java` — MockMvc: `POST /api/admin/canchas` con token ADMINISTRADOR → 201, `POST /api/admin/canchas` con token CLIENTE → 403, `DELETE /api/admin/canchas/{id}` con reservas activas → 409

**Checkpoint**: `./mvnw test` pasa con cobertura ≥ 80% en código nuevo. `ReservaServiceTest` y `PagoServiceTest` al 100%. Tiempo de suite < 5 minutos.

---

## Phase 7: Setup Frontend — React 19, Vite, TypeScript, Router

**Propósito**: Configuración de la SPA: proxy API, Axios con JWT interceptor, AuthContext, Router con guards basados en rol, componentes de layout y UI base.

**⚠️ BLOQUEO**: Debe completarse antes de Phase 8 (páginas) y Phase 9 (integración).

- [ ] T058 Actualizar `2026-MTN-TP3-Front-Miceli-Tabuada/vite.config.ts` — agregar `server.proxy`: `'/api' → { target: 'http://localhost:8081', changeOrigin: true }`; confirmar `base: '/'` para SPA routing
- [ ] T059 [P] Actualizar `2026-MTN-TP3-Front-Miceli-Tabuada/tsconfig.app.json` — verificar `strict: true`, `strictNullChecks: true`, `noImplicitAny: true`; agregar path alias `@/*` → `src/*` si no existe
- [ ] T060 [P] Crear `2026-MTN-TP3-Front-Miceli-Tabuada/vitest.config.ts` — configurar Vitest: `environment: 'jsdom'`, `setupFiles: ['./src/test/setup.ts']`, `coverage.provider: 'v8'`, `coverage.thresholds.lines: 80`
- [ ] T061 [P] Actualizar `2026-MTN-TP3-Front-Miceli-Tabuada/eslint.config.js` — agregar reglas: `@typescript-eslint/no-explicit-any: 'error'`, `react-hooks/rules-of-hooks: 'error'`, `react-hooks/exhaustive-deps: 'warn'`
- [ ] T062 Actualizar `2026-MTN-TP3-Front-Miceli-Tabuada/src/context/AuthContext.tsx` — estado: `{ usuario: UsuarioResponse | null, token: string | null, rol: Rol | null }`; funciones: `login(email, password): Promise<void>` (llama `auth.ts` y persiste token), `logout(): void` (limpia estado + localStorage), `isAuthenticated(): boolean`, `hasRole(rol: Rol): boolean`; inicializar desde `localStorage` al montar
- [ ] T063 [P] Crear `2026-MTN-TP3-Front-Miceli-Tabuada/src/hooks/useAuth.ts` — hook que consume `AuthContext` y expone: `isAuthenticated`, `usuario`, `rol`, `hasRole(rol)`, `login`, `logout`; lanza error si se usa fuera del `AuthProvider`
- [ ] T064 Actualizar `2026-MTN-TP3-Front-Miceli-Tabuada/src/services/api.ts` — Axios instance con `baseURL='/api'`; request interceptor: agrega `Authorization: Bearer {token}` si existe en `localStorage`; response interceptor: redirige a `/login` en status 401
- [ ] T065 [P] Actualizar `2026-MTN-TP3-Front-Miceli-Tabuada/src/types/index.ts` — definir tipos TypeScript para todas las entidades: `Rol`, `EstadoReserva`, `DiaSemana`, `TipoCancha`, `EstadoPago`, `UsuarioResponse`, `CanchaResponse`, `TurnoResponse`, `DisponibilidadItem`, `ReservaResponse`, `ReservaConPagoResponse`, `PagoResponse`, `ClimaResponse`, `AuthResponse`; tipos de request: `RegistroRequest`, `LoginRequest`, `CanchaRequest`, `TurnoRequest`, `ReservaRequest`, `PagoIniciarRequest`
- [ ] T066 Actualizar `2026-MTN-TP3-Front-Miceli-Tabuada/src/router/AppRouter.tsx` — definir rutas: `/` (redirect según rol), `/login`, `/registro`, `/grilla` (auth), `/cliente/dashboard` (CLIENTE), `/cliente/nueva-reserva` (CLIENTE), `/admin/dashboard` (ADMINISTRADOR), `/admin/canchas` (ADMINISTRADOR), `/admin/turnos` (ADMINISTRADOR), `/admin/usuarios` (ADMINISTRADOR); rutas envueltas en `ProtectedRoute` con `requiredRole`
- [ ] T067 [P] Actualizar `2026-MTN-TP3-Front-Miceli-Tabuada/src/router/ProtectedRoute.tsx` — prop `requiredRole?: Rol`; si no autenticado → redirect a `/login`; si autenticado pero rol incorrecto → redirect a `/` con mensaje de error; no dispersar lógica de rol en componentes individuales
- [ ] T068 [P] Actualizar `2026-MTN-TP3-Front-Miceli-Tabuada/src/router/routes.ts` — exportar constantes de paths y sus `requiredRole` como objeto tipado: `{ GRILLA: { path: '/grilla', requiredRole: null }, CLIENTE_DASHBOARD: { path: '/cliente/dashboard', requiredRole: Rol.CLIENTE }, ... }`
- [ ] T069 [P] Actualizar `2026-MTN-TP3-Front-Miceli-Tabuada/src/components/layout/Navbar.tsx` — mostrar links condicionales por rol usando `useAuth`: Grilla (autenticados), Panel Cliente (CLIENTE), Panel Admin (ADMINISTRADOR); botón Logout; responsive mobile

**Checkpoint**: `npm run dev` levanta en `http://localhost:5173`. Proxy a backend funciona (`/api/auth/login` no lanza CORS error). ESLint sin errores. `npm run test` pasa con suite vacía.

---

## Phase 8: Pantallas y Componentes Frontend

**Propósito**: Implementación de todas las vistas separadas por rol (Cliente y Administrador).

**Depende de**: Phase 7 completa (AuthContext, Router, tipos, Axios).

- [ ] T070 [US1] Actualizar `2026-MTN-TP3-Front-Miceli-Tabuada/src/pages/Login.tsx` — formulario: email + password; validación de campos vacíos; llamar `auth.login()`; manejar error 401 con mensaje genérico (no revelar si existe el email); redirect post-login según rol (`/cliente/dashboard` o `/admin/dashboard`)
- [ ] T071 [US1] Actualizar `2026-MTN-TP3-Front-Miceli-Tabuada/src/pages/Register.tsx` — formulario: dni, nombre, apellido, email, password, telefono (opcional); validación de formato; manejar error 409 (email/DNI duplicado) con mensaje específico; redirect a `/login` tras registro exitoso
- [ ] T072 [US4] Crear `2026-MTN-TP3-Front-Miceli-Tabuada/src/pages/Grilla.tsx` — date picker para seleccionar fecha (default hoy); grilla interactiva canchas × turnos mostrando estado: disponible (verde), ocupado (rojo); botón "Reservar" en turnos libres que navega a `/cliente/nueva-reserva?turnoId=X&fecha=Y`; botón "Actualizar" manual (Q1 resuelto: sin tiempo real automático)
- [ ] T073 [US6] Crear `2026-MTN-TP3-Front-Miceli-Tabuada/src/pages/cliente/Dashboard.tsx` — listado de `mis-reservas` con badge de estado, fecha, cancha y horario; botón "Cancelar" con modal de confirmación (muestra si aplica reembolso según regla 24hs); link a `/cliente/nueva-reserva`; estado vacío con CTA
- [ ] T074 [US5] Crear `2026-MTN-TP3-Front-Miceli-Tabuada/src/pages/cliente/NuevaReserva.tsx` — stepper de 3 pasos: **Paso 1** turno/fecha (prellenado desde query params si vienen de Grilla); **Paso 2** info del clima (`ClimaResponse`; banner de aviso si `disponible=false`); **Paso 3** confirmar → `POST /api/reservas` → `POST /api/pagos/iniciar` → `window.location.href = redirectUrl`; manejo de 409 (turno ya ocupado)
- [ ] T075 [US7] Crear `2026-MTN-TP3-Front-Miceli-Tabuada/src/pages/admin/Dashboard.tsx` — panel resumen con cards de acceso rápido: Canchas, Turnos, Usuarios; sin datos dinámicos en esta pantalla
- [ ] T076 [US2] Crear `2026-MTN-TP3-Front-Miceli-Tabuada/src/pages/admin/CanchasABM.tsx` — tabla con canchas (nombre, tipo, estado activa badge); botones: Crear (modal con `CanchaRequest`), Editar (modal prellenado), Activar/Desactivar, Eliminar (confirmación con aviso de conflicto si 409); manejo de error 409 mostrando reservas afectadas
- [ ] T077 [US3] Crear `2026-MTN-TP3-Front-Miceli-Tabuada/src/pages/admin/TurnosABM.tsx` — selector de cancha; tabla de turnos por cancha (día, horaInicio, horaFin, disponible badge); botones: Crear, Editar, Habilitar/Deshabilitar, Eliminar; manejo de conflicto si hay reservas activas
- [ ] T078 [US7] Crear `2026-MTN-TP3-Front-Miceli-Tabuada/src/pages/admin/UsuariosPanel.tsx` — tabla paginada de usuarios (nombre, email, reservas activas); expandir fila para ver historial de reservas con estado badge; botón "Cancelar reserva" abre modal que solicita motivo obligatorio; filtros por fecha/cancha/estado

**Checkpoint**: Todas las páginas renderizan sin errores en el navegador. Navegación protegida funciona: CLIENTE no puede acceder a `/admin/**`; no autenticado redirige a `/login`.

---

## Phase 9: Integración Frontend-Backend — Consumo de API REST y JWT

**Propósito**: Conectar cada página con su servicio HTTP correspondiente usando la instancia Axios con JWT interceptor.

**Depende de**: Phase 5 (endpoints backend operativos), Phase 7 (Axios + AuthContext), Phase 8 (páginas).

- [ ] T079 [US1] Actualizar `2026-MTN-TP3-Front-Miceli-Tabuada/src/services/auth.ts` — implementar: `registro(req: RegistroRequest): Promise<UsuarioResponse>` → `POST /api/auth/registro`; `login(req: LoginRequest): Promise<void>` → `POST /api/auth/login`, guarda token + usuario en `AuthContext`; `logout(): void` → `POST /api/auth/logout` + limpia `AuthContext` + `localStorage`
- [ ] T080 [US2] Crear `2026-MTN-TP3-Front-Miceli-Tabuada/src/services/canchas.ts` — funciones: `getAllCanchas()`, `createCancha(req)`, `updateCancha(id, req)`, `deleteCancha(id)`, `updateEstadoCancha(id, activa)`; todos vía Axios instance; tipos de retorno explícitos con tipos de `types/index.ts`
- [ ] T081 [US3] Crear `2026-MTN-TP3-Front-Miceli-Tabuada/src/services/turnos.ts` — funciones: `getTurnosByCancha(canchaId)`, `createTurno(req)`, `updateTurno(id, req)`, `deleteTurno(id)`, `updateDisponibilidad(id, disponible)`
- [ ] T082 [US4][US6] Actualizar `2026-MTN-TP3-Front-Miceli-Tabuada/src/services/reservas.ts` (ya existe, ampliar) — implementar: `getDisponibilidad(fecha, canchaId?)`, `getMisReservas(estado?)`, `createReserva(req)`, `cancelarReserva(id)`, `getClimaParaTurno(fecha, hora)`, `getAllReservas(filters)` (admin), `cancelarReservaAdmin(id, motivo)` (admin)
- [ ] T083 [US5] Crear `2026-MTN-TP3-Front-Miceli-Tabuada/src/services/pago.ts` — función `iniciarPago(reservaId): Promise<PagoIniciarResponse>` → `POST /api/pagos/iniciar`
- [ ] T084 [US1] Conectar `Login.tsx` y `Register.tsx` con `auth.ts` — `Login.tsx`: llamar `login()`, actualizar `AuthContext`, redirigir; `Register.tsx`: llamar `registro()`, manejar 409 con mensaje de campo específico; spinner durante request
- [ ] T085 [US4] Conectar `Grilla.tsx` con `reservas.ts` — llamar `getDisponibilidad(fecha, canchaId)` al cambiar fecha o filtro; spinner durante carga; mensaje de error si falla; refetch manual al pulsar "Actualizar"
- [ ] T086 [US5] Conectar `NuevaReserva.tsx` con `reservas.ts` y `pago.ts` — Paso 2: llamar `getClimaParaTurno(fecha, hora)` con banner de fallback; Paso 3: llamar `createReserva()` luego `iniciarPago()` y redirigir a `redirectUrl`; manejo de 409 con mensaje "Turno no disponible"
- [ ] T087 [US6] Conectar `cliente/Dashboard.tsx` con `reservas.ts` — `getMisReservas()` al montar; `cancelarReserva(id)` tras confirmación; mensaje informativo sobre política de reembolso (> 24h → reembolso, < 24h → sin reembolso); refetch tras cancelación
- [ ] T088 [US2][US3] Conectar `CanchasABM.tsx` con `canchas.ts` y `TurnosABM.tsx` con `turnos.ts` — CRUD completo; refetch tras cada mutación; manejar error 409 mostrando reservas en conflicto
- [ ] T089 [US7] Conectar `UsuariosPanel.tsx` con endpoints admin — `getAllReservas(filters)` con paginación; `cancelarReservaAdmin(id, motivo)` con modal; expandir usuario → `getMisReservas` filtrado por usuario via `/api/admin/usuarios/{id}/reservas`

**Checkpoint**: Flujo end-to-end verificado manualmente: registro → login → grilla → nueva reserva → clima → redirect MP sandbox → retorno → mis reservas → cancelar (con y sin reembolso). Panel admin: crear cancha → crear turno → ver usuarios.

---

## Phase 10: Validación E2E con Docker Desktop

**Propósito**: Contenerizar el stack completo y validar todos los criterios de éxito de `quickstart.md`.

**Depende de**: Phase 5 (backend completo) y Phase 9 (frontend completo).

- [ ] T090 Actualizar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/Dockerfile` — multi-stage: stage 1 `maven:3.9-eclipse-temurin-17-alpine` ejecuta `./mvnw package -DskipTests`; stage 2 `eclipse-temurin:17-jre-alpine` copia el JAR, expone puerto 8081, corre con usuario no-root (`addgroup -S app && adduser -S app -G app`)
- [ ] T091 [P] Actualizar `2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/Dockerfile.single` — imagen única `eclipse-temurin:17-jdk-alpine`: instala Maven, copia todo el proyecto, ejecuta `mvnw spring-boot:run`; expone 8081; usuario no-root; útil para debug local
- [ ] T092 [P] Actualizar `2026-MTN-TP3-Front-Miceli-Tabuada/Dockerfile` — multi-stage: stage 1 `node:20-alpine` ejecuta `npm ci && npm run build`; stage 2 `nginx:alpine` copia `dist/` a `/usr/share/nginx/html`, copia `nginx.conf`, expone puerto 80; usuario no-root
- [ ] T093 [P] Actualizar `2026-MTN-TP3-Front-Miceli-Tabuada/Dockerfile.single` — imagen `node:20-alpine`: instala dependencias y corre `npm run preview -- --host 0.0.0.0 --port 5173`; útil para debug
- [ ] T094 Crear `2026-MTN-TP3-Front-Miceli-Tabuada/nginx.conf` — configurar: `root /usr/share/nginx/html`; `try_files $uri $uri/ /index.html` para SPA client-side routing; `location /api { proxy_pass http://backend:8081; proxy_set_header Host $host; proxy_set_header X-Real-IP $remote_addr; }`; `gzip on`; cache headers para assets estáticos (`Cache-Control: public, max-age=31536000` para archivos con hash)
- [ ] T095 Crear `2026-MTN-TP5-FutYa-SDD/docker-compose.yml` — servicios: `db` (mysql:8.0, volumen `futya-db-data`, healthcheck `mysqladmin ping`), `backend` (build `../2026-MTN-TP3-Back-Miceli-Tabuada/backEnd`, puerto 8081, `depends_on db condition: service_healthy`, env_file: `.env`), `frontend` (build `../2026-MTN-TP3-Front-Miceli-Tabuada`, puerto `5173:80`, `depends_on backend`); volúmenes declarados
- [ ] T096 [P] Crear `2026-MTN-TP5-FutYa-SDD/.env.example` — template con todas las variables requeridas y comentarios explicativos: `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, `JWT_SECRET`, `JWT_EXPIRATION_MS`, `OPENWEATHER_API_KEY`, `OPENWEATHER_LAT`, `OPENWEATHER_LON`, `MERCADOPAGO_ACCESS_TOKEN`, `MERCADOPAGO_WEBHOOK_SECRET`, `MERCADOPAGO_SUCCESS_URL`, `MERCADOPAGO_FAILURE_URL`, `MERCADOPAGO_PENDING_URL`, `MERCADOPAGO_NOTIFICATION_URL`
- [ ] T097 Ejecutar validación E2E según `specs/001-futbol5ya-gestion-plataforma/quickstart.md` — `docker compose up --build`; health check `/actuator/health` → UP; verificar CU1+CU2 (registro + login), CU8+CU12 (crear cancha + turno como admin), CU4 (grilla), CU5 (crear reserva → HTTP 409 en duplicado concurrente), CU6 (mis reservas), CU7 (cancelar); frontend accesible en `http://localhost:5173`

**Checkpoint Final**: Stack completo corriendo en Docker Desktop. Todos los CU1–CU17 verificados. Criterios SC-001 a SC-007 medibles.

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1: Setup Backend
  └─► Phase 2: Domain Model (ENUMs + JPA Entities)
        └─► Phase 3: Repositories
              └─► Phase 4: Services + Security
                    └─► Phase 5: Controllers + DTOs
                          ├─► Phase 6: Tests Backend (paralelo con Phase 7+)
                          └─────────────────────────────────────────────────┐
Phase 7: Setup Frontend (puede iniciar desde Phase 1, tipos desde Phase 5)  │
  └─► Phase 8: Pages                                                         │
        └─► Phase 9: Integration Frontend-Backend                            │
              └─► Phase 10: Docker + E2E (requiere Phase 6 también) ◄────────┘
```

### User Story Dependencies

| Historia | Backend (fases 4-5) | Frontend (fases 8-9) | Independencia |
|----------|--------------------|--------------------|---------------|
| US1 — Autenticación (P1) | T024, T040 | T070, T071, T079, T084 | **Bloquea todo lo demás** |
| US2 — Gestión Canchas (P2) | T025, T043 | T076, T080, T088 | Independiente de US3–US7 |
| US3 — Config Turnos (P3) | T026, T044 | T077, T081, T088 | Depende de US2 (canchas existen) |
| US4 — Grilla (P4) | T027, T041 | T072, T082, T085 | Depende de US2+US3 (datos demo) |
| US5 — Reserva+Clima+Pago (P5) | T028–T030, T042, T046, T047 | T074, T083, T086 | Depende de US4 |
| US6 — Gestión Reservas (P6) | T028, T042 | T073, T082, T087 | Depende de US5 |
| US7 — Panel Admin (P7) | T031, T045 | T075, T078, T089 | Depende de US2+US3+US5 |

### Parallel Execution Opportunities

Dentro de cada fase las tareas marcadas `[P]` se pueden distribuir entre distintos miembros del equipo:

| Fase | Máxima paralelización |
|------|-----------------------|
| Phase 2 | T007–T012 (ENUMs + entidades simples) simultáneos |
| Phase 5 DTOs | T032–T039 (8 grupos de DTOs independientes) |
| Phase 6 | T048–T053 (tests unitarios por servicio) |
| Phase 7 | T059–T061, T065, T067–T069 |
| Phase 10 | T091–T093, T096 (Dockerfiles + .env.example) |

### Suggested MVP Scope

**MVP mínimo** (US1 + US2 + US3 + US4): Completar Phases 1–5 backend + Phases 7–8 frontend para esas historias.

Entrega: autenticación JWT funcional, gestión de canchas y turnos por el administrador, grilla de disponibilidad visible para el cliente. Deployable independientemente antes de agregar pagos e integraciones externas.
