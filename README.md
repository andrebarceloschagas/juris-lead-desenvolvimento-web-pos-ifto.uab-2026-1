# JurisLead CRM

## IFTO / UAB - Campus Araguatins

## Curso de Pós-Graduação Lato Sensu em Desenvolvimento de Sistemas Computacionais

## Disciplina: Desenvolvimento Web

## Alunos: Antonio André Barcelos Chagas e Fabíola Gomes da Rocha

JurisLead CRM é um projeto de plataforma web para escritórios de advocacia focada em captação de leads, triagem com IA, gestão de agenda, controle de processos e automação de follow-ups por WhatsApp.

Principais características:

- Landing page para captação de leads
- Chat inicial com IA para triagem
- Cadastro de clientes e leads
- Agenda de consultas
- Controle de processos jurídicos
- Follow-up automático via WhatsApp
- Painel de métricas e administração de usuários

Tecnologias previstas:

- Python 3
- Flask (MVC)
- SQLAlchemy + SQLite
- Jinja2 + Bootstrap 5
- Integrações: APIs de IA e WhatsApp
- Tarefas agendadas: APScheduler ou Celery

Estrutura sugerida do projeto:

```text
jurislead_crm/
├── docs/
│   ├── especificacoes-projeto-jurislead-crm.md
│   └── descricao-projeto-jurislead-crm.md
├── app/
│   ├── __init__.py
│   ├── models.py
│   ├── routes.py
│   ├── services/
│   │   ├── ia_service.py
│   │   └── whatsapp_service.py
│   ├── templates/
│   └── static/
├── tests/
│   ├── test_lead.py
│   ├── test_ia_triage.py
│   ├── test_agenda.py
│   ├── test_processos.py
|	└── test_whatsapp.py
├── config.py
├── requirements.txt
├── .env
└── run.py
```

Como rodar (desenvolvimento):

1. Criar virtualenv e ativar:

```bash
python3 -m venv venv
source venv/bin/activate
```

1. Instalar dependências:

```bash
pip install -r requirements.txt
```

1. Exportar variáveis de ambiente (exemplo):

```bash
export FLASK_APP=run.py
export FLASK_ENV=development
export SECRET_KEY="sua_chave"
```

1. Executar a aplicação:

```bash
flask run
# ou
python run.py
```

Documentação do projeto e especificações completas estão em [docs/descricao-projeto-jurislead-crm.md](docs/descricao-projeto-jurislead-crm.md) e [docs/especificacoes-projeto-jurislead-crm.md](docs/especificacoes-projeto-jurislead-crm.md).

Documentação da API e exemplos de uso:

- Endpoints: [docs/api-endpoints.md](docs/api-endpoints.md)
- Exemplos em cURL: [docs/api-curl-examples.md](docs/api-curl-examples.md)
 - Postman collection: [docs/postman-collection.json](docs/postman-collection.json)

### Importar a Postman collection

Você pode importar a collection gerada de duas maneiras:

- Pelo app Postman (interface): `File` → `Import` → selecione o arquivo [docs/postman-collection.json](docs/postman-collection.json).

- Pela CLI (executar com Newman):

```bash
# instalar newman (se necessário)
npm install -g newman

# executar a collection apontando para a URL base
newman run docs/postman-collection.json --env-var "base_url=http://localhost:5000"
```

## Testes automatizados

Para executar a suíte de testes automatizados (recomenda-se usar o virtualenv acima):

```bash
.venv/bin/python -m pytest -q
```

Para ver relatório de cobertura:

```bash
.venv/bin/python -m pytest --cov=app --cov-report=term-missing
```
