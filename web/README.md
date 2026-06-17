# JurisLead CRM - Backend & Web Interface

Este diretório contém o coração do ecossistema JurisLead: o servidor Backend (API REST) e a interface administrativa Web.

## 🛠️ Tecnologias
- **Framework:** [Flask](https://flask.palletsprojects.com/) (Python 3)
- **Banco de Dados:** SQLite (Desenvolvimento) / SQLAlchemy (ORM)
- **Segurança:** Flask-Login (Sessões Web) e em breve JWT (API Mobile)
- **Frontend Web:** Jinja2 Templates & Bootstrap 5
- **Automação:** APScheduler (Tarefas em segundo plano)
- **Testes:** Pytest

## 📂 Estrutura de Pastas
```text
web/
 ├─ app/
 │   ├─ models.py          # Definição das tabelas (User, Lead, Processo, etc)
 │   ├─ routes.py          # Controladores e Endpoints da API
 │   ├─ services/          # Integrações (IA Gemini, WhatsApp)
 │   ├─ templates/         # Páginas HTML (Jinja2)
 │   └─ static/            # CSS, JS e Imagens
 ├─ docs/                  # Especificações e documentação da API
 ├─ tests/                 # Suíte de testes automatizados
 ├─ requirements.txt       # Dependências Python
 └─ run.py                 # Ponto de entrada da aplicação
```

## 🚀 Como Executar

1. **Configurar Ambiente Virtual:**
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # Windows: .venv\Scripts\activate
   ```

2. **Instalar Dependências:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Configurar Variáveis (.env):**
   Crie um arquivo `.env` com base no `config.py`:
   ```env
   SECRET_KEY=sua_chave_secreta
   DATABASE_URL=sqlite:///jurislead.db
   GEMINI_API_KEY=sua_chave_ia
   ```

4. **Rodar o Servidor:**
   ```bash
   python run.py
   ```
   Acesse: `http://localhost:5000`

## 🧪 Testes
Para rodar os testes:
```bash
pytest
```

---
**Documentação completa em:** [web/docs/especificacoes-projeto-jurislead-crm.md](docs/especificacoes-projeto-jurislead-crm.md)
