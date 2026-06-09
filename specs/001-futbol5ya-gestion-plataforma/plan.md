# Implementation Plan: FutYa — Plataforma Integral de Gestión de Fútbol 5

**Branch**: `001-futbol5ya-gestion-plataforma` | **Date**: 2026-06-09 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-futbol5ya-gestion-plataforma/spec.md`

## Summary

Implementación full-stack de la plataforma FutYa para la gestión de complejos de fútbol 5. El sistema expone una API REST protegida con JWT (Spring Boot 3 / Java 17, puerto 8081) consumida por una SPA (React 19 / TypeScript / Vite, puerto 5173). Cubre 17 casos de uso REST organizados en cinco dominios: autenticación, disponibilidad, reservas (cliente), gestión de canchas y turnos (administrador) y gestión de usuarios (administrador). Incluye integraciones externas con un servicio de clima (OpenWeatherMap) y una pasarela de pagos real (Mercado Pago). El despliegue se realiza con Docker multi-stage utilizando NGINX como único servidor web y proxy inverso.

## Technical Context

**Language/Version**:
- Backend: Java 17
- Frontend: TypeScript 5 / React 19

**Primary Dependencies**:
- Backend: Spring Boot (latest stable), Spring Security + JJWT, Spring Data JPA / Hibernate, MySQL Connector/J, Spring Web MVC, Lombok, Bean Validation (jakarta.validation), Mercado Pago Java SDK (`com.mercadopago:sdk-java`), Spring WebClient (para OpenWeatherMap)
- Frontend: React 19, Vite, TypeScript, React Router v6, Axios, Vitest, React Testing Library

**Storage**: MySQL 8 vía JPA/Hibernate (puerto 3306)

**Testing**:
- Backend: JUnit 5 + Mockito; integración con Spring Boot Test + H2 in-memory o Testcontainers (MySQL-compatible)
- Frontend: Vitest + React Testing Library; cobertura ≥ 80% en archivos modificados

**Target Platform**: Web — Linux + Docker + NGINX (producción); localhost con Vite dev-server (desarrollo)

**Project Type**: Full-stack web application — SPA (frontend) + API REST (backend)

**Performance Goals**:
- Backend API p95: ≤ 300 ms en reads, ≤ 500 ms en writes
- Frontend LCP: ≤ 2.5 s en conexión 4G; TTI: ≤ 3.5 s
- MySQL: ninguna query individual en el request path supera 100 ms; N+1 queries prohibidas

**Constraints**:
- JWT obligatorio en todos los endpoints protegidos (Spring Security + JwtAuthFilter)
- NGINX como único servidor web y reverse proxy (Apache prohibido en cualquier contexto)
- Roles: exclusivamente `CLIENTE` y `ADMINISTRADOR`; validación de rol en backend Y en protected routes del frontend
- Backend puerto 8081 exclusivo; frontend dev-server puerto 5173 con proxy `/api` → `http://localhost:8081`
- No `any` en TypeScript excepto en boundaries de APIs externas, con narrowing inmediato

**Scale/Scope**: ≤ 100 usuarios concurrentes en carga nominal; 2 capas independientes (backend + frontend); 17 casos de uso REST

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principio | Estado | Notas |
|-----------|--------|-------|
| I. Code Quality — SRP y separación de capas (Controller → Service → Repository) | ✅ PASS | Sin bypass de capas; controllers no contienen lógica de negocio |
| I. Code Quality — TypeScript sin `any` permanente | ✅ PASS | `unknown` con narrowing en boundaries de Mercado Pago y OpenWeatherMap |
| I. Code Quality — Nombres descriptivos, sin abreviaciones | ✅ PASS | Convención explícita en estructura de carpetas y DTOs |
| II. Testing — JUnit 5 + Mockito para backend | ✅ PASS | Un test unitario por Service; un integration test por Controller endpoint |
| II. Testing — Vitest + RTL para frontend | ✅ PASS | Cada componente user-facing con al menos un test de render |
| II. Testing — Cobertura ≥ 80% en código nuevo | ✅ PASS | Crítico: ReservaService y PagoService al 100% |
| II. Testing — Suite en < 5 minutos en CI | ✅ PASS | H2 in-memory para tests de integración; sin I/O a servicios externos reales |
| III. UX — Componentes en `/frontend/src/components` | ✅ PASS | Layout y UI bajo la jerarquía definida |
| III. UX — Role-aware routing en React Router (no disperso) | ✅ PASS | `ProtectedRoute` con validación de rol centralizada |
| III. UX — WCAG 2.1 AA | ✅ PASS | Incluido en NFR-007 del spec; validación con herramienta automatizada |
| IV. Performance — p95 ≤ 300ms reads, ≤ 500ms writes | ✅ PASS | @EntityGraph en queries con relaciones; índices en turno_id+fecha y usuario_id |
| IV. Performance — Sin N+1 queries | ✅ PASS | ReservaRepository usa JOIN FETCH para cargar turno y cancha |
| V. Simplicity — YAGNI; sin abstracciones especulativas | ✅ PASS | Solo funcionalidades del spec; no microservicios ni event bus |
| Stack — Java 17 + Spring Boot + MySQL + JPA | ✅ PASS | Cumple Technology Stack de la constitución |
| Stack — React 19 + TypeScript + Vite + React Router | ✅ PASS | Cumple Technology Stack de la constitución |
| Security — JWT en endpoints protegidos (Spring Security) | ✅ PASS | Todos excepto `/api/auth/registro` y `/api/auth/login` requieren token válido |
| Security — Validación de rol en backend con @PreAuthorize | ✅ PASS | Frontend-only enforcement es defecto de seguridad; ambas capas validan |
| Infrastructure — NGINX exclusivo (Apache prohibido) | ✅ PASS | Dockerfiles de ambas capas usan imagen `nginx:alpine` |
| Infrastructure — Dockerfile + Dockerfile.single por capa | ✅ PASS | Ambos requeridos en backend y frontend |
| Quality Gate — Linting (Checkstyle + ESLint) | ✅ PASS | Configurados desde el inicio; zero-error obligatorio |

**Post-Phase 1 Re-check**: Todos los gates pasan también tras el diseño (data-model + contratos). Sin violaciones. Sin entradas en Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/001-futbol5ya-gestion-plataforma/
├── plan.md              # Este archivo (salida de /speckit.plan)
├── spec.md              # Especificación de requerimientos
├── research.md          # Phase 0: Análisis de APIs externas (clima + pagos)
├── data-model.md        # Phase 1: Modelo de datos MySQL
├── quickstart.md        # Phase 1: Guía de entorno local con Docker
├── contracts/
│   └── openapi.yaml     # Phase 1: Contratos REST OpenAPI 3.0
└── tasks.md             # Phase 2: salida de /speckit.tasks (aún no generado)
```

### Source Code (repository root)

```text
2026-MTN-TP3-Back-Miceli-Tabuada/
└── backEnd/
    ├── Dockerfile                    # Multi-stage: build Maven → NGINX proxy runtime
    ├── Dockerfile.single             # Single-stage: desarrollo/debug
    ├── pom.xml                       # Dependencias Maven
    └── src/
        ├── main/
        │   ├── java/com/example/backEnd/
        │   │   ├── BackEndApplication.java
        │   │   ├── config/
        │   │   │   ├── DataSeeder.java           # Seed: admin inicial + datos demo
        │   │   │   └── SecurityConfig.java       # Spring Security + JWT filter chain
        │   │   ├── Controller/
        │   │   │   ├── AuthController.java        # CU1, CU2, CU3
        │   │   │   ├── DisponibilidadController.java  # CU4
        │   │   │   ├── ReservaController.java     # CU5, CU6, CU7
        │   │   │   ├── CanchaController.java      # CU8, CU9, CU10, CU11
        │   │   │   ├── TurnoController.java       # CU12, CU13, CU14, CU15
        │   │   │   └── UsuarioController.java     # CU16, CU17 + admin reservas
        │   │   ├── DTO/
        │   │   │   ├── auth/                      # LoginRequest, RegistroRequest, AuthResponse
        │   │   │   ├── cancha/                    # CanchaRequest, CanchaResponse
        │   │   │   ├── turno/                     # TurnoRequest, TurnoResponse
        │   │   │   ├── reserva/                   # ReservaRequest, ReservaResponse
        │   │   │   ├── usuario/                   # UsuarioResponse
        │   │   │   └── pago/                      # PagoResponse, PagoIniciarRequest
        │   │   ├── Entidad/
        │   │   │   ├── Usuario.java
        │   │   │   ├── Cancha.java
        │   │   │   ├── Turno.java
        │   │   │   ├── Reserva.java
        │   │   │   ├── Pago.java
        │   │   │   ├── Rol.java                   # ENUM: ADMINISTRADOR, CLIENTE
        │   │   │   ├── EstadoReserva.java          # ENUM: PENDIENTE, CONFIRMADA, CANCELADA
        │   │   │   ├── DiaSemana.java              # ENUM: LUNES…DOMINGO
        │   │   │   └── TipoCancha.java             # ENUM: FUTBOL_5, FUTBOL_7, etc.
        │   │   ├── Exception/
        │   │   │   └── GlobalExceptionHandler.java
        │   │   ├── Repository/
        │   │   │   ├── UsuarioRepository.java
        │   │   │   ├── CanchaRepository.java
        │   │   │   ├── TurnoRepository.java
        │   │   │   ├── ReservaRepository.java
        │   │   │   └── PagoRepository.java
        │   │   ├── Security/
        │   │   │   ├── JwtAuthFilter.java
        │   │   │   └── JwtUtil.java
        │   │   └── Service/
        │   │       ├── UsuarioService.java
        │   │       ├── CanchaService.java
        │   │       ├── TurnoService.java
        │   │       ├── ReservaService.java         # Lógica de negocio + regla 24hs
        │   │       ├── PagoService.java            # Integración Mercado Pago SDK
        │   │       └── ClimaService.java           # Integración OpenWeatherMap
        │   └── resources/
        │       └── application.properties
        └── test/
            └── java/com/example/backEnd/
                ├── Service/                        # Unit tests con Mockito
                └── Controller/                     # Integration tests con MockMvc

2026-MTN-TP3-Front-Miceli-Tabuada/
├── Dockerfile                        # Multi-stage: build Vite → NGINX serve
├── Dockerfile.single                 # Single-stage: desarrollo/debug
├── package.json
├── vite.config.ts                    # Proxy /api → http://localhost:8081
└── src/
    ├── assets/
    ├── components/
    │   ├── layout/                   # Navbar, Footer, Layout
    │   └── ui/                       # Button, Card, Input, Modal, Badge, Spinner
    ├── context/
    │   └── AuthContext.tsx           # JWT + rol + usuario + logout
    ├── hooks/
    │   ├── useLocalStorage.ts
    │   └── useAuth.ts
    ├── pages/
    │   ├── Login.tsx                 # CU2
    │   ├── Register.tsx              # CU1
    │   ├── Grilla.tsx                # CU4: grilla de disponibilidad
    │   ├── cliente/
    │   │   ├── Dashboard.tsx         # CU6: mis reservas + acceso a CU5, CU7
    │   │   └── NuevaReserva.tsx      # CU5: selección turno + clima + pago
    │   └── admin/
    │       ├── Dashboard.tsx         # Panel resumen
    │       ├── CanchasABM.tsx        # CU8–CU11
    │       ├── TurnosABM.tsx         # CU12–CU15
    │       └── UsuariosPanel.tsx     # CU16, CU17 + cancelación admin
    ├── router/
    │   ├── AppRouter.tsx
    │   ├── ProtectedRoute.tsx        # Role-aware guard (CLIENTE / ADMINISTRADOR)
    │   └── routes.ts
    ├── services/
    │   ├── api.ts                    # Instancia Axios con JWT interceptor
    │   ├── auth.ts                   # CU1, CU2, CU3
    │   ├── canchas.ts                # CU8–CU11
    │   ├── turnos.ts                 # CU12–CU15
    │   ├── reservas.ts               # CU4, CU5, CU6, CU7
    │   └── pago.ts                   # Inicio de pago + estado
    └── types/
        └── index.ts                  # Tipos TypeScript para todas las entidades
```

**Structure Decision**: Web application full-stack — dos capas independientes mapeadas a directorios existentes en el repositorio raíz (`2026-MTN-TP3-Back-Miceli-Tabuada/backEnd` para el backend y `2026-MTN-TP3-Front-Miceli-Tabuada` para el frontend). Cada capa mantiene sus propios Dockerfiles. En producción, NGINX sirve el build estático de React y hace reverse proxy a Spring Boot en el puerto 8081. En desarrollo, Vite dev-server en 5173 redirige `/api` a `localhost:8081`.

## Complexity Tracking

> No hay violaciones de la constitución. Esta sección no aplica.

---

## Phase 0: Research

Investigación completada en [research.md](research.md).

Decisiones clave:
- **API de clima**: OpenWeatherMap — API de pronóstico (5 días / 3 horas) vía llamada server-side desde `ClimaService`. El frontend no llama directamente al proveedor externo; la información se sirve a través del backend para proteger la API key.
- **Pasarela de pagos**: Mercado Pago — SDK Java oficial (`com.mercadopago:sdk-java`). Flujo: el backend crea una preferencia de pago y devuelve la `init_point` URL; el frontend redirige al checkout de Mercado Pago. Un webhook (`POST /api/pagos/webhook`) recibe la notificación de confirmación y actualiza el estado de la Reserva y el Pago.

---

## Phase 1: Design & Contracts

### 1.1 Data Model

Detallado en [data-model.md](data-model.md). Entidades principales:

| Tabla | Descripción |
|-------|-------------|
| `usuarios` | Personas registradas — rol CLIENTE o ADMINISTRADOR |
| `canchas` | Espacios físicos del complejo — activa/inactiva |
| `turnos` | Plantillas de horario por día de semana + cancha (recurrentes) |
| `reservas` | Instancia concreta: usuario + turno + fecha específica |
| `pagos` | Registro del cobro asociado a cada reserva |

Constraint clave: `UNIQUE (turno_id, fecha)` en `reservas` garantiza que no existan dos reservas para el mismo turno en la misma fecha (integridad requerida por SC-003).

### 1.2 API Contracts

Definidos en [contracts/openapi.yaml](contracts/openapi.yaml). Endpoints por dominio:

| Dominio | CUs | Métodos |
|---------|-----|---------|
| Autenticación | CU1, CU2, CU3 | `POST /api/auth/registro`, `POST /api/auth/login`, `POST /api/auth/logout` |
| Disponibilidad | CU4 | `GET /api/disponibilidad` |
| Reservas (CLIENTE) | CU5, CU6, CU7 | `POST /api/reservas`, `GET /api/reservas/mis-reservas`, `PATCH /api/reservas/{id}/cancelar` |
| Canchas (ADMIN) | CU8–CU11 | CRUD + `PATCH /api/admin/canchas/{id}/estado` |
| Turnos (ADMIN) | CU12–CU15 | CRUD + `PATCH /api/admin/turnos/{id}/disponibilidad` |
| Usuarios (ADMIN) | CU16, CU17 | `GET /api/admin/usuarios`, `GET /api/admin/usuarios/{id}/reservas` |
| Reservas (ADMIN) | — | `GET /api/admin/reservas`, `PATCH /api/admin/reservas/{id}/cancelar` |
| Pagos | — | `POST /api/pagos/iniciar`, `POST /api/pagos/webhook` |
| Clima | — | `GET /api/clima` (proxy server-side a OpenWeatherMap) |

### 1.3 Quickstart

Guía de entorno local en [quickstart.md](quickstart.md). Stack completo levantado con `docker compose up`.

---

## Phase 2: Implementation

> Esta fase es ejecutada por `/speckit.tasks`. El presente documento no la cubre.

Secuencia de implementación sugerida (a detallar en `tasks.md`):

1. **Dominio backend**: Entidades JPA, ENUMs, repositorios con queries nombradas
2. **Seguridad**: Spring Security config, JwtUtil, JwtAuthFilter, role-based @PreAuthorize
3. **Auth API**: AuthController, UsuarioService — registro + login (CU1, CU2, CU3)
4. **Canchas + Turnos API**: CanchaController/Service, TurnoController/Service (CU8–CU15)
5. **Disponibilidad API**: DisponibilidadController con query por fecha/día (CU4)
6. **Reservas API**: ReservaController/Service con regla de 24hs y control de concurrencia (CU5–CU7)
7. **Integraciones externas**: ClimaService (OpenWeatherMap) + PagoService (Mercado Pago webhook)
8. **Admin APIs**: UsuarioController con CU16, CU17 y cancelación admin
9. **Frontend base**: Estructura, Vite config proxy, AuthContext, instancia Axios con JWT interceptor
10. **Páginas de autenticación**: Login.tsx, Register.tsx
11. **Grilla de disponibilidad**: Grilla.tsx (CU4) con filtros por fecha y cancha
12. **Panel del cliente**: Dashboard.tsx + NuevaReserva.tsx (CU5–CU7 + clima + pago)
13. **Panel del administrador**: CanchasABM, TurnosABM, UsuariosPanel (CU8–CU17)
14. **Tests**: Unitarios (Services con Mockito) + Integración (MockMvc) + Frontend (Vitest/RTL)
15. **Docker**: Dockerfiles multi-stage + single-stage para ambas capas + docker-compose.yml
