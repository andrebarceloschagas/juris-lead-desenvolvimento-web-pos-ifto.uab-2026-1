# Descrição Preliminar do JurisLead CRM Mobile

## IFTO / UAB - Campus Araguatins

## Curso de Pós-Graduação Lato Sensu em Desenvolvimento de Sistemas Computacionais

## Disciplina: Desenvolvimento Mobile

## Alunos: Antonio André Barcelos Chagas e Fabíola Gomes da Rocha

O **JurisLead CRM Mobile** é a evolução de uma aplicação web voltada para escritórios de advocacia, expandindo seu ecossistema para incluir o acesso por dispositivos móveis. O sistema permite que os profissionais organizem a captação de leads, qualifiquem contatos com rapidez e acompanhem o relacionamento com os clientes de qualquer lugar.

O projeto reúne recursos para autocadastro de clientes, triagem inicial com inteligência artificial, gestão de atendentes, agenda de consultas, controle de processos, automação de mensagens por WhatsApp e visualização de métricas operacionais — tudo centralizado e agora acessível na palma da mão.

## Objetivo

O objetivo principal do sistema é reduzir a perda de oportunidades de atendimento jurídico (oportunidades comerciais). Ao incluir o cenário móvel, a solução oferece aos advogados uma estrutura ainda mais simples e acessível para registrar contatos, priorizar atendimentos e acompanhar a evolução de cada lead até sua conversão em cliente, garantindo maior eficiência operacional.

## Problema que o sistema resolve

Em muitos escritórios, os contatos chegam por canais variados e acabam sendo registrados de forma manual ou dispersa. Isso dificulta o retorno rápido, gerando perda de oportunidades e "esfriamento" de leads. Além disso, a limitação a um computador fixo pode atrasar a resposta da equipe. O JurisLead CRM Mobile resolve esse cenário oferecendo uma experiência centralizada e responsiva por meio de dispositivos móveis, permitindo gerenciar agendas e consultar o histórico dos casos em tempo real, onde o advogado estiver.

## Solução proposta

A solução proposta é expandir o CRM jurídico existente, migrando de uma arquitetura puramente de servidor para uma **Arquitetura Cliente-Servidor (API REST)**. O backend continuará sendo gerido em Flask, SQLAlchemy e SQLite rodando em contêineres Docker, enquanto a interface de uso interativo migrará para um aplicativo móvel *cross-platform* (Android/iOS) desenvolvido com tecnologias modernas. O fluxo abrangerá desde a captação do lead até o acompanhamento contínuo dos processos.

## Funcionalidades previstas

- Aplicativo móvel para cadastro e gestão de leads, clientes e usuários atendentes;
- Autocadastro de clientes via *landing page* ou app;
- Consulta e triagem de casos com suporte de Inteligência Artificial;
- Visualização e gerenciamento de agenda de consultas pelo celular;
- Controle de processos, movimentações e histórico na palma da mão;
- Acompanhamento dos envios de lembretes e follow-ups integrados ao WhatsApp;
- Painel mobile com métricas e indicadores de produtividade;
- Administração de usuários (administrador, atendente, cliente) e controle de permissões.

## Público-alvo

O sistema é direcionado a:

- advogados autônomos;
- escritórios de pequeno e médio porte;
- equipes jurídicas que precisam padronizar o atendimento e necessitam de mobilidade;
- profissionais que desejam acompanhar leads e clientes em um único ambiente organizado e previsível.

## Tecnologias principais

- **Frontend Mobile:** Linguagem Dart e Framework Flutter;
- **IDE:** Android Studio;
- **Inteligência Artificial (Apoio no ciclo de dev):** Gemini CLI e Gemini integrado ao Android Studio;
- **Backend / API REST:** Python 3, Flask, SQLAlchemy, e SQLite;
- **Integrações e Automação:** APIs HTTP (para IA e WhatsApp) e APScheduler para rotinas agendadas;
- **Infraestrutura:** Contêineres Docker e controle de versão via GitHub.

## Situação atual

A base web do projeto já contempla a estrutura principal de autenticação, leads, agenda, processos e integração com WhatsApp e IA, construída de forma monolítica. O próximo passo e situação atual do projeto no contexto móvel englobam a adaptação de *endpoints* (API REST) e a implementação das interfaces em Flutter para integração ao backend existente.