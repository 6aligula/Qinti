# Firestore — Chat API (conversaciones / DMs)

Propuesta para persistir DMs (y luego salas) en Firestore desde la Chat API.

## Estrategia recomendada: RAM/Redis + escritura asíncrona a Firestore

- **Tiempo real (ahora):** DMs en **RAM** en la Chat API. Más adelante: **Redis** como store en vivo (compartido entre instancias de Cloud Run).
- **Persistencia:** Un **proceso aparte** (worker, Cloud Function, o lógica en la misma API en background) que vaya **guardando en Firestore** lo que ocurre en RAM/Redis (conversaciones nuevas, mensajes nuevos). Sin bloquear la ruta crítica.
- **Ventajas:** Si Cloud Run escala, reinicia o se pierde el WebSocket, los datos siguen en Firestore. Se puede recuperar historial o reconstruir estado; más adelante Redis da consistencia entre instancias y Firestore sigue siendo el respaldo duradero.

## Colección recomendada: `conversations`

- **Nombre:** `conversations`
- **Document ID para un DM:** determinista a partir del par de usuarios, para que A↔B sea siempre el mismo documento.
  - Formato sugerido: `dm_<hash12>` donde `hash12` = primeros 12 caracteres base64url de `SHA256(sortedUserId1 + ":" + sortedUserId2)`.
  - Ejemplo: usuarios `uuid-a` y `uuid-b` (ordenados) → mismo doc id siempre.

## Estructura de un documento DM

```json
{
  "convoId": "dm_xxxxxxxxxxxx",
  "kind": "dm",
  "key": "userId1:userId2",
  "members": ["userId1", "userId2"],
  "messages": []
}
```

- `convoId`: mismo valor que el document ID (determinista).
- `key`: ids ordenados unidos por `:` (para búsquedas por par).
- `members`: array de 2 userIds.
- `messages`: array de mensajes (o subcolección `messages` si se prefiere).

## Creación en Firebase Console

1. Crear colección: **`conversations`**.
2. No hace falta crear documentos a mano; el backend los crea al hacer POST /dm.

## Uso en la Chat API

- **Opción A — Solo RAM (y luego Redis):** La API sirve DMs desde RAM/Redis. Un proceso separado escribe en Firestore (nuevas conversaciones, nuevos mensajes) de forma asíncrona para tener persistencia sin acoplarla al path en vivo.
- **Opción B — Firestore como store principal:** Variable de entorno **`CHAT_USE_FIRESTORE=true`** o **`CHAT_CONVOS_DRIVER=firebase`**; la API lee/escribe directamente en la colección `conversations`. Credenciales: igual que en Auth API (`GOOGLE_APPLICATION_CREDENTIALS` o `FIREBASE_*` / ADC en Cloud Run).

## Relación con el cliente iOS

- El cliente no accede a Firestore directamente; sigue usando REST (`GET /conversations`, `POST /dm`, etc.) y WebSocket.
- El `convoId` que devuelve el backend (y que usa el cliente para navegar y filtrar mensajes) es el mismo que el document ID en Firestore, así que el mismo par de usuarios obtiene el mismo `convoId` en todos los clientes.
