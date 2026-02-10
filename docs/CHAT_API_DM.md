# Chat API — POST /dm (crear DM)

Contrato del endpoint para alinear backend y cliente iOS.

## Request

- **Método:** `POST /dm`
- **Headers:** `Authorization: Bearer <jwt>`
- **Body:** `{ "otherUserId": "<userId del otro usuario>" }`

## Comportamiento

- **DM nuevo:** se crea la conversación y se devuelve.
- **DM ya existente:** se devuelve la misma conversación (getOrCreate). No se devuelve 4xx ni 409.
- **Importante:** para el mismo par de usuarios (A, B), el `convoId` debe ser **siempre el mismo**, tanto si quien llama es A o B (p. ej. generar el ID de forma determinista: mismos usuarios → mismo convoId). Si cada usuario recibe un convoId distinto, cada uno entra en una “sala” distinta y los mensajes no se ven en el otro cliente.

## Response

- **Código:** siempre **200** (nuevo o existente).
- **Body:** objeto conversación (misma forma que cada elemento de `GET /conversations`):

```json
{
  "convoId": "<string>",
  "kind": "dm",
  "members": ["<userId1>", "<userId2>"]
}
```

- Sin wrapper (no es `{ "data": { ... } }`).
- No se usa 201 ni 204.

El cliente iOS decodifica la respuesta como `Conversation` y navega a la pantalla de chat.

## Errores

- **400:** `otherUserId` ausente o inválido.
- **401:** falta `Authorization` o token inválido.

## Uso en iOS

- `APIService.createDM(otherUserId:)` → `Conversation`.
- `NewChatView` recibe la conversación, llama `onConversationCreated(conversation)` y cierra la hoja; la lista navega a `ChatView` con esa conversación.
