## IFTO / UAB - Campus Araguatins

## Curso de Pós-Graduação Lato Sensu em Desenvolvimento de Sistemas Computacionais

## Disciplina: Desenvolvimento Web

## Alunos: Antonio André Barcelos Chagas e Fabíola Gomes da Rocha

## JurisLead CRM

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

```
jurislead_crm/
├── docs/
│   ├── especificacoes-projeto-jurislead-crm.md
│   └── descricao-projeto-jurislead-crm.md
├── app/
│   ├── __init__.py
│   ├── models.py
│   ├── routes.py
│   ├── services/
│   ├── templates/
│   └── static/
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

2. Instalar dependências:

```bash
pip install -r requirements.txt
```

3. Exportar variáveis de ambiente (exemplo):

```bash
export FLASK_APP=run.py
export FLASK_ENV=development
export SECRET_KEY="sua_chave"
```

4. Executar a aplicação:

```bash
flask run
# ou
python run.py
```

Documentação do projeto e especificações completas estão em [docs/descricao-projeto-jurislead-crm.md](docs/descricao-projeto-jurislead-crm.md) e [docs/especificacoes-projeto-jurislead-crm.md](docs/especificacoes-projeto-jurislead-crm.md).

Se quiser, posso também criar um `requirements.txt` mínimo e um `run.py` de exemplo para iniciar rapidamente.
