# Research: FutYa — Integraciones con Servicios Externos

**Feature**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)
**Date**: 2026-06-09

Este documento resuelve los dos **NEEDS CLARIFICATION técnicos** identificados durante el diseño: la selección de la API de clima y la estrategia de integración con la pasarela de pagos.

---

## 1. API de Clima

### Objetivo

El sistema debe consultar las condiciones meteorológicas previstas para la fecha y hora de un turno específico antes de que el cliente confirme su reserva (FR-018, FR-019).

### Opciones Evaluadas

| Proveedor | Tier gratuito | Formato | Auth | Pronóstico horario | Cobertura Argentina |
|-----------|--------------|---------|------|--------------------|--------------------|
| **OpenWeatherMap** | 1.000 llamadas/día (Free) | JSON | API Key | Sí (cada 3 h, hasta 5 días) | Excelente |
| WeatherAPI.com | 1.000.000 llamadas/mes (Free) | JSON | API Key | Sí (cada hora, hasta 14 días) | Buena |
| Open-Meteo | Sin límite documentado | JSON | Sin key | Sí (cada hora, hasta 16 días) | Buena |
| AccuWeather | 50 llamadas/día (Free) | JSON | API Key | Sí (hasta 12 h) | Buena |

### Decisión: OpenWeatherMap — Forecast 5 days / 3 hours

**Justificación**:
- Documentación ampliamente conocida y estable; SDK o cliente HTTP simple.
- Tier gratuito suficiente para el volumen de reservas esperado (≤ 100 usuarios concurrentes, flujo de reserva no masivo).
- Datos de pronóstico horario permiten mostrar la condición más cercana al horario del turno seleccionado.
- Alternativa natural ante cierre del proyecto con Open-Meteo (sin API key), que puede usarse como fallback sin cambios de contrato.

**Alternativas rechazadas**:
- WeatherAPI.com: mayor generosidad de tier pero menos adopción en proyectos académicos Java/Spring Boot; documentación de integración menos directa.
- Open-Meteo: adecuado como fallback pero el contrato de respuesta difiere de OpenWeatherMap; migrar requeriría cambios en el DTO de clima.
- AccuWeather: límite de 50 llamadas/día es insuficiente incluso en desarrollo.

### Endpoint a Utilizar

```
GET https://api.openweathermap.org/data/2.5/forecast
  ?lat={latitud_complejo}
  &lon={longitud_complejo}
  &appid={OPENWEATHER_API_KEY}
  &units=metric
  &lang=es
  &cnt=40
```

**Parámetros relevantes en la respuesta**:
- `list[].dt_txt`: Fecha y hora del pronóstico (UTC)
- `list[].main.temp`: Temperatura en °C
- `list[].weather[0].description`: Descripción textual (ej: "lluvia ligera")
- `list[].weather[0].icon`: Código de ícono para la UI
- `list[].pop`: Probabilidad de precipitación (0.0–1.0)

### Patrón de Integración: Server-Side Proxy

El frontend **no llama directamente** a OpenWeatherMap. La API key se mantiene exclusivamente en el backend.

```
[Frontend] → GET /api/clima?fecha={fecha}&hora={hora}
           → [ClimaService] → GET api.openweathermap.org/data/2.5/forecast
           ← ClimaResponseDTO { temperatura, descripcion, iconoCodigo, probabilidadLluvia }
           ← [Frontend]
```

**Beneficios**:
- La API key nunca se expone al navegador.
- El backend puede cachear respuestas por fecha/hora para reducir llamadas al proveedor.
- El frontend recibe un DTO normalizado, independiente del proveedor; cambiar de OpenWeatherMap a Open-Meteo solo afecta `ClimaService`.

### DTO de Respuesta al Frontend

```json
{
  "fecha": "2026-07-10",
  "hora": "18:00",
  "temperatura": 12.5,
  "descripcion": "Parcialmente nublado",
  "iconoCodigo": "03d",
  "probabilidadLluvia": 0.15
}
```

### Manejo de Fallo (FR-019)

Si OpenWeatherMap devuelve un error o timeout:
- `ClimaService` captura la excepción y retorna un `ClimaResponseDTO` con `disponible: false`.
- El Controller devuelve HTTP 200 con `disponible: false` (no un error 5xx) para que el flujo de reserva pueda continuar.
- El frontend muestra un banner informativo: *"Información del clima no disponible temporalmente. Podés continuar con tu reserva."*

### Variables de Entorno Requeridas

```properties
# application.properties (backend)
clima.openweathermap.api-key=${OPENWEATHER_API_KEY}
clima.openweathermap.base-url=https://api.openweathermap.org/data/2.5
clima.openweathermap.lat=-34.6037    # Configurar según ubicación del complejo
clima.openweathermap.lon=-58.3816
clima.openweathermap.timeout-ms=3000
```

---

## 2. Pasarela de Pagos — Mercado Pago

### Objetivo

El sistema debe integrar una pasarela de pago real para cobrar al cliente al confirmar una reserva (FR-020). La cancelación con reembolso (> 24 hs) debe procesarse también vía la misma pasarela (US6, FR-026).

### Decisión: Mercado Pago — Checkout API (Preferencias de Pago)

**Justificación**:
- SDK Java oficial disponible (`com.mercadopago:sdk-java`), mantenido activamente.
- Entorno Sandbox completo para desarrollo y pruebas sin transacciones reales.
- Mecanismo de webhooks robusto para notificación asíncrona del resultado del pago.
- Es la pasarela de referencia explícita en la especificación del proyecto.
- Alternativas (Stripe, PayPal) no están optimizadas para el mercado argentino y el enunciado las menciona como fuera de alcance.

### Flujo de Pago

```
1. Cliente confirma reserva en NuevaReserva.tsx
2. POST /api/reservas { turnoId, fecha }
   → ReservaService.crearReserva(...)
   → PagoService.iniciarPago(reservaId)
   → SDK: MercadoPago.preference().create({ ... })
   ← ReservaConPagoResponse { ..., pagoRedirectUrl }
3. Frontend redirige al checkout de Mercado Pago usando pagoRedirectUrl
4. Usuario completa el pago en el entorno de MP
5. MP llama al webhook configurado:
   POST /api/pagos/webhook (IP de Mercado Pago, sin JWT)
   → PagoService.procesarWebhook(notification)
   → Actualiza Pago.estado → CONFIRMADO
   → Actualiza Reserva.estado → CONFIRMADA
   → Envía notificación de confirmación al cliente (email, post-MVP)
6. Frontend: al regresar desde MP, consulta GET /api/reservas/mis-reservas
   para mostrar el estado actualizado

Nota: `POST /api/pagos/iniciar` se conserva como endpoint alternativo para
reintentos sobre reservas pendientes o uso administrativo.
```

### Flujo de Reembolso (Cancelación > 24 hs)

```
1. PATCH /api/reservas/{id}/cancelar
   → ReservaService.cancelar(reservaId, usuarioId)
   → Valida anticipación > 24 hs
   → PagoService.reembolsar(pagoId)
   → SDK: MercadoPago.refund().create(paymentId)
   → Actualiza Pago.estado → REEMBOLSADO
   → Actualiza Reserva.estado → CANCELADA
   → Envía notificación de cancelación con detalle de reembolso
```

### Dependencia Maven

```xml
<dependency>
  <groupId>com.mercadopago</groupId>
  <artifactId>sdk-java</artifactId>
  <version>2.1.24</version>  <!-- última versión estable al 2026-06-09 -->
</dependency>
```

### Variables de Entorno Requeridas

```properties
# application.properties (backend)
mercadopago.access-token=${MERCADOPAGO_ACCESS_TOKEN}
mercadopago.webhook-secret=${MERCADOPAGO_WEBHOOK_SECRET}
mercadopago.success-url=http://localhost:5173/reservas?estado=confirmado
mercadopago.failure-url=http://localhost:5173/reservas?estado=fallido
mercadopago.pending-url=http://localhost:5173/reservas?estado=pendiente
mercadopago.notification-url=https://{ngrok-o-dominio}/api/pagos/webhook
```

### Seguridad del Webhook

El endpoint `POST /api/pagos/webhook` debe estar **excluido de la autenticación JWT** (Mercado Pago no envía token). Sin embargo, debe validarse la firma HMAC usando el `x-signature` header y el `MERCADOPAGO_WEBHOOK_SECRET` para prevenir payloads fraudulentos.

### Manejo de Estados del Pago

| Estado MP | Acción en el sistema |
|-----------|---------------------|
| `approved` | Pago → CONFIRMADO; Reserva → CONFIRMADA; notificar cliente |
| `rejected` | Pago → RECHAZADO; Reserva permanece PENDIENTE; turno se libera tras timeout |
| `pending` | Pago → PENDIENTE; Reserva → PENDIENTE; timeout configurable |
| `in_process` | No acción; esperar próximo webhook |
| `refunded` | Pago → REEMBOLSADO; Reserva → CANCELADA; notificar cliente |

### Timeout de Pago (FR-022)

Si el pago no se confirma en el plazo máximo (configurable, por defecto 15 minutos), un job programado (`@Scheduled`) libera el turno:
- Busca Reservas en estado PENDIENTE con `fechaCreacion` + timeout < ahora
- Las marca como CANCELADA con motivo "Pago no completado en tiempo"
- El turno queda disponible para otras reservas

```properties
reserva.pago.timeout-minutos=15
```

---

## Resumen de Decisiones

| Decisión | Resultado | Alternativas Consideradas |
|----------|-----------|--------------------------|
| API de clima | OpenWeatherMap (Free tier, pronóstico cada 3 h) | WeatherAPI.com, Open-Meteo, AccuWeather |
| Integración clima | Server-side proxy en ClimaService | Llamada directa desde frontend (descartada por seguridad) |
| Pasarela de pagos | Mercado Pago — Checkout API + SDK Java | Stripe, PayPal (fuera del contexto Argentina) |
| Flujo de pago | Redirect al checkout de MP + webhook de confirmación | Checkout pro inline (mayor complejidad frontend) |
| Reembolso | SDK MP `MercadoPago.refund().create()` | Manual (fuera de alcance) |
| Timeout de pago | Job programado `@Scheduled` (15 min configurable) | Trigger de base de datos (mayor acoplamiento) |
