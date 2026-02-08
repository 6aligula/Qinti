# MoldLine — Auth API (Servicio separado)

Especificación para el desarrollador backend. Esta API gestiona registro, login y gestión de usuarios. Debe desplegarse como un **servicio independiente** de la API de chat, ya que tendrá menos tráfico y distinta lógica de escalado.

---

## Arquitectura

```
┌─────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  App iOS    │────▶│  Auth API        │     │  Chat API        │
│             │     │  (Cloud Run)     │     │  (Cloud Run)     │
│             │────▶│  /register       │     │  /conversations  │
│             │     │  /login          │     │  /messages       │
│             │     │  /me             │     │  /ws             │
│             │     └───────┬──────────┘     └───────┬──────────┘
│             │             │                        │
│             │             ▼                        ▼
│             │     ┌──────────────────┐     ┌──────────────────┐
│             │     │  DB Usuarios     │     │  DB Chat / Redis │
│             │     │  (Postgres/Mongo)│     │  (existente)     │
└─────────────┘     └──────────────────┘     └──────────────────┘
```

**Dominio sugerido:** `https://moldline-auth-XXXXX.europe-southwest1.run.app`

---

## Base de datos — Modelo `User`

```sql
CREATE TABLE users (
    user_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(50) NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,  -- bcrypt hash
    email       VARCHAR(255),
    phone       VARCHAR(20),
    created_at  TIMESTAMP DEFAULT NOW()
);
```

**Notas:**
- `name` es el nickname, debe ser **único** (es el identificador público).
- `password` se almacena como **hash bcrypt** (nunca en texto plano).
- `email` y `phone` son opcionales.

---

## Autenticación — JWT

Tras un login/registro exitoso, la API devuelve un **JWT** que la app iOS enviará en las peticiones a ambas APIs.

### Token payload

```json
{
  "sub": "uuid-del-usuario",
  "name": "nickname",
  "iat": 1700000000,
  "exp": 1700086400
}
```

### Header para peticiones autenticadas

```
Authorization: Bearer <jwt_token>
```

**Importante:** La Chat API existente usa `x-user-id` como header. Durante la migración, el Auth API puede generar el JWT y la Chat API puede:
1. **(Fase 1)** Seguir aceptando `x-user-id` — la app iOS extrae el `userId` del JWT y lo envía.
2. **(Fase 2)** Validar el JWT directamente — ambos servicios comparten el mismo `JWT_SECRET`.

---

## Endpoints

### `POST /register`

Crea un nuevo usuario.

**Request:**
```
POST /register
Content-Type: application/json
```

```json
{
  "name": "miNickname",
  "password": "miPassword123",
  "email": "opcional@mail.com",
  "phone": "+34600000000"
}
```

| Campo      | Tipo   | Obligatorio | Validación                          |
|------------|--------|-------------|-------------------------------------|
| `name`     | string | Si          | 2-50 chars, único, sin espacios     |
| `password` | string | Si          | Min 4 chars                         |
| `email`    | string | No          | Formato email válido si se envía    |
| `phone`    | string | No          | Formato E.164 si se envía           |

**Response 201:**
```json
{
  "userId": "uuid-generado",
  "name": "miNickname",
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response 409 (nombre duplicado):**
```json
{
  "error": "USERNAME_TAKEN",
  "message": "This nickname is already in use"
}
```

**Response 400 (validación):**
```json
{
  "error": "VALIDATION_ERROR",
  "message": "Password must be at least 4 characters"
}
```

---

### `POST /login`

Inicia sesión con nickname y password.

**Request:**
```
POST /login
Content-Type: application/json
```

```json
{
  "name": "miNickname",
  "password": "miPassword123"
}
```

**Response 200:**
```json
{
  "userId": "uuid-del-usuario",
  "name": "miNickname",
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response 401:**
```json
{
  "error": "INVALID_CREDENTIALS",
  "message": "Invalid nickname or password"
}
```

---

### `GET /me`

Devuelve el perfil del usuario autenticado.

**Request:**
```
GET /me
Authorization: Bearer <jwt_token>
```

**Response 200:**
```json
{
  "userId": "uuid",
  "name": "miNickname",
  "email": "opcional@mail.com",
  "phone": "+34600000000",
  "createdAt": "2025-01-15T10:30:00Z"
}
```

**Response 401:**
```json
{
  "error": "UNAUTHORIZED",
  "message": "Invalid or expired token"
}
```

---

### `POST /refresh`

Renueva un token JWT antes de que expire.

**Request:**
```
POST /refresh
Authorization: Bearer <jwt_token_actual>
```

**Response 200:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...(nuevo)"
}
```

---

### `GET /users`

Lista de usuarios registrados (para buscar contactos). Requiere autenticación.

**Request:**
```
GET /users
Authorization: Bearer <jwt_token>
```

**Response 200:**
```json
[
  { "userId": "uuid-1", "name": "alice" },
  { "userId": "uuid-2", "name": "bob" }
]
```

---

### `GET /health`

Health check sin autenticación.

**Response 200:**
```json
{ "status": "ok", "service": "auth" }
```

---

## Variables de entorno

```env
PORT=8080
DATABASE_URL=postgresql://user:pass@host:5432/moldline_auth
JWT_SECRET=tu-secreto-compartido-con-chat-api
JWT_EXPIRATION=24h
BCRYPT_ROUNDS=12
```

---

## Seguridad

- **Passwords:** Siempre bcrypt con salt (12 rounds mínimo).
- **JWT:** Firmar con HS256 y un secret de mínimo 32 chars.
- **Rate limiting:** Aplicar en `/register` y `/login` (ej: 5 intentos/min por IP).
- **CORS:** No aplica para apps nativas, pero configurar si se usa desde web.
- **HTTPS:** Obligatorio (Cloud Run lo proporciona por defecto).

---

## Stack sugerido

| Componente     | Opción recomendada                       |
|----------------|------------------------------------------|
| Runtime        | Node.js / Deno / Go (lo que uses en chat)|
| Framework      | Express / Fastify / Hono                 |
| DB             | PostgreSQL (Cloud SQL) o MongoDB Atlas   |
| Hash           | bcryptjs / bcrypt                        |
| JWT            | jsonwebtoken / jose                      |
| Validación     | zod / joi                                |
| Deploy         | Cloud Run (mismo proyecto GCP)           |

---

## Integración con la Chat API existente

Para que la Chat API valide los tokens JWT del Auth API:

1. **Compartir `JWT_SECRET`** entre ambos servicios como variable de entorno.
2. **Middleware en Chat API:**

```javascript
// middleware/auth.js
const jwt = require('jsonwebtoken');

function authMiddleware(req, res, next) {
  // Fase 1: soportar ambos métodos
  const token = req.headers.authorization?.replace('Bearer ', '');
  const legacyUserId = req.headers['x-user-id'];

  if (token) {
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.userId = decoded.sub;
      return next();
    } catch (err) {
      return res.status(401).json({ error: 'UNAUTHORIZED' });
    }
  }

  // Fallback legacy (eliminar en Fase 2)
  if (legacyUserId) {
    req.userId = legacyUserId;
    return next();
  }

  return res.status(401).json({ error: 'UNAUTHORIZED' });
}
```

3. **WebSocket:** Pasar el token como query param: `/ws?token=<jwt>`

---

## Flujo completo desde la app iOS

```
1. Usuario abre app → ve LoginView
2. Toca "Create Account" → RegisterView
3. Rellena form → POST /register (Auth API)
4. Auth API → hash password, guarda en DB, genera JWT
5. Auth API → responde con { userId, name, token }
6. App guarda token en Keychain
7. App usa token en header Authorization para Chat API
8. Chat API valida JWT → extrae userId → funciona normal
```

---

## Cambios necesarios en la app iOS (ya preparados)

La app ya tiene:
- `RegisterView` con campos name, password, email (opcional), phone (opcional)
- `RegisterViewModel` que llama a `POST /register`
- `APIService.register()` que envía el request

**Pendiente en la app (cuando el Auth API esté listo):**
- Actualizar `Constants.swift` con la URL del Auth API
- Guardar el JWT en Keychain tras registro/login
- Enviar `Authorization: Bearer <token>` en vez de `x-user-id`
- Añadir pantalla de Login (con nickname + password)
- Auto-refresh del token
