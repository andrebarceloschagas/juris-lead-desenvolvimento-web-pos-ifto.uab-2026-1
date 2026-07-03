# Roteiro de Apresentação (Vídeo) - JurisLead CRM Mobile (Antonio)

## IFTO / UAB - Campus Araguatins

## Curso de Pós-Graduação Lato Sensu em Desenvolvimento de Sistemas Computacionais

## Disciplina: Desenvolvimento Mobile

## Aluno: Antonio André Barcelos Chagas

---

Este documento contém o roteiro completo de fala e as orientações visuais do aluno **Antonio André Barcelos Chagas** para a gravação individual do vídeo de apresentação do projeto **JurisLead CRM Mobile**.

---

### **Instruções de Gravação**
* **Duração sugerida:** 5 a 8 minutos.
* **Formato de gravação:** Captura de tela com a apresentação de slides (PDF), câmera do apresentador visível no canto da tela (PiP) e gravação de tela do emulador/celular durante a demonstração do app.
* **Postura:** Apresentação clara, objetiva, com tom acadêmico e profissional.

---

## **Slide a Slide: Roteiro Individual do Antonio**

### **Slide 1: Capa / Identificação**
* **Visual do Slide:** Título "JurisLead CRM Mobile - Sistema de CRM para Escritórios de Advocacia", logotipos do IFTO / UAB, identificação do curso de Pós-Graduação, disciplina de Desenvolvimento Mobile, professor Dr. Fábio Silveira Vidal e nomes dos autores (Antonio André Barcelos Chagas e Fabíola Gomes da Rocha).
* **Instrução de Vídeo:** Câmera aberta no apresentador ou PiP ativo.
* **Fala do Antonio:**
  > *"Olá a todos! Sejam muito bem-vindos. Meu nome é Antonio André Barcelos Chagas, sou aluno do curso de Pós-Graduação Lato Sensu em Desenvolvimento de Sistemas Computacionais pelo IFTO / UAB - Campus Araguatins. Vou apresentar o projeto final da disciplina de Desenvolvimento Mobile, ministrada pelo professor Doutor Fábio Silveira Vidal. O projeto chama-se **JurisLead CRM Mobile** e foi desenvolvido em parceria com a colega Fabíola Gomes da Rocha. Vamos iniciar contextualizando o problema que buscamos resolver."*

---

### **Slide 2: Contextualização do Problema**
* **Visual do Slide:** Imagem conceitual e texto explicativo sobre as dificuldades dos escritórios de advocacia (contatos dispersos, processos manuais, limitação ao uso de computadores fixos, atraso nas respostas e risco de perda de leads).
* **Instrução de Vídeo:** Exibição do slide com PiP da webcam ativa.
* **Fala do Antonio:**
  > *"Os escritórios de advocacia tradicionais frequentemente enfrentam dificuldades com contatos e solicitações que chegam de forma dispersa, seja por telefone, e-mail ou redes sociais. O registro manual desses leads costuma ser ineficiente. Além disso, a dependência de computadores fixos para gerenciar esses atendimentos atrasa as respostas da equipe. Isso provoca o 'esfriamento' de leads e a perda de valiosas oportunidades de atendimento jurídico. Identificamos, portanto, uma necessidade clara de trazer mobilidade e agilidade a essa rotina."*

---

### **Slide 3: Objetivos do Projeto**
* **Visual do Slide:** Lista de objetivos: Reduzir a perda de oportunidades jurídicas; Estrutura simples via mobile; Priorização de atendimentos; Eficiência operacional. Mockup do app ao lado com o menu de ações de um lead.
* **Instrução de Vídeo:** Foco no slide.
* **Fala do Antonio:**
  > *"Diante desse problema, o objetivo principal do JurisLead CRM Mobile é expandir as funcionalidades da plataforma web para o ambiente móvel, permitindo ao advogado e atendente gerenciar o ciclo de atendimento na palma da mão. Nossos objetivos específicos envolvem reduzir a perda de oportunidades de novos negócios, oferecer uma estrutura de registro de contatos simples e intuitiva, classificar e priorizar atendimentos em tempo real e garantir maior eficiência operacional com foco na mobilidade."*

---

### **Slide 4: Requisitos Funcionais (Parte 1)**
* **Visual do Slide:** Destaques para: Autenticação Segura (JWT), Gestão de Leads (Listagem, pesquisa, filtros e funil) e Triagem com IA.
* **Instrução de Vídeo:** Foco no slide.
* **Fala do Antonio:**
  > *"Para estruturar o escopo do aplicativo, dividimos as funcionalidades essenciais. Na primeira parte dos requisitos funcionais, temos o módulo de **Autenticação Segura**, com login protegido por token JWT para garantir que os dados sensíveis dos clientes estejam seguros. O segundo módulo é a **Gestão de Leads**, onde o advogado pode ver a listagem de contatos cadastrados, pesquisar e filtrar pelo status do funil, como Novo, Triado ou Convertido. E, por fim, a **Triagem com IA**, fornecendo uma interface para que o profissional ative a inteligência artificial para obter resumos operacionais automáticos."*

---

### **Slide 5: Requisitos Funcionais (Parte 2)**
* **Visual do Slide:** Detalhes dos módulos: Controle de Processos, Integração com WhatsApp e Dashboard/Administração (RBAC).
* **Instrução de Vídeo:** Foco no slide.
* **Fala do Antonio:**
  > *"Na segunda parte dos requisitos funcionais, contemplamos o **Controle de Processos**, que traz o histórico de andamento de casos e permite que a equipe registre movimentações diretamente pelo celular. Outro recurso é a **Integração com o WhatsApp**, permitindo o disparo ágil de lembretes e notificações de acompanhamento. E por fim, o módulo de **Dashboard e Administração**, que gerencia os perfis de usuários com diferentes níveis de permissão — Administrador, Atendente e Cliente — e exibe os principais indicadores de produtividade do escritório."*

---

### **Slide 6: Requisitos Não Funcionais**
* **Visual do Slide:** Tópicos: Desempenho (respostas rápidas), Segurança (HTTPS e dados cifrados), Usabilidade (padrões mobile), Acessibilidade (leitores de tela/contraste) e Responsividade. Mockup do app exibindo a tela "Meu Perfil" e modal de edição.
* **Instrução de Vídeo:** Foco no slide.
* **Fala do Antonio:**
  > *"Em relação aos Requisitos Não Funcionais, estabelecemos metas claras de qualidade. No quesito **Desempenho**, focamos em respostas rápidas e carregamento eficiente. Na **Segurança**, toda comunicação com o backend ocorre via HTTPS e o token de autenticação é gravado de forma cifrada no armazenamento seguro do aparelho. A **Usabilidade** segue os padrões do Material Design 3. A **Acessibilidade** garante suporte adequado a leitores de tela e contraste de cores, e a **Responsividade** assegura que o app se adapte perfeitamente a diferentes tamanhos de smartphones."*

---

### **Slide 7: Metodologia Empregada**
* **Visual do Slide:** Blocos conceituais: Arquitetura (REST e MVVM), Equipe (Multidisciplinar), Qualidade e CI/CD.
* **Instrução de Vídeo:** Foco no slide.
* **Fala do Antonio:**
  > *"A metodologia de desenvolvimento baseou-se em uma **Arquitetura Cliente-Servidor (API REST)**, em que o backend Flask expõe os endpoints de dados e o frontend em Flutter consome de forma assíncrona. Implementamos o padrão **MVVM** para organizar o código do app de forma limpa e manutenível. A equipe operou sob papéis multidisciplinares — Product Owner, Designer, Desenvolvedores, QA e DevOps. Nosso foco de qualidade envolveu testes de unidade, de widget e integração, além de um pipeline de CI/CD utilizando Docker para conteinerização."*

---

### **Slide 8: Ferramentas Empregadas**
* **Visual do Slide:** Tabela contendo as camadas (Frontend Mobile, Backend/API, Banco de Dados, Infraestrutura, IA, Integrações) e as respectivas tecnologias (Flutter, Flask, SQLite, Docker, Gemini, WhatsApp API, JWT).
* **Instrução de Vídeo:** Exibição da tabela.
* **Fala do Antonio:**
  > *"Utilizamos um conjunto moderno de ferramentas. Para o **Frontend Mobile**, adotamos a linguagem Dart com o framework Flutter no Android Studio. O **Backend** roda em Python 3 com o framework Flask. Para banco de dados, usamos SQLite com SQLAlchemy como ORM. A nossa infraestrutura conta com Docker e GitHub para versionamento. Para a Inteligência Artificial, consumimos a API do Google Gemini, e as integrações são feitas via WhatsApp Business API e JWT para sessões seguras."*

---

### **Slide 9: Benefícios da Aplicação de IA no Desenvolvimento**
* **Visual do Slide:** Textos sobre: Gemini CLI & Android Studio, Aceleração do Desenvolvimento e Triagem Jurídica Inteligente.
* **Instrução de Vídeo:** Foco no slide.
* **Fala do Antonio:**
  > *"No desenvolvimento, a Inteligência Artificial atuou como um co-piloto. A integração com o **Gemini CLI** e recursos de IA do Android Studio permitiram otimizar nosso código, refatorar trechos complexos, sugerir padrões de design e agilizar a criação de testes de unidade e widgets. Já na aplicação final, a IA traz o benefício de triar de forma automatizada o relato inicial do lead, estruturando um resumo jurídico inteligente que ajuda a equipe a poupar tempo valioso no primeiro atendimento."*

---

### **Slide 10: Dificuldades da Aplicação de IA no Desenvolvimento**
* **Visual do Slide:** Desafios: Ajuste de chaves/conexão, Custos de chamadas reais, Necessidade de revisão humana dos resumos, Conformidade com a LGPD e Limitações em cenários específicos.
* **Instrução de Vídeo:** Foco no slide.
* **Fala do Antonio:**
  > *"Por outro lado, também enfrentamos desafios no uso da IA. Tivemos dificuldades no ajuste de segurança e sincronização de chaves de API entre o Flutter e o backend Flask. Outros pontos de atenção são os custos associados às requisições em ambientes reais, a necessidade mandatória de revisão humana dos resumos gerados pela IA para evitar alucinações jurídicas, e o alinhamento total das informações tratadas com as regras rígidas da LGPD para proteção de dados sensíveis de clientes."*

---

### **Slide 11: Demonstração do Projeto**
* **Visual do Slide / Transição de Tela:** O apresentador minimiza os slides e projeta o emulador móvel rodando o aplicativo JurisLead CRM Mobile integrado com a API Flask ativa.
* **Instrução de Vídeo:** Gravação de tela do celular/emulador sendo manuseado com fluidez pelo apresentador.
* **Fala do Antonio:**
  > *"Vamos agora para a demonstração prática da aplicação. Como vocês podem ver na tela, ao realizarmos o login seguro no aplicativo, o Dashboard mobile carrega em tempo real do nosso backend em Flask as métricas operacionais do escritório: o número total de leads, consultas agendadas e processos ativos. 
  > 
  > Ao navegar na aba de **Leads**, o Flutter faz uma chamada HTTP autenticada com token JWT e exibe a lista. Podemos fazer pesquisas rápidas e filtrar por status. Clicando em um lead específico, visualizamos seus detalhes e as opções para 'Iniciar Triagem IA', 'Agendar Consulta', 'Abrir Processo' ou iniciar contato via WhatsApp. 
  > 
  > Na aba de **Processos**, o sistema lista os casos ativos. Para demonstrar a usabilidade, reparem na fluidez do toque na tela: ao clicar em qualquer item da lista, a interface exibe o efeito visual de splash tátil (ripple) do Material Design, fornecendo feedback claro e instantâneo ao usuário. Também tratamos de forma consistente qualquer dado ausente vindo do backend, exibindo formatações amigáveis no padrão do pacote `intl` para evitar quebras de layout."*

---

### **Slide 12: Considerações Finais**
* **Visual do Slide:** Textos conclusivos: JurisLead CRM Mobile representa uma solução completa, unindo mobilidade e IA; Transição de monolito web para cliente-servidor multiplataforma garante eficiência e segurança.
* **Instrução de Vídeo:** Foco no slide.
* **Fala do Antonio:**
  > *"Como considerações finais, a transição da arquitetura anterior para o ecossistema cliente-servidor multiplataforma com Flutter e Flask se mostrou altamente eficaz. O JurisLead CRM Mobile cumpre seu propósito de modernizar a gestão de contatos jurídicos, combinando a flexibilidade e portabilidade de um aplicativo nativo para celular com o processamento inteligente auxiliado por inteligência artificial, garantindo segurança e usabilidade."*

---

### **Slide 13: Trabalhos Futuros**
* **Visual do Slide:** Tópicos: Funcionalidades offline, Chat em tempo real, IA preditiva de casos, Integração com tribunais, Assinatura digital, Painel de BI, etc.
* **Instrução de Vídeo:** Foco no slide.
* **Fala do Antonio:**
  > *"Em termos de trabalhos futuros, pretendemos estender o sistema implementando suporte offline com sincronização automática em segundo plano, desenvolvimento de chat interno integrado via WebSockets, recursos de IA preditiva para análise de jurisprudências, integração automática com os principais sistemas judiciais como o PJe e módulo de assinatura digital nativo para procurações e contratos diretamente no app."*

---

### **Slide 14: Encerramento / Agradecimentos**
* **Visual do Slide:** Frase "Obrigado pela Atenção!" com tela final estilizada do aplicativo.
* **Instrução de Vídeo:** Câmera aberta no apresentador.
* **Fala do Antonio:**
  > *"Concluo aqui a apresentação do JurisLead CRM Mobile. Agradeço a atenção de todos, ao professor doutor Fábio Silveira Vidal pelo direcionamento na disciplina, e ao IFTO / UAB por proporcionar essa formação. Muito obrigado!"*
