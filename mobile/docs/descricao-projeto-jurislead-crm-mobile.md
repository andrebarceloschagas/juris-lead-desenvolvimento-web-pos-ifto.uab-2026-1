# Descrição do Projeto: JurisLead CRM Mobile

## IFTO / UAB - Campus Araguatins

## Curso de Pós-Graduação Lato Sensu em Desenvolvimento de Sistemas Computacionais

## Disciplina: Desenvolvimento Mobile

## Alunos: Antonio André Barcelos Chagas e Fabíola Gomes da Rocha

## 1. Visão Geral e Objetivo

O **JurisLead CRM Mobile** é a evolução de uma plataforma de atendimento jurídico para um ecossistema móvel integrado (SaaS). O objetivo principal é combater a perda de oportunidades comerciais e a demora no atendimento, transformando um fluxo de trabalho reativo em um processo organizado e previsível. Ao migrar para o ambiente mobile, o sistema permite que o advogado gerencie leads, processos e agendas diretamente do seu *smartphone*, garantindo mobilidade e foco na experiência do usuário (UX).

## 2. Perfis de Usuários e Casos de Uso

O sistema adota um rigoroso controle de acesso baseado em papéis, dividindo as interações em três perfis principais:

* **Administrador:** Acesso inicial e total. É responsável pelos relatórios gerenciais, configurações do escritório e por realizar o CRUD (Cadastro, Leitura, Atualização e Exclusão) dos usuários Atendentes.

* **Atendente (Advogados/Equipe):** Cadastrados pelo Administrador. Acessam o aplicativo para consultar solicitações, responder leads, movimentar a agenda de consultas e gerenciar processos.

* **Cliente (Lead):** O usuário final. Ele realiza o seu próprio autocadastro no sistema, envia solicitações de atendimento e acompanha as respostas pelo aplicativo.

## 3. Equipe e Papéis (Multidisciplinar)

Conforme as premissas de desenvolvimento mobile, a equipe assume os seguintes papéis principais:

* **Product Owner (PO) / Tech Lead:** Define as prioridades do backlog e coordena a arquitetura do projeto.

* **UX/UI Designer:** Responsável por garantir usabilidade, acessibilidade e responsividade nas interfaces móveis.

* **Desenvolvedores (Frontend Mobile e Backend):** Responsáveis pela codificação da interface e da API.

* **Quality Assurance (QA) e Cibersegurança:** Foco em testes automatizados, inspeção de vulnerabilidades e segurança.

* **DevOps:** Gerencia o ciclo de CI/CD, a conteinerização e o *deploy* em nuvem.

## 4. Arquitetura da Aplicação

O projeto transiciona de um modelo web monolítico para uma **Arquitetura Cliente-Servidor (API REST)**:

* **Frontend (Cliente Móvel):** O aplicativo consome os serviços da API via requisições HTTP, focado exclusivamente na apresentação de dados e na interação do usuário (UI).

* **Backend (Servidor/API):** O servidor web (Python) expõe os *endpoints* necessários para o aplicativo funcionar, gerenciando a lógica de negócios e as consultas ao banco de dados.

## 5. Plataforma Tecnológica e Inteligência Artificial

A *stack* do projeto mescla a base web existente com tecnologias de ponta em desenvolvimento móvel orientado a IA:

* **Frontend Mobile:** Desenvolvido em linguagem **Dart** com o framework multiplataforma **Flutter**, utilizando a IDE **Android Studio**.

* **Backend:** Linguagem **Python 3**, utilizando o framework **Flask** para a criação da API REST.

* **Banco de Dados:** **SQLite** integrado ao ORM **SQLAlchemy** para persistência.

* **Infraestrutura:** A aplicação será encapsulada em contêineres **Docker**, com versionamento pelo **GitHub** conectado a uma conta online.

* **Apoio de IA no Desenvolvimento:** Uso do **Gemini CLI** e do **Gemini integrado ao Android Studio** para apoiar etapas de refatoração, implementação de código e geração de testes.

## 6. Estrutura de Diretórios

O projeto manterá uma separação lógica baseada em responsabilidades:

```text
jurislead-projeto/
 ├─ app-mobile/             # Código-fonte do Frontend em Flutter
 │   ├─ lib/
 │   │   ├─ main.dart       # Ponto de entrada do App
 │   │   ├─ views/          # Telas (UI) responsivas
 │   │   └─ services/       # Clientes HTTP para consumir a API Flask
 │   └─ pubspec.yaml        # Dependências do Dart/Flutter
 │
 ├─ api-backend/            # Código-fonte do Backend (Servidor)
 │   ├─ app/
 │   │   ├─ routes/         # Endpoints da API REST
 │   │   ├─ models.py       # Entidades SQLAlchemy (Leads, Usuários, etc)
 │   │   └─ services/       # Lógica de integrações (IA, WhatsApp)
 │   ├─ Dockerfile          # Definição do contêiner Docker
 │   ├─ requirements.txt    # Dependências Python
 │   └─ run.py              # Ponto de inicialização do servidor
```

## 7. Serviços Integrados

* **Serviço de Inteligência Artificial:** Responsável pela triagem inicial no chat para estruturar o resumo jurídico do lead.

* **Serviço de Notificações (WhatsApp):** Módulo para envio automático de lembretes e *follow-ups* com os clientes.

* **Rotinas de Fundo:** Uso do **APScheduler** para orquestrar as tarefas assíncronas e os disparos agendados.

## 8. Cibersegurança e Convenções

O projeto adota diretrizes baseadas na cartilha da OWASP e boas práticas do ecossistema mobile:

* **Autenticação Segura:** Uso de **JWT (JSON Web Tokens)** para gerenciar sessões entre o Flutter e a API.

* **Proteção em Trânsito:** Comunicação baseada em protocolos **HTTPS/TLS**, assegurando tráfego de dados cifrado.

* **Versionamento Seguro:** Uso de *branches* no Git e proteção rigorosa de segredos (Secrets/Vault) que nunca sobem no código-fonte.

* **Adequação à LGPD:** Cuidado extra na captação e tratamento de dados pessoais dos clientes.

## 9. Variáveis de Ambiente

Os dados sensíveis serão gerenciados através de variáveis de ambiente para funcionamento nos contêineres Docker:

* `FLASK_APP` e `FLASK_ENV`

* `DATABASE_URL`

* `JWT_SECRET_KEY` (Assinatura de tokens)

* `GEMINI_API_KEY` (Acesso à IA)

* `WHATSAPP_API_KEY` (Integração de mensageria)
