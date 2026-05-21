## IFTO / UAB - Campus Araguatins

## Curso de Pós-Graduação Lato Sensu em Desenvolvimento de Sistemas Computacionais

## Disciplina: Desenvolvimento Web

## Alunos: Antonio André Barcelos Chagas e Fabíola Gomes da Rocha

## Descrição do JurisLead CRM

O **JurisLead CRM** é uma plataforma web desenvolvida para escritórios de advocacia que precisam atender leads com mais agilidade, organizar o relacionamento com clientes e automatizar etapas operacionais do atendimento jurídico. A proposta combina captação de contatos, triagem inicial com inteligência artificial, gestão de agenda, acompanhamento de processos e automação de follow-up por WhatsApp em um único sistema.

## Visão geral

Em muitos escritórios, a perda de oportunidades comerciais acontece por demora no retorno ao cliente, falta de organização dos atendimentos e ausência de um fluxo padronizado para acompanhamento dos casos. O JurisLead CRM foi pensado para resolver esse problema com uma experiência centralizada, simples de usar e orientada a resultados.

O sistema segue uma arquitetura monolítica baseada em MVC, com Flask no backend, SQLAlchemy para persistência em SQLite e templates Jinja 2 renderizados no servidor. A interface é construída com HTML5, CSS3 e Bootstrap 5, priorizando responsividade para uso em desktop e dispositivos móveis.

## Problema que o sistema resolve

Escritórios de advocacia frequentemente perdem clientes por três motivos principais:

- demora no atendimento inicial;
- ausência de controle dos leads recebidos;
- dificuldade para acompanhar processos, consultas e retornos.

O JurisLead CRM enfrenta essas dores com automação, organização e monitoramento contínuo do funil de atendimento jurídico.

## Solução proposta

O sistema atua como um CRM especializado para advocacia, reunindo ferramentas para captar leads, qualificar contatos, registrar informações relevantes do caso e manter o relacionamento com o cliente de forma previsível.

Entre os principais recursos previstos estão:

- Landing page para captação de leads;
- Chat inicial com IA para triagem e coleta de contexto;
- Cadastro de clientes e leads;
- Agenda de consultas e compromissos;
- Controle de processos jurídicos;
- Follow-up automático via WhatsApp;
- Painel de métricas e visão gerencial.

## Público-alvo

O JurisLead CRM é direcionado a:

- advogados autônomos;
- escritórios de pequeno porte;
- escritórios que desejam padronizar o atendimento e melhorar a conversão de leads;
- equipes jurídicas que precisam centralizar comunicação, agenda e acompanhamento de processos.

## Funcionalidades principais

### 1. Landing page de captação

A plataforma pode receber contatos de uma página inicial voltada à conversão, permitindo que o lead entre no fluxo de atendimento já com os dados básicos registrados.

### 2. Chat com inteligência artificial

Um assistente inicial baseado em API de IA realiza a triagem do lead, coleta informações sobre o problema apresentado e ajuda a organizar o contexto antes do atendimento humano.

### 3. Cadastro de clientes

O sistema mantém o registro de clientes, leads e informações associadas, facilitando a consulta rápida e a continuidade do atendimento.

### 4. Agenda de consultas

O módulo de agenda organiza reuniões, atendimentos e retornos, reduzindo falhas de comunicação e esquecimentos.

### 5. Controle de processos

Os casos jurídicos podem ser acompanhados em um único lugar, com histórico e atualização de informações relevantes para a equipe.

### 6. Follow-up automático por WhatsApp

Mensagens automatizadas podem ser enviadas para lembrar consultas, reforçar contatos e manter o relacionamento com o cliente ativo.

### 7. Painel de métricas

O painel gerencial apresenta indicadores importantes para acompanhamento comercial e operacional do escritório.

## Arquitetura e tecnologia

O projeto foi desenhado com base em uma stack leve e consolidada para aplicações web:

- **Linguagem:** Python 3;
- **Framework web:** Flask;
- **Banco de dados:** SQLite com SQLAlchemy ORM;
- **Frontend:** HTML5, CSS3, Bootstrap 5 e Jinja 2;
- **Automação e integrações:** APIs externas para IA e WhatsApp;
- **Tarefas assíncronas:** APScheduler ou Celery para rotinas automatizadas.

A estrutura modular facilita manutenção, evolução do sistema e separação clara entre rotas, modelos, serviços e templates.

## Modelo de usuários

O sistema prevê três perfis principais:

- **Administrador:** acesso total, gerenciamento de usuários, planos, configurações e métricas globais;
- **Advogado/Atendente:** acesso às rotinas operacionais, agenda, chat, processos e cadastro de leads;
- **Cliente (Lead):** acesso restrito às próprias informações, consultas e histórico do atendimento.

## Modelo de monetização

O JurisLead CRM possui forte potencial comercial por ser uma solução especializada para um nicho com dor clara e recorrente. A monetização pode ser estruturada por assinatura mensal:

- **Plano Individual:** R$ 97/mês para advogado autônomo;
- **Plano Pequeno Escritório:** R$ 297/mês;
- **Plano Escritório Grande:** R$ 597/mês.

Esse modelo permite atender desde profissionais independentes até estruturas maiores, com escalabilidade conforme o crescimento do cliente.

## Diferencial competitivo

O principal diferencial do JurisLead CRM está no fato de resolver um problema real e sensível do mercado jurídico: a perda de clientes por falta de resposta rápida e organização. Além disso, o projeto parte de uma dor que já é conhecida no setor, o que aumenta a chance de aderência comercial.

Outro ponto forte é a combinação entre atendimento inteligente, automação e visão de CRM, criando uma solução prática para escritórios que desejam ganhar produtividade sem aumentar complexidade operacional.

## Resumo

O **JurisLead CRM** é uma solução SaaS voltada para escritórios de advocacia que desejam melhorar a captação de clientes, organizar o atendimento e automatizar tarefas repetitivas. Com foco em conversão, relacionamento e controle operacional, o projeto une tecnologia, produtividade e posicionamento comercial em uma única plataforma.
