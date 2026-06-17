# Exemplos em cURL — JurisLead CRM

Abaixo estão exemplos de chamadas em cURL para os endpoints implementados. Substitua `http://localhost:5000` pelo host/porta onde a aplicação está rodando.

---

## Criar lead

```bash
curl -sS -X POST http://localhost:5000/leads \
  -H 'Content-Type: application/json' \
  -d '{"name":"João Silva","email":"joao@example.com","phone":"+5511999999999","origin":"landing"}'
```

Resposta esperada: JSON com `id` e `status`.

---

## Triagem de IA (lead id = 1)

```bash
curl -sS -X POST http://localhost:5000/leads/1/triage
```

Resposta esperada: JSON com `triage_summary` e `classification`.

---

## Criar consulta (agendamento)

```bash
curl -sS -X POST http://localhost:5000/consultas \
  -H 'Content-Type: application/json' \
  -d '{"lead_id":1,"scheduled_at":"2026-06-10T15:00:00"}'
```

Resposta esperada: JSON com `id` e `status: "scheduled"`.

---

## Cancelar consulta (consulta id = 10)

```bash
curl -sS -X POST http://localhost:5000/consultas/10/cancel
```

Resposta esperada: JSON confirmando `status: "cancelled"`.

---

## Enviar notificação WhatsApp (consulta id = 10)

```bash
curl -sS -X POST http://localhost:5000/consultas/10/notify
```

Resposta esperada: JSON com resultado da API de WhatsApp (mockável em testes).

---

## Criar processo (vinculado a lead)

```bash
curl -sS -X POST http://localhost:5000/processos \
  -H 'Content-Type: application/json' \
  -d '{"lead_id":1,"title":"Ação de Cobrança","description":"Resumo do processo"}'
```

Resposta esperada: JSON com `id` e `lead_id`.

---

## Adicionar movimentação ao processo (processo id = 5)

```bash
curl -sS -X POST http://localhost:5000/processos/5/movimentacoes \
  -H 'Content-Type: application/json' \
  -d '{"description":"Distribuído ao fórum"}'
```

Resposta esperada: JSON com `id` da movimentação e `processo_id`.

---

## Obter processo com movimentações (processo id = 5)

```bash
curl -sS http://localhost:5000/processos/5
```

Resposta esperada: JSON com campos do processo e array `movimentacoes`.

---

Observações:

- Adicione `-H "Authorization: Bearer <token>"` caso a API exija autenticação futura.
- Para integração com serviços reais de IA/WhatsApp, configure as variáveis de ambiente `AI_API_URL`, `AI_API_KEY`, `WHATSAPP_API_URL`, `WHATSAPP_API_TOKEN`.
- Nos testes automatizados, as chamadas externas são mockadas (usar `responses`).
