# Plano de Testes do JurisLead CRM

## IFTO / UAB - Campus Araguatins

## Curso de Pós-Graduação Lato Sensu em Desenvolvimento de Sistemas Computacionais

## Disciplina: Desenvolvimento Web

## Alunos: Antonio André Barcelos Chagas e Fabíola Gomes da Rocha

## 1. Objetivo

Definir uma estratégia de testes automatizados para o JurisLead CRM com foco em TDD First, priorizando cenários críticos de negócio, redução de regressões e validação contínua das funcionalidades descritas em [docs/especificacoes-projeto-jurislead-crm.md](docs/especificacoes-projeto-jurislead-crm.md).

## 2. Diretriz TDD First

A implementação deve seguir o ciclo Red, Green, Refactor:

1. escrever o teste antes da funcionalidade;
2. fazer o teste falhar pelo motivo correto;
3. implementar o menor código possível para passar;
4. refatorar sem quebrar o comportamento validado.

A regra operacional é criar primeiro os testes que representam o fluxo crítico de cada funcionalidade, especialmente os caminhos de sucesso e as falhas que evitam perda de dados, autenticação indevida ou disparos incorretos de automação.

## 3. Estratégia de teste

A estratégia proposta é automatizada e orientada a regressão, com divisão em camadas:

- testes unitários para regras de negócio, validações e serviços isolados;
- testes de integração para rotas Flask, persistência SQLAlchemy e integração entre componentes;
- testes funcionais de fluxo para os principais casos de uso do sistema;
- testes de contrato com mocks para APIs externas de IA e WhatsApp.

Sempre que houver dependência externa, o teste deve usar mock, stub ou fake para isolar o comportamento e tornar a execução determinística.

## 4. Prioridade de cobertura

A prioridade segue a criticidade do fluxo para a operação do escritório:

1. autenticação e autorização;
2. captação e armazenamento de leads;
3. triagem com IA;
4. agenda e compromissos;
5. processos jurídicos;
6. automação de WhatsApp;
7. indicadores e painel gerencial;
8. administração de usuários e permissões.

## 5. Níveis de teste e foco

| Nível | Foco | Exemplos |
| --- | --- | --- |
| Unitário | Funções e serviços sem dependências externas reais | validação de lead, regra de status, cálculo de métricas |
| Integração | Comunicação entre rotas, serviços e banco | criação de lead via rota, persistência de consulta |
| Funcional | Fluxo completo do usuário | cadastro inicial, agendamento, follow-up |
| Contrato | Integração simulada com APIs externas | IA, WhatsApp, relatórios assíncronos |

## 6. Matriz de testes por funcionalidade

### 6.1 Captação de leads

| ID | Cenário crítico | Tipo | Dependências simuladas | Resultado esperado |
| --- | --- | --- | --- | --- |
| TST-LEAD-01 | Submissão válida do formulário da landing page | Integração | banco de dados em memória | lead criado com status inicial e origem registrada |
| TST-LEAD-02 | Submissão com campo obrigatório ausente | Unitário/Integração | validação local | retorno de erro e nenhum registro persistido |

Prioridade: validar primeiro o fluxo de submissão válida, pois ele representa a entrada principal do funil comercial.

### 6.2 Triagem com IA

| ID | Cenário crítico | Tipo | Dependências simuladas | Resultado esperado |
| --- | --- | --- | --- | --- |
| TST-IA-01 | IA retorna resumo e classificação do caso | Contrato | API de IA mockada | contexto salvo e lead classificado corretamente |
| TST-IA-02 | API de IA indisponível | Contrato/Integração | resposta de erro simulada | sistema registra falha e mantém o fluxo com mensagem controlada |

Prioridade: garantir que a indisponibilidade da IA não quebre o atendimento nem corrompa o cadastro do lead.

### 6.3 Cadastro de clientes e leads

| ID | Cenário crítico | Tipo | Dependências simuladas | Resultado esperado |
| --- | --- | --- | --- | --- |
| TST-CLI-01 | Conversão de lead em cliente | Integração | banco de dados em memória | dados migrados ou vinculados com histórico preservado |
| TST-CLI-02 | Tentativa de duplicidade por e-mail ou documento | Unitário/Integração | regra de unicidade | rejeição da duplicidade com mensagem adequada |

Prioridade: impedir duplicidade e perda de histórico, pois isso afeta a confiabilidade do CRM.

### 6.4 Agenda

| ID | Cenário crítico | Tipo | Dependências simuladas | Resultado esperado |
| --- | --- | --- | --- | --- |
| TST-AGE-01 | Criação de consulta com data futura válida | Integração | controle de data com freezegun | consulta persistida e associada ao cliente |
| TST-AGE-02 | Cancelamento de consulta existente | Integração | banco de dados em memória | status alterado para cancelado e evento registrado |

Prioridade: garantir a criação e o cancelamento porque são os pontos de maior impacto operacional.

### 6.5 Processos jurídicos

| ID | Cenário crítico | Tipo | Dependências simuladas | Resultado esperado |
| --- | --- | --- | --- | --- |
| TST-PROC-01 | Cadastro de processo com vínculo a cliente | Integração | banco de dados em memória | processo armazenado com relacionamento correto |
| TST-PROC-02 | Atualização de movimentação/processo | Unitário/Integração | serviço de persistência | histórico atualizado sem sobrescrever dados essenciais |

Prioridade: assegurar a integridade do vínculo entre cliente e processo, pois é o núcleo do acompanhamento jurídico.

### 6.6 Automação de WhatsApp

| ID | Cenário crítico | Tipo | Dependências simuladas | Resultado esperado |
| --- | --- | --- | --- | --- |
| TST-WA-01 | Disparo de lembrete para consulta agendada | Contrato | API WhatsApp mockada | mensagem enviada com conteúdo e destino corretos |
| TST-WA-02 | Falha na API de WhatsApp | Contrato | resposta de erro simulada | falha tratada sem interromper a aplicação e com log do erro |

Prioridade: validar o disparo e o tratamento de erro, evitando envio duplicado ou falha silenciosa.

### 6.7 Painel de métricas

| ID | Cenário crítico | Tipo | Dependências simuladas | Resultado esperado |
| --- | --- | --- | --- | --- |
| TST-MET-01 | Consolidação de indicadores com dados reais do banco | Integração | banco de dados em memória | totais e taxas calculados corretamente |
| TST-MET-02 | Painel com ausência de dados | Unitário/Integração | base vazia | indicadores exibem zero ou estado vazio sem erro |

Prioridade: conferir consistência dos números, pois o painel orienta decisões gerenciais.

### 6.8 Administração

| ID | Cenário crítico | Tipo | Dependências simuladas | Resultado esperado |
| --- | --- | --- | --- | --- |
| TST-ADM-01 | Criação e edição de usuário administrador | Integração | banco de dados em memória | usuário salvo com perfil correto |
| TST-ADM-02 | Bloqueio de acesso a rota restrita para usuário sem permissão | Funcional | sessão autenticada simulada | acesso negado com resposta apropriada |

Prioridade: proteger rotas e perfis para evitar exposição indevida de dados e funções sensíveis.

## 7. Cenários transversais obrigatórios

Além dos testes por funcionalidade, os seguintes cenários devem sempre existir na suíte:

- autenticação válida com sessão ativa;
- acesso negado para usuário não autenticado;
- validação de campos obrigatórios;
- tratamento de exceções de integração externa;
- persistência correta em SQLite;
- comportamento em base vazia;
- prevenção de duplicidade de registros;
- formato de resposta consistente nas rotas principais.

## 8. Técnica de automação

A automação deve ser implementada com `pytest` e executada em ambiente isolado, preferencialmente com banco SQLite em memória ou banco temporário por teste.

Recursos recomendados para o projeto:

- `pytest` para execução da suíte;
- `pytest-cov` para cobertura mínima e regressão visual;
- `pytest-mock` para mocks e spies;
- `responses` para simular chamadas HTTP externas;
- `freezegun` para datas e horários determinísticos;
- fixtures reutilizáveis para app Flask, client HTTP e sessão autenticada.

## 9. Critérios de aceitação dos testes

Um incremento de funcionalidade só deve ser considerado concluído quando:

- o teste da funcionalidade estiver escrito antes da implementação;
- o teste falhar inicialmente pelo motivo esperado;
- a implementação fizer o teste passar sem comprometer outros cenários;
- a suíte completa puder ser executada de forma repetível;
- a cobertura dos fluxos críticos permanecer estável após alterações.

## 10. Pipeline de execução sugerido

| Etapa | Comando sugerido | Objetivo |
| --- | --- | --- |
| Validação rápida | `pytest -q` | identificar falhas funcionais rapidamente |
| Cobertura | `pytest --cov=app --cov-report=term-missing` | medir aderência dos testes ao código |
| Regime de regressão | `pytest -q --maxfail=1` | parar cedo em falhas críticas |

## 11. Riscos e mitigação

| Risco | Impacto | Mitigação |
| --- | --- | --- |
| Dependência externa instável | Quebra de testes | usar mocks e respostas simuladas |
| Dados compartilhados entre testes | Falsos positivos/negativos | fixtures com isolamento por teste |
| Datas e horários variáveis | Flakiness | uso de `freezegun` |
| Ausência de cobertura das rotas críticas | Regressões em produção | priorizar testes funcionais das jornadas principais |

## 12. Dependências de teste

O arquivo `requirements.txt` deve incluir, no mínimo, as dependências de execução do sistema e da suíte automatizada:

- Flask;
- SQLAlchemy;
- python-dotenv;
- APScheduler;
- requests;
- pytest;
- pytest-cov;
- pytest-mock;
- freezegun;
- responses.

## 13. Conclusão

O plano de testes do JurisLead CRM prioriza o que é mais crítico para a operação do sistema: entrada de leads, triagem com IA, agenda, processos, automações e administração segura. A abordagem TDD First, combinada com testes automatizados e uso criterioso de mocks, reduz regressões e cria uma base confiável para evolução contínua do produto.

## 14. Implementação atual da suíte e status

Esta seção descreve o estado atual da suíte de testes implementada no repositório.

- Testes implementados e automatizados:
  - `TST-LEAD-01`, `TST-LEAD-02` — criação de lead e validação de campos (`tests/test_lead.py`).
  - `TST-CLI-01`, `TST-CLI-02` — conversão de lead em cliente e prevenção de duplicidade de e-mail/documento (`tests/test_clientes.py` e `tests/test_lead.py`).
  - `TST-IA-01`, `TST-IA-02` — triagem via IA com sucesso e falha (`tests/test_ia_triage.py`).
  - `TST-AGE-01`, `TST-AGE-02` — criação e cancelamento de consultas (`tests/test_agenda.py`).
  - `TST-PROC-01`, `TST-PROC-02` — criação de processo e adição de movimentação (`tests/test_processos.py`).
  - `TST-WA-01`, `TST-WA-02` — disparo de lembrete por WhatsApp e tratamento de erro (`tests/test_whatsapp.py`).

- Como executar a suíte completa (a partir da raiz do projeto):

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
.venv/bin/python -m pytest -q
```

- Executar apenas um arquivo de testes (exemplo):

```bash
.venv/bin/python -m pytest tests/test_agenda.py -q
```

- Executar com relatório de cobertura:

```bash
.venv/bin/python -m pytest --cov=app --cov-report=term-missing
```

Observação: os testes foram projetados para rodar de forma determinística (SQLite em memória, `responses` para HTTP mocks e `freezegun` para controle de tempo). Se quiser que eu atualize os testes para cobrir casos adicionais ou adicionar integração contínua (GitHub Actions), posso incluir um workflow básico.
