# Plano de Testes - JurisLead CRM Mobile

## 1. Introdução

Este documento detalha o plano de testes para o projeto **JurisLead CRM Mobile**. A abordagem principal adotada é o **TDD (Test-Driven Development) First**, o que significa que os testes serão elaborados e implementados antes ou em conjunto com o código de produção.

A prioridade deste plano é validar os cenários críticos do aplicativo, garantindo que as regras de negócio essenciais sejam preservadas em cada alteração de código. O uso de **mocks** será adotado sistematicamente para isolar dependências externas, como APIs RESTful e serviços de terceiros.

## 2. Estratégia de Testes

A estratégia de automação está dividida em três camadas no Flutter:

1. **Testes de Unidade:** Validação isolada de `ViewModels`, lógica de estado, parse de JSON e regras de negócio nos `Models`.

2. **Testes de Widget (Componente):** Verificação de renderização, interações de usuário (cliques, scroll) e estados visuais isolados (Material Design 3).

3. **Testes de Integração:** Fluxos ponta a ponta que atravessam múltiplas telas (ex: Login até a tela principal).

Todas as validações farão parte do pipeline de integração contínua (CI) para **evitar regressões**.

---

## 3. Plano de Testes por Funcionalidade

Abaixo, os testes prioritários para cada módulo do sistema (focando em cenários críticos).

### 3.1. Autenticação Segura

**Objetivo:** Garantir que o usuário só tenha acesso ao sistema mediante credenciais válidas.

* **Cenário Crítico (Unidade - ViewModel):** Tentativa de login com credenciais válidas.
    * *Ação:* Chamar `login(email, senha)` no ViewModel.
    * *Mock:* Mockar a camada de `AuthService` para retornar um token JWT válido e status HTTP 200.
    * *Resultado Esperado:* O estado do ViewModel deve mudar para logado, e o token JWT deve ser salvo no armazenamento seguro (`flutter_secure_storage`).

* **Cenário de Falha (Widget):** Tentativa de login com e-mail inválido.
    * *Ação:* Inserir formato inválido de e-mail e tentar submeter o formulário.
    * *Resultado Esperado:* A interface deve impedir a submissão e exibir a mensagem de erro "E-mail com formato inválido" sob o campo.

### 3.2. Gestão de Leads

**Objetivo:** Validar a listagem, visualização e criação de novos leads.

* **Cenário Crítico (Unidade):** Carregamento e filtragem de leads por status.
    * *Ação:* Solicitar lista de leads e aplicar o filtro "Novo".
    * *Mock:* `LeadService` retorna um JSON mockado com 5 leads, sendo 3 com status "Novo".
    * *Resultado Esperado:* O estado interno atualiza corretamente a lista exibindo apenas os 3 leads filtrados, descartando os demais.

* **Cenário Crítico (Integração):** Cadastro de novo Lead.
    * *Ação:* Preencher o formulário de cadastro, submeter, e retornar para a listagem.
    * *Mock:* Mockar o `POST /api/v1/leads` para retornar HTTP 201 (Created).
    * *Resultado Esperado:* Tela de listagem atualizada para conter o lead recém-criado, sem recarregar a tela inteira (atualização de estado reativa).

### 3.3. Triagem com IA

**Objetivo:** Testar a acurácia e a resiliência do sistema ao consultar resumos de inteligência artificial.

* **Cenário Crítico (Unidade - ViewModel):** Acionar a triagem de IA em um Lead e lidar com indisponibilidade do serviço.
    * *Ação:* Disparar o evento de geração de resumo `triageLead(id)`.
    * *Mock:* Mockar `POST /api/v1/leads/<id>/triage` retornando um HTTP 500 (Erro no backend ou indisponibilidade do Gemini).
    * *Resultado Esperado:* ViewModel deve tratar a exceção adequadamente e atualizar o estado da UI para exibir um alerta amigável "Não foi possível gerar a triagem. Tente novamente", sem fechar o aplicativo (crash).

### 3.4. Agenda de Consultas

**Objetivo:** Controlar e exibir corretamente a agenda de consultas.

* **Cenário Crítico (Unidade/Model):** Validação de choque de horários na criação local de evento.
    * *Ação:* Tentar adicionar um agendamento cujo horário colida com um evento já listado no Model.
    * *Resultado Esperado:* A função de validação deve retornar `false` / gerar uma Exception de conflito antes mesmo de disparar a requisição de API.

* **Cenário Crítico (Widget):** Cancelamento de compromisso.
    * *Ação:* Clicar no botão "Cancelar Consulta" e confirmar a caixa de diálogo.
    * *Mock:* `AgendaService` responde com HTTP 200.
    * *Resultado Esperado:* O item deve sumir da lista visual exibida pela interface na mesma hora, via estado reativo.

### 3.5. Controle de Processos e Movimentações

**Objetivo:** Validar a exibição de processos e adição de novos andamentos.

* **Cenário Crítico (Integração):** Registrar nova movimentação processual.
    * *Ação:* Acessar Detalhes do Processo > Adicionar Movimentação > Salvar.
    * *Mock:* A API de `GET /api/v1/processos/<id>` inicialmente retorna o histórico, e após a adição, simular uma nova requisição com os dados atualizados.
    * *Resultado Esperado:* A linha do tempo (timeline) do processo deve ser renderizada corretamente com a nova movimentação ordenada por data decrescente.

### 3.6. Integração WhatsApp

**Objetivo:** Validar a abertura da intenção (intent) para o aplicativo externo e uso de links universais.

* **Cenário Crítico (Unidade/Widget):** Acionar o contato via WhatsApp.
    * *Ação:* Clicar no botão "Falar no WhatsApp" no perfil do Lead.
    * *Mock:* Usar pacote como `url_launcher_platform_interface` para mockar a verificação de "canLaunch" (retornar verdadeiro).
    * *Resultado Esperado:* O serviço de launcher deve ser chamado passando a formatação correta de URL (`https://wa.me/...` ou `whatsapp://send?phone=...` com a mensagem pré-configurada em URL-Encode).

### 3.7. Dashboard e Indicadores

**Objetivo:** Verificar a correta atribuição dos números e resumos da tela inicial.

* **Cenário Crítico (Unidade):** Agregação de métricas locais e da API.
    * *Ação:* Carregar painel inicial.
    * *Mock:* O endpoint `GET /api/v1/metrics` retorna um total de 12 leads e 4 consultas pendentes.
    * *Resultado Esperado:* A conversão do JSON pelo Model de Métricas deve transcorrer com sucesso. A view deve exibir exatamente "12" no card de Leads e "4" no card de pendências.

---

## 4. Uso de Mocks

Para a implementação dos cenários listados e a garantia de isolamento em TDD, o projeto adotará os seguintes padrões e ferramentas:

* **Mockito / Mocktail:** Frameworks Dart para criação das instâncias falsas (`mocks`) das interfaces de serviço de API e pacotes como `flutter_secure_storage`.
* **HTTP Client Mocking:** Para os testes nos pacotes que efetuam requisições HTTP (`http` ou `dio`), as chamadas não deverão alcançar a rede. As respostas serão estáticas, definidas com JSONs que simulam exatamente a documentação da API Flask/Backend.
* **Geração Automática:** Utilização do `build_runner` para regerar mocks automaticamente sempre que as assinaturas das classes de serviço mudarem.

## 5. Execução e Prevenção de Regressões

O foco em evitar regressões se dará por:

1. **Red-Green-Refactor:** Para cada bug relatado ou nova feature, primeiro cria-se um teste que falha. Em seguida, o código é implementado.
2. **Cobertura Mínima:** A branch principal (main) só deverá aceitar Pull Requests que não diminuam o percentual de cobertura de testes, especialmente nos pacotes `models` e `viewmodels`.
3. **Continuous Integration (CI):** Uma pipeline via GitHub Actions executará o comando `flutter test` em todos os pull requests e commits, bloqueando merges caso alguma automação quebre.
