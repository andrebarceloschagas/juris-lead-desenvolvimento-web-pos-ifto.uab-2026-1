# Especificações do JurisLead CRM Mobile

## IFTO / UAB - Campus Araguatins

## Curso de Pós-Graduação Lato Sensu em Desenvolvimento de Sistemas Computacionais

## Disciplina: Desenvolvimento Mobile

## Alunos: Antonio André Barcelos Chagas e Fabíola Gomes da Rocha

Este documento detalha as especificações técnicas, funcionais e arquiteturais do **JurisLead CRM Mobile**, a expansão para dispositivos móveis do ecossistema JurisLead. O aplicativo visa proporcionar mobilidade para advogados e atendentes, permitindo a gestão de leads, consultas e processos em tempo real.

## 1. Objetivo do sistema

O objetivo do JurisLead CRM Mobile é estender as funcionalidades da plataforma web para o ambiente móvel, garantindo que o profissional jurídico possa:

- Acompanhar e qualificar leads em qualquer lugar;
- Gerenciar a agenda de consultas e compromissos;
- Consultar e atualizar movimentações de processos;
- Receber notificações e realizar follow-ups rápidos via WhatsApp;
- Monitorar métricas operacionais essenciais.

## 2. Escopo do produto

### 2.1 Módulos previstos

- **Autenticação Segura:** Login via JWT e gerenciamento de sessão;
- **Gestão de Leads:** Listagem, filtros, detalhes e criação de leads;
- **Triagem com IA:** Interface para acionar e visualizar resumos de triagem;
- **Agenda de Consultas:** Visualização e controle de agendamentos;
- **Controle de Processos:** Histórico de processos e inclusão de movimentações;
- **Integração WhatsApp:** Disparo de lembretes e mensagens pré-configuradas;
- **Dashboard Mobile:** Visualização rápida de métricas e indicadores.

### 2.2 Fora do escopo inicial

- Funcionalidades offline complexas (edição de dados sem conexão);
- Chat em tempo real (substituído por integração com WhatsApp);
- Pagamentos integrados no aplicativo.

## 3. Arquitetura

O aplicativo utilizará o framework **Flutter** com uma arquitetura orientada a dados e separação de responsabilidades (MVVM - Model-View-ViewModel):

- **Model:** Representação das entidades de dados (Lead, Processo, User, etc) e lógica de conversão JSON;
- **View:** Interfaces construídas com widgets Flutter, seguindo o Material Design 3;
- **ViewModel/State:** Gerenciamento de estado da aplicação (ex: Provider ou Riverpod), isolando a lógica de negócio da interface.
- **Services:** Camada de comunicação com a API REST (HTTP Client).

## 4. Plataforma tecnológica

- **Linguagem:** Dart;
- **Framework:** Flutter;
- **IDE:** Android Studio;
- **Gerenciamento de Estado:** Provider ou Riverpod;
- **Comunicação:** Pacote `http` ou `dio` para requisições REST;
- **Segurança:** `flutter_secure_storage` para armazenamento de tokens JWT;
- **Persistência Local:** `shared_preferences` para configurações simples;
- **IA:** Apoio do Gemini no ciclo de desenvolvimento.

## 5. Estrutura de diretórios

A estrutura do projeto Flutter seguirá a convenção sugerida:

```text
mobile/app_mobile/
├── lib/
│   ├── main.dart             # Ponto de entrada
│   ├── models/               # Entidades de dados
│   ├── views/                # Telas e widgets
│   ├── viewmodels/           # Lógica de estado e negócios
│   ├── services/             # Clientes da API REST
│   └── utils/                # Constantes, temas e validadores
├── assets/                   # Imagens, ícones e fontes
├── test/                     # Testes de unidade e widgets
└── pubspec.yaml              # Dependências
```

## 6. Convenções de desenvolvimento

- Código Dart seguindo o `lints` oficial da Google;
- Nomenclatura de arquivos em `snake_case`;
- Classes em `PascalCase`;
- Variáveis e funções em `camelCase`;
- Uso rigoroso de tipos (Strong Typing);
- Comentários em funções complexas e documentação de APIs internas.

## 7. Requisitos funcionais

### 7.1 Autenticação

O sistema deve permitir login seguro com e-mail e senha, suportando a persistência da sessão via token JWT.

### 7.2 Gestão de Leads

Listagem de leads com pesquisa e filtros por status (Novo, Triado, Convertido). Visualização completa do histórico e dados de contato.

### 7.3 Triagem e IA

Permitir que o usuário acione a triagem por IA e visualize o resumo gerado diretamente no celular.

### 7.4 Agenda Mobile

Visualização dos compromissos do dia/semana com opção de agendar novas consultas ou cancelar existentes.

### 7.5 Processos e Movimentações

Consulta rápida a processos ativos e inclusão de novas movimentações (textuais) com registro automático de data.

### 7.6 Dashboard e Indicadores

Tela inicial com cards resumindo: total de leads, consultas pendentes e processos abertos.

## 8. Requisitos não funcionais

- **Desempenho:** Respostas de interface rápidas e carregamento eficiente de listas;
- **Segurança:** Comunicação via HTTPS e armazenamento cifrado de segredos;
- **Usabilidade:** Interface intuitiva seguindo padrões mobile (gestos, navegação);
- **Acessibilidade:** Suporte a leitores de tela e contraste adequado;
- **Responsividade:** Adaptação correta entre diferentes tamanhos de tela e orientações (portrait/landscape).

## 9. Especificação da API (Endpoints)

A API Flask deverá ser estendida para suportar o prefixo `/api/v1` e autenticação JWT:

- `POST /api/v1/auth/login` - Autenticação;
- `GET /api/v1/leads` - Listagem de leads;
- `POST /api/v1/leads/<id>/triage` - Triagem IA;
- `GET /api/v1/processos/<id>` - Detalhes do processo;
- `GET /api/v1/metrics` - Dados do dashboard.

## 10. Plano de Testes

- **Unidade:** Testes de modelos e lógica de ViewModels;
- **Widget:** Verificação de renderização e interação de componentes de UI;
- **Integração:** Testes de fluxo de ponta a ponta (Login -> Dashboard -> Lead).

## 11. Variáveis de Ambiente (Configuração do App)

| Variável | Descrição |
| --- | --- |
| `BASE_URL` | URL base da API Backend (ex: <https://api.jurislead.com/api/v1>) |
| `ENV` | Ambiente (development/production) |
