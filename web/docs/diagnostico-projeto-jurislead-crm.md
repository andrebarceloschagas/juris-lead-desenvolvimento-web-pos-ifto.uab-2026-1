# Diagnóstico Técnico do Projeto JurisLead CRM Web

Este documento apresenta a análise de conformidade do projeto **JurisLead CRM Web** em relação à documentação em [web/docs](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/docs), avalia a preparação do backend para a futura integração com o aplicativo mobile (Flutter/Dart) e define um plano de melhorias.

---

## 1. Escopo e Objetivos da Análise

Antes de iniciar a implementação do **JurisLead CRM Mobile**, realizou-se uma varredura completa da base de código da aplicação web atual (`web/`) para verificar:
1. **Adequação funcional:** Se o sistema implementa o que as especificações em [especificacoes-projeto-jurislead-crm.md](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/docs/especificacoes-projeto-jurislead-crm.md) definem.
2. **Cibersegurança:** Análise do código em face das vulnerabilidades descritas em [inspecao-ciberseguranca-jurislead-crm.md](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/docs/inspecao-ciberseguranca-jurislead-crm.md).
3. **Qualidade dos Testes:** Cobertura, isolamento e confiabilidade da suíte automatizada.
4. **Preparação Mobile:** O que precisa ser ajustado ou reestruturado para suportar o Flutter via API REST.

---

## 2. Diagnóstico de Adequação Funcional

A tabela abaixo resume a adequação dos arquivos da aplicação em relação aos requisitos das especificações:

| Funcionalidade / Requisito | Status no Código | Arquivo Relacionado | Observação / Desvio Identificado |
| --- | --- | --- | --- |
| **Captação de Leads (Landing Page)** | **Completo** | [routes.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/routes.py#L163) | O formulário público realiza o POST e salva o lead, tratando duplicidade de e-mail e documento (`409 Conflict`). |
| **Triagem com IA** | **Parcial** | [ia_service.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/services/ia_service.py) | A triagem é executada chamando uma API simulada (mockada nos testes). No entanto, ela é disparada manualmente por um administrador via rota `/leads/<id>/triage` e não por um "chat de conversação" inicial, como sugere a descrição prévia. |
| **Cadastro de Clientes e Leads** | **Completo** | [models.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/models.py#L65) / [routes.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/routes.py#L616) | A conversão de `Lead` para `Cliente` está funcional, gerando opcionalmente uma conta de `User` vinculada. |
| **Controle de Processos e Movimentações** | **Completo** | [models.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/models.py#L111) / [routes.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/routes.py#L714) | As entidades `Processo` e `Movimentacao` estão modeladas e expõem endpoints para criação e consulta de histórico. |
| **Automação de WhatsApp** | **Incompleto** | [whatsapp_service.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/services/whatsapp_service.py) / [routes.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/routes.py#L764) | **Gaps importantes:**<br>1. O envio pela rota `/consultas/<id>/notify` não salva o registro do envio na tabela `Mensagem` (a entidade `Mensagem` está modelada, mas não é utilizada).<br>2. A rotina em segundo plano (`APScheduler`) está configurada, mas o job é apenas um placeholder de log (`check_upcoming_consultas` em [tasks.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/services/tasks.py#L6)). Não existe lógica para escanear consultas futuras e disparar mensagens automáticas. |
| **Painel de Métricas** | **Completo** | [routes.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/routes.py#L441) / [metrics.html](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/templates/metrics.html) | Exibe os totais de leads, consultas, processos e usuários ativos. |
| **Controle de Acesso / Perfis** | **Parcial** | [routes.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/routes.py#L12) | Há decoradores como `roles_required` e `admin_required`. No entanto, rotas críticas como a conversão de leads (`convert_lead`) estão protegidas apenas com `@login_required`, permitindo que usuários com papel `cliente` façam alterações operacionais graves no sistema. |

---

## 3. Diagnóstico de Cibersegurança (OWASP Top 10)

Foram avaliados os 6 achados identificados no relatório de cibersegurança do repositório:

1. **Escalação de privilégios no cadastro público (Crítico):**
   - **Causa:** O endpoint `/usuarios/cadastro` aceita o parâmetro `role` do payload JSON diretamente: `role=data.get('role') or 'user'`.
   - **Impacto:** Qualquer usuário pode criar uma conta administrativa enviando `"role": "admin"`.
   - **Dependência do Teste:** O arquivo [conftest.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/tests/conftest.py#L38) explora essa falha para registrar um `admin_client` de testes. Se a vulnerabilidade for corrigida diretamente, a suíte de testes quebrará.
2. **Configuração insegura e segredo padrão (Alto):**
   - **Causa:** `SECRET_KEY` padrão é `'dev'` em [config.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/config.py#L8) e `debug=True` está hardcoded no entrypoint [run.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/run.py#L8).
3. **Falta de autorização no fluxo de conversão (Alto):**
   - **Causa:** `/leads/<id>/convert` possui apenas `@login_required`. Qualquer perfil pode converter leads.
4. **Senha padrão na conversão de Lead (Alto):**
   - **Causa:** A conversão define a senha como `'123456'` em [routes.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/routes.py#L641), facilitando o comprometimento inicial.
5. **Vazamento de detalhes de erro em integrações (Médio):**
   - **Causa:** Retorno de `str(exc)` em payloads de erro (IA e WhatsApp), revelando endpoints e stacks do servidor.
6. **Ausência de proteção CSRF (Alto):**
   - **Causa:** Falta de tokens de proteção CSRF em formulários (Login, Registro, Logout) e nas rotas que realizam mutação (`POST`).

---

## 4. Diagnóstico de Testes Automatizados

- **Estrutura:** Bem estruturada com `pytest`, `responses` (para simular chamadas HTTP externas) e `freezegun` (para tempo determinístico).
- **Status:** Todos os 34 testes passam.
- **Acoplamento Técnico:** Como notado no item anterior, o `admin_client` fixture depende da falha de privilégios. A correção dessa falha exigirá adaptar a fixture para persistir o papel diretamente no banco usando o contexto do banco de dados de testes (`db.session`), e não o endpoint público `/usuarios/cadastro`.

---

## 5. Adequação e Preparação para o Mobile (Flutter)

A arquitetura atual do backend é **híbrida (Monolito com MVC + suporte AJAX)**. Para implementar o aplicativo mobile, é necessária uma transição organizada para uma **Arquitetura Cliente-Servidor (API REST)**, conforme descrito em [descricao-projeto-jurislead-crm-mobile.md](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/mobile/docs/descricao-projeto-jurislead-crm-mobile.md):

* **Autenticação:** O Flutter não utiliza sessões baseadas em cookies do navegador (`Flask-Login` cookies). Ele exigirá autenticação baseada em **JWT (JSON Web Tokens)**, trafegada via cabeçalhos HTTP (`Authorization: Bearer <token>`).
* **Estrutura de Rotas:** Recomenda-se separar as rotas de visualização web (`/web/...`, `/perfil`) das rotas exclusivas de API REST (`/api/v1/...`), que devem retornar exclusivamente JSON e usar status HTTP corretos.
* **Infraestrutura (Docker):** A especificação mobile planeja a conteinerização do backend. O projeto web atual não possui `Dockerfile` nem configurações de ambiente prontas para contêineres.

---

## 6. Plano de Melhorias (Roadmap de Refatoração)

Para garantir uma base estável, segura e pronta para a comunicação com o Flutter, propõe-se um plano de 3 fases antes de focar na codificação do frontend mobile:

### Fase 1: Correção de Segurança e Ajuste dos Testes (Urgente)
* [ ] **Correção da Escalação de Privilégios:** 
  - Forçar `role = 'user'` no endpoint `/usuarios/cadastro`.
  - Criar uma rota administrativa protegida ou comando CLI/seed para atribuição de outros papéis.
* [ ] **Ajuste nos Testes:** 
  - Atualizar as fixtures `admin_client` e testes em [conftest.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/tests/conftest.py) e [test_users.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/tests/test_users.py) para que criem e salvem usuários admin diretamente no banco, contornando a restrição de cadastro público.
* [ ] **Proteção CSRF na Web:** 
  - Integrar o `Flask-WTF` ou middleware de CSRF para proteger formulários web e requisições AJAX.
* [ ] **Refinamento de Autorização:** 
  - Proteger a rota `/leads/<id>/convert` com privilégios adequados (`roles_required('admin', 'advogado', 'atendente')`).
* [ ] **Redução de Exposição de Erros:** 
  - Substituir `str(exc)` por mensagens genéricas no frontend e capturar a stack real usando `app.logger.exception` no servidor.
* [ ] **Políticas de Senha:** 
  - Substituir a senha provisória estática `'123456'` na conversão por geração de senhas aleatórias de alta entropia.

### Fase 2: Finalização de Pendências Funcionais e de Background Tasks
* [ ] **Orquestração de Disparos de Lembretes:** 
  - Implementar a rotina real dentro do job `check_upcoming_consultas` em [tasks.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/services/tasks.py) para buscar consultas marcadas para as próximas 24 horas.
  - Invocar o serviço de WhatsApp para cada consulta elegível que ainda não foi notificada.
* [ ] **Histórico na Entidade Mensagem:** 
  - Alterar o fluxo de envio de WhatsApp para salvar um registro na tabela `mensagens` (model `Mensagem`) a cada envio com sucesso ou falha, preservando a rastreabilidade do CRM.

### Fase 3: Preparação da API REST e Autenticação JWT (Pré-Mobile)
* [ ] **Dockerização:** 
  - Criar o `Dockerfile` e `docker-compose.yml` para empacotar o Flask com suas dependências e inicialização automática.
* [ ] **Autenticação JWT:** 
  - Integrar o `Flask-JWT-Extended` no backend.
  - Criar rota `/api/v1/auth/login` que valide credenciais e retorne o Token JWT.
* [ ] **Estruturação de Blueprint da API REST (`/api/v1`)**
  - Mapear endpoints limpos para o Flutter consumir:
    - `GET /api/v1/leads` e `POST /api/v1/leads`
    - `POST /api/v1/leads/<id>/triage`
    - `POST /api/v1/leads/<id>/convert`
    - `GET /api/v1/processos` e `POST /api/v1/processos/<id>/movimentacoes`
    - `GET /api/v1/consultas` e `POST /api/v1/consultas`
  - Proteger esses endpoints com `@jwt_required()` para garantir acesso autenticado e seguro ao aplicativo mobile.
