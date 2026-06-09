#!/usr/bin/env bash
# =============================================================================
# create_issues.sh — FutYa: Crear GitHub Issues para cada tarea de tasks.md
# =============================================================================
# Requisitos:
#   - GitHub CLI (gh) instalado y autenticado: gh auth login
#   - Tener permisos de escritura en los repositorios indicados
# Uso:
#   chmod +x create_issues.sh
#   bash create_issues.sh
# =============================================================================

set -euo pipefail

BACK_REPO="Instituto-Politecnico-Modelo/2026-MTN-TP3-Back-Miceli-Tabuada"
FRONT_REPO="Instituto-Politecnico-Modelo/2026-MTN-TP3-Front-Miceli-Tabuada"
SDD_REPO="Instituto-Politecnico-Modelo/2026-MTN-TP5-FutYa-SDD"

# =============================================================================
# Crear labels en los tres repositorios (ignora error si ya existen)
# =============================================================================
create_labels() {
  local REPO=$1
  echo "→ Creando labels en $REPO..."
  for label in "backend" "frontend" "database" "security" "api" "testing" \
               "setup" "domain" "service" "ui" "integration" "docker" \
               "enhancement" "spec:US1" "spec:US2" "spec:US3" "spec:US4" \
               "spec:US5" "spec:US6" "spec:US7"; do
    gh label create "$label" --repo "$REPO" --color "#0075ca" --force 2>/dev/null || true
  done
}

create_labels "$BACK_REPO"
create_labels "$FRONT_REPO"
create_labels "$SDD_REPO"

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo " Creando issues — Phase 1: Setup del Backend"
echo "═══════════════════════════════════════════════════════════════════"

gh issue create --repo "$BACK_REPO" \
  --title "T001 — Actualizar pom.xml con todas las dependencias requeridas" \
  --label "backend,setup,enhancement" \
  --body "**Fase**: Phase 1 — Setup del Backend

**Archivo**: \`2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/pom.xml\`

Agregar dependencias faltantes: \`spring-boot-starter-security\`, \`jjwt-api/impl/jackson\`, \`spring-boot-starter-webflux\` (WebClient), \`com.mercadopago:sdk-java\`, \`spring-boot-starter-validation\`, \`spring-boot-devtools\`. Agregar plugin \`maven-checkstyle-plugin\`.

**Ref**: plan.md § Technical Context — Primary Dependencies"

gh issue create --repo "$BACK_REPO" \
  --title "T002 — Actualizar application.properties con configuración de JWT, OpenWeatherMap y Mercado Pago" \
  --label "backend,setup,enhancement" \
  --body "**Fase**: Phase 1 — Setup del Backend

**Archivo**: \`2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/resources/application.properties\`

Agregar: \`jwt.secret\`, \`jwt.expiration-ms\`, \`clima.openweathermap.*\`, \`mercadopago.*\`, \`reserva.pago.timeout-minutos=15\`.

**Ref**: research.md § Variables de Entorno Requeridas"

gh issue create --repo "$BACK_REPO" \
  --title "T003 — [P] Crear subdirectorios de paquetes DTO" \
  --label "backend,setup,enhancement" \
  --body "**Fase**: Phase 1 — Setup del Backend

**Directorio base**: \`2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/src/main/java/com/example/backEnd/DTO/\`

Crear subcarpetas: \`auth/\`, \`cancha/\`, \`turno/\`, \`reserva/\`, \`usuario/\`, \`pago/\`, \`disponibilidad/\`, \`clima/\`

**Paralelo con**: T004, T005, T006"

gh issue create --repo "$BACK_REPO" \
  --title "T004 — [P] Actualizar DataSeeder con seed de admin y datos de demo" \
  --label "backend,setup,enhancement" \
  --body "**Fase**: Phase 1 — Setup del Backend

**Archivo**: \`config/DataSeeder.java\`

Seed: admin \`admin@futya.com / Admin1234!\` con BCrypt; 3 canchas activas; turnos de ejemplo LUNES–VIERNES 18:00–21:00. Ejecutar solo con \`@Profile(\"dev\")\`.

**Ref**: data-model.md § Seed de Datos Inicial"

gh issue create --repo "$BACK_REPO" \
  --title "T005 — [P] Actualizar GlobalExceptionHandler con todos los tipos de error" \
  --label "backend,setup,enhancement" \
  --body "**Fase**: Phase 1 — Setup del Backend

**Archivo**: \`Exception/GlobalExceptionHandler.java\`

Manejar: ResourceNotFoundException (404), DataIntegrityViolationException (409), AccessDeniedException (403), BadCredentialsException (401 genérico), MethodArgumentNotValidException (400).

**Ref**: contracts/openapi.yaml § components/responses"

gh issue create --repo "$BACK_REPO" \
  --title "T006 — [P] Crear checkstyle.xml y registrar plugin en pom.xml" \
  --label "backend,setup,enhancement" \
  --body "**Fase**: Phase 1 — Setup del Backend

**Archivos**: \`checkstyle.xml\` (nuevo), actualizar \`pom.xml\`

Reglas Google Java Style adaptadas; \`failOnViolation=true\` en fase \`validate\`.

**Ref**: plan.md § Constitution Check — Linting"

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo " Creando issues — Phase 2: Modelo de Dominio"
echo "═══════════════════════════════════════════════════════════════════"

gh issue create --repo "$BACK_REPO" \
  --title "T007 — [P] Verificar Rol.java (ADMINISTRADOR, CLIENTE)" \
  --label "backend,domain,enhancement" \
  --body "**Fase**: Phase 2 — Modelo de Dominio

**Archivo**: \`Entidad/Rol.java\`

Verificar valores exactos: \`ADMINISTRADOR, CLIENTE\`. Confirmar \`@Enumerated(EnumType.STRING)\` en \`Usuario.rol\`.

**Ref**: data-model.md § Tipos Enumerados § Rol"

gh issue create --repo "$BACK_REPO" \
  --title "T008 — [P] Crear EstadoReserva.java ENUM" \
  --label "backend,domain,enhancement" \
  --body "**Fase**: Phase 2 — Modelo de Dominio

**Archivo**: \`Entidad/EstadoReserva.java\` (nuevo)

Valores: \`PENDIENTE, CONFIRMADA, CANCELADA\`

**Ref**: data-model.md § Tipos Enumerados § EstadoReserva"

gh issue create --repo "$BACK_REPO" \
  --title "T009 — [P] Crear DiaSemana.java ENUM" \
  --label "backend,domain,enhancement" \
  --body "**Fase**: Phase 2 — Modelo de Dominio

**Archivo**: \`Entidad/DiaSemana.java\` (nuevo)

Valores: \`LUNES, MARTES, MIERCOLES, JUEVES, VIERNES, SABADO, DOMINGO\`

**Ref**: data-model.md § Tipos Enumerados § DiaSemana"

gh issue create --repo "$BACK_REPO" \
  --title "T010 — [P] Verificar/actualizar TipoCancha.java ENUM" \
  --label "backend,domain,enhancement" \
  --body "**Fase**: Phase 2 — Modelo de Dominio

**Archivo**: \`Entidad/TipoCancha.java\`

Debe contener: \`FUTBOL_5, FUTBOL_7, FUTBOL_11\`

**Ref**: data-model.md § Tipos Enumerados § TipoCancha"

gh issue create --repo "$BACK_REPO" \
  --title "T011 — Actualizar Usuario.java con campos completos del dominio" \
  --label "backend,domain,enhancement" \
  --body "**Fase**: Phase 2 — Modelo de Dominio

**Archivo**: \`Entidad/Usuario.java\`

Agregar: \`dni\` (VARCHAR 20), \`apellido\`, \`telefono\` (nullable), \`activo\` (bool, default true), \`fechaRegistro\` (auto). Agregar \`@Table(uniqueConstraints)\` para email y dni.

**Ref**: data-model.md § Tabla: usuarios"

gh issue create --repo "$BACK_REPO" \
  --title "T012 — [P] Verificar/actualizar Cancha.java con mapeo completo" \
  --label "backend,domain,enhancement" \
  --body "**Fase**: Phase 2 — Modelo de Dominio

**Archivo**: \`Entidad/Cancha.java\`

Campos: \`nombre\`, \`tipo\` (TipoCancha, @Enumerated STRING), \`descripcion\` (Text, nullable), \`activa\` (bool).

**Ref**: data-model.md § Tabla: canchas"

gh issue create --repo "$BACK_REPO" \
  --title "T013 — Crear Turno.java entidad JPA" \
  --label "backend,domain,enhancement" \
  --body "**Fase**: Phase 2 — Modelo de Dominio

**Archivo**: \`Entidad/Turno.java\` (nuevo)

Campos: id, diaSemana (@Enumerated DiaSemana), horaInicio (Time), horaFin (Time), disponible, @ManyToOne(LAZY) cancha. Índice en (cancha_id, dia_semana).

**Ref**: data-model.md § Tabla: turnos"

gh issue create --repo "$BACK_REPO" \
  --title "T014 — Crear Reserva.java entidad JPA con constraint UNIQUE (turno_id, fecha)" \
  --label "backend,domain,database,enhancement" \
  --body "**Fase**: Phase 2 — Modelo de Dominio

**Archivo**: \`Entidad/Reserva.java\` (nuevo)

Campos: id, fecha (LocalDate), estado, motivoCancelacion, canceladoPorAdmin, fechaCreacion, fechaModificacion, @ManyToOne usuario, @ManyToOne turno, @OneToOne pago. **@UniqueConstraint(turno_id, fecha)** — garantiza SC-003.

**Ref**: data-model.md § Tabla: reservas"

gh issue create --repo "$BACK_REPO" \
  --title "T015 — Crear Pago.java entidad JPA" \
  --label "backend,domain,enhancement" \
  --body "**Fase**: Phase 2 — Modelo de Dominio

**Archivo**: \`Entidad/Pago.java\` (nuevo)

Campos: id, @OneToOne(LAZY) reserva, monto (BigDecimal 10,2), moneda, estado, referenciaExterna, preferenceId, fechaTransaccion.

**Ref**: data-model.md § Tabla: pagos"

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo " Creando issues — Phase 3: Repositorios y Persistencia"
echo "═══════════════════════════════════════════════════════════════════"

gh issue create --repo "$BACK_REPO" \
  --title "T016 — [P] Actualizar UsuarioRepository con queries de búsqueda" \
  --label "backend,database,enhancement" \
  --body "**Fase**: Phase 3 — Repositorios y Persistencia

**Archivo**: \`Repository/UsuarioRepository.java\`

Agregar: findByEmail, findByDni, existsByEmail, existsByDni, findByRol(Pageable).

**Ref**: data-model.md § Queries Críticas"

gh issue create --repo "$BACK_REPO" \
  --title "T017 — [P] Actualizar CanchaRepository con queries de activación" \
  --label "backend,database,enhancement" \
  --body "**Fase**: Phase 3 — Repositorios y Persistencia

**Archivo**: \`Repository/CanchaRepository.java\`

Agregar: findByActivaTrue(), findByActiva(boolean).

**Ref**: data-model.md"

gh issue create --repo "$BACK_REPO" \
  --title "T018 — [P] Crear TurnoRepository con query de reservas activas" \
  --label "backend,database,enhancement" \
  --body "**Fase**: Phase 3 — Repositorios y Persistencia

**Archivo**: \`Repository/TurnoRepository.java\` (nuevo)

Métodos: findByCanchaId, findByCanchaIdAndDisponibleTrue, existsReservaActivaByTurnoId (@Query JPQL).

**Ref**: data-model.md"

gh issue create --repo "$BACK_REPO" \
  --title "T019 — Crear ReservaRepository con queries JPQL para grilla y admin" \
  --label "backend,database,enhancement" \
  --body "**Fase**: Phase 3 — Repositorios y Persistencia

**Archivo**: \`Repository/ReservaRepository.java\` (nuevo)

Queries: getGrilla(fecha) con JOIN FETCH, findByUsuarioIdOrderByFechaDesc con @EntityGraph, findByEstadoAndFechaCreacionBefore (job timeout), findWithFilters (admin paginado).

**Ref**: data-model.md § Queries Críticas"

gh issue create --repo "$BACK_REPO" \
  --title "T020 — [P] Crear PagoRepository" \
  --label "backend,database,enhancement" \
  --body "**Fase**: Phase 3 — Repositorios y Persistencia

**Archivo**: \`Repository/PagoRepository.java\` (nuevo)

Métodos: findByReservaId, findByReferenciaExterna, findByPreferenceId.

**Ref**: data-model.md § Tabla: pagos"

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo " Creando issues — Phase 4: Servicios y Seguridad JWT"
echo "═══════════════════════════════════════════════════════════════════"

gh issue create --repo "$BACK_REPO" \
  --title "T021 — Configurar SecurityConfig (Spring Security filter chain + JWT)" \
  --label "backend,security,enhancement" \
  --body "**Fase**: Phase 4 — Servicios y Seguridad JWT

**Archivo**: \`config/SecurityConfig.java\`

csrf.disable, sessionManagement STATELESS, permitAll para /api/auth/** y POST /api/pagos/webhook, JwtAuthFilter before UsernamePasswordAuthenticationFilter, BCrypt PasswordEncoder.

**Ref**: plan.md § Constitution Check — Security"

gh issue create --repo "$BACK_REPO" \
  --title "T022 — Actualizar JwtUtil con soporte de rol y validación" \
  --label "backend,security,enhancement" \
  --body "**Fase**: Phase 4 — Servicios y Seguridad JWT

**Archivo**: \`Security/JwtUtil.java\`

Agregar: claim de rol en generateToken(email, rol), validateToken(token, email), extractRole(token). Leer secret y expiration de @Value.

**Ref**: plan.md § Constitution Check — JWT"

gh issue create --repo "$BACK_REPO" \
  --title "T023 — Actualizar JwtAuthFilter con extracción de rol y manejo de errores" \
  --label "backend,security,enhancement" \
  --body "**Fase**: Phase 4 — Servicios y Seguridad JWT

**Archivo**: \`Security/JwtAuthFilter.java\`

Extraer email + rol del token, crear UsernamePasswordAuthenticationToken con authorities, manejar ExpiredJwtException y MalformedJwtException retornando 401.

**Ref**: plan.md § Constitution Check — Security"

gh issue create --repo "$BACK_REPO" \
  --title "T024 — [US1] Actualizar UsuarioService (registro, login, UserDetailsService)" \
  --label "backend,service,security,spec:US1,enhancement" \
  --body "**Fase**: Phase 4 — Servicios y Seguridad JWT | **Historia**: US1 — Autenticación (P1)

**Archivo**: \`Service/UsuarioService.java\`

Implementar: loadUserByUsername, registrar(RegistroRequestDTO) con validación de unicidad, login(LoginRequestDTO) retornando AuthResponseDTO con JWT.

**Ref**: spec.md § US1; contracts/openapi.yaml § /api/auth"

gh issue create --repo "$BACK_REPO" \
  --title "T025 — [US2] Crear CanchaService (CRUD + activar/desactivar + validación reservas)" \
  --label "backend,service,spec:US2,enhancement" \
  --body "**Fase**: Phase 4 — Servicios y Seguridad JWT | **Historia**: US2 — Gestión de Canchas (P2)

**Archivo**: \`Service/CanchaService.java\` (nuevo)

CRUD completo, activar/desactivar, eliminar con validación de reservas activas (lanza ConflictoReservasException si existen).

**Ref**: spec.md § US2; data-model.md § canchas"

gh issue create --repo "$BACK_REPO" \
  --title "T026 — [US3] Crear TurnoService (CRUD + habilitar/deshabilitar + validación)" \
  --label "backend,service,spec:US3,enhancement" \
  --body "**Fase**: Phase 4 — Servicios y Seguridad JWT | **Historia**: US3 — Config Turnos (P3)

**Archivo**: \`Service/TurnoService.java\` (nuevo)

CRUD por cancha, habilitar/deshabilitar, impedir modificación/eliminación con reservas activas.

**Ref**: spec.md § US3; data-model.md § turnos"

gh issue create --repo "$BACK_REPO" \
  --title "T027 — [US4] Crear DisponibilidadService (grilla por fecha)" \
  --label "backend,service,spec:US4,enhancement" \
  --body "**Fase**: Phase 4 — Servicios y Seguridad JWT | **Historia**: US4 — Grilla (P4)

**Archivo**: \`Service/DisponibilidadService.java\` (nuevo)

getGrilla(LocalDate, Long canchaId): JOIN FETCH turno+cancha+reservas, marca reservado=true si existe PENDIENTE/CONFIRMADA para esa fecha.

**Ref**: spec.md § US4; data-model.md § Queries Críticas § Grilla"

gh issue create --repo "$BACK_REPO" \
  --title "T028 — [US5][US6] Crear ReservaService (crear, cancelar 24h rule, @Scheduled timeout)" \
  --label "backend,service,spec:US5,spec:US6,enhancement" \
  --body "**Fase**: Phase 4 — Servicios y Seguridad JWT | **Historias**: US5 (P5), US6 (P6)

**Archivo**: \`Service/ReservaService.java\` (nuevo)

crearReserva (PENDIENTE + Pago PENDIENTE @Transactional), cancelarReserva (>24h → reembolso, <24h → sin reembolso), cancelarReservaAdmin, @Scheduled liberarReservasPendientes (cada 5 min).

**Ref**: spec.md § US5, US6; research.md § Timeout de Pago"

gh issue create --repo "$BACK_REPO" \
  --title "T029 — [US5] Crear ClimaService (proxy OpenWeatherMap con fallback)" \
  --label "backend,service,spec:US5,enhancement" \
  --body "**Fase**: Phase 4 — Servicios y Seguridad JWT | **Historia**: US5 (P5)

**Archivo**: \`Service/ClimaService.java\` (nuevo)

WebClient a OpenWeatherMap, timeout 3000ms, mapea pronóstico más cercano a ClimaResponseDTO. Si falla → retorna ClimaResponseDTO{disponible=false}.

**Ref**: research.md § API de Clima; spec.md § FR-019"

gh issue create --repo "$BACK_REPO" \
  --title "T030 — [US5] Crear PagoService (Mercado Pago SDK: preference + webhook + reembolso)" \
  --label "backend,service,security,spec:US5,enhancement" \
  --body "**Fase**: Phase 4 — Servicios y Seguridad JWT | **Historia**: US5 (P5)

**Archivo**: \`Service/PagoService.java\` (nuevo)

iniciarPago: crea preferencia MP + retorna init_point. procesarWebhook: valida firma HMAC, actualiza estado. reembolsar: MP refund API.

**Ref**: research.md § Pasarela de Pagos — Mercado Pago"

gh issue create --repo "$BACK_REPO" \
  --title "T031 — [US7] Ampliar UsuarioService con métodos admin (listado, historial, cancelación)" \
  --label "backend,service,spec:US7,enhancement" \
  --body "**Fase**: Phase 4 — Servicios y Seguridad JWT | **Historia**: US7 — Panel Admin (P7)

**Archivo**: \`Service/UsuarioService.java\`

Agregar: findAllClientes(Pageable), findReservasByUsuarioId(Long), cancelarReservaAdmin(reservaId, motivo, adminId).

**Ref**: spec.md § US7; contracts/openapi.yaml § CU16, CU17"

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo " Creando issues — Phase 5: API REST — Controladores y DTOs"
echo "═══════════════════════════════════════════════════════════════════"

gh issue create --repo "$BACK_REPO" \
  --title "T032 — [P] Crear DTOs de autenticación (auth/)" \
  --label "backend,api,enhancement" \
  --body "**Fase**: Phase 5 — API REST | **Paralelo con**: T033–T039

**Archivos** en \`DTO/auth/\`: RegistroRequestDTO.java, AuthResponseDTO.java; actualizar LoginRequestDTO.java.

**Ref**: contracts/openapi.yaml § schemas/RegistroRequest, AuthResponse"

gh issue create --repo "$BACK_REPO" \
  --title "T033 — [P] Crear DTOs de cancha (cancha/)" \
  --label "backend,api,enhancement" \
  --body "**Fase**: Phase 5 — API REST | **Paralelo con**: T032, T034–T039

**Archivos** en \`DTO/cancha/\`: CanchaRequestDTO.java, CanchaResponseDTO.java, EstadoCanchaRequestDTO.java.

**Ref**: contracts/openapi.yaml § schemas/CanchaRequest, CanchaResponse"

gh issue create --repo "$BACK_REPO" \
  --title "T034 — [P] Crear DTOs de turno (turno/)" \
  --label "backend,api,enhancement" \
  --body "**Fase**: Phase 5 — API REST | **Paralelo con**: T032–T033, T035–T039

**Archivos** en \`DTO/turno/\`: TurnoRequestDTO.java, TurnoResponseDTO.java, DisponibilidadTurnoRequestDTO.java.

**Ref**: contracts/openapi.yaml § schemas/TurnoRequest, TurnoResponse"

gh issue create --repo "$BACK_REPO" \
  --title "T035 — [P] Crear DTOs de reserva (reserva/)" \
  --label "backend,api,enhancement" \
  --body "**Fase**: Phase 5 — API REST | **Paralelo con**: T032–T034, T036–T039

**Archivos** en \`DTO/reserva/\`: ReservaRequestDTO.java, ReservaResponseDTO.java, ReservaConPagoResponseDTO.java, CancelacionAdminRequestDTO.java.

**Ref**: contracts/openapi.yaml § schemas/ReservaRequest, ReservaResponse"

gh issue create --repo "$BACK_REPO" \
  --title "T036 — [P] Actualizar UsuarioResponseDTO con campos completos" \
  --label "backend,api,enhancement" \
  --body "**Fase**: Phase 5 — API REST | **Paralelo con**: T032–T035, T037–T039

**Archivo**: \`DTO/UsuarioResponseDTO.java\`

Agregar: dni, apellido, telefono, rol Rol, activo boolean.

**Ref**: contracts/openapi.yaml § schemas/UsuarioResponse"

gh issue create --repo "$BACK_REPO" \
  --title "T037 — [P] Crear DTOs de pago (pago/)" \
  --label "backend,api,enhancement" \
  --body "**Fase**: Phase 5 — API REST | **Paralelo con**: T032–T036, T038–T039

**Archivos** en \`DTO/pago/\`: PagoResponseDTO.java, PagoIniciarRequestDTO.java, PagoIniciarResponseDTO.java.

**Ref**: contracts/openapi.yaml § schemas/PagoResponse, PagoIniciarResponse"

gh issue create --repo "$BACK_REPO" \
  --title "T038 — [P] Crear DisponibilidadItemDTO" \
  --label "backend,api,enhancement" \
  --body "**Fase**: Phase 5 — API REST | **Paralelo con**: T032–T037, T039

**Archivo**: \`DTO/disponibilidad/DisponibilidadItemDTO.java\` (nuevo)

Campos: turnoId, canchaId, canchaNombre, canchaTipo, diaSemana, horaInicio, horaFin, reservado.

**Ref**: contracts/openapi.yaml § schemas/DisponibilidadItem"

gh issue create --repo "$BACK_REPO" \
  --title "T039 — [P] Crear ClimaResponseDTO" \
  --label "backend,api,enhancement" \
  --body "**Fase**: Phase 5 — API REST | **Paralelo con**: T032–T038

**Archivo**: \`DTO/clima/ClimaResponseDTO.java\` (nuevo)

Campos: disponible, fecha, hora, temperatura, descripcion, iconoCodigo, probabilidadLluvia.

**Ref**: contracts/openapi.yaml § schemas/ClimaResponse; research.md § DTO de Respuesta"

gh issue create --repo "$BACK_REPO" \
  --title "T040 — [US1] Actualizar AuthController (CU1: registro, CU2: login, CU3: logout)" \
  --label "backend,api,spec:US1,enhancement" \
  --body "**Fase**: Phase 5 — API REST | **Historia**: US1 — Autenticación (P1) | **CUs**: CU1, CU2, CU3

**Archivo**: \`Controller/AuthController.java\`

POST /api/auth/registro → 201 UsuarioResponseDTO; POST /api/auth/login → 200 AuthResponseDTO; POST /api/auth/logout → 204.

**Ref**: contracts/openapi.yaml § /api/auth"

gh issue create --repo "$BACK_REPO" \
  --title "T041 — [US4] Crear DisponibilidadController (CU4: grilla por fecha)" \
  --label "backend,api,spec:US4,enhancement" \
  --body "**Fase**: Phase 5 — API REST | **Historia**: US4 — Grilla (P4) | **CU**: CU4

**Archivo**: \`Controller/DisponibilidadController.java\` (nuevo)

GET /api/disponibilidad?fecha=&canchaId= → 200 List<DisponibilidadItemDTO>. Requiere JWT.

**Ref**: contracts/openapi.yaml § /api/disponibilidad"

gh issue create --repo "$BACK_REPO" \
  --title "T042 — [US5][US6] Crear ReservaController (CU5: crear, CU6: mis-reservas, CU7: cancelar)" \
  --label "backend,api,spec:US5,spec:US6,enhancement" \
  --body "**Fase**: Phase 5 — API REST | **Historias**: US5 (P5), US6 (P6) | **CUs**: CU5, CU6, CU7

**Archivo**: \`Controller/ReservaController.java\` (nuevo)

POST /api/reservas → 201; GET /api/reservas/mis-reservas → 200; PATCH /api/reservas/{id}/cancelar → 200. @PreAuthorize CLIENTE.

**Ref**: contracts/openapi.yaml § /api/reservas"

gh issue create --repo "$BACK_REPO" \
  --title "T043 — [US2] Crear CanchaController (CU8–CU11: CRUD + estado)" \
  --label "backend,api,spec:US2,enhancement" \
  --body "**Fase**: Phase 5 — API REST | **Historia**: US2 — Gestión Canchas (P2) | **CUs**: CU8, CU9, CU10, CU11

**Archivo**: \`Controller/CanchaController.java\` (nuevo)

GET/POST /api/admin/canchas; PUT/DELETE /api/admin/canchas/{id}; PATCH /api/admin/canchas/{id}/estado. @PreAuthorize ADMINISTRADOR.

**Ref**: contracts/openapi.yaml § /api/admin/canchas"

gh issue create --repo "$BACK_REPO" \
  --title "T044 — [US3] Crear TurnoController (CU12–CU15: CRUD + disponibilidad)" \
  --label "backend,api,spec:US3,enhancement" \
  --body "**Fase**: Phase 5 — API REST | **Historia**: US3 — Config Turnos (P3) | **CUs**: CU12, CU13, CU14, CU15

**Archivo**: \`Controller/TurnoController.java\` (nuevo)

GET/POST /api/admin/turnos; PUT/DELETE /api/admin/turnos/{id}; PATCH /api/admin/turnos/{id}/disponibilidad. @PreAuthorize ADMINISTRADOR.

**Ref**: contracts/openapi.yaml § /api/admin/turnos"

gh issue create --repo "$BACK_REPO" \
  --title "T045 — [US7] Actualizar UsuarioController (CU16: usuarios, CU17: historial reservas, cancelación admin)" \
  --label "backend,api,spec:US7,enhancement" \
  --body "**Fase**: Phase 5 — API REST | **Historia**: US7 — Panel Admin (P7) | **CUs**: CU16, CU17

**Archivo**: \`Controller/UsuarioController.java\`

GET /api/admin/usuarios paginado; GET /api/admin/usuarios/{id}/reservas; GET /api/admin/reservas con filtros; PATCH /api/admin/reservas/{id}/cancelar. @PreAuthorize ADMINISTRADOR.

**Ref**: contracts/openapi.yaml § /api/admin/usuarios, /api/admin/reservas"

gh issue create --repo "$BACK_REPO" \
  --title "T046 — Crear PagoController (iniciar pago + webhook Mercado Pago)" \
  --label "backend,api,security,enhancement" \
  --body "**Fase**: Phase 5 — API REST

**Archivo**: \`Controller/PagoController.java\` (nuevo)

POST /api/pagos/iniciar (JWT CLIENTE) → PagoIniciarResponseDTO; POST /api/pagos/webhook (sin JWT, valida firma HMAC x-signature).

**Ref**: contracts/openapi.yaml § /api/pagos; research.md § Seguridad del Webhook"

gh issue create --repo "$BACK_REPO" \
  --title "T047 — [P] Crear ClimaController (proxy servidor a OpenWeatherMap)" \
  --label "backend,api,enhancement" \
  --body "**Fase**: Phase 5 — API REST

**Archivo**: \`Controller/ClimaController.java\` (nuevo)

GET /api/clima?fecha=&hora= → ClimaResponseDTO. Si disponible=false retorna 200 igualmente.

**Ref**: contracts/openapi.yaml § /api/clima; research.md § Patrón de Integración"

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo " Creando issues — Phase 6: Tests Backend"
echo "═══════════════════════════════════════════════════════════════════"

gh issue create --repo "$BACK_REPO" \
  --title "T048 — [P][US1] UsuarioServiceTest (unit tests con Mockito)" \
  --label "backend,testing,spec:US1,enhancement" \
  --body "**Fase**: Phase 6 — Tests Backend | **Historia**: US1 | **Cobertura target**: ≥ 80%

**Archivo**: \`test/.../Service/UsuarioServiceTest.java\` (nuevo)

Tests: registro exitoso, email duplicado, DNI duplicado, login credenciales válidas, login credenciales inválidas.

**Ref**: plan.md § Constitution Check — Testing Standards"

gh issue create --repo "$BACK_REPO" \
  --title "T049 — [P][US2] CanchaServiceTest (unit tests con Mockito)" \
  --label "backend,testing,spec:US2,enhancement" \
  --body "**Fase**: Phase 6 — Tests Backend | **Historia**: US2

**Archivo**: \`test/.../Service/CanchaServiceTest.java\` (nuevo)

Tests: crear, desactivar, eliminar con/sin reservas activas.

**Ref**: spec.md § US2 — Acceptance Scenarios"

gh issue create --repo "$BACK_REPO" \
  --title "T050 — [P][US3] TurnoServiceTest (unit tests con Mockito)" \
  --label "backend,testing,spec:US3,enhancement" \
  --body "**Fase**: Phase 6 — Tests Backend | **Historia**: US3

**Archivo**: \`test/.../Service/TurnoServiceTest.java\` (nuevo)

Tests: CRUD básico, modificación con reservas activas (excepción), habilitar/deshabilitar.

**Ref**: spec.md § US3 — Acceptance Scenarios"

gh issue create --repo "$BACK_REPO" \
  --title "T051 — [US5][US6] ReservaServiceTest — COBERTURA 100% (crítico)" \
  --label "backend,testing,spec:US5,spec:US6,enhancement" \
  --body "**Fase**: Phase 6 — Tests Backend | **Historias**: US5, US6 | **Cobertura**: 100% OBLIGATORIO

**Archivo**: \`test/.../Service/ReservaServiceTest.java\` (nuevo)

Tests: crear reserva OK, turno ya ocupado (409), cancelar >24h con reembolso, cancelar <24h sin reembolso, reserva pasada rechazada, job de timeout libera reservas pendientes.

**Ref**: spec.md § SC-003, FR-025, FR-026"

gh issue create --repo "$BACK_REPO" \
  --title "T052 — [P][US5] ClimaServiceTest (mock WebClient)" \
  --label "backend,testing,spec:US5,enhancement" \
  --body "**Fase**: Phase 6 — Tests Backend | **Historia**: US5

**Archivo**: \`test/.../Service/ClimaServiceTest.java\` (nuevo)

Tests: respuesta OK de OpenWeatherMap, servicio no disponible → disponible=false, timeout → disponible=false.

**Ref**: spec.md § FR-019; research.md § Manejo de Fallo"

gh issue create --repo "$BACK_REPO" \
  --title "T053 — [P][US5] PagoServiceTest — COBERTURA 100% (crítico)" \
  --label "backend,testing,spec:US5,enhancement" \
  --body "**Fase**: Phase 6 — Tests Backend | **Historia**: US5 | **Cobertura**: 100% OBLIGATORIO

**Archivo**: \`test/.../Service/PagoServiceTest.java\` (nuevo)

Tests: crear preferencia MP y retornar redirectUrl, webhook aprobado actualiza a CONFIRMADA, webhook rechazado permanece PENDIENTE, procesar reembolso, firma webhook inválida lanza excepción.

**Ref**: research.md § Flujo de Pago; spec.md § FR-020–FR-022"

gh issue create --repo "$BACK_REPO" \
  --title "T054 — [US1] AuthControllerIntegrationTest (MockMvc + H2)" \
  --label "backend,testing,spec:US1,enhancement" \
  --body "**Fase**: Phase 6 — Tests Backend | **Historia**: US1

**Archivo**: \`test/.../Controller/AuthControllerIntegrationTest.java\` (nuevo)

Tests: POST /registro → 201, POST /login → 200 con token, endpoint protegido sin token → 401, endpoint admin con token CLIENTE → 403.

**Ref**: contracts/openapi.yaml § /api/auth"

gh issue create --repo "$BACK_REPO" \
  --title "T055 — [US4] DisponibilidadControllerIntegrationTest (MockMvc)" \
  --label "backend,testing,spec:US4,enhancement" \
  --body "**Fase**: Phase 6 — Tests Backend | **Historia**: US4

**Archivo**: \`test/.../Controller/DisponibilidadControllerIntegrationTest.java\` (nuevo)

Tests: GET /disponibilidad con fecha → 200 lista, sin token → 401, filtro canchaId.

**Ref**: contracts/openapi.yaml § /api/disponibilidad"

gh issue create --repo "$BACK_REPO" \
  --title "T056 — [US5] ReservaControllerIntegrationTest (MockMvc — verifica SC-003)" \
  --label "backend,testing,spec:US5,enhancement" \
  --body "**Fase**: Phase 6 — Tests Backend | **Historia**: US5

**Archivo**: \`test/.../Controller/ReservaControllerIntegrationTest.java\` (nuevo)

Tests: POST /reservas → 201, POST reserva duplicada mismo turno+fecha → 409 (verifica SC-003), GET mis-reservas → 200, PATCH cancelar válido → 200.

**Ref**: spec.md § SC-003; contracts/openapi.yaml § /api/reservas"

gh issue create --repo "$BACK_REPO" \
  --title "T057 — [US2] CanchaControllerIntegrationTest (MockMvc — verifica RBAC)" \
  --label "backend,testing,spec:US2,enhancement" \
  --body "**Fase**: Phase 6 — Tests Backend | **Historia**: US2

**Archivo**: \`test/.../Controller/CanchaControllerIntegrationTest.java\` (nuevo)

Tests: POST /admin/canchas con ADMINISTRADOR → 201, con CLIENTE → 403, DELETE con reservas activas → 409.

**Ref**: contracts/openapi.yaml § /api/admin/canchas"

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo " Creando issues — Phase 7: Setup Frontend"
echo "═══════════════════════════════════════════════════════════════════"

gh issue create --repo "$FRONT_REPO" \
  --title "T058 — Actualizar vite.config.ts con proxy /api → backend:8081" \
  --label "frontend,setup,enhancement" \
  --body "**Fase**: Phase 7 — Setup Frontend

**Archivo**: \`2026-MTN-TP3-Front-Miceli-Tabuada/vite.config.ts\`

Agregar server.proxy: \`/api → { target: 'http://localhost:8081', changeOrigin: true }\`.

**Ref**: plan.md § Technical Context — Frontend; quickstart.md § Paso 3"

gh issue create --repo "$FRONT_REPO" \
  --title "T059 — [P] Verificar tsconfig.app.json (strict mode + path aliases)" \
  --label "frontend,setup,enhancement" \
  --body "**Fase**: Phase 7 — Setup Frontend

**Archivo**: \`tsconfig.app.json\`

Verificar: strict: true, strictNullChecks: true, noImplicitAny: true; agregar path alias @/* → src/* si no existe.

**Ref**: plan.md § Constitution Check — TypeScript sin any"

gh issue create --repo "$FRONT_REPO" \
  --title "T060 — [P] Crear vitest.config.ts (jsdom + coverage 80%)" \
  --label "frontend,setup,testing,enhancement" \
  --body "**Fase**: Phase 7 — Setup Frontend

**Archivo**: \`vitest.config.ts\` (nuevo)

Configurar: environment jsdom, setupFiles con @testing-library/jest-dom, coverage provider v8, threshold lines 80%.

**Ref**: plan.md § Constitution Check — Testing Standards"

gh issue create --repo "$FRONT_REPO" \
  --title "T061 — [P] Actualizar eslint.config.js (no-explicit-any, react-hooks rules)" \
  --label "frontend,setup,enhancement" \
  --body "**Fase**: Phase 7 — Setup Frontend

**Archivo**: \`eslint.config.js\`

Agregar: @typescript-eslint/no-explicit-any: error, react-hooks/rules-of-hooks: error, react-hooks/exhaustive-deps: warn.

**Ref**: plan.md § Constitution Check — Linting"

gh issue create --repo "$FRONT_REPO" \
  --title "T062 — Actualizar AuthContext con JWT storage, login/logout y hasRole" \
  --label "frontend,security,enhancement" \
  --body "**Fase**: Phase 7 — Setup Frontend

**Archivo**: \`src/context/AuthContext.tsx\`

Estado: usuario, token, rol. Funciones: login(email, password), logout(), isAuthenticated(), hasRole(rol). Inicializar desde localStorage.

**Ref**: plan.md § Constitution Check — Security (role-aware routing)"

gh issue create --repo "$FRONT_REPO" \
  --title "T063 — [P] Crear useAuth.ts hook" \
  --label "frontend,setup,enhancement" \
  --body "**Fase**: Phase 7 — Setup Frontend

**Archivo**: \`src/hooks/useAuth.ts\` (nuevo)

Hook que consume AuthContext: isAuthenticated, usuario, rol, hasRole(rol), login, logout.

**Ref**: plan.md § Source Code Structure"

gh issue create --repo "$FRONT_REPO" \
  --title "T064 — Actualizar api.ts (Axios instance + JWT interceptor + 401 redirect)" \
  --label "frontend,integration,enhancement" \
  --body "**Fase**: Phase 7 — Setup Frontend

**Archivo**: \`src/services/api.ts\`

baseURL='/api'; request interceptor: agrega Authorization Bearer {token}; response interceptor: redirige a /login en 401.

**Ref**: plan.md § Constitution Check — /api calls through Vite proxy"

gh issue create --repo "$FRONT_REPO" \
  --title "T065 — [P] Actualizar types/index.ts con todos los tipos del dominio" \
  --label "frontend,setup,enhancement" \
  --body "**Fase**: Phase 7 — Setup Frontend

**Archivo**: \`src/types/index.ts\`

Definir todos los tipos TypeScript: Rol, EstadoReserva, DiaSemana, TipoCancha, EstadoPago, y todos los Response/Request DTOs correspondientes al backend.

**Ref**: contracts/openapi.yaml § components/schemas"

gh issue create --repo "$FRONT_REPO" \
  --title "T066 — Actualizar AppRouter con todas las rutas protegidas por rol" \
  --label "frontend,setup,enhancement" \
  --body "**Fase**: Phase 7 — Setup Frontend

**Archivo**: \`src/router/AppRouter.tsx\`

Rutas: /login, /registro, /grilla (auth), /cliente/dashboard (CLIENTE), /cliente/nueva-reserva (CLIENTE), /admin/** (ADMINISTRADOR). Envueltas en ProtectedRoute con requiredRole.

**Ref**: plan.md § Constitution Check — role-aware routing"

gh issue create --repo "$FRONT_REPO" \
  --title "T067 — [P] Actualizar ProtectedRoute con validación de rol centralizada" \
  --label "frontend,security,enhancement" \
  --body "**Fase**: Phase 7 — Setup Frontend

**Archivo**: \`src/router/ProtectedRoute.tsx\`

Prop requiredRole?: Rol. Sin auth → /login. Auth sin rol correcto → / con mensaje. No dispersar lógica de rol en componentes.

**Ref**: plan.md § Constitution Check — role-aware routing"

gh issue create --repo "$FRONT_REPO" \
  --title "T068 — [P] Actualizar routes.ts con paths tipados y requiredRole" \
  --label "frontend,setup,enhancement" \
  --body "**Fase**: Phase 7 — Setup Frontend

**Archivo**: \`src/router/routes.ts\`

Exportar constantes de paths con requiredRole tipado.

**Ref**: plan.md § Source Code Structure"

gh issue create --repo "$FRONT_REPO" \
  --title "T069 — [P] Actualizar Navbar con visibilidad condicional por rol" \
  --label "frontend,ui,enhancement" \
  --body "**Fase**: Phase 7 — Setup Frontend

**Archivo**: \`src/components/layout/Navbar.tsx\`

Links condicionales por rol usando useAuth. Botón Logout. Responsive mobile.

**Ref**: plan.md § Constitution Check — UX Consistency"

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo " Creando issues — Phase 8: Pantallas y Componentes Frontend"
echo "═══════════════════════════════════════════════════════════════════"

gh issue create --repo "$FRONT_REPO" \
  --title "T070 — [US1] Actualizar Login.tsx (formulario + redirect por rol)" \
  --label "frontend,ui,spec:US1,enhancement" \
  --body "**Fase**: Phase 8 — Pantallas | **Historia**: US1 — Autenticación (P1)

**Archivo**: \`src/pages/Login.tsx\`

Formulario: email + password. Validación campos vacíos. Error 401 con mensaje genérico. Redirect por rol: CLIENTE → /cliente/dashboard, ADMINISTRADOR → /admin/dashboard.

**Ref**: spec.md § US1 — Acceptance Scenarios 1, 2"

gh issue create --repo "$FRONT_REPO" \
  --title "T071 — [US1] Actualizar Register.tsx (formulario completo + manejo de 409)" \
  --label "frontend,ui,spec:US1,enhancement" \
  --body "**Fase**: Phase 8 — Pantallas | **Historia**: US1 — Autenticación (P1)

**Archivo**: \`src/pages/Register.tsx\`

Campos: dni, nombre, apellido, email, password, telefono (opcional). Manejo de 409 para email/DNI duplicado. Redirect a /login tras éxito.

**Ref**: spec.md § US1 — Acceptance Scenarios 1"

gh issue create --repo "$FRONT_REPO" \
  --title "T072 — [US4] Crear Grilla.tsx (grilla de disponibilidad interactiva)" \
  --label "frontend,ui,spec:US4,enhancement" \
  --body "**Fase**: Phase 8 — Pantallas | **Historia**: US4 — Grilla (P4)

**Archivo**: \`src/pages/Grilla.tsx\` (nuevo)

Date picker, grilla canchas×turnos con colores disponible/ocupado, botón Reservar en turnos libres → /cliente/nueva-reserva?turnoId=X&fecha=Y, botón Actualizar manual.

**Ref**: spec.md § US4; research decision Q1 (manual refresh)"

gh issue create --repo "$FRONT_REPO" \
  --title "T073 — [US6] Crear cliente/Dashboard.tsx (mis reservas + cancelar)" \
  --label "frontend,ui,spec:US6,enhancement" \
  --body "**Fase**: Phase 8 — Pantallas | **Historia**: US6 — Gestión Reservas (P6)

**Archivo**: \`src/pages/cliente/Dashboard.tsx\` (nuevo)

Listado mis-reservas con badge de estado. Botón cancelar con modal de confirmación mostrando política de reembolso (24h rule). Link a nueva reserva.

**Ref**: spec.md § US6; spec.md § Assumptions — Política de cancelación"

gh issue create --repo "$FRONT_REPO" \
  --title "T074 — [US5] Crear cliente/NuevaReserva.tsx (stepper: turno → clima → pago)" \
  --label "frontend,ui,spec:US5,enhancement" \
  --body "**Fase**: Phase 8 — Pantallas | **Historia**: US5 — Reserva+Clima+Pago (P5)

**Archivo**: \`src/pages/cliente/NuevaReserva.tsx\` (nuevo)

Stepper 3 pasos: selección turno/fecha (prellenado desde query params), info clima con banner fallback, confirmar → POST /api/reservas → POST /api/pagos/iniciar → redirect MP.

**Ref**: spec.md § US5 — Acceptance Scenarios 1–6"

gh issue create --repo "$FRONT_REPO" \
  --title "T075 — [US7] Crear admin/Dashboard.tsx (panel resumen admin)" \
  --label "frontend,ui,spec:US7,enhancement" \
  --body "**Fase**: Phase 8 — Pantallas | **Historia**: US7 — Panel Admin (P7)

**Archivo**: \`src/pages/admin/Dashboard.tsx\` (nuevo)

Cards de acceso rápido: Canchas, Turnos, Usuarios. Sin datos dinámicos en esta pantalla.

**Ref**: spec.md § US7"

gh issue create --repo "$FRONT_REPO" \
  --title "T076 — [US2] Crear admin/CanchasABM.tsx (tabla + modal ABM + gestión 409)" \
  --label "frontend,ui,spec:US2,enhancement" \
  --body "**Fase**: Phase 8 — Pantallas | **Historia**: US2 — Gestión Canchas (P2)

**Archivo**: \`src/pages/admin/CanchasABM.tsx\` (nuevo)

Tabla canchas con estado badge. Modales: crear, editar. Botones: activar/desactivar, eliminar (confirmación). Manejo de 409 mostrando reservas afectadas.

**Ref**: spec.md § US2 — Acceptance Scenarios"

gh issue create --repo "$FRONT_REPO" \
  --title "T077 — [US3] Crear admin/TurnosABM.tsx (tabla por cancha + modal ABM)" \
  --label "frontend,ui,spec:US3,enhancement" \
  --body "**Fase**: Phase 8 — Pantallas | **Historia**: US3 — Config Turnos (P3)

**Archivo**: \`src/pages/admin/TurnosABM.tsx\` (nuevo)

Selector de cancha. Tabla de turnos por cancha. Modales: crear, editar. Botones: habilitar/deshabilitar, eliminar. Manejo de conflicto con reservas activas.

**Ref**: spec.md § US3 — Acceptance Scenarios"

gh issue create --repo "$FRONT_REPO" \
  --title "T078 — [US7] Crear admin/UsuariosPanel.tsx (tabla paginada + historial + cancelar admin)" \
  --label "frontend,ui,spec:US7,enhancement" \
  --body "**Fase**: Phase 8 — Pantallas | **Historia**: US7 — Panel Admin (P7)

**Archivo**: \`src/pages/admin/UsuariosPanel.tsx\` (nuevo)

Tabla paginada de usuarios. Expandir fila → historial de reservas. Cancelar reserva con modal de motivo obligatorio. Filtros por fecha/cancha/estado.

**Ref**: spec.md § US7 — Acceptance Scenarios"

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo " Creando issues — Phase 9: Integración Frontend-Backend"
echo "═══════════════════════════════════════════════════════════════════"

gh issue create --repo "$FRONT_REPO" \
  --title "T079 — [US1] Actualizar auth.ts (registro, login + AuthContext, logout)" \
  --label "frontend,integration,spec:US1,enhancement" \
  --body "**Fase**: Phase 9 — Integración | **Historia**: US1

**Archivo**: \`src/services/auth.ts\`

registro(RegistroRequest), login(LoginRequest) → guarda token en AuthContext, logout() → limpia AuthContext + localStorage.

**Ref**: contracts/openapi.yaml § /api/auth"

gh issue create --repo "$FRONT_REPO" \
  --title "T080 — [US2] Crear canchas.ts (CRUD + estado via /api/admin/canchas)" \
  --label "frontend,integration,spec:US2,enhancement" \
  --body "**Fase**: Phase 9 — Integración | **Historia**: US2

**Archivo**: \`src/services/canchas.ts\` (nuevo)

getAllCanchas, createCancha, updateCancha, deleteCancha, updateEstadoCancha. Tipos explícitos de types/index.ts.

**Ref**: contracts/openapi.yaml § /api/admin/canchas"

gh issue create --repo "$FRONT_REPO" \
  --title "T081 — [US3] Crear turnos.ts (CRUD + disponibilidad via /api/admin/turnos)" \
  --label "frontend,integration,spec:US3,enhancement" \
  --body "**Fase**: Phase 9 — Integración | **Historia**: US3

**Archivo**: \`src/services/turnos.ts\` (nuevo)

getTurnosByCancha, createTurno, updateTurno, deleteTurno, updateDisponibilidad.

**Ref**: contracts/openapi.yaml § /api/admin/turnos"

gh issue create --repo "$FRONT_REPO" \
  --title "T082 — [US4][US6] Actualizar reservas.ts (disponibilidad + mis-reservas + admin)" \
  --label "frontend,integration,spec:US4,spec:US6,enhancement" \
  --body "**Fase**: Phase 9 — Integración | **Historias**: US4, US6

**Archivo**: \`src/services/reservas.ts\`

Ampliar con: getDisponibilidad(fecha, canchaId?), getMisReservas(estado?), createReserva, cancelarReserva, getClimaParaTurno, getAllReservas (admin), cancelarReservaAdmin (admin).

**Ref**: contracts/openapi.yaml § /api/disponibilidad, /api/reservas, /api/admin/reservas"

gh issue create --repo "$FRONT_REPO" \
  --title "T083 — [US5] Crear pago.ts (iniciar pago via /api/pagos/iniciar)" \
  --label "frontend,integration,spec:US5,enhancement" \
  --body "**Fase**: Phase 9 — Integración | **Historia**: US5

**Archivo**: \`src/services/pago.ts\` (nuevo)

iniciarPago(reservaId): POST /api/pagos/iniciar → PagoIniciarResponse.

**Ref**: contracts/openapi.yaml § /api/pagos/iniciar"

gh issue create --repo "$FRONT_REPO" \
  --title "T084 — [US1] Conectar Login.tsx y Register.tsx con auth.ts + AuthContext" \
  --label "frontend,integration,spec:US1,enhancement" \
  --body "**Fase**: Phase 9 — Integración | **Historia**: US1

**Archivos**: \`src/pages/Login.tsx\`, \`src/pages/Register.tsx\`

Login: llamar auth.login(), actualizar AuthContext, redirigir por rol. Register: llamar auth.registro(), manejar 409 por campo.

**Ref**: spec.md § US1 — Acceptance Scenarios"

gh issue create --repo "$FRONT_REPO" \
  --title "T085 — [US4] Conectar Grilla.tsx con reservas.ts (getDisponibilidad)" \
  --label "frontend,integration,spec:US4,enhancement" \
  --body "**Fase**: Phase 9 — Integración | **Historia**: US4

**Archivo**: \`src/pages/Grilla.tsx\`

Llamar getDisponibilidad al cambiar fecha/filtros. Spinner durante carga. Refetch al pulsar Actualizar.

**Ref**: spec.md § US4 — Acceptance Scenarios"

gh issue create --repo "$FRONT_REPO" \
  --title "T086 — [US5] Conectar NuevaReserva.tsx con reservas.ts y pago.ts" \
  --label "frontend,integration,spec:US5,enhancement" \
  --body "**Fase**: Phase 9 — Integración | **Historia**: US5

**Archivo**: \`src/pages/cliente/NuevaReserva.tsx\`

Paso 2: getClimaParaTurno con banner fallback. Paso 3: createReserva() → iniciarPago() → window.location.href = redirectUrl. Manejo de 409 'Turno no disponible'.

**Ref**: spec.md § US5 — Acceptance Scenarios 1–6"

gh issue create --repo "$FRONT_REPO" \
  --title "T087 — [US6] Conectar Dashboard cliente con reservas.ts (mis-reservas + cancelar)" \
  --label "frontend,integration,spec:US6,enhancement" \
  --body "**Fase**: Phase 9 — Integración | **Historia**: US6

**Archivo**: \`src/pages/cliente/Dashboard.tsx\`

getMisReservas al montar. cancelarReserva con confirmación y mensaje de política 24h. Refetch tras cancelación.

**Ref**: spec.md § US6 — Assumptions — Política de cancelación"

gh issue create --repo "$FRONT_REPO" \
  --title "T088 — [US2][US3] Conectar CanchasABM con canchas.ts y TurnosABM con turnos.ts" \
  --label "frontend,integration,spec:US2,spec:US3,enhancement" \
  --body "**Fase**: Phase 9 — Integración | **Historias**: US2, US3

**Archivos**: \`src/pages/admin/CanchasABM.tsx\`, \`src/pages/admin/TurnosABM.tsx\`

CRUD completo via services. Refetch tras cada mutación. Manejo de 409 con reservas en conflicto.

**Ref**: spec.md § US2, US3 — Acceptance Scenarios"

gh issue create --repo "$FRONT_REPO" \
  --title "T089 — [US7] Conectar UsuariosPanel con endpoints admin" \
  --label "frontend,integration,spec:US7,enhancement" \
  --body "**Fase**: Phase 9 — Integración | **Historia**: US7

**Archivo**: \`src/pages/admin/UsuariosPanel.tsx\`

getAllReservas con filtros y paginación. Expandir usuario → /api/admin/usuarios/{id}/reservas. cancelarReservaAdmin con motivo.

**Ref**: contracts/openapi.yaml § /api/admin/usuarios, /api/admin/reservas"

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo " Creando issues — Phase 10: Validación E2E con Docker Desktop"
echo "═══════════════════════════════════════════════════════════════════"

gh issue create --repo "$BACK_REPO" \
  --title "T090 — Actualizar Dockerfile backend (multi-stage Maven + JRE alpine)" \
  --label "backend,docker,enhancement" \
  --body "**Fase**: Phase 10 — Docker + E2E

**Archivo**: \`2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/Dockerfile\`

Stage 1: maven:3.9-eclipse-temurin-17-alpine → mvnw package -DskipTests. Stage 2: eclipse-temurin:17-jre-alpine → run JAR puerto 8081. Usuario no-root.

**Ref**: quickstart.md § Paso 3; plan.md § Infrastructure"

gh issue create --repo "$BACK_REPO" \
  --title "T091 — [P] Actualizar Dockerfile.single backend (single-stage para dev)" \
  --label "backend,docker,enhancement" \
  --body "**Fase**: Phase 10 — Docker + E2E

**Archivo**: \`2026-MTN-TP3-Back-Miceli-Tabuada/backEnd/Dockerfile.single\`

eclipse-temurin:17-jdk-alpine con Maven. mvnw spring-boot:run. Puerto 8081. Usuario no-root.

**Ref**: plan.md § Infrastructure — Dockerfile.single"

gh issue create --repo "$FRONT_REPO" \
  --title "T092 — [P] Actualizar Dockerfile frontend (multi-stage Vite + NGINX alpine)" \
  --label "frontend,docker,enhancement" \
  --body "**Fase**: Phase 10 — Docker + E2E

**Archivo**: \`2026-MTN-TP3-Front-Miceli-Tabuada/Dockerfile\`

Stage 1: node:20-alpine → npm ci && npm run build. Stage 2: nginx:alpine → serve dist/, copiar nginx.conf. Puerto 80. Usuario no-root.

**Ref**: quickstart.md § Paso 3; plan.md § Infrastructure — NGINX exclusivo"

gh issue create --repo "$FRONT_REPO" \
  --title "T093 — [P] Actualizar Dockerfile.single frontend (single-stage para dev)" \
  --label "frontend,docker,enhancement" \
  --body "**Fase**: Phase 10 — Docker + E2E

**Archivo**: \`2026-MTN-TP3-Front-Miceli-Tabuada/Dockerfile.single\`

node:20-alpine con npm run preview --host --port 5173. Puerto 5173.

**Ref**: plan.md § Infrastructure — Dockerfile.single"

gh issue create --repo "$FRONT_REPO" \
  --title "T094 — Crear nginx.conf (SPA routing + proxy /api + gzip)" \
  --label "frontend,docker,enhancement" \
  --body "**Fase**: Phase 10 — Docker + E2E

**Archivo**: \`2026-MTN-TP3-Front-Miceli-Tabuada/nginx.conf\` (nuevo)

try_files para SPA routing. location /api proxy_pass http://backend:8081. gzip on. Cache headers para assets estáticos.

**⚠️ IMPORTANTE**: Usar NGINX exclusivamente. Apache está terminantemente prohibido.

**Ref**: plan.md § Constitution Check — Infrastructure NGINX; quickstart.md"

gh issue create --repo "$SDD_REPO" \
  --title "T095 — Crear docker-compose.yml (db + backend + frontend con healthcheck)" \
  --label "docker,enhancement" \
  --body "**Fase**: Phase 10 — Docker + E2E

**Archivo**: \`2026-MTN-TP5-FutYa-SDD/docker-compose.yml\` (nuevo)

Servicios: db (mysql:8.0, healthcheck mysqladmin), backend (depende de db service_healthy), frontend (depende de backend). Volumen persistente futya-db-data.

**Ref**: quickstart.md § Paso 3"

gh issue create --repo "$SDD_REPO" \
  --title "T096 — [P] Crear .env.example con todas las variables requeridas" \
  --label "docker,setup,enhancement" \
  --body "**Fase**: Phase 10 — Docker + E2E

**Archivo**: \`2026-MTN-TP5-FutYa-SDD/.env.example\` (nuevo)

Variables: MYSQL_*, JWT_SECRET, JWT_EXPIRATION_MS, OPENWEATHER_API_KEY, OPENWEATHER_LAT/LON, MERCADOPAGO_ACCESS_TOKEN, MERCADOPAGO_WEBHOOK_SECRET, URLs de retorno MP.

**Ref**: quickstart.md § Paso 2"

gh issue create --repo "$SDD_REPO" \
  --title "T097 — Ejecutar validación E2E completa según quickstart.md (CU1–CU17)" \
  --label "docker,testing,enhancement" \
  --body "**Fase**: Phase 10 — Docker + E2E — VALIDACIÓN FINAL

**Ref**: \`specs/001-futbol5ya-gestion-plataforma/quickstart.md\`

Pasos: docker compose up --build → health check backend → CU1+CU2 (registro+login) → CU8+CU12 (admin: cancha+turno) → CU4 (grilla) → CU5 (reserva + 409 duplicado) → CU6 (mis reservas) → CU7 (cancelar) → frontend http://localhost:5173.

Verificar criterios de éxito SC-001 a SC-007."

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo " ✅ Issues creados exitosamente (T001–T097)"
echo "   Backend  → $BACK_REPO"
echo "   Frontend → $FRONT_REPO"
echo "   SDD/E2E  → $SDD_REPO"
echo "═══════════════════════════════════════════════════════════════════"
