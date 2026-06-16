# Quickstart: FutYa — Entorno de Desarrollo Local

**Feature**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)
**Date**: 2026-06-09

Esta guía permite levantar el entorno completo de FutYa localmente usando Docker Desktop, validar que el sistema funciona de extremo a extremo y ejecutar los casos de uso clave.

---

## Requisitos Previos

| Herramienta | Versión mínima | Verificar |
|-------------|---------------|-----------|
| Docker Desktop | 4.x | `docker --version` |
| Docker Compose | v2 (incluido en Docker Desktop) | `docker compose version` |
| Git | cualquier reciente | `git --version` |
| (Opcional) Bruno / Postman / curl | cualquier | Para probar la API directamente |

> No es necesario instalar Java, Node.js ni MySQL localmente. Docker los provee.

---

## Estructura del Repositorio Raíz

```text
2026-MTN-TP5-FutYa-SDD/          ← este repositorio (meta-spec)
2026-MTN-TP3-Back-Miceli-Tabuada/ ← backend Spring Boot
2026-MTN-TP3-Front-Miceli-Tabuada/← frontend React
```

Los tres directorios deben estar al mismo nivel. Si trabajás desde el repo raíz:

```bash
cd /ruta/donde/clonaste/2026-MTN-TP5-FutYa-SDD
ls ../
# Debe mostrar: 2026-MTN-TP3-Back-Miceli-Tabuada  2026-MTN-TP3-Front-Miceli-Tabuada  2026-MTN-TP5-FutYa-SDD
```

---

## Paso 1: Clonar los Repositorios

Si aún no los tenés clonados:

```bash
# Clonar los tres repositorios al mismo nivel
git clone https://github.com/Instituto-Politecnico-Modelo/2026-MTN-TP5-FutYa-SDD.git
git clone https://github.com/Instituto-Politecnico-Modelo/2026-MTN-TP3-Back-Miceli-Tabuada.git
git clone https://github.com/Instituto-Politecnico-Modelo/2026-MTN-TP3-Front-Miceli-Tabuada.git
```

---

## Paso 2: Configurar Variables de Entorno

Crear el archivo `.env` en el directorio donde estará el `docker-compose.yml`
(recomendado: en el repo raíz `2026-MTN-TP5-FutYa-SDD/`).

```bash
cp .env.example .env
# Luego editar .env con tus claves reales (ver abajo)
```

Contenido del `.env`:

```dotenv
# ── Base de Datos ─────────────────────────────────────────────────────────────
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=futya_db
MYSQL_USER=futya_user
MYSQL_PASSWORD=futya_password

# ── Backend ───────────────────────────────────────────────────────────────────
BACKEND_PORT=8081
JWT_SECRET=una-clave-secreta-muy-larga-de-al-menos-256-bits-para-hs256
JWT_EXPIRATION_MS=86400000

# ── OpenWeatherMap ────────────────────────────────────────────────────────────
# Obtener clave gratuita en https://openweathermap.org/appid
OPENWEATHER_API_KEY=tu_api_key_aqui
OPENWEATHER_LAT=-34.6037
OPENWEATHER_LON=-58.3816

# ── Mercado Pago ──────────────────────────────────────────────────────────────
# Obtener credenciales en https://www.mercadopago.com.ar/developers/panel
# Usar credenciales de PRUEBA (Sandbox) para desarrollo
MERCADOPAGO_ACCESS_TOKEN=TEST-tu_access_token_de_prueba
MERCADOPAGO_WEBHOOK_SECRET=tu_webhook_secret_de_prueba

# ── URLs de retorno post-pago (Mercado Pago redirige a estas URLs) ─────────────
MERCADOPAGO_SUCCESS_URL=http://localhost:5173/reservas?estado=confirmado
MERCADOPAGO_FAILURE_URL=http://localhost:5173/reservas?estado=fallido
MERCADOPAGO_PENDING_URL=http://localhost:5173/reservas?estado=pendiente
# Para webhooks locales: usar ngrok (ver Paso 5)
MERCADOPAGO_NOTIFICATION_URL=https://tu-subdominio.ngrok-free.app/api/pagos/webhook

# ── Frontend ──────────────────────────────────────────────────────────────────
FRONTEND_PORT=5173
```

> **Obtener API keys para desarrollo:**
> - OpenWeatherMap: Registrarse gratis en [openweathermap.org](https://openweathermap.org/appid). La key tarda hasta 2 horas en activarse.
> - Mercado Pago Sandbox: Crear cuenta en [mercadopago.com.ar/developers](https://www.mercadopago.com.ar/developers/panel) → Mis credenciales → Credenciales de prueba.

---

## Paso 3: Crear el docker-compose.yml

Crear `docker-compose.yml` en `2026-MTN-TP5-FutYa-SDD/`:

```yaml
services:

  db:
    image: mysql:8.0
    container_name: futya-db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    ports:
      - "3306:3306"
    volumes:
      - futya-db-data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p${MYSQL_ROOT_PASSWORD}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  backend:
    build:
      context: ../2026-MTN-TP3-Back-Miceli-Tabuada/backEnd
      dockerfile: Dockerfile
    container_name: futya-backend
    restart: unless-stopped
    ports:
      - "${BACKEND_PORT:-8081}:8081"
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://db:3306/${MYSQL_DATABASE}?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=America/Argentina/Buenos_Aires
      SPRING_DATASOURCE_USERNAME: ${MYSQL_USER}
      SPRING_DATASOURCE_PASSWORD: ${MYSQL_PASSWORD}
      JWT_SECRET: ${JWT_SECRET}
      JWT_EXPIRATION_MS: ${JWT_EXPIRATION_MS:-86400000}
      OPENWEATHER_API_KEY: ${OPENWEATHER_API_KEY}
      OPENWEATHER_LAT: ${OPENWEATHER_LAT}
      OPENWEATHER_LON: ${OPENWEATHER_LON}
      MERCADOPAGO_ACCESS_TOKEN: ${MERCADOPAGO_ACCESS_TOKEN}
      MERCADOPAGO_WEBHOOK_SECRET: ${MERCADOPAGO_WEBHOOK_SECRET}
      MERCADOPAGO_SUCCESS_URL: ${MERCADOPAGO_SUCCESS_URL}
      MERCADOPAGO_FAILURE_URL: ${MERCADOPAGO_FAILURE_URL}
      MERCADOPAGO_PENDING_URL: ${MERCADOPAGO_PENDING_URL}
      MERCADOPAGO_NOTIFICATION_URL: ${MERCADOPAGO_NOTIFICATION_URL}
    depends_on:
      db:
        condition: service_healthy

  frontend:
    build:
      context: ../2026-MTN-TP3-Front-Miceli-Tabuada
      dockerfile: Dockerfile
    container_name: futya-frontend
    restart: unless-stopped
    ports:
      - "${FRONTEND_PORT:-5173}:80"
    depends_on:
      - backend

volumes:
  futya-db-data:
```

---

## Paso 4: Levantar el Stack Completo

```bash
# Desde el directorio 2026-MTN-TP5-FutYa-SDD/
docker compose up --build
```

El proceso completo tarda entre 2 y 5 minutos la primera vez (descarga de imágenes base + compilación Maven + build Vite).

**Salida esperada:**

```
✔ Container futya-db        Started
✔ Container futya-backend   Started
✔ Container futya-frontend  Started
```

Verificar que el backend esté listo:
```bash
curl http://localhost:8081/actuator/health
# Esperado: {"status":"UP"}
```

Verificar el frontend:
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:5173
# Esperado: 200
```

---

## Paso 5: Configurar ngrok para Webhooks (Mercado Pago)

Mercado Pago requiere una URL pública para enviar notificaciones de pago. En desarrollo local se usa ngrok:

```bash
# Instalar ngrok: https://ngrok.com/download
ngrok http 8081
```

Copiar la URL HTTPS generada (ej: `https://abc123.ngrok-free.app`) y actualizar en `.env`:
```dotenv
MERCADOPAGO_NOTIFICATION_URL=https://abc123.ngrok-free.app/api/pagos/webhook
```

Reiniciar el backend para que tome el nuevo valor:
```bash
docker compose restart backend
```

> **Alternativa sin webhook**: Usar el modo sandbox de Mercado Pago consultando manualmente el estado del pago en el panel de desarrolladores. Válido solo para pruebas manuales.

---

## Paso 6: Validar los Casos de Uso Principales

### CU1 + CU2: Registro e Inicio de Sesión

```bash
# Registrar un cliente
curl -X POST http://localhost:8081/api/auth/registro \
  -H "Content-Type: application/json" \
  -d '{
    "dni": "30123456",
    "nombre": "Juan",
    "apellido": "Pérez",
    "email": "juan@test.com",
    "password": "MiClave123!"
  }'
# Esperado: HTTP 201 con UsuarioResponse

# Iniciar sesión
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "juan@test.com", "password": "MiClave123!"}'
# Esperado: HTTP 200 con {"token": "eyJ...", "rol": "CLIENTE"}

# Guardar el token para las siguientes llamadas:
TOKEN="eyJ..."
```

### Login del Administrador (seed inicial)

```bash
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@futya.com", "password": "Admin1234!"}'
# Esperado: HTTP 200 con {"rol": "ADMINISTRADOR"}

ADMIN_TOKEN="eyJ..."
```

### CU8: Crear una Cancha (Admin)

```bash
curl -X POST http://localhost:8081/api/admin/canchas \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"nombre": "Cancha 1", "tipo": "FUTBOL_5", "descripcion": "Cancha techada", "activa": true}'
# Esperado: HTTP 201 con CanchaResponse {"id": 1, ...}
```

### CU12: Crear un Turno (Admin)

```bash
curl -X POST http://localhost:8081/api/admin/turnos \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"diaSemana": "LUNES", "horaInicio": "18:00", "horaFin": "19:00", "canchaId": 1}'
# Esperado: HTTP 201 con TurnoResponse {"id": 1, ...}
```

### CU4: Consultar Grilla de Disponibilidad

```bash
# Obtener el próximo lunes
FECHA=$(date -d "next monday" +%Y-%m-%d 2>/dev/null || date -v+Mon +%Y-%m-%d)

curl "http://localhost:8081/api/disponibilidad?fecha=$FECHA" \
  -H "Authorization: Bearer $TOKEN"
# Esperado: HTTP 200 con array de DisponibilidadItem
# Verificar que el turno creado aparece con reservado: false
```

### Clima (antes de reservar)

```bash
curl "http://localhost:8081/api/clima?fecha=$FECHA&hora=18:00" \
  -H "Authorization: Bearer $TOKEN"
# Esperado: HTTP 200 con ClimaResponse
# Si la API key no está configurada: {"disponible": false}
```

### CU5: Crear una Reserva (Cliente)

```bash
curl -X POST http://localhost:8081/api/reservas \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"turnoId\": 1, \"fecha\": \"$FECHA\"}"
# Esperado: HTTP 201 con ReservaConPagoResponse
# El campo pagoRedirectUrl contiene la URL de Mercado Pago
```

### CU6: Ver Mis Reservas

```bash
curl http://localhost:8081/api/reservas/mis-reservas \
  -H "Authorization: Bearer $TOKEN"
# Esperado: HTTP 200 con array de ReservaResponse
# La reserva creada aparece en estado PENDIENTE
```

### CU7: Cancelar una Reserva

```bash
# Cancelar la reserva con ID 1 (debe ser futura)
curl -X PATCH http://localhost:8081/api/reservas/1/cancelar \
  -H "Authorization: Bearer $TOKEN"
# Si la reserva es con > 24hs de anticipación:
# Esperado: HTTP 200 con ReservaResponse en estado CANCELADA + pago REEMBOLSADO
# Si es con < 24hs de anticipación:
# Esperado: HTTP 200 con ReservaResponse en estado CANCELADA + pago sin reembolso
```

### CU16 + CU17: Panel de Admin

```bash
# Listar usuarios
curl http://localhost:8081/api/admin/usuarios \
  -H "Authorization: Bearer $ADMIN_TOKEN"
# Esperado: HTTP 200 con PageUsuarioResponse

# Ver reservas de un usuario específico
curl http://localhost:8081/api/admin/usuarios/2/reservas \
  -H "Authorization: Bearer $ADMIN_TOKEN"
# Esperado: HTTP 200 con array de ReservaResponse
```

---

## Paso 7: Acceder al Frontend

Abrir el navegador en [http://localhost:5173](http://localhost:5173)

| Ruta | Descripción | Rol requerido |
|------|-------------|---------------|
| `/login` | Inicio de sesión | Público |
| `/registro` | Registro de nuevo cliente | Público |
| `/grilla` | Grilla de disponibilidad | Cualquier autenticado |
| `/cliente/dashboard` | Panel del cliente (mis reservas) | CLIENTE |
| `/cliente/nueva-reserva` | Flujo de nueva reserva | CLIENTE |
| `/admin/dashboard` | Panel resumen admin | ADMINISTRADOR |
| `/admin/canchas` | ABM de canchas | ADMINISTRADOR |
| `/admin/turnos` | ABM de turnos | ADMINISTRADOR |
| `/admin/usuarios` | Usuarios y reservas | ADMINISTRADOR |

---

## Comandos Útiles

```bash
# Ver logs en tiempo real
docker compose logs -f backend
docker compose logs -f frontend

# Acceder a la base de datos MySQL
docker compose exec db mysql -u futya_user -pfutya_password futya_db

# Reconstruir solo el backend (tras cambios de código)
docker compose up --build backend

# Detener y eliminar contenedores + volúmenes (reset completo de DB)
docker compose down -v

# Modo desarrollo: backend solo (sin Docker, requiere Java 17 y MySQL local)
cd ../2026-MTN-TP3-Back-Miceli-Tabuada/backEnd
./mvnw spring-boot:run

# Modo desarrollo: frontend solo (sin Docker, requiere Node.js 20+)
cd ../2026-MTN-TP3-Front-Miceli-Tabuada
npm install && npm run dev
```

---

## Referencia de Contratos

El contrato completo de la API está en [contracts/openapi.yaml](contracts/openapi.yaml).

Para visualizarlo interactivamente:
```bash
# Con Docker — Swagger UI
docker run -p 8090:8080 \
  -e SWAGGER_JSON=/spec/openapi.yaml \
  -v "$(pwd)/specs/001-futbol5ya-gestion-plataforma/contracts:/spec" \
  swaggerapi/swagger-ui

# Abrir: http://localhost:8090
```

---

## Verificación de Criterios de Éxito

| SC | Criterio | Cómo verificar |
|----|----------|---------------|
| SC-001 | Flujo de reserva completo < 3 min | Cronometrar desde grilla hasta notificación recibida |
| SC-002 | Grilla carga < 2 s | Abrir DevTools → Network → verificar tiempo de `GET /api/disponibilidad` |
| SC-003 | Solo una reserva por turno+fecha | Ejecutar dos `POST /api/reservas` paralelos con los mismos datos; el segundo debe devolver HTTP 409 |
| SC-004 | Notificación < 30 s post-pago (Post-MVP) | Diferido fuera del alcance del MVP actual |
| SC-006 | Operaciones < 5 s | Observar tiempos de respuesta en DevTools o logs de Spring Boot |
