# Roteiro de Apresentação e Vídeo - JurisLead CRM

## IFTO / UAB - Campus Araguatins

## Curso de Pós-Graduação Lato Sensu em Desenvolvimento de Sistemas Computacionais

## Disciplina: Desenvolvimento Web

## Alunos: Antonio André Barcelos Chagas e Fabíola Gomes da Rocha

Este documento traz um roteiro pronto para:

- montar os slides;
- gravar o vídeo de apresentação;
- conduzir uma demonstração do sistema rodando.

Tempo sugerido total: 12 a 15 minutos.

---

## 1) Estrutura geral da apresentação

- Bloco 1 (contexto e problema): slides 1 a 4
- Bloco 2 (solução e arquitetura): slides 5 a 9
- Bloco 3 (demonstração rodando): slides 10 a 13
- Bloco 4 (testes, resultados e próximos passos): slides 14 a 16

---

## 2) Roteiro slide a slide

## Slide 1 - Capa

### O que colocar no slide

- Título: JurisLead CRM
- Subtítulo: Plataforma web para captação, triagem e gestão de atendimento jurídico
- Disciplina, curso, instituição
- Nome dos integrantes

### O que falar

"Este projeto foi desenvolvido na disciplina de Desenvolvimento Web com foco em resolver um problema real de escritórios de advocacia: perda de leads por falta de organização e resposta rápida. O JurisLead CRM centraliza captação, atendimento e acompanhamento em uma única plataforma."

---

## Slide 2 - Contexto do problema

### O que colocar no slide

- Dor do mercado jurídico:
  - demora no primeiro contato;
  - perda de oportunidades;
  - processos e agenda descentralizados.
- Um fluxo visual simples do problema atual.

### O que falar

"No cenário tradicional, o escritório recebe contatos por vários canais e não consegue padronizar o atendimento. Isso causa atrasos, retrabalho e queda de conversão. Nosso projeto nasce para organizar esse funil desde a captação até o acompanhamento do caso."

---

## Slide 3 - Objetivo do projeto

### O que colocar no slide

- Objetivo principal: reduzir perda de oportunidades comerciais.
- Objetivos específicos:
  - captar leads com landing page;
  - estruturar triagem inicial com IA;
  - organizar consultas e processos;
  - apoiar follow-up por WhatsApp;
  - fornecer visão gerencial por métricas.

### O que falar

"O foco é aumentar eficiência operacional e melhorar conversão. Em vez de ferramentas isoladas, o JurisLead CRM propõe uma plataforma única para o escritório acompanhar toda a jornada do lead até o cliente."

---

## Slide 4 - Público-alvo e proposta de valor

### O que colocar no slide

- Público-alvo:
  - advogados autônomos;
  - escritórios de pequeno e médio porte.
- Proposta de valor:
  - resposta mais rápida;
  - atendimento padronizado;
  - visão centralizada de leads, consultas e processos.

### O que falar

"A proposta de valor é simples: transformar atendimento reativo em um fluxo organizado e previsível. Isso impacta diretamente produtividade da equipe e percepção de qualidade pelo cliente."

---

## Slide 5 - Visão funcional do sistema

### O que colocar no slide

- Funcionalidades implementadas e previstas:
  - landing page e captação de leads;
  - cadastro e gestão de leads;
  - cadastro e gestão de usuários;
  - agenda de consultas;
  - controle de processos e movimentações;
  - painel de métricas;
  - integração com WhatsApp via serviços.

### O que falar

"O sistema já possui base funcional de CRM jurídico, com foco em operações de atendimento e organização. A integração com WhatsApp estão desacopladas em serviços, prontas para uso com provedores externos."

---

## Slide 6 - Arquitetura da aplicação

### O que colocar no slide

- Arquitetura monolítica em MVC.
- Camadas:
  - Model: SQLAlchemy (entidades e persistência);
  - View: templates Jinja2 + Bootstrap;
  - Controller: rotas Flask.
- Diagrama simples: usuário -> rotas -> serviços/modelos -> banco.

### O que falar

"A escolha por monólito MVC foi intencional para manter simplicidade de implantação e evolução incremental. O Flask organiza bem as rotas, o SQLAlchemy abstrai persistência e o Jinja2 permite páginas server-side rápidas para este contexto acadêmico e de MVP."

---

## Slide 7 - Stack e ferramentas

### O que colocar no slide

- Backend: Python 3, Flask, Flask-SQLAlchemy, Flask-Login
- Banco: SQLite
- Frontend: HTML, CSS, Bootstrap, JavaScript
- Rotinas: APScheduler
- Integrações HTTP: requests
- Testes: pytest, pytest-cov, responses, freezegun
- Apoio de API: documentação em Markdown e coleção Postman

### O que falar

"A stack foi escolhida para equilibrar produtividade, baixo custo de setup e clareza arquitetural. Em ambiente local, o SQLite acelera desenvolvimento. Para testes, usamos ferramentas que cobrem regras de negócio e integrações mockadas."

---

## Slide 8 - Estrutura do projeto

### O que colocar no slide

- Estrutura de pastas principal:
  - app/
  - app/services/
  - app/templates/
  - app/static/
  - tests/
  - docs/
- Destacar arquivos-chave:
  - run.py
  - config.py
  - app/routes.py
  - app/models.py

### O que falar

"A estrutura está organizada por responsabilidade. Em app ficam regras e camadas principais; em services, integrações externas; em tests, a validação automatizada; e em docs, toda a documentação técnica e de API para facilitar manutenção e evolução."

---

## Slide 9 - Fluxo principal de uso

### O que colocar no slide

- Fluxo em etapas:
  1. captação do lead;
  2. registro e qualificação;
  3. agendamento de consulta;
  4. abertura de processo;
  5. acompanhamento e métricas.

### O que falar

"Este fluxo representa a jornada principal do negócio dentro do sistema. A ideia é reduzir perda de contexto entre etapas e manter histórico rastreável para tomada de decisão comercial e operacional."

---

## Slide 10 - Passo a passo para rodar localmente (Windows)

### O que colocar no slide

- Comandos:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
$env:FLASK_APP="run.py"
$env:FLASK_ENV="development"
python run.py
```

- URL local: http://127.0.0.1:5000

### O que falar

"Para rodar localmente, criamos o ambiente virtual, instalamos as dependências e executamos a aplicação Flask. O banco SQLite é criado automaticamente e o sistema sobe na porta 5000."

---

## Slide 11 - Demonstração 1: fluxo web

### O que colocar no slide

- Checklist da demo:
  1. abrir landing page;
  2. cadastrar usuário;
  3. fazer login;
  4. abrir tela de novo lead;
  5. listar leads e visualizar detalhes.

### O que falar

"Na demonstração web, mostramos a jornada inicial de uso do sistema: entrada pela landing, autenticação, criação de lead e consulta das informações registradas. Isso já evidencia a proposta de centralização do atendimento."

---

## Slide 12 - Demonstração 2: API (opcional, recomendada)

### O que colocar no slide

- Exemplo de sequência via API:
  - POST /captacao
  - POST /consultas
  - POST /processos
  - POST /processos/{id}/movimentacoes
  - GET /processos/{id}
- Referência: docs/api-endpoints.md e docs/api-curl-examples.md

### O que falar

"Além da interface web, o sistema também expõe endpoints para integração. Na demo API, mostramos criação de lead, consulta, processo e movimentação, finalizando com uma leitura consolidada do processo e histórico."

---

## Slide 13 - Demonstração 3: integrações e automação

### O que colocar no slide

- Integrações disponíveis por serviço:
  - WhatsApp para notificações e comunicação com os clientes.
- Rotina agendada:
  - job periódico via APScheduler.
- Observação: em testes, integrações são mockadas.

### O que falar

"As integrações externas foram encapsuladas em serviços para facilitar troca de provedor e testes. O projeto também possui agendamento de tarefas, o que abre caminho para lembretes automáticos e rotinas operacionais recorrentes."

---

## Slide 14 - Qualidade e testes

### O que colocar no slide

- Testes automatizados por módulo:
  - leads;
  - agenda;
  - processos;
  - usuários;
  - IA;
  - WhatsApp;
  - métricas.
- Comandos:

```powershell
pytest -q
pytest --cov=app --cov-report=term-missing
```

### O que falar

"A estratégia de qualidade combina testes de regras de negócio e cenários de integração com mocks, garantindo previsibilidade sem depender de serviços externos durante a validação local."

---

## Slide 15 - Resultados, limitações e melhorias

### O que colocar no slide

- Entregas atuais:
  - base funcional do CRM jurídico;
  - documentação técnica e de API;
  - cobertura de testes automatizados.
- Limitações de MVP:
  - integrações reais dependem de credenciais;
  - evolução de segurança e observabilidade em produção.
- Próximos passos:
  - hardening de segurança;
  - dashboards mais avançados;
  - deploy e monitoramento.

### O que falar

"Como MVP acadêmico, o projeto já demonstra valor funcional real. O próximo ciclo foca produção: reforço de segurança, observabilidade, governança de dados e expansão das análises de métricas para suporte à gestão do escritório."

---

## Slide 16 - Encerramento

### O que colocar no slide

- Conclusão principal em uma frase
- Agradecimentos
- Espaço para perguntas

### O que falar

"O JurisLead CRM mostra como uma arquitetura web enxuta, bem documentada e orientada ao problema do domínio pode gerar valor prático para escritórios de advocacia. Obrigado pela atenção."

---

## 3) Roteiro de gravação do vídeo (teleprompter curto)

Use esta sequência para gravar com fluidez:

1. Abertura (30-40s): apresente tema, problema e objetivo.
2. Contexto e proposta (1-2 min): explique dor do mercado e solução.
3. Arquitetura e stack (2-3 min): apresente MVC, módulos e tecnologias.
4. Demo rodando (4-6 min): execute aplicação, navegue no sistema e mostre endpoints.
5. Qualidade e encerramento (1-2 min): testes, limitações, próximos passos e conclusão.

Frase de transição sugerida para a demo:

"Agora que vimos o contexto e a arquitetura, vou mostrar o JurisLead CRM em execução para validar o fluxo principal da solução."

---

## 4) Checklist final antes da apresentação

- Ambiente virtual criado e dependências instaladas.
- Aplicação iniciando sem erros em localhost:5000.
- Banco SQLite criado e com dados mínimos para demo.
- Roteiro da navegação aberto para não esquecer passos.
- Endpoints de demonstração separados (Postman ou terminal).
- Tempo ensaiado para ficar dentro do limite da banca.

---

## 5) Sugestão de distribuição de tempo (15 min)

- Slides 1-4: 3 min
- Slides 5-9: 4 min
- Slides 10-13 (demo): 6 min
- Slides 14-16: 2 min

Se o tempo da apresentação for menor, reduza principalmente a parte conceitual e mantenha a demonstração prática.
