# Descrição Preliminar do JurisLead CRM

## IFTO / UAB - Campus Araguatins

## Curso de Pós-Graduação Lato Sensu em Desenvolvimento de Sistemas Computacionais

## Disciplina: Desenvolvimento Web

## Alunos: Antonio André Barcelos Chagas e Fabíola Gomes da Rocha

O **JurisLead CRM** é uma aplicação web voltada para escritórios de advocacia que desejam organizar a captação de leads, qualificar contatos com mais rapidez e acompanhar o relacionamento com clientes em um fluxo centralizado.

O projeto reúne, em uma única plataforma, recursos para landing page de captação, triagem inicial com inteligência artificial, cadastro de clientes, agenda de consultas, controle de processos, automação de mensagens por WhatsApp e visualização de métricas operacionais.

## Objetivo

O objetivo principal do sistema é reduzir a perda de oportunidades de atendimento jurídico, oferecendo uma estrutura simples para registrar contatos, priorizar atendimentos e acompanhar a evolução de cada lead até sua conversão em cliente.

## Problema que o sistema resolve

Em muitos escritórios, os contatos chegam por canais variados e acabam sendo registrados de forma manual ou dispersa. Isso dificulta o retorno rápido, a organização da agenda e o acompanhamento do histórico de cada caso. O JurisLead CRM foi pensado para resolver esse cenário com uma experiência centralizada e responsiva.

## Solução proposta

A solução proposta é um CRM jurídico monolítico, construído com Flask, SQLAlchemy e SQLite, com interface renderizada no servidor por meio de Jinja 2 e Bootstrap 5. A aplicação deve permitir um fluxo contínuo desde a captação inicial do lead até o acompanhamento do atendimento e dos processos vinculados.

## Funcionalidades previstas

- Landing page para captação de contatos;
- Triagem inicial com IA;
- Cadastro e gestão de leads e clientes;
- Agenda de consultas e atendimentos;
- Controle de processos e movimentações;
- Envio de lembretes e follow-ups via WhatsApp;
- Painel com métricas e indicadores;
- Administração de usuários e permissões.

## Público-alvo

O sistema é direcionado a:

- advogados autônomos;
- pequenos escritórios de advocacia;
- equipes jurídicas que precisam padronizar o atendimento;
- profissionais que desejam acompanhar leads e clientes em um único ambiente.

## Tecnologias principais

- Python 3;
- Flask;
- SQLAlchemy;
- SQLite;
- Jinja 2;
- Bootstrap 5;
- APIs HTTP para integrações com IA e WhatsApp;
- APScheduler para rotinas automatizadas.

## Situação atual

A base do projeto já contempla a estrutura principal de autenticação, leads, usuários, agenda, processos e integrações externas. Esta descrição preliminar serve como visão geral inicial do sistema, antes da documentação funcional e técnica mais detalhada.