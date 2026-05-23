# Refatoração e Otimização — Registro de Mudanças

## IFTO / UAB - Campus Araguatins

## Curso de Pós-Graduação Lato Sensu em Desenvolvimento de Sistemas Computacionais

## Disciplina: Desenvolvimento Web

## Alunos: Antonio André Barcelos Chagas e Fabíola Gomes da Rocha

Data: 23 de maio de 2026

Resumo
-------
Este documento descreve, de forma sucinta e rastreável, as mudanças realizadas na etapa de refatoração e otimização do projeto JurisLead CRM. As alterações mantêm a arquitetura monolítica e a compatibilidade com as especificações presentes em `docs/especificacoes-projeto-jurislead-crm.md`.

Principais mudanças
-------------------
- **Modelos**
  - [app/models.py](app/models.py): adição do campo `documento` ao model `Lead` (unicidade opcional) e criação do novo model `Cliente` vinculado ao `Lead` original. Objetivo: suportar o fluxo "conversão de lead → cliente" e preservar histórico.

- **Rotas / API**
  - [app/routes.py](app/routes.py): validação de duplicidade em `POST /leads` e na captura pública (`public_capture_lead`) retornando `409 Conflict` em caso de `email` ou `documento` já existentes.
  - Adicionado endpoint `POST /leads/<id>/convert` que cria o registro em `Cliente`, atualiza o `Lead` para `status='converted'` e, opcionalmente, cria uma conta de `User` com role `cliente` (quando solicitado via payload `create_user`).

- **Jobs / Agendamento**
  - [app/__init__.py](app/__init__.py): integração e inicialização do `APScheduler` (BackgroundScheduler), com desligamento controlado via `atexit`.
  - [app/services/tasks.py](app/services/tasks.py): novo módulo contendo o registro de jobs (placeholder `check_upcoming_consultas`) e a função `register_jobs()` que é chamada na inicialização da app.

- **Testes**
  - [tests/test_lead.py](tests/test_lead.py): inclusão de casos de teste para prevenção de duplicidade (`email` e `documento`) e preservação de validações existentes.
  - [tests/test_clientes.py](tests/test_clientes.py): novo arquivo com o teste de conversão `TST-CLI-01` (conversão de `Lead` para `Cliente` e criação de `User` com role `cliente`).
  - Resultado: suíte executada localmente com o comando abaixo e todos os testes passando (34 passed).

- **Documentação**
  - [docs/testes-projeto-jurislead-crm.md](docs/testes-projeto-jurislead-crm.md): atualização para refletir os novos cenários `TST-CLI-01` e `TST-CLI-02` e seus arquivos de teste correspondentes.
  - [README.md](README.md): pequena atualização para registrar que o `APScheduler` está configurado e o módulo de conversão de leads foi adicionado.

Comandos usados para verificação
--------------------------------
Para rodar a suíte de testes localmente (virtualenv):

```bash
.venv/bin/python -m pytest -q
```

Exemplo de saída obtida durante a verificação:

```
34 passed in 4.55s
```

Racional e notas de implementação
---------------------------------
- As mudanças foram propostas para fechar gaps descritos em `docs/especificacoes-projeto-jurislead-crm.md`, sem introduzir novas abstrações arquiteturais. O `APScheduler` foi escolhido por manter o projeto simples e de fácil implantação (alinhado ao escopo monolítico).

- A conversão `Lead → Cliente` preserva o vínculo histórico (campo `lead_id` em `Cliente`) e opcionalmente gera uma conta `User` com role `cliente`. A senha inicial é temporária (placeholder) e recomenda-se fluxo de `esqueci a senha` para o cliente assumir acesso real.

- A checagem de duplicidade é aplicada no momento de criação do `Lead` tanto via rota autenticada (`POST /leads`) quanto via captura pública (`public_capture_lead`). A verificação considera `email` e `documento` conforme requisito.

Próximos passos recomendados
---------------------------
- Normalizar e validar formatos de `documento` (CPF/CNPJ) no momento da inserção.
- Substituir a senha placeholder por fluxo seguro de invite/recuperação de senha.
- Expandir os jobs do `APScheduler` para enviar lembretes X horas antes da `Consulta` (configurável) e registrar logs/auditoria dos envios via `app/services/whatsapp_service.py`.
- Implementar políticas de acesso mais restritas para que `Cliente` acesse apenas seus próprios dados via autenticação.

Arquivos alterados (resumo rápido)
----------------------------------
- app/models.py
- app/routes.py
- app/__init__.py
- app/services/tasks.py (novo)
- tests/test_lead.py (modificado)
- tests/test_clientes.py (novo)
- docs/testes-projeto-jurislead-crm.md (modificado)
- README.md (modificado)
