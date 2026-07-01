# Realizações do Projeto, Melhorias e Estado Atual — JurisLead CRM

## IFTO / UAB - Campus Araguatins

## Curso de Pós-Graduação Lato Sensu em Desenvolvimento de Sistemas Computacionais

## Disciplina: Desenvolvimento Web

## Alunos: Antonio André Barcelos Chagas e Fabíola Gomes da Rocha

Data: 25 de junho de 2026

---

## 1. Resumo Executivo

Este documento consolida todas as melhorias técnicas, correções de segurança, automações de background, e a reestruturação arquitetural para suporte móvel efetuadas no projeto **JurisLead CRM Web**.

O projeto original foi auditado e refatorado em três fases sequenciais, elevando a segurança da aplicação às melhores práticas da indústria (OWASP Top 10), ativando processos reais em segundo plano para lembretes automatizados de clientes, estruturando uma API RESTful completa com autenticação via JSON Web Tokens (JWT) e, por fim, containerizando toda a infraestrutura com Docker e docker-compose.

---

## 2. Fase 1: Correções de Cibersegurança e Robustez dos Testes

Focada em mitigar vulnerabilidades críticas do sistema e adaptar a suíte de testes legada para que não dependesse de falhas arquiteturais.

* **Mitigação de Escalação de Privilégios (Crítico):**
  * *Local:* [app/routes.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/routes.py)
  * *Ação:* Removemos a aceitação direta do campo `role` no payload JSON do endpoint público `/usuarios/cadastro`. Qualquer novo registro público agora é forçado a ter o papel `'user'`, prevenindo a criação de administradores não autorizados.
* **Mecanismo de Proteção CSRF Customizado (Alto):**
  * *Local:* [app/__init__.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/__init__.py)
  * *Ação:* Desenvolvemos um middleware customizado no hook `before_request` do Flask que valida um token criptográfico armazenado na sessão (`csrf_token`).
  * *Integração:* Adicionamos o campo oculto contendo o token em todos os 13 formulários HTML mutáveis da aplicação web.
* **Validação de Autorização de Perfis (Alto):**
  * *Local:* [app/routes.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/routes.py)
  * *Ação:* Restringimos o endpoint de conversão de lead (`/leads/<id>/convert`) para aceitar somente perfis operacionais legítimos (`admin`, `manager`, `advogado`, `atendente`) através do decorador `@roles_required`, impedindo que usuários externos (papel `cliente`) efetuem mutações operacionais.
* **Segurança de Credenciais no Cadastro (Alto):**
  * *Local:* [app/routes.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/routes.py)
  * *Ação:* Substituímos a senha padrão e previsível `'123456'` que era gerada na conversão de um Lead por uma senha aleatória de alta entropia gerada dinamicamente via biblioteca padrão com `secrets.token_urlsafe(16)`.
* **Exposição Segura de Exceções (Médio):**
  * *Local:* [app/services/ia_service.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/services/ia_service.py) e [app/services/whatsapp_service.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/services/whatsapp_service.py)
  * *Ação:* Removemos retornos do tipo `str(exc)` que revelavam infraestrutura e stacks internos para o cliente. As falhas agora são logadas com `current_app.logger.exception()` no servidor e o usuário recebe códigos e mensagens de erro genéricas padronizadas.
* **Desacoplamento e Correção de Fixtures de Teste:**
  * *Local:* [tests/conftest.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/tests/conftest.py) e [tests/test_users.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/tests/test_users.py)
  * *Ação:* As fixtures `admin_client` e `auth_client` que exploravam a escalação de privilégios do cadastro para atuar nos testes foram refatoradas. Elas agora realizam o cadastro comum e alteram o perfil (`role`) diretamente na tabela do SQLite usando o contexto de banco de dados (`db.session`), preservando a fidelidade dos testes de segurança.

---

## 3. Fase 2: Automação do Agendamento e Histórico de Mensagens

Esta etapa ativou tarefas de fundo no ecossistema Flask e estabeleceu controles de rastreabilidade para disparos manuais e automáticos de mensagens.

* **Ativação da Rotina de Fundo (Scheduler):**
  * *Local:* [app/services/tasks.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/services/tasks.py)
  * *Ação:* Implementamos a lógica real da tarefa de background `check_upcoming_consultas(app)`. O scheduler escaneia periodicamente consultas com status `scheduled` cujo agendamento ocorrerá dentro das próximas 24 horas.
* **Prevenção de Spam (Envio Duplicado):**
  * *Local:* [app/services/tasks.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/services/tasks.py)
  * *Ação:* Antes de acionar a API de notificação externa, o sistema realiza uma checagem no banco de dados SQLite para verificar se já existe uma mensagem enviada com sucesso para aquele lead e horário específico.
* **Logs e Auditoria Histórica (Tabela `mensagens`):**
  * *Local:* [app/routes.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/routes.py) e [app/services/tasks.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/services/tasks.py)
  * *Ação:* Tanto o disparo manual via rota `/consultas/<id>/notify` quanto a rotina em lote do Scheduler agora inserem um registro histórico persistente na entidade `Mensagem` marcando o status como `'sent'` (sucesso) ou `'failed'` (caso a chamada de API retorne erro ou haja falha de conexão).

---

## 4. Fase 3: Dockerização e API REST com Autenticação JWT

Fase crítica de expansão arquitetural visando fornecer suporte completo ao aplicativo móvel Flutter sem gerar regressões na aplicação web baseada em HTML/Templates.

* **Arquitetura Isolada de API RESTful:**
  * *Local:* [app/api_routes.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/api_routes.py)
  * *Ação:* Criamos um Blueprint sob o prefixo `/api/v1` contendo endpoints focados no modelo cliente-servidor que recebem e respondem estritamente payloads em JSON com códigos de status HTTP semânticos.
* **Autenticação via JSON Web Token (JWT):**
  * *Local:* [app/api_routes.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/api_routes.py) e [app/__init__.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/__init__.py)
  * *Ação:* Inicializamos o `JWTManager` via `Flask-JWT-Extended`. Criamos o endpoint `/api/v1/auth/login` para autenticação com e-mail e senha, retornando um token de acesso de 30 dias para uso contínuo em ambiente móvel.
* **Convivência de Segurança (Bypass de CSRF na API):**
  * *Local:* [app/__init__.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/__init__.py)
  * *Ação:* O middleware CSRF foi adaptado para verificar se o path da requisição inicia com `/api/`. Em caso positivo, o token CSRF de cookie é ignorado, pois o cliente API móvel já se protege usando o cabeçalho `Authorization: Bearer <JWT>`. A aplicação web convencional continua 100% protegida.
* **Portfólio de Endpoints RESTful Implementados:**
  * `POST /api/v1/auth/login` -> Login JWT.
  * `GET/POST /api/v1/leads` -> Consulta e criação de leads (protegido por JWT + perfil operacional).
  * `POST /api/v1/leads/<id>/triage` -> Dispara triagem IA (protegido por JWT + perfil operacional).
  * `POST /api/v1/leads/<id>/convert` -> Conversão em cliente (protegido por JWT + perfil operacional).
  * `POST /api/v1/consultas` e `/api/v1/consultas/<id>/cancel` -> Criação e cancelamento (protegido por JWT + perfil operacional).
  * `POST /api/v1/processos`, `GET /api/v1/processos/<id>` e `POST /api/v1/processos/<id>/movimentacoes` -> Gestão de processos e inserção de movimentações históricas (protegido por JWT + perfil operacional).
* **Dockerização e Orquestração do Backend:**
  * *Local:* [Dockerfile](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/Dockerfile) e [docker-compose.yml](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/docker-compose.yml)
  * *Ação:* Criamos um Dockerfile baseado na imagem `python:3.11-slim`. Configuramos uma pasta `/app/data` para a base de dados SQLite persistente.
  * *Persistência:* No `docker-compose.yml`, orquestramos o serviço Flask mapeando a porta local `5000:5000` e atrelando um volume persistente (`sqlite_data:/app/data`). A URI de banco do container foi apontada para `sqlite:////app/data/jurislead.db` garantindo que os dados inseridos persistam ao reiniciar ou recriar os containers.

---

## 5. Cobertura de Testes Automatizados (Estado Atual)

Todas as melhorias foram sistematicamente integradas à suíte de testes para prevenir qualquer regressão funcional ou lógica. 

* **Testes de Integração Criados para a API REST:**
  * Desenvolvemos o arquivo [tests/test_api.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/tests/test_api.py) com cobertura para fluxos completos: login com credenciais válidas e inválidas, rejeição de requisições sem token JWT, validação de privilégios de perfil (`roles`), criação de lead, consulta, cancelamento, processo e inserção de movimentações.

### Resumo dos Resultados de Teste

A execução local com Pytest cobre todo o projeto web:

```bash
.venv/bin/python -m pytest -q
```

**Resultado Final Obtido:**

```text
........................................                                 [100%]
40 passed, 5 warnings in 7.83s
```

*A evolução do projeto partiu de 34 testes herdados para 40 testes totalmente validados.*

---

## 6. Relato de Andamento do Desenvolvimento Mobile

Como parte da transição para a versão móvel do **JurisLead CRM**, apresenta-se a seguir o status de andamento do desenvolvimento do aplicativo mobile:

* **Plataforma Tecnológica:** Decidiu-se pela utilização do ecossistema **Dart/Flutter** para o desenvolvimento da aplicação mobile. O Flutter foi escolhido por viabilizar a criação de uma aplicação nativa de alta performance e interface rica para Android e iOS a partir de uma única base de código.
* **Instalação do Ambiente de Desenvolvimento:** O ambiente local de desenvolvimento foi configurado com sucesso no sistema operacional Windows utilizando a IDE **Android Studio** integrada ao Flutter SDK e gerenciadores de emuladores virtuais.
* **Inicialização do Projeto:** O projeto foi inicializado com sucesso e a estrutura de diretórios do módulo `mobile` está pronta. O foco principal nesta fase foi a refatoração e preparação completa do backend (conforme documentado acima) para prover suporte de autenticação por tokens e consumo de endpoints limpos em JSON pela aplicação móvel.
* **Dificuldades Encontradas:** Até o momento atual, nenhuma dificuldade técnica ou de configuração de ambiente foi encontrada.

---

## 7. Arquivos Modificados e Criados (Mapeamento Rastreável)

Abaixo listamos as principais modificações rastreáveis efetuadas no repositório:

| Arquivo | Estado | Responsabilidade |
| --- | --- | --- |
| [requirements.txt](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/requirements.txt) | **Modificado** | Inclusão do pacote `Flask-JWT-Extended`. |
| [run.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/run.py) | **Modificado** | Configuração de host dinâmico para rodar de dentro do container Docker. |
| [app/\_\_init\_\_.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/__init__.py) | **Modificado** | Registro do Blueprint de API, middleware CSRF com bypass de `/api/` e JWTManager. |
| [app/routes.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/routes.py) | **Modificado** | Correção de privilégios de cadastro e conversão, além de auditoria de lembrete manual. |
| [app/services/tasks.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/services/tasks.py) | **Modificado** | Lógica real do Scheduler para escaneamento e envio automático de lembretes. |
| [app/api_routes.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/api_routes.py) | **Novo** | Blueprint `/api/v1` contendo toda a lógica REST da API móvel. |
| [Dockerfile](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/Dockerfile) | **Novo** | Especificação leve de containerização da aplicação. |
| [docker-compose.yml](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/docker-compose.yml) | **Novo** | Orquestração com variáveis de ambiente e volume para o SQLite persistente. |
| [tests/test_api.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/tests/test_api.py) | **Novo** | Testes completos de integração da API REST e tokens de acesso JWT. |
| *13 Templates HTML* | **Modificado** | Adição de proteção CSRF com `<input type="hidden" name="csrf_token" value="{{ csrf_token() }}">`. |
