# Roteiro de Apresentação (Vídeo) - JurisLead CRM Mobile (Fabíola)

## IFTO / UAB - Campus Araguatins

## Curso de Pós-Graduação Lato Sensu em Desenvolvimento de Sistemas Computacionais

## Disciplina: Desenvolvimento Mobile

## Aluna: Fabíola Gomes da Rocha

---

Este documento contém o roteiro completo de fala e as orientações visuais da aluna **Fabíola Gomes da Rocha** para a gravação individual do vídeo de apresentação do projeto **JurisLead CRM Mobile**.

---

### **Instruções de Gravação**
* **Duração sugerida:** 5 a 8 minutos.
* **Formato de gravação:** Captura de tela com a apresentação de slides (PDF), câmera da apresentadora visível no canto da tela (PiP) e gravação de tela do emulador/celular durante a demonstração do app.
* **Postura:** Apresentação clara, objetiva, com tom acadêmico e profissional.

---

## **Slide a Slide: Roteiro Individual da Fabíola**

### **Slide 1: Capa / Identificação**
* **Visual do Slide:** Título "JurisLead CRM Mobile - Sistema de CRM para Escritórios de Advocacia", logotipos do IFTO / UAB, identificação do curso de Pós-Graduação, disciplina de Desenvolvimento Mobile, professor Dr. Fábio Silveira Vidal e nomes dos autores (Antonio André Barcelos Chagas e Fabíola Gomes da Rocha).
* **Instrução de Vídeo:** Câmera aberta na apresentadora ou PiP ativo.
* **Fala da Fabíola:**
  > *"Olá a todos! Sejam muito bem-vindos. Meu nome é Fabíola Gomes da Rocha e sou aluna do curso de Pós-Graduação Lato Sensu em Desenvolvimento de Sistemas Computacionais pelo IFTO / UAB - Campus Araguatins. Irei apresentar o projeto final desenvolvido para a disciplina de Desenvolvimento Mobile, ministrada pelo professor Doutor Fábio Silveira Vidal. O projeto chama-se **JurisLead CRM Mobile** e foi desenvolvido por mim em conjunto com o colega de grupo Antonio André Barcelos Chagas. Vamos iniciar abordando a contextualização do problema."*

---

### **Slide 2: Contextualização do Problema**
* **Visual do Slide:** Imagem conceitual e texto explicativo sobre as dificuldades dos escritórios de advocacia (contatos dispersos, processos manuais, limitação ao uso de computadores fixos, atraso nas respostas e risco de perda de leads).
* **Instrução de Vídeo:** Exibição do slide com PiP da webcam ativa.
* **Fala da Fabíola:**
  > *"Muitos escritórios de advocacia tradicionais sofrem com a desorganização ao lidar com dados e contatos de clientes que chegam dispersos por diversos meios, como e-mails e redes sociais. O registro manual desses leads cria falhas operacionais. A limitação física de gerenciar essas informações apenas por computadores de mesa atrasa a velocidade de resposta aos clientes. Como consequência, ocorre o 'esfriamento' dos leads e a perda de oportunidades comerciais valiosas. Identificamos aí uma necessidade crucial de mobilidade e agilidade."*

---

### **Slide 3: Objetivos do Projeto**
* **Visual do Slide:** Lista de objetivos: Reduzir a perda de oportunidades jurídicas; Estrutura simples via mobile; Priorização de atendimentos; Eficiência operacional. Mockup do app ao lado com o menu de ações de um lead.
* **Instrução de Vídeo:** Foco no slide.
* **Fala da Fabíola:**
  > *"Para solucionar este cenário, o objetivo geral do JurisLead CRM Mobile é expandir a nossa plataforma de CRM jurídico para o ecossistema móvel. Isso permite que advogados e atendentes acessem as informações essenciais de qualquer lugar. Como objetivos específicos, buscamos minimizar a perda de leads, fornecer um fluxo simples de entrada de dados no smartphone, dar maior clareza na priorização de consultas e atendimentos de urgência, e maximizar a eficiência operacional do escritório por meio de soluções digitais móveis."*

---

### **Slide 4: Requisitos Funcionais (Parte 1)**
* **Visual do Slide:** Destaques para: Autenticação Segura (JWT), Gestão de Leads (Listagem, pesquisa, filtros e funil) e Triagem com IA.
* **Instrução de Vídeo:** Foco no slide.
* **Fala da Fabíola:**
  > *"Em termos de Requisitos Funcionais, o escopo foi planejado em módulos. A primeira parte engloba: o módulo de **Autenticação Segura**, com autenticação via e-mail/senha e proteção por token JWT que mantém sessões ativas com segurança; o módulo de **Gestão de Leads**, que permite listar e filtrar os leads conforme seu progresso (Novos, Triados ou Convertidos); e o recurso de **Triagem por IA**, que possibilita solicitar análises sintéticas inteligentes dos relatos enviados pelos clientes."*

---

### **Slide 5: Requisitos Funcionais (Parte 2)**
* **Visual do Slide:** Detalhes dos módulos: Controle de Processos, Integração com WhatsApp e Dashboard/Administração (RBAC).
* **Instrução de Vídeo:** Foco no slide.
* **Fala da Fabíola:**
  > *"A segunda parte dos requisitos funcionais foca no fluxo diário do advogado: o **Controle de Processos**, que exibe o histórico de movimentações processuais de cada cliente; a **Integração com WhatsApp** para envio ágil de lembretes e mensagens pré-formatadas; e o módulo de **Dashboard e Administração**, que implementa a separação lógica de permissões baseada em perfis (Administrador, Atendente e Cliente) e consolida os indicadores gerenciais em telas adaptadas para celular."*

---

### **Slide 6: Requisitos Não Funcionais**
* **Visual do Slide:** Tópicos: Desempenho (respostas rápidas), Segurança (HTTPS e dados cifrados), Usabilidade (padrões mobile), Acessibilidade (leitores de tela/contraste) e Responsividade. Mockup do app exibindo a tela "Meu Perfil" e modal de edição.
* **Instrução de Vídeo:** Foco no slide.
* **Fala da Fabíola:**
  > *"Definimos também os Requisitos Não Funcionais primordiais para a qualidade da aplicação. O **Desempenho** foi projetado para carregamentos rápidos com a API. A **Segurança** assegura conexões cifradas via HTTPS e armazenamento protegido dos tokens JWT no próprio telefone. A **Usabilidade** baseia-se nas diretrizes do Material Design da Google, enquanto a **Acessibilidade** garante contraste adequado e compatibilidade com leitores de tela. Por fim, a **Responsividade** ajusta as telas de forma fluida a qualquer tamanho de smartphone."*

---

### **Slide 7: Metodologia Empregada**
* **Visual do Slide:** Blocos conceituais: Arquitetura (REST e MVVM), Equipe (Multidisciplinar), Qualidade e CI/CD.
* **Instrução de Vídeo:** Foco no slide.
* **Fala da Fabíola:**
  > *"Nossa metodologia envolveu uma transição arquitetural para o padrão **Cliente-Servidor baseado em API REST**. No aplicativo móvel, adotamos a arquitetura **MVVM** (Model-View-ViewModel), isolando a lógica de negócio e o estado da aplicação da camada visual. Simulamos o fluxo de uma equipe multidisciplinar (PO, Designer, Desenvolvedores, QA e DevOps) com responsabilidades bem mapeadas. Nosso controle de qualidade engloba rodadas de testes automatizados e implantação através de uma esteira CI/CD conteinerizada com Docker."*

---

### **Slide 8: Ferramentas Empregadas**
* **Visual do Slide:** Tabela contendo as camadas (Frontend Mobile, Backend/API, Banco de Dados, Infraestrutura, IA, Integrações) e as respectivas tecnologias (Flutter, Flask, SQLite, Docker, Gemini, WhatsApp API, JWT).
* **Instrução de Vídeo:** Exibição da tabela.
* **Fala da Fabíola:**
  > *"A nossa tabela de tecnologias apresenta escolhas consolidadas do mercado: no **Frontend Mobile**, usamos Dart e Flutter para compilação multiplataforma; no **Backend/API**, implementamos Python com Flask; para persistência local, o banco SQLite estruturado com ORM SQLAlchemy; na **Infraestrutura**, Docker e GitHub; no suporte a inteligência artificial, consumimos a API do Google Gemini; e, para **Integrações**, aplicamos a API do WhatsApp Business e tokens JWT."*

---

### **Slide 9: Benefícios da Aplicação de IA no Desenvolvimento**
* **Visual do Slide:** Textos sobre: Gemini CLI & Android Studio, Aceleração do Desenvolvimento e Triagem Jurídica Inteligente.
* **Instrução de Vídeo:** Foco no slide.
* **Fala da Fabíola:**
  > *"A Inteligência Artificial desempenhou um papel central. Em termos de produtividade no desenvolvimento, a integração com o **Gemini CLI** no Android Studio facilitou a refatoração, a aplicação de boas práticas de design e a geração ágil de testes unitários e de UI. No produto final para o usuário, o grande benefício é a **Triagem Jurídica Inteligente**, onde o Gemini sintetiza as demandas dos leads, permitindo ao escritório priorizar e classificar atendimentos rapidamente."*

---

### **Slide 10: Dificuldades da Aplicação de IA no Desenvolvimento**
* **Visual do Slide:** Desafios: Ajuste de chaves/conexão, Custos de chamadas reais, Necessidade de revisão humana dos resumos, Conformidade com a LGPD e Limitações em cenários específicos.
* **Instrução de Vídeo:** Foco no slide.
* **Fala da Fabíola:**
  > *"Também enfrentamos alguns obstáculos operacionais no uso de IA. Gerenciar as chaves de API com segurança e lidar com a necessidade de uma conexão constante para chamadas de IA foram os primeiros desafios. Além disso, consideramos o custo financeiro das chamadas em produção, a obrigação ética de manter uma revisão humana sobre os resumos (evitando erros de preenchimento automatizado) e a conformidade legal para que o tratamento desses dados sensíveis de clientes esteja de acordo com as regras da LGPD."*

---

### **Slide 11: Demonstração do Projeto**
* **Visual do Slide / Transição de Tela:** A apresentadora minimiza os slides e projeta o emulador móvel rodando o aplicativo JurisLead CRM Mobile integrado com a API Flask ativa.
* **Instrução de Vídeo:** Gravação de tela do celular/emulador sendo manuseado de forma fluida pela apresentadora.
* **Fala da Fabíola:**
  > *"Passando para a demonstração prática do nosso projeto, reparem na tela de login. Após realizar o acesso seguro, as métricas dinâmicas do Dashboard carregam rapidamente a partir do banco de dados persistido no nosso servidor Flask. 
  > 
  > Ao abrirmos a lista de **Leads**, o aplicativo executa a chamada HTTP autorizada via JWT. O usuário pode realizar pesquisas e aplicar filtros de status. Ao clicar em um lead, o app exibe a tela detalhada e as opções rápidas para acionar a Triagem IA, marcar uma consulta, abrir processo ou enviar mensagem nativa pelo WhatsApp. 
  > 
  > Na aba **Processos**, o sistema mostra os processos vinculados. Do ponto de vista de usabilidade e interface móvel, gostaria de destacar os detalhes de polimento visual: ao tocar em qualquer item das listas, temos a animação de splash tátil (efeito ripple) do Material Design funcionando perfeitamente sobre os cards coloridos. Além disso, as informações de datas e campos nulos retornados pela API são inteiramente tratados na camada de ViewModel com auxílio do pacote `intl`, mantendo a consistência visual e a estabilidade do app."*

---

### **Slide 12: Considerações Finais**
* **Visual do Slide:** Textos conclusivos: JurisLead CRM Mobile representa uma solução completa, unindo mobilidade e IA; Transição de monolito web para cliente-servidor multiplataforma garante eficiência e segurança.
* **Instrução de Vídeo:** Foco no slide.
* **Fala da Fabíola:**
  > *"Em conclusão, a transição da antiga arquitetura web monolítica para este ecossistema integrado com API REST, Flutter e Flask atende com excelência os objetivos de produtividade do projeto. O JurisLead CRM Mobile oferece aos profissionais do direito uma ferramenta moderna e focada em usabilidade, que otimiza a conversão de novos clientes mantendo a segurança e o controle dos dados."*

---

### **Slide 13: Trabalhos Futuros**
* **Visual do Slide:** Tópicos: Funcionalidades offline, Chat em tempo real, IA preditiva de casos, Integração com tribunais, Assinatura digital, Painel de BI, etc.
* **Instrução de Vídeo:** Foco no slide.
* **Fala da Fabíola:**
  > *"Como perspectivas de trabalhos futuros, pretendemos desenvolver suporte a banco de dados local para uso offline com sincronização inteligente posterior, implementar chat interno via WebSockets, IA preditiva para chances de sucesso com base em jurisprudências, integração automática com os portais de tribunais de justiça e a geração automática de contratos com assinatura digital no aplicativo."*

---

### **Slide 14: Encerramento / Agradecimentos**
* **Visual do Slide:** Frase "Obrigado pela Atenção!" com tela final estilizada do aplicativo.
* **Instrução de Vídeo:** Câmera aberta na apresentadora.
* **Fala da Fabíola:**
  > *"Agradeço a todos pela atenção ao longo desta apresentação, ao professor orientador doutor Fábio Silveira Vidal, e ao IFTO / UAB pela oportunidade de desenvolvimento deste projeto. Muito obrigada!"*
