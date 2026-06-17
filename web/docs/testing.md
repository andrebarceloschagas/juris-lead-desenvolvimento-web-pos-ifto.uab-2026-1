# Plano de Testes Frontend — JurisLead CRM

Data: 23 de maio de 2026

Este documento descreve os cenários de teste específicos para o frontend, complementando `docs/testes-projeto-jurislead-crm.md`.

1. Objetivo
- Garantir que componentes UI cumpram requisitos de comportamento visual, responsividade, acessibilidade e integração com o backend.

2. Ferramentas recomendadas
- Cypress ou Playwright para E2E e testes de interação;
- axe-core (integrado ao Cypress/Playwright) para testes de acessibilidade;
- Storybook + Chromatic (opcional) para testes de regressão visual e validação de componentes isolados;
- Jest/Testing Library para testes unitários de JS, quando houver lógica JS complexa.

3. Tipos de testes e cenários

3.1 Testes de componentes
- Verificar renderização de `FormField` com label, hint e mensagem de erro.
- Testar foco visual e navegação por teclado (Tab) entre campos do formulário.
- Testar estados `loading`, `empty` e `ready` para componentes que consomem API.

3.2 Testes de integração com APIs
- Testar que o formulário de lead faz POST para `/leads` e maneja os seguintes códigos:
  - `201` → redireciona para `/web/leads/<id>`;
  - `400` → exibe mensagens de validação inline;
  - `401` → mostra mensagem global de autenticação;
  - `409` → mostra mensagem de conflito/duplicidade associada ao campo;
  - `500` → mostra mensagem de erro genérica.
- Testar retry em caso de timeout (mockar falha e depois sucesso).

3.3 Testes responsivos
- Validar layout em breakpoints: desktop (1200x800), tablet (800x1024) e mobile (375x667).
- Verificar que tabelas tornam-se listagens com rótulos (`data-label`) e que botão "Ver detalhes" aparece.
- Verificar menu hamburguer e navegação no mobile.

3.4 Testes de acessibilidade
- Rodar axe-core para detectar violações de contraste, labels ausentes e roles faltantes.
- Verificar `aria-live` em status de formulário e anúncios de modais.
- Testar leitura por teclado, foco em campos de erro e navegação em modais.

3.5 Testes de renderização condicional
- Testar componentes que exibem `loading` → `empty` → `ready` conforme resposta mockada da API.
- Verificar que estado `empty` mostra CTA e não quebra layout.

3.6 Testes E2E
- Fluxo completo: autenticação → criação de lead → triagem (mock IA) → conversão para cliente → ver cliente.
- Testar cancelamento de consulta com confirmação e feedback visual.

3.7 Testes de regressão visual
- Capturar snapshots por componente e por páginas críticas (leads list, lead detail, dashboard) e comparar em CI.

3.8 Testes de usabilidade e fallback
- Verificar mensagens de erro amigáveis em falhas de rede.
- Verificar timeout e opção de retry.

4. Critérios de aceitação
- Nenhuma violação crítica de acessibilidade (axe-core: no violations of level A/AA);
- Layout funcional nos três breakpoints (sem conteúdo fora de tela);
- Formulários apresentam feedbacks de loading e erros de forma previsível;
- Integração com backend respeita os contratos HTTP e renderiza os estados corretos.

5. Integração com pipeline CI
- Adicionar job E2E em branch principal que rode testes Playwright/Cypress e axe-core;
- Rodar regressão visual em merges para `main`.

6. Amostras de comandos

```bash
# Executar E2E local com Playwright
npx playwright test

# Executar Cypress
npx cypress open

# Usar axe-core com Playwright (exemplo)
npx playwright test --project=chromium
```

Notas finais
- Testes frontend devem ser adicionados incrementalmente; priorizar páginas e componentes de maior criticidade (captação de leads, painel, agenda e lead detail).
