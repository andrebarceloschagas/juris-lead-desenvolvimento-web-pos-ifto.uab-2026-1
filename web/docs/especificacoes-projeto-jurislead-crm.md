# Especificações do JurisLead CRM

## IFTO / UAB - Campus Araguatins

## Curso de Pós-Graduação Lato Sensu em Desenvolvimento de Sistemas Computacionais

## Disciplina: Desenvolvimento Web

## Alunos: Antonio André Barcelos Chagas e Fabíola Gomes da Rocha

Este documento consolida as especificações funcionais, técnicas e arquiteturais do JurisLead CRM, um sistema voltado para escritórios de advocacia que desejam captar leads, organizar atendimentos e automatizar o relacionamento com clientes.

## 1. Objetivo do sistema

O JurisLead CRM tem como objetivo reduzir a perda de oportunidades comerciais em escritórios de advocacia, centralizando em uma única plataforma o processo de captação, triagem, atendimento, agendamento e acompanhamento de clientes e processos.

O sistema deve permitir:

- captação de leads por landing page;
- triagem inicial com inteligência artificial;
- cadastro e acompanhamento de clientes;
- gestão de agenda e consultas;
- controle de processos e movimentações;
- automação de follow-up por WhatsApp;
- visualização de métricas operacionais e comerciais.

## 2. Escopo do produto

### 2.1 Módulos previstos

- Landing page de captação;
- Chat com IA para pré-atendimento;
- Gestão de leads e clientes;
- Agenda de consultas;
- Controle de processos jurídicos;
- Automação de mensagens e lembretes;
- Painel de indicadores;
- Administração de usuários e permissões.

### 2.2 Fora do escopo inicial

Nesta primeira versão, o sistema não deve depender de microsserviços nem de infraestrutura complexa. O foco é entregar um monólito bem estruturado, fácil de implantar e de evoluir.

## 3. Arquitetura

O sistema utilizará uma arquitetura monolítica baseada no padrão **MVC (Model-View-Controller)**, adequada ao ecossistema Flask.

- **Controller:** rotas Flask responsáveis por receber requisições HTTP, validar entradas, aplicar regras de negócio e acionar integrações externas.
- **Model:** camadas de persistência com SQLAlchemy, representando usuários, leads, clientes, processos, agendamentos e registros de mensagens.
- **View:** templates HTML renderizados no servidor com Jinja 2, com interface responsiva baseada em Bootstrap 5.

## 4. Plataforma tecnológica

- **Linguagem:** Python 3;
- **Framework web:** Flask;
- **ORM:** SQLAlchemy;
- **Banco de dados:** SQLite;
- **Frontend:** HTML5, CSS3, Bootstrap 5 e Jinja 2;
- **Autenticação e sessão:** Flask e cookies seguros;
- **Tarefas agendadas:** APScheduler ou Celery;
- **Integrações externas:** APIs HTTP para IA e WhatsApp;
- **Versionamento:** Git e GitHub.

## 5. Estrutura de diretórios

Organização modular para facilitar manutenção e crescimento do projeto:

```text
jurislead_crm/
|── docs/
    |── especificacoes-projeto-jurislead-crm.md
    |── descricao-projeto-jurislead-crm.md
├── app/
│   ├── __init__.py
│   ├── models.py
│   ├── routes.py
│   ├── services/
│   ├── templates/
│   └── static/
├── config.py
├── requirements.txt
├── .env
├── .gitignore
└── run.py
```

### 5.1 Responsabilidade dos diretórios

- `app/__init__.py`: criação da aplicação, registro de extensões e blueprints;
- `app/models.py`: definição das entidades e relacionamentos;
- `app/routes.py`: controladores e mapeamento de rotas;
- `app/services/`: serviços de IA, WhatsApp, relatórios e rotinas auxiliares;
- `app/templates/`: páginas HTML renderizadas no servidor;
- `app/static/`: estilos, scripts, imagens e recursos estáticos;
- `config.py`: configurações por ambiente;
- `run.py`: ponto de entrada da aplicação.

## 6. Convenções de desenvolvimento

- Código Python seguindo PEP 8;
- Classes de modelo em `PascalCase`;
- Tabelas e colunas em `snake_case`;
- Rotas RESTful em minúsculo, com palavras separadas por hífen;
- Templates nomeados de forma compatível com a rota ou funcionalidade;
- Validações e mensagens de erro consistentes em toda a aplicação.

## 7. Requisitos funcionais

### 7.1 Captação de leads

O sistema deve permitir que visitantes preencham um formulário em landing page e entrem automaticamente no fluxo de atendimento.

### 7.2 Triagem com IA

O sistema deve usar um serviço de inteligência artificial para coletar informações iniciais do caso, identificar a necessidade do lead e registrar o contexto da conversa.

### 7.3 Cadastro de clientes e leads

O sistema deve armazenar dados cadastrais, histórico de atendimento, origem do lead e status atual do relacionamento.

### 7.4 Agenda

O sistema deve permitir criar, editar, listar e cancelar consultas e compromissos.

### 7.5 Processos

O sistema deve registrar processos jurídicos e manter informações úteis para acompanhamento interno.

### 7.6 Automação de WhatsApp

O sistema deve enviar lembretes automáticos de consultas, retornos e follow-ups com base em regras configuradas.

### 7.7 Painel de métricas

O sistema deve apresentar indicadores como volume de leads, taxa de conversão, atendimentos agendados e evolução de processos.

### 7.8 Administração

O sistema deve permitir o gerenciamento de usuários, perfis, acesso e configurações gerais do escritório.

## 8. Requisitos não funcionais

- Interface responsiva para desktop e dispositivos móveis;
- Estrutura simples de instalar e manter;
- Código organizado para facilitar testes e evolução futura;
- Uso de autenticação segura para perfis restritos;
- Separação clara entre regras de negócio, persistência e apresentação;
- Possibilidade de operação com banco SQLite em ambiente inicial.

## 9. Entidades principais

As entidades mínimas do domínio devem contemplar:

- **Usuário:** administra o acesso ao sistema;
- **Lead:** representa o contato captado na landing page ou no chat;
- **Cliente:** representa um lead qualificado ou convertido;
- **Consulta:** agenda de atendimento e retornos;
- **Processo:** informações relacionadas ao caso jurídico;
- **Mensagem:** histórico de contato e automações enviadas;
- **Métrica:** indicadores consolidados para o painel.

## 10. Fluxos principais

### 10.1 Fluxo de captação

O visitante acessa a landing page, preenche os dados iniciais e é registrado como lead.

### 10.2 Fluxo de triagem

A IA realiza perguntas iniciais, coleta o contexto do caso e classifica as informações para o escritório.

### 10.3 Fluxo de atendimento

O advogado ou atendente consulta os dados do lead, agenda reunião e acompanha o histórico do contato.

### 10.4 Fluxo de acompanhamento

O sistema executa lembretes e follow-ups automáticos via WhatsApp conforme regras e prazos definidos.

## 11. Serviços e integrações

- **IA:** integração via API HTTP com provedores como OpenAI ou Google Gemini;
- **WhatsApp:** integração via serviços como Twilio, Z-API ou Evolution API;
- **Agendamento de tarefas:** uso de APScheduler ou Celery para rotinas assíncronas;
- **Relatórios:** geração de consolidações e indicadores para uso gerencial.

## 12. Variáveis de ambiente

| Variável | Descrição |
| --- | --- |
| `FLASK_APP` | Arquivo principal de execução, como `run.py`. |
| `FLASK_ENV` | Ambiente da aplicação, como `development` ou `production`. |
| `SECRET_KEY` | Chave criptográfica para sessões e segurança. |
| `DATABASE_URI` | URL do banco SQLite, como `sqlite:///jurislead.db`. |
| `AI_API_KEY` | Chave de autenticação do provedor de IA. |
| `WHATSAPP_API_TOKEN` | Token de autenticação da API de WhatsApp. |
| `ADMIN_DEFAULT_EMAIL` | E-mail inicial do administrador seed. |
| `ADMIN_DEFAULT_PASS` | Senha inicial do administrador seed. |

## 13. Perfis de usuário

| Perfil | Acesso e autorização | Regras de cadastro |
| --- | --- | --- |
| **Administrador** | Controle total do sistema, incluindo usuários, configurações, métricas e dados do escritório. | Conta seed criada na inicialização; pode cadastrar outros administradores. |
| **Advogado/Atendente** | Acesso à agenda, leads, processos, chat e rotinas operacionais. | Deve ser criado ou inativado por um administrador. |
| **Cliente (Lead)** | Acesso restrito ao próprio atendimento, consultas e histórico relacionado. | Pode ser criado por autocadastro ou pelo fluxo da IA. |

## 14. Critérios de qualidade

- O sistema deve manter coerência visual e responsividade em todas as páginas;
- A navegação deve ser simples e orientada à produtividade;
- As integrações externas devem falhar com mensagens claras e tratamento apropriado de erro;
- Os dados sensíveis devem ser tratados com cuidado e não expostos indevidamente;
- O projeto deve permitir evolução futura sem reestruturação completa da base.

## 15. Resumo técnico

O JurisLead CRM será um CRM jurídico monolítico, construído com Flask, SQLAlchemy, SQLite e Jinja 2, focado em captação de leads, automação de atendimento e controle de processos. A arquitetura proposta equilibra simplicidade de implantação, clareza de código e potencial de evolução para um produto comercial escalável.

## 16. Endpoints implementados (estado atual)

Observação: esta lista descreve os endpoints implementados na versão atual do repositório.

- `POST /leads` — cria um `Lead` a partir de `name`, `email`, `phone`, `origin`.
- `POST /leads/<id>/triage` — dispara a triagem via serviço de IA (mockável), grava `triage_summary` e `triage_classification` no `Lead`.
- `POST /consultas` — cria uma `Consulta` (campos: `lead_id`, `scheduled_at` em ISO8601) com validação de data futura.
- `POST /consultas/<id>/cancel` — cancela uma `Consulta` (altera `status` para `cancelled`).
- `POST /consultas/<id>/notify` — envia lembrete via integração com API de WhatsApp (mockável).
- `POST /processos` — cria um `Processo` vinculado a um `Lead` (campos: `lead_id`, `title`, `description`).
- `POST /processos/<id>/movimentacoes` — adiciona uma `Movimentacao` a um `Processo`.
- `GET /processos/<id>` — retorna o `Processo` com suas movimentações (`movimentacoes`).

## 17. Variáveis de ambiente relevantes para integrações

Para executar integrações externas (em produção ou testes manuais), as seguintes variáveis são consideradas pelo código:

- `AI_API_URL` — URL base da API de IA (padrão no código: `https://example-ai.local/triage`).
- `AI_API_KEY` — token Bearer opcional para a API de IA.
- `WHATSAPP_API_URL` — URL da API de envio de WhatsApp (padrão: `https://example-whatsapp.local/send`).
- `WHATSAPP_API_TOKEN` — token Bearer opcional para a API de WhatsApp.

Em ambiente de testes automatizados, as chamadas a APIs externas são mockadas (biblioteca `responses`) e as variáveis não são obrigatórias.

## 18. Como executar localmente e rodar a suíte de testes

Recomendação rápida para criar um ambiente local e executar a suíte:

1. criar e ativar um virtualenv na raiz do projeto:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

1. instalar dependências:

```bash
pip install -r requirements.txt
```

1. executar a aplicação (opcional):

```bash
export FLASK_APP=run.py
flask run
# ou
python run.py
```

1. rodar a suíte de testes automatizados:

```bash
.venv/bin/python -m pytest -q
```

Observação: os testes usam banco SQLite em memória e mocks para integrações externas.

## 19. Frontend — comportamento visual, acessibilidade e padrões

Esta seção define exclusivamente correções, refinamentos e regras para o frontend (comportamento visual, componentes, estados de tela e interação). As regras abaixo complementam os requisitos funcionais sem introduzir novas funcionalidades de backend.

### 19.1 Comportamento visual e layout
- A interface deve preservar consistência visual entre páginas usando `base.html` como template principal e classes utilitárias CSS centralizadas em `static/css/style.css`.
- Componentes básicos (botões, alertas, formulários, cards e tabelas) devem seguir espaçamentos e tipografia consistentes: margem padrão `1rem`, padding `0.75rem`, e uso de fonte base definida em `:root`.
- Todas as páginas devem suportar três breakpoints mínimos: `desktop (>=1024px)`, `tablet (>=768px and <1024px)` e `mobile (<768px)`; os layouts devem reflow sem esconder informações essenciais.

### 19.2 Componentes de interface e Design System
- Padronizar botões com classes: `.btn`, `.btn-primary`, `.btn-secondary`, `.btn-link`.
- Formulários devem utilizar rótulos (`<label>`) ligados a campos (`for` / `id`) e mensagens de erro inline com a classe `.field-error`.
- Inputs obrigatórios devem exibir um marcador visual e texto alternativo (`aria-required="true"`).
- Usar componentes reutilizáveis em templates fragmentados (ex.: `templates/components/_form_field.html`) quando aplicável.

### 19.3 Estados de tela e feedbacks
- Todos os formulários submetidos devem apresentar estado de `loading` (botão com `aria-busy="true"` ou skeleton) até o término da requisição.
- Tratar explicitamente estados vazios com mensagens amigáveis e CTA (ex.: "Nenhum lead encontrado — criar novo lead").
- Exibir mensagens de sucesso e erro na parte superior do conteúdo com roles apropriados (`role="status"` para sucesso, `role="alert"` para erros).

### 19.4 Responsividade
- Componentes que contenham tabelas devem virar listagem responsiva em telas pequenas, mostrando colunas essenciais e um botão para ver detalhes.
- Menus de navegação deverão transformar-se em um menu hamburguer no breakpoint mobile.

### 19.5 Acessibilidade (a11y)
- Navegação por teclado: todos os controles interativos (links, botões, formulários) devem ser alcançáveis via `Tab` e possuir foco visível (outline ou box-shadow).
- Labels adequados para formulários, uso de `aria-label` quando não existir `label` visível.
- Contraste de cores deve atender ao mínimo AA (relativo ao texto principal sobre fundo) conforme WCAG 2.1.
- Elementos dinâmicos (modais, alerts, atualizações AJAX) devem usar `aria-live` ou `role` apropriado para anunciar mudanças a leitores de tela.

### 19.6 Validações visuais e mensagens de erro
- Mensagens de erro devem ser claras, concisas e associadas ao campo com `aria-describedby` apontando para o elemento de mensagem.
- Em caso de erro de validação de formulário, o primeiro campo inválido deve receber foco automaticamente.

### 19.7 Integração frontend/backend e regras de renderização
- O frontend deve assumir os contratos REST já descritos; para estados de loading/erro o frontend deve mapear respostas HTTP a mensagens amigáveis: `400` → validação, `401` → autenticação, `404` → recurso não encontrado, `409` → conflito/duplicidade, `500` → erro interno.
- Renderização condicional: componentes que dependem de dados devem renderizar três estados: `loading`, `empty` (sem dados) e `ready` (dados carregados).

### 19.8 Tratamento de formulários e padrões de interação
- Submissão de formulários via AJAX deve desabilitar o botão de envio até resposta; permitir re-tentativa em caso de timeout com contador de tentativas curto.
- Confirm dialogs para ações destrutivas (ex.: excluir lead) com role `dialog` e foco gerenciado.

### 19.9 Padronização do design system
- Documentar classes utilitárias (cores, espaçamento, tipografia) em `static/css/style.css` e manter uso consistente.
- Evitar estilos inline; preferir classes CSS e variáveis `:root`.

Estas regras são mandatórias para a próxima versão e devem ser testadas com os cenários de frontend definidos em `docs/testing.md`.
