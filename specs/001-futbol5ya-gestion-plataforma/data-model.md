# Data Model: FutYa — Esquema Físico MySQL

**Feature**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)
**Date**: 2026-06-09

---

## Diagrama de Entidades y Relaciones

```
usuarios (1) ──────────── (N) reservas
canchas  (1) ──────────── (N) turnos
turnos   (1) ──────────── (N) reservas
reservas (1) ──────────── (1) pagos
```

**Cardinalidades**:
- Un `Usuario` puede tener muchas `Reservas`
- Una `Cancha` puede tener muchos `Turnos` (bloques horarios recurrentes por día)
- Un `Turno` puede tener muchas `Reservas`, pero **solo una por fecha** (constraint `UNIQUE`)
- Cada `Reserva` tiene exactamente un `Pago` asociado (relación 1:1)

---

## Tipos Enumerados

### Rol
```sql
ENUM('ADMINISTRADOR', 'CLIENTE')
```
Mapeo JPA: `@Enumerated(EnumType.STRING)` en `Usuario.rol`

### EstadoReserva
```sql
ENUM('PENDIENTE', 'CONFIRMADA', 'CANCELADA')
```
- `PENDIENTE`: reserva creada, pago no confirmado aún
- `CONFIRMADA`: pago aprobado por Mercado Pago
- `CANCELADA`: cancelada por el cliente, por el admin, o por timeout de pago

Mapeo JPA: `@Enumerated(EnumType.STRING)` en `Reserva.estado`

### DiaSemana
```sql
ENUM('LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO', 'DOMINGO')
```
Mapeo JPA: `@Enumerated(EnumType.STRING)` en `Turno.diaSemana`

### TipoCancha
```sql
ENUM('FUTBOL_5', 'FUTBOL_7', 'FUTBOL_11')
```
Mapeo JPA: `@Enumerated(EnumType.STRING)` en `Cancha.tipo`

### EstadoPago
```sql
ENUM('PENDIENTE', 'CONFIRMADO', 'RECHAZADO', 'REEMBOLSADO')
```
Mapeo JPA: `@Enumerated(EnumType.STRING)` en `Pago.estado`

---

## Definición de Tablas

### `usuarios`

| Columna | Tipo | Restricciones | Descripción |
|---------|------|--------------|-------------|
| `id` | `BIGINT` | PK, AUTO_INCREMENT | Identificador único |
| `dni` | `VARCHAR(20)` | NOT NULL, UNIQUE | Documento de identidad |
| `nombre` | `VARCHAR(100)` | NOT NULL | Nombre de pila |
| `apellido` | `VARCHAR(100)` | NOT NULL | Apellido |
| `email` | `VARCHAR(150)` | NOT NULL, UNIQUE | Email de acceso |
| `password` | `VARCHAR(255)` | NOT NULL | Hash BCrypt de la contraseña |
| `telefono` | `VARCHAR(20)` | NULL | Número de contacto opcional |
| `rol` | `ENUM(...)` | NOT NULL, DEFAULT 'CLIENTE' | Rol del usuario |
| `activo` | `TINYINT(1)` | NOT NULL, DEFAULT 1 | Habilitación de la cuenta |
| `fecha_registro` | `TIMESTAMP` | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha de creación |

```sql
CREATE TABLE usuarios (
    id             BIGINT       NOT NULL AUTO_INCREMENT,
    dni            VARCHAR(20)  NOT NULL,
    nombre         VARCHAR(100) NOT NULL,
    apellido       VARCHAR(100) NOT NULL,
    email          VARCHAR(150) NOT NULL,
    password       VARCHAR(255) NOT NULL,
    telefono       VARCHAR(20),
    rol            ENUM('ADMINISTRADOR','CLIENTE') NOT NULL DEFAULT 'CLIENTE',
    activo         TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_registro TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT uq_usuarios_dni   UNIQUE (dni),
    CONSTRAINT uq_usuarios_email UNIQUE (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Índices adicionales**:
```sql
CREATE INDEX idx_usuarios_rol ON usuarios (rol);
```

---

### `canchas`

| Columna | Tipo | Restricciones | Descripción |
|---------|------|--------------|-------------|
| `id` | `BIGINT` | PK, AUTO_INCREMENT | Identificador único |
| `nombre` | `VARCHAR(100)` | NOT NULL | Nombre descriptivo de la cancha |
| `tipo` | `ENUM(...)` | NOT NULL | Tipo de cancha (FUTBOL_5, etc.) |
| `descripcion` | `TEXT` | NULL | Descripción opcional |
| `activa` | `TINYINT(1)` | NOT NULL, DEFAULT 1 | Visibilidad en grilla |

```sql
CREATE TABLE canchas (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(100) NOT NULL,
    tipo        ENUM('FUTBOL_5','FUTBOL_7','FUTBOL_11') NOT NULL,
    descripcion TEXT,
    activa      TINYINT(1)   NOT NULL DEFAULT 1,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### `turnos`

Representa un **bloque horario recurrente** por día de la semana para una cancha. No es una instancia de fecha concreta.

| Columna | Tipo | Restricciones | Descripción |
|---------|------|--------------|-------------|
| `id` | `BIGINT` | PK, AUTO_INCREMENT | Identificador único |
| `dia_semana` | `ENUM(...)` | NOT NULL | Día de la semana |
| `hora_inicio` | `TIME` | NOT NULL | Hora de inicio del bloque |
| `hora_fin` | `TIME` | NOT NULL | Hora de fin del bloque |
| `disponible` | `TINYINT(1)` | NOT NULL, DEFAULT 1 | Si el turno está habilitado |
| `cancha_id` | `BIGINT` | NOT NULL, FK → canchas.id | Cancha a la que pertenece |

```sql
CREATE TABLE turnos (
    id          BIGINT   NOT NULL AUTO_INCREMENT,
    dia_semana  ENUM('LUNES','MARTES','MIERCOLES','JUEVES','VIERNES','SABADO','DOMINGO') NOT NULL,
    hora_inicio TIME     NOT NULL,
    hora_fin    TIME     NOT NULL,
    disponible  TINYINT(1) NOT NULL DEFAULT 1,
    cancha_id   BIGINT   NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_turnos_cancha
        FOREIGN KEY (cancha_id) REFERENCES canchas (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Índices adicionales**:
```sql
CREATE INDEX idx_turnos_cancha_dia ON turnos (cancha_id, dia_semana);
CREATE INDEX idx_turnos_disponible  ON turnos (disponible);
```

**Constraint de negocio**: No puede existir dos turnos en la misma cancha para el mismo día y horario solapado. Se valida a nivel de servicio (no constraint SQL, por la complejidad de solapamiento de TIME).

---

### `reservas`

Representa la **instancia concreta** de un turno para una fecha de calendario específica.

| Columna | Tipo | Restricciones | Descripción |
|---------|------|--------------|-------------|
| `id` | `BIGINT` | PK, AUTO_INCREMENT | Identificador único |
| `fecha` | `DATE` | NOT NULL | Fecha calendario del turno reservado |
| `estado` | `ENUM(...)` | NOT NULL, DEFAULT 'PENDIENTE' | Estado de la reserva |
| `motivo_cancelacion` | `VARCHAR(500)` | NULL | Motivo (obligatorio si cancela el admin) |
| `cancelado_por_admin` | `TINYINT(1)` | NOT NULL, DEFAULT 0 | Flag para distinguir tipo de cancelación |
| `fecha_creacion` | `TIMESTAMP` | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha de creación de la reserva |
| `fecha_modificacion` | `TIMESTAMP` | NULL, ON UPDATE CURRENT_TIMESTAMP | Última modificación |
| `usuario_id` | `BIGINT` | NOT NULL, FK → usuarios.id | Cliente que hizo la reserva |
| `turno_id` | `BIGINT` | NOT NULL, FK → turnos.id | Turno reservado |

```sql
CREATE TABLE reservas (
    id                   BIGINT       NOT NULL AUTO_INCREMENT,
    fecha                DATE         NOT NULL,
    estado               ENUM('PENDIENTE','CONFIRMADA','CANCELADA') NOT NULL DEFAULT 'PENDIENTE',
    motivo_cancelacion   VARCHAR(500),
    cancelado_por_admin  TINYINT(1)   NOT NULL DEFAULT 0,
    fecha_creacion       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion   TIMESTAMP    NULL ON UPDATE CURRENT_TIMESTAMP,
    usuario_id           BIGINT       NOT NULL,
    turno_id             BIGINT       NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT uq_reservas_turno_fecha
        UNIQUE (turno_id, fecha),
    CONSTRAINT fk_reservas_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_reservas_turno
        FOREIGN KEY (turno_id) REFERENCES turnos (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Nota sobre integridad (SC-003)**: El constraint `UNIQUE (turno_id, fecha)` es la garantía en base de datos de que dos usuarios no pueden reservar el mismo turno para la misma fecha. Cuando dos transacciones concurrentes intentan insertar la misma combinación, la segunda fallará con `DuplicateKeyException`, que `GlobalExceptionHandler` transforma en HTTP 409.

**Índices adicionales**:
```sql
CREATE INDEX idx_reservas_usuario_estado ON reservas (usuario_id, estado);
CREATE INDEX idx_reservas_fecha          ON reservas (fecha);
CREATE INDEX idx_reservas_estado_creacion ON reservas (estado, fecha_creacion);
```
El índice `idx_reservas_estado_creacion` optimiza el job de timeout de pagos pendientes.

---

### `pagos`

Registro del cobro asociado a cada reserva (relación 1:1).

| Columna | Tipo | Restricciones | Descripción |
|---------|------|--------------|-------------|
| `id` | `BIGINT` | PK, AUTO_INCREMENT | Identificador único |
| `reserva_id` | `BIGINT` | NOT NULL, UNIQUE, FK → reservas.id | Reserva asociada |
| `monto` | `DECIMAL(10,2)` | NOT NULL | Monto cobrado |
| `moneda` | `VARCHAR(3)` | NOT NULL, DEFAULT 'ARS' | Código ISO de moneda |
| `estado` | `ENUM(...)` | NOT NULL, DEFAULT 'PENDIENTE' | Estado del pago |
| `referencia_externa` | `VARCHAR(255)` | NULL | ID del pago en Mercado Pago |
| `preference_id` | `VARCHAR(255)` | NULL | ID de la preferencia de pago MP |
| `fecha_transaccion` | `TIMESTAMP` | NULL | Fecha de confirmación/rechazo |

```sql
CREATE TABLE pagos (
    id                  BIGINT          NOT NULL AUTO_INCREMENT,
    reserva_id          BIGINT          NOT NULL,
    monto               DECIMAL(10,2)   NOT NULL,
    moneda              VARCHAR(3)      NOT NULL DEFAULT 'ARS',
    estado              ENUM('PENDIENTE','CONFIRMADO','RECHAZADO','REEMBOLSADO') NOT NULL DEFAULT 'PENDIENTE',
    referencia_externa  VARCHAR(255),
    preference_id       VARCHAR(255),
    fecha_transaccion   TIMESTAMP       NULL,
    PRIMARY KEY (id),
    CONSTRAINT uq_pagos_reserva
        UNIQUE (reserva_id),
    CONSTRAINT fk_pagos_reserva
        FOREIGN KEY (reserva_id) REFERENCES reservas (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## Relaciones JPA — Resumen

| Entidad | Campo | Tipo relación | Entidad destino |
|---------|-------|--------------|----------------|
| `Cancha` | `turnos` | `@OneToMany(mappedBy="cancha")` | `Turno` |
| `Turno` | `cancha` | `@ManyToOne` | `Cancha` |
| `Turno` | `reservas` | `@OneToMany(mappedBy="turno")` | `Reserva` |
| `Reserva` | `turno` | `@ManyToOne` | `Turno` |
| `Reserva` | `usuario` | `@ManyToOne` | `Usuario` |
| `Usuario` | `reservas` | `@OneToMany(mappedBy="usuario")` | `Reserva` |
| `Reserva` | `pago` | `@OneToOne(mappedBy="reserva")` | `Pago` |
| `Pago` | `reserva` | `@OneToOne` | `Reserva` |

**Carga diferida**: Todas las colecciones (`@OneToMany`) usan `fetch = FetchType.LAZY` por defecto para evitar N+1. Las consultas que necesiten cargar turnos y canchas en la grilla de disponibilidad usarán `@EntityGraph` o `JOIN FETCH` explícito.

---

## Queries Críticas

### Grilla de disponibilidad (CU4)

```sql
-- Turnos disponibles para un día de la semana específico,
-- indicando si ya están reservados en una fecha concreta
SELECT
    t.id             AS turno_id,
    t.dia_semana,
    t.hora_inicio,
    t.hora_fin,
    c.id             AS cancha_id,
    c.nombre         AS cancha_nombre,
    c.tipo           AS cancha_tipo,
    CASE WHEN r.id IS NOT NULL THEN 1 ELSE 0 END AS reservado
FROM turnos t
JOIN canchas c ON c.id = t.cancha_id
LEFT JOIN reservas r ON r.turno_id = t.id
    AND r.fecha = :fecha
    AND r.estado IN ('PENDIENTE', 'CONFIRMADA')
WHERE t.dia_semana = :diaSemana
  AND t.disponible = 1
  AND c.activa = 1
ORDER BY c.nombre, t.hora_inicio;
```

### Reservas de un usuario con detalles (CU6)

```sql
SELECT r FROM Reserva r
JOIN FETCH r.turno t
JOIN FETCH t.cancha c
LEFT JOIN FETCH r.pago p
WHERE r.usuario.id = :usuarioId
ORDER BY r.fecha DESC, t.horaInicio ASC;
```

### Timeout de pagos pendientes (job @Scheduled)

```sql
SELECT r FROM Reserva r
WHERE r.estado = 'PENDIENTE'
  AND r.fechaCreacion < :limite;
-- :limite = NOW() - timeout configurado (15 minutos por defecto)
```

---

## Seed de Datos Inicial

```sql
-- Usuario administrador por defecto (contraseña: Admin1234! en BCrypt)
INSERT INTO usuarios (dni, nombre, apellido, email, password, telefono, rol, activo)
VALUES ('00000000', 'Admin', 'FutYa', 'admin@futya.com',
        '$2a$12$hashedpassword...', NULL, 'ADMINISTRADOR', 1);

-- Canchas de ejemplo
INSERT INTO canchas (nombre, tipo, descripcion, activa) VALUES
    ('Cancha 1', 'FUTBOL_5', 'Cancha principal techada', 1),
    ('Cancha 2', 'FUTBOL_5', 'Cancha al aire libre', 1),
    ('Cancha 3', 'FUTBOL_7', 'Cancha grande con iluminación', 1);

-- Turnos de ejemplo (Cancha 1, Lunes a Viernes, bloques de 1 hora)
INSERT INTO turnos (dia_semana, hora_inicio, hora_fin, disponible, cancha_id) VALUES
    ('LUNES', '18:00', '19:00', 1, 1),
    ('LUNES', '19:00', '20:00', 1, 1),
    ('LUNES', '20:00', '21:00', 1, 1),
    ('MARTES', '18:00', '19:00', 1, 1),
    ('MARTES', '19:00', '20:00', 1, 1);
-- (continuar para todos los días y canchas)
```

> El seed completo se implementa en `DataSeeder.java` usando `CommandLineRunner` con perfil `dev`.
