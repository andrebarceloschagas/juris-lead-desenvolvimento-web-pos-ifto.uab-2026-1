# Inspeção de Cibersegurança - JurisLead CRM

## IFTO / UAB - Campus Araguatins

## Curso de Pós-Graduação Lato Sensu em Desenvolvimento de Sistemas Computacionais

## Disciplina: Desenvolvimento Web

## Alunos: Antonio André Barcelos Chagas e Fabíola Gomes da Rocha


Escopo: revisão moderada do backend Flask, das rotas HTTP, dos modelos, dos serviços externos e dos templates mais expostos.

## Resumo executivo

Foram encontrados 6 achados com impacto relevante em OWASP Top 10, sendo 1 crítico, 4 altos e 1 médio. Não houve evidência direta de SQL injection clássico nas rotas revisadas, porque o acesso ao banco está majoritariamente mediado por ORM, nem de XSS refletido ou armazenado nas páginas analisadas, porque o Jinja2 está sendo usado sem uso aparente de filtros perigosos como escape desativado. Mesmo assim, a superfície do sistema ainda possui falhas graves de autenticação, autorização, configuração segura e proteção contra CSRF.

Contagem por severidade:

- Crítica: 1
- Alta: 4
- Média: 1
- Baixa: 0

### 5 ações mais urgentes

1. Remover a elevação de privilégio no cadastro público e fixar o papel do usuário recém-criado como usuário comum.
2. Substituir o segredo padrão, desativar debug fora do ambiente local e endurecer cookies e transporte.
3. Remover a senha padrão 123456 do fluxo de conversão de lead e trocar por convite ou redefinição de senha.
4. Implementar CSRF em todos os formulários e mutações por POST, inclusive nos fluxos JSON/AJAX.
5. Parar de retornar detalhes internos de exceção para o cliente e registrar apenas no servidor.

## Achados detalhados

### 1. Escalação de privilégios no cadastro público

Severidade: crítica

OWASP Top 10: A01 Broken Access Control, A07 Authentication Failures

Referências CWE: CWE-266 Incorrect Privilege Assignment, CWE-285 Improper Authorization

Localização:

- [app/routes.py](../app/routes.py#L199), função register

Descrição do problema:

O endpoint público de cadastro aceita o campo role vindo do cliente e o grava sem validação. Isso permite que um atacante envie role=admin ou outro papel privilegiado no payload de registro e crie uma conta com privilégios indevidos.

Evidência:

    user = User(name=name, email=email, bio=data.get('bio'), role=data.get('role') or 'user')

Impacto potencial:

- Criação de contas privilegiadas sem autorização.
- Comprometimento total da aplicação por escalada de privilégios.
- Acesso indevido a rotas administrativas, métricas, usuários e dados sensíveis.

Recomendação de correção:

- Ignorar role em cadastro público e forçar role='user'.
- Permitir mudança de papel somente em rota administrativa explícita, com whitelist de valores aceitos.
- Validar o papel em servidor antes de persistir.

Exemplo de correção:

    allowed_roles = {'user'}
    role = 'user'
    user = User(name=name, email=email, bio=data.get('bio'), role=role)

### 2. Configuração insegura de bootstrap e segredo padrão fraco

Severidade: alta

OWASP Top 10: A02 Security Misconfiguration, A04 Cryptographic Failures

Referências CWE: CWE-321 Use of Hard-coded Cryptographic Key, CWE-489 Active Debug Code

Localização:

- [config.py](../config.py#L8), classe Config
- [run.py](../run.py#L8), bloco principal

Descrição do problema:

O segredo da aplicação usa o valor padrão dev quando a variável de ambiente não existe, e o entrypoint sempre sobe com debug=True. Em um deploy mal configurado, isso abre espaço para comprometimento de sessão, exposição de stack traces e, dependendo do contexto de execução, abuso do debugger.

Evidência:

    SECRET_KEY = os.getenv('SECRET_KEY', 'dev')
    app.run(debug=True)

Impacto potencial:

- Assinatura fraca de sessão e risco de manipulação de cookies.
- Vazamento de detalhes internos em exceções.
- Aumento da superfície de ataque em ambiente exposto à rede.

Recomendação de correção:

- Exigir SECRET_KEY forte e aleatória fora do código-fonte.
- Desativar debug por padrão e habilitar apenas em ambiente local controlado.
- Definir cookies seguros na configuração de produção:

    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_SAMESITE = 'Lax'
    PREFERRED_URL_SCHEME = 'https'

### 3. Falta de autorização fina no fluxo de conversão de lead

Severidade: alta

OWASP Top 10: A01 Broken Access Control, A06 Insecure Design

Referências CWE: CWE-862 Missing Authorization, CWE-285 Improper Authorization

Localização:

- [app/routes.py](../app/routes.py#L618), função convert_lead

Descrição do problema:

O endpoint de conversão está protegido apenas por login_required. Como o sistema possui papéis distintos e já usa roles_required em outras rotas, qualquer usuário autenticado pode converter lead, criar cliente e até criar usuário vinculado ao cliente, mesmo sem perfil operacional adequado.

Evidência:

    @bp.route('/leads/<int:lead_id>/convert', methods=['POST'])
    @login_required
    def convert_lead(lead_id):

Impacto potencial:

- Usuários comuns podem alterar o ciclo de vida de leads.
- Criação indevida de clientes e contas associadas.
- Violação de segregação de funções entre perfis do sistema.

Recomendação de correção:

- Proteger a rota com roles_required('admin', 'manager', 'advogado', 'atendente') ou com a política exata definida pela especificação.
- Aplicar a mesma regra em rotas de mutação correlatas que hoje dependem apenas de login.

### 4. Senha padrão fraca ao converter lead em usuário

Severidade: alta

OWASP Top 10: A07 Authentication Failures, A06 Insecure Design

Referências CWE: CWE-798 Use of Hard-coded Credentials, CWE-521 Weak Password Requirements

Localização:

- [app/routes.py](../app/routes.py#L641), função convert_lead

Descrição do problema:

Quando create_user está habilitado, o sistema cria um usuário com a senha literal 123456. Isso gera credenciais previsíveis e cria uma conta que pode ser descoberta ou abusada imediatamente.

Evidência:

    new_user.set_password('123456')

Impacto potencial:

- Comprometimento imediato da conta criada.
- Possibilidade de acesso não autorizado ao perfil do cliente.
- Quebra do fluxo de autenticação e onboarding seguro.

Recomendação de correção:

- Gerar convite com token temporário e exigir redefinição de senha no primeiro acesso.
- Se precisar de senha provisória, gerar valor aleatório de alta entropia e expirar após o primeiro login.

Exemplo de correção:

    temporary_password = secrets.token_urlsafe(24)
    new_user.set_password(temporary_password)

### 5. Vazamento de detalhes internos em falhas de integração

Severidade: média

OWASP Top 10: A09 Security Logging and Alerting Failures, A10 Mishandling of Exceptional Conditions

Referências CWE: CWE-209 Generation of Error Message Containing Sensitive Information

Localização:

- [app/routes.py](../app/routes.py#L593), função lead_triage
- [app/routes.py](../app/routes.py#L781), função notify_consulta_whatsapp

Descrição do problema:

As rotas de falha de IA e WhatsApp retornam str(exc) diretamente ao cliente. Isso pode expor nomes internos de serviços, endpoints, mensagens de stack e outros detalhes que facilitam reconhecimento e exploração.

Evidência:

    return jsonify({'error': 'ai_service_failure', 'detail': str(exc)}), 502
    return jsonify({'error': 'whatsapp_service_failure', 'detail': str(exc)}), 502

Impacto potencial:

- Vazamento de detalhes internos da aplicação e de integrações.
- Auxílio para enumeração de endpoints e engenharia de ataque.
- Exposição de dados sensíveis em mensagens de erro.

Recomendação de correção:

- Retornar mensagem genérica ao cliente.
- Registrar o erro completo apenas no lado do servidor com logger.exception.
- Evitar propagação de exceções externas em payloads HTTP.

Exemplo de correção:

    except Exception:
        app.logger.exception('Falha na triagem do lead')
        return jsonify({'error': 'ai_service_failure'}), 502

### 6. Ausência de proteção CSRF nos formulários e mutações por POST

Severidade: alta

OWASP Top 10: A01 Broken Access Control

Referências CWE: CWE-352 Cross-Site Request Forgery

Localização:

- [app/templates/register.html](../app/templates/register.html#L4), formulário de cadastro
- [app/templates/login.html](../app/templates/login.html#L4), formulário de login
- [app/templates/base.html](../app/templates/base.html#L37), formulário de logout
- [app/routes.py](../app/routes.py#L1), conjunto de rotas POST sem proteção CSRF explícita

Descrição do problema:

Os formulários HTML mutáveis não exibem token CSRF, e não foi encontrada integração com Flask-WTF nem outra proteção equivalente para os endpoints POST. Em uma aplicação baseada em cookie de sessão, isso abre caminho para requisições forjadas pelo navegador da vítima.

Evidência:

    <form method="post" action="/usuarios/cadastro" class="ajax">
    <form method="post" action="/entrar" class="ajax">
    <form method="post" action="/sair" class="d-inline form-logout ajax">

Impacto potencial:

- Execução involuntária de ações autenticadas pela vítima.
- Alteração de dados, criação de registros e disparo de operações sensíveis.
- Aumento do impacto de qualquer XSS ou clique malicioso em páginas externas.

Recomendação de correção:

- Adotar CSRF em todos os formulários e endpoints de mutação.
- Para Flask, usar Flask-WTF ou um middleware próprio com token assinado por sessão.
- Exigir o token também nos fluxos AJAX/JSON.

Exemplo de correção:

    <input type="hidden" name="csrf_token" value="{{ csrf_token() }}">

## Observações finais

O relatório foca nos pontos com impacto mais plausível e com evidência direta no código. As áreas de maior risco hoje são autorização, autenticação, configuração segura e proteção contra CSRF. Antes de qualquer exposição pública, é recomendado corrigir os itens críticos e altos e depois adicionar verificações automáticas para evitar regressão.