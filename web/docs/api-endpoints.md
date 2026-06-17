# API - Endpoints implementados

Esta referência descreve os endpoints atualmente implementados no repositório, com exemplos de request/response para uso em testes manuais e integração.

Nota: as rotas usam JSON para entrada e saída. URLs de integração externa (IA / WhatsApp) são mockáveis em testes.

---

## POST /leads
Cria um lead a partir dos campos básicos.

Request (JSON):

```json
{
  "name": "João Silva",
  "email": "joao@example.com",
  "phone": "+5511999999999",
  "origin": "landing"
}
```

Sucesso (201 Created):

```json
{ "id": 1, "status": "new" }
```

Erro (campo obrigatório ausente, 400):

```json
{ "error": "name is required" }
```

---

## POST /leads/<id>/triage
Dispara triagem de IA para o lead identificado por `<id>`. A integração com provedor de IA é externa e deve retornar `summary` e `classification`.

Request: vazio (POST sem corpo) — usa dados do lead já cadastrado.

Sucesso (200):

```json
{
  "id": 1,
  "triage_summary": "Resumo breve do caso",
  "classification": "civil"
}
```

Falha na integração com IA (502):

```json
{ "error": "ai_service_failure", "detail": "ConnectionError(...)" }
```

---

## POST /consultas
Cria uma consulta (agendamento) vinculada a um `lead_id`. `scheduled_at` deve ser ISO8601 e data futura.

Request (JSON):

```json
{ "lead_id": 1, "scheduled_at": "2026-06-10T15:00:00" }
```

Sucesso (201):

```json
{ "id": 10, "status": "scheduled" }
```

Erros comuns:
- 400 se faltar `lead_id` ou `scheduled_at` ou formato inválido;
- 404 se `lead_id` não existir;
- 400 se `scheduled_at` não for data futura.

---

## POST /consultas/<id>/cancel
Cancela a consulta identificada por `<id>`.

Sucesso (200):

```json
{ "id": 10, "status": "cancelled" }
```

404 se a consulta não existir.

---

## POST /consultas/<id>/notify
Envia lembrete por WhatsApp para o `lead` associado à consulta. Exige que o `lead.phone` esteja preenchido.

Sucesso (200):

```json
{ "ok": true, "result": { "message_id": "msg_123" } }
```

Falha na API de WhatsApp (502):

```json
{ "error": "whatsapp_service_failure", "detail": "HTTPError(...)" }
```

Erro (400) se o lead não tiver telefone: `{ "error": "lead phone not available" }`.

---

## POST /processos
Cria um processo vinculado a um `lead`.

Request (JSON):

```json
{ "lead_id": 1, "title": "Ação de Cobrança", "description": "Resumo do processo" }
```

Sucesso (201):

```json
{ "id": 5, "lead_id": 1 }
```

404 se `lead_id` não existir.

---

## POST /processos/<id>/movimentacoes
Adiciona uma movimentação ao processo.

Request (JSON):

```json
{ "description": "Distribuído ao fórum" }
```

Sucesso (201):

```json
{ "id": 21, "processo_id": 5 }
```

400 se `description` ausente; 404 se processo não existir.

---

## GET /processos/<id>
Retorna o processo com as movimentações ordenadas.

Sucesso (200):

```json
{
  "id": 5,
  "lead_id": 1,
  "title": "Ação de Cobrança",
  "description": "Resumo do processo",
  "status": "open",
  "movimentacoes": [ { "id": 21, "description": "Distribuído ao fórum", "created_at": "2026-01-02T10:00:00" } ]
}
```

404 se o processo não existir.

---

Observações finais:
- Todas as rotas retornam JSON com códigos HTTP apropriados.
- Em desenvolvimento e nos testes a integração com IA e WhatsApp é mockada (usar a biblioteca `responses`).
- Para testes manuais com serviços reais, configure `AI_API_URL`, `AI_API_KEY`, `WHATSAPP_API_URL` e `WHATSAPP_API_TOKEN` em variáveis de ambiente.
