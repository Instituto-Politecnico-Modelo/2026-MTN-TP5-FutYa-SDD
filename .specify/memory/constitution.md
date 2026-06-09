<!--
SYNC IMPACT REPORT
==================
Version change: 1.0.0 → 1.1.0
Added sections:
  - Technology Stack & Architecture Constraints (backend + frontend rules, ports, JWT, roles)
  - Infrastructure & Deployment (NGINX-only, Docker multi/single-stage)
  - AI Interaction Style (directness, commit atomicity, task decomposition)
Modified principles:
  - I. Code Quality — added layer-separation rule and backend/frontend directory scope
  - II. Testing Standards — added Spring Boot (JUnit/Mockito) and React (Vitest/RTL) tooling
  - III. UX Consistency — tied to React 19 component library and TypeScript typing
  - IV. Performance Requirements — added Spring Boot and Vite-specific targets
  - V. Simplicity — added dependency justification for Maven (backend) and npm (frontend)
Removed sections: N/A
Templates requiring updates:
  - .specify/templates/plan-template.md ✅ (Constitution Check and Technical Context rows updated)
  - .specify/templates/spec-template.md ✅ (aligns with user story + acceptance scenario format)
  - .specify/templates/tasks-template.md ✅ (backend/frontend path conventions now explicit)
Follow-up TODOs: None — all placeholders resolved.
-->

# Futbol5Ya Constitution

## Core Principles

### I. Code Quality (NON-NEGOTIABLE)

All code MUST be clean, readable, and maintainable by any team member without additional explanation.

- Every module, class, and function MUST have a single, clearly defined responsibility (SRP).
- **Backend** (`/backend`): Architecture MUST enforce strict layer separation — Controllers call Services;
  Services call Repositories; no cross-layer bypasses are permitted.
- **Frontend** (`/frontend`): Components MUST be typed with TypeScript; `any` is forbidden except at
  explicit external API boundaries, where it MUST be narrowed immediately.
- Variable, function, and class names MUST be descriptive and unambiguous; abbreviations are forbidden
  unless universally recognized domain terms (e.g., `id`, `url`, `jwt`).
- Code duplication MUST be eliminated through abstraction before a feature is considered complete.
- Cyclomatic complexity per function MUST NOT exceed 10; functions exceeding this MUST be refactored
  before merge.
- Linting and formatting rules are enforced by automated tooling; no PR may bypass linting gates.

**Rationale**: Maintainability is a first-class concern. The layered backend and typed frontend are
non-optional architectural decisions that must be reflected in every file.

### II. Testing Standards (NON-NEGOTIABLE)

Tests are written before implementation (TDD). No feature is complete without passing tests.

- Unit test coverage MUST be ≥ 80% for all new code paths; critical business logic MUST reach 100%.
- The Red-Green-Refactor cycle is strictly enforced: failing tests MUST exist before any implementation
  code is written.
- **Backend**: Unit tests use JUnit 5 + Mockito; integration tests use Spring Boot Test with an
  in-memory H2 database or Testcontainers (MySQL-compatible). Every REST endpoint MUST have at least
  one integration test validating its contract.
- **Frontend**: Unit/component tests use Vitest + React Testing Library. Every user-facing component
  MUST have at least one render test covering its primary interaction.
- Test names MUST follow the pattern `should_[expected_behaviour]_when_[condition]` (Java) or
  `should [behaviour] when [condition]` (TypeScript describe/it blocks).
- Flaky tests MUST be treated as blocking defects and fixed or quarantined immediately.
- Test suites MUST run in under 5 minutes in CI.

**Rationale**: Untested code is unmaintainable code. Automated suites are the primary safety net
enabling confident refactoring and continuous delivery across both layers.

### III. User Experience Consistency

Every user-facing surface MUST follow the established design system and interaction patterns.

- All UI components MUST reside under `/frontend/src/components`; no ad-hoc inline styles or one-off
  components are permitted without design review.
- Interaction patterns (navigation via React Router, form validation feedback, error messages, loading
  states) MUST be identical across equivalent flows.
- Error messages shown to users MUST be human-readable, actionable, and free of backend stack traces
  or raw HTTP status codes.
- Accessibility MUST meet WCAG 2.1 Level AA as a minimum; keyboard navigation and screen-reader
  compatibility are non-optional.
- Role-based UI rendering (CLIENTE vs. ADMINISTRADOR) MUST be implemented at the route guard level
  through React Router protected routes, not scattered across individual components.

**Rationale**: Inconsistent UX erodes user trust. Role-aware UI MUST mirror the backend authorization
model to prevent security gaps caused by frontend/backend role mismatches.

### IV. Performance Requirements

Performance targets are defined per tier and MUST be validated before a feature ships to production.

- **Backend API** (Spring Boot, port 8081): p95 latency MUST be ≤ 300 ms for read endpoints and
  ≤ 500 ms for write endpoints under nominal load.
- **Frontend** (Vite/React 19, port 5173): Largest Contentful Paint MUST be ≤ 2.5 s on a standard
  4G connection; Time to Interactive MUST be ≤ 3.5 s.
- **Database** (MySQL via JPA/Hibernate): No single query in a request path may exceed 100 ms;
  N+1 queries are forbidden and MUST be resolved with `@EntityGraph` or explicit JOIN FETCH before merge.
- **NGINX proxy**: Reverse-proxy configuration MUST not introduce latency > 5 ms per request hop.
- Performance regressions of > 10% on any tracked metric MUST be treated as blocking defects.

**Rationale**: Performance is a feature. Both tiers have concrete targets that reflect the real-world
context of a booking platform where latency directly impacts conversion.

### V. Simplicity & Maintainability

The simplest solution that satisfies requirements MUST be chosen. Over-engineering is a defect.

- YAGNI: no speculative abstractions, frameworks, or infrastructure are introduced without a concrete,
  present requirement.
- **Backend** dependencies are managed via Maven (`pom.xml`); each new dependency MUST be justified
  in the PR description with version, license, and security posture.
- **Frontend** dependencies are managed via npm (`package.json`); the same justification rule applies.
- Architecture decisions MUST be documented with context, options considered, and rationale (lightweight
  ADR in the relevant spec folder is sufficient).
- Complexity MUST be explicitly justified in code review; reviewers MUST reject unnecessary complexity
  regardless of correctness.

**Rationale**: Simple systems are easier to test, debug, and evolve across both layers.

## Technology Stack & Architecture Constraints

These constraints are NON-NEGOTIABLE and cannot be overridden by individual feature decisions.

### Backend (`/backend`)

| Constraint | Value |
|------------|-------|
| Language | Java 17 |
| Framework | Spring Boot (latest stable) |
| ORM | JPA / Hibernate |
| Database | MySQL |
| Port | **8081** (exclusive) |
| Architecture | Controller → Service → Repository (strict layering) |
| Auth | JWT — mandatory on all secured endpoints |

- MUST NOT introduce any alternative ORM (e.g., MyBatis, JOOQ) without a constitution amendment.
- MUST NOT run on any port other than 8081; hardcoded alternative ports are a merge blocker.
- Every secured endpoint MUST validate the JWT and enforce role authorization (`CLIENTE` or
  `ADMINISTRADOR`) before executing business logic.

### Frontend (`/frontend`)

| Constraint | Value |
|------------|-------|
| Runtime | React 19 |
| Language | TypeScript |
| Build tool | Vite |
| Navigation | React Router |
| Dev port | **5173** |
| API proxy | `/api` → `http://localhost:8081` (Vite config) |

- MUST NOT use `class` components; functional components with hooks are the only permitted pattern.
- MUST NOT use `any` as a permanent type annotation; `unknown` with type narrowing is the correct
  alternative.
- All `/api` calls MUST go through the Vite dev-server proxy in development; no direct `localhost:8081`
  references are permitted in source files.

### Security & Authorization

- JWT tokens MUST be issued and validated exclusively by the `/backend`.
- Two roles are defined: `CLIENTE` and `ADMINISTRADOR`. No additional roles may be added without a
  constitution amendment.
- Role checks MUST occur at both the backend (Spring Security) and frontend (protected route guards)
  layers. Frontend-only role enforcement is a security defect.
- Sensitive routes that leak booking or user data MUST require `ADMINISTRADOR` role validation at the
  backend controller level.

## Infrastructure & Deployment

### Web Server & Reverse Proxy

- **NGINX is the only permitted web server and reverse proxy**. Apache HTTP Server and any other web
  server MUST NOT be configured, mentioned, or suggested in any file, documentation, or AI response.
- NGINX handles: static asset serving (React build), reverse-proxy to backend on port 8081, SSL
  termination (when applicable).

### Containerization

- Every layer (`/backend`, `/frontend`) MUST maintain two Dockerfile variants:
  - `Dockerfile` — multi-stage build (production-optimized)
  - `Dockerfile.single` — single-stage build (development/debugging convenience)
- Docker Compose MUST be the standard method for running the full stack locally. Any `docker run`
  commands provided in documentation MUST also have an equivalent Compose service definition.
- Container images MUST NOT run processes as root.

## Quality Gates

Every feature increment MUST pass the following gates before merging to the main branch:

| Gate | Requirement |
|------|-------------|
| Linting | Zero errors: Checkstyle (backend), ESLint (frontend) |
| Unit tests | All tests pass; coverage ≥ 80% on changed files |
| Integration tests | All Spring Boot + React component integration tests pass |
| Performance check | No regression > 10% on tracked metrics vs. baseline |
| Code review | At least one peer approval; Constitution Check in plan.md signed off |
| Accessibility | Automated a11y scan produces zero critical violations on changed UI |
| Security | No endpoint accessible without JWT validation where required |

Bypassing any gate requires explicit written justification in the PR, acknowledged by the team lead.

## Development Workflow

1. **Spec first**: A feature spec (`spec.md`) MUST be created before implementation begins.
2. **Plan next**: An implementation plan (`plan.md`) including a Constitution Check MUST be produced.
   Plans MUST clearly separate backend endpoints from frontend UI components.
3. **TDD**: Write failing tests → get approval → implement until tests pass → refactor.
4. **Atomic commits**: Each commit MUST reflect a single, specific change in one of:
   - Database schema or seed data (MySQL)
   - Backend business logic (Spring Boot)
   - Frontend interface (React)
   Mixed-layer commits are forbidden unless the change is a single coordinated contract update
   (e.g., a DTO change reflected in both backend response and frontend type).
5. **Small PRs**: Each PR MUST address a single user story or task.
6. **CI mandatory**: All quality gates are enforced by CI; local bypasses are forbidden.

## AI Interaction Style

When generating code, plans, or documentation for this project, the following rules apply:

- Responses MUST be direct and technical; prefer code over prose.
- Any file path reference MUST explicitly indicate `/backend` or `/frontend` scope.
- When using `/speckit.plan`, tasks MUST be decomposed separating:
  - Backend: endpoint definition, service logic, repository query, DTO contract
  - Frontend: route, page component, API service call, UI component
- Commit messages suggested by AI MUST follow the convention:
  `<type>(<scope>): <description>` where `scope` is `backend`, `frontend`, `infra`, or `db`.
  Example: `feat(backend): add POST /api/reservas endpoint with JWT validation`
- AI MUST NOT suggest Apache or any non-NGINX web server solution under any circumstance.

## Governance

This constitution supersedes all other documented practices. In any conflict, the constitution wins.

- **Amendment procedure**: Amendments MUST be proposed as a PR to `.specify/memory/constitution.md`
  with a written rationale, impact analysis, and migration plan for affected features in progress.
  Amendments require approval from all active team members.
- **Versioning policy**: Version numbers follow semantic versioning.
  MAJOR bumps for principle removals or incompatible governance changes.
  MINOR bumps for new sections, principles, or materially expanded guidance.
  PATCH bumps for clarifications, wording fixes, and non-semantic refinements.
- **Compliance review**: Every PR MUST include a Constitution Check confirming the change does not
  violate any principle. Reviewers MUST reject non-compliant PRs.
- **Living document**: The constitution is reviewed at the start of each project milestone.

**Version**: 1.1.0 | **Ratified**: 2026-06-09 | **Last Amended**: 2026-06-09
