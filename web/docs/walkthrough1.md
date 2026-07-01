# Walkthrough - Implementação da Fase 1: Correção de Segurança e Ajustes dos Testes

Este documento resume as melhorias técnicas de segurança e de confiabilidade de testes que foram implementadas com sucesso no **JurisLead CRM Web**.

---

## Alterações Realizadas

### 1. Backend: Correções de Segurança e Mutações
* **Correção de Escalação de Privilégios (Crítico):** A rota pública `/usuarios/cadastro` em [routes.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/routes.py#L222) foi blindada. O campo `role` enviado pelo cliente agora é explicitamente ignorado e qualquer nova conta criada recebe por padrão o papel `'user'`.
* **Proteção CSRF Customizada (Alto):** Implementamos em [__init__.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/__init__.py#L25) um mecanismo robusto de proteção CSRF integrado por sessão (sem dependências externas novas). Ele gera um token seguro em `session['csrf_token']` exposto para os templates Jinja e intercepta qualquer requisição de mutação (`POST`, `PUT`, `DELETE`, `PATCH`) no gancho `@app.before_request`. A validação é ignorada em ambiente de testes (`TESTING = True`) para preservar as chamadas de API da suíte.
* **Refinamento de Autorização (Alto):** A rota de conversão `/leads/<id>/convert` em [routes.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/routes.py#L617) foi restrita para aceitar apenas os papéis operacionais competentes (`admin`, `manager`, `advogado`, `atendente`), bloqueando acessos indevidos com `@roles_required`.
* **Políticas de Senha Robustas (Alto):** Substituímos o uso da senha padrão estática `'123456'` na criação automática de usuário durante a conversão do lead por uma senha aleatória e segura gerada dinamicamente com `secrets.token_urlsafe(16)`.
* **Prevenção de Vazamento de Exceções (Médio):** Removemos o retorno de stacks brutas com `str(exc)` nos endpoints de triagem de IA e notificações via WhatsApp. Agora, os erros são devidamente registrados no servidor via `current_app.logger.exception()` e o cliente recebe mensagens de erro genéricas seguras.

### 2. Frontend: Inclusão dos Tokens CSRF
Adicionamos o campo oculto `<input type="hidden" name="csrf_token" value="{{ csrf_token() }}">` em todos os 13 formulários HTML mutáveis da aplicação:
- [base.html](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/templates/base.html) (Logout)
- [landing.html](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/templates/landing.html) (Cadastro Público)
- [login.html](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/templates/login.html) (Entrar)
- [register.html](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/templates/register.html) (Registrar Usuário)
- [profile_edit.html](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/templates/profile_edit.html) (Editar Perfil)
- [user_edit.html](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/templates/user_edit.html) (Editar Usuário Admin)
- [leads_new.html](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/templates/leads_new.html) (Criar Lead)
- [lead_detail.html](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/templates/lead_detail.html) (Excluir Lead)
- [leads_list.html](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/templates/leads_list.html) (Excluir inline)
- [processo_detail.html](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/templates/processo_detail.html) (Adicionar Movimentação)
- [processos_list.html](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/templates/processos_list.html) (Criar Processo)
- [user_detail.html](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/templates/user_detail.html) (Ativar/Desativar)
- [users_list.html](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/app/templates/users_list.html) (Ações inline de Usuários)

### 3. Adaptação dos Testes Automatizados
* **Isolamento de Papéis:** Adaptamos as fixtures `auth_client` e `admin_client` em [conftest.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/tests/conftest.py) para simular o cadastro público e, em seguida, promover as contas diretamente no banco de dados SQLite de testes (`role='advogado'` e `role='admin'`).
* **Correção dos Testes de Registro:** Ajustamos todos os testes que registravam administradores ou gerentes em [test_users.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/tests/test_users.py) e [test_metrics.py](file:///c:/Users/andre/StudioProjects/juris-lead-desenvolvimento-web-pos-ifto.uab-2026-1/web/tests/test_metrics.py) para usar o contexto do banco de dados para a atribuição de papéis, respeitando a nova segurança.

---

## Verificação e Testes

### Execução dos Testes Automatizados
Configuramos um ambiente virtual Python (`.venv`) e executamos a suíte de testes do Pytest:

```bash
.venv/bin/python -m pytest -q
```

**Resultado Obtido:**
```text
..................................                                       [100%]
34 passed in 6.93s
```

Todos os 34 testes unitários e de integração estão passando com sucesso, validando que as correções de cibersegurança foram aplicadas sem quebrar nenhuma regra de negócio.
