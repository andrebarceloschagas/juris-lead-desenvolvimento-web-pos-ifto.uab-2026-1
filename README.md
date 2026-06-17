# JurisLead CRM - Ecossistema Integrado

## IFTO / UAB - Campus Araguatins
## Curso de Pós-Graduação Lato Sensu em Desenvolvimento de Sistemas Computacionais
## Disciplinas: Desenvolvimento Web & Desenvolvimento Mobile
## Alunos: Antonio André Barcelos Chagas e Fabíola Gomes da Rocha

O **JurisLead CRM** é uma plataforma completa para escritórios de advocacia, focada na captação de leads, triagem com Inteligência Artificial, gestão de agenda e controle de processos. O ecossistema é composto por uma aplicação Web robusta e um aplicativo Mobile multiplataforma (Android/iOS), integrados via uma API REST centralizada.

---

## 🚀 Estrutura do Projeto

O repositório está dividido em duas frentes principais:

- **`web/`**: Aplicação Web (Flask) e Backend (API REST).
- **`mobile/`**: Aplicativo Móvel desenvolvido com Flutter.

### Tecnologias Principais

- **Backend:** Python 3, Flask, SQLAlchemy, SQLite, APScheduler.
- **Frontend Web:** Jinja2, Bootstrap 5.
- **Frontend Mobile:** Dart, Flutter.
- **IA:** Integração com Google Gemini para triagem de leads.
- **Comunicação:** Integração com APIs de WhatsApp para automação.
- **Infraestrutura:** Docker, GitHub Actions (CI/CD).

---

## 📁 Organização de Pastas

```text
jurislead-projeto/
 ├─ web/                    # Backend e Interface Web
 │   ├─ app/                # Código-fonte Flask (Models, Routes, Services)
 │   ├─ docs/               # Documentação técnica Web
 │   ├─ tests/              # Testes automatizados (Pytest)
 │   └─ run.py              # Inicialização do Servidor
 │
 ├─ mobile/                 # Aplicativo Flutter
 │   ├─ app_mobile/         # Código-fonte Dart (Views, ViewModels, Services)
 │   └─ docs/               # Documentação técnica Mobile
 │
 └─ README.md               # Este arquivo (Visão Geral)
```

---

## ⚙️ Como Executar

### 1. Backend (API & Web)
Navegue até a pasta `web/` e siga as instruções detalhadas no [README do Web](web/README.md) (se disponível) ou execute os comandos básicos:

```bash
cd web
python3 -m venv .venv
source .venv/bin/activate  # ou .venv\Scripts\activate no Windows
pip install -r requirements.txt
python run.py
```

### 2. Frontend Mobile (Flutter)
Navegue até a pasta `mobile/app_mobile/` (após a inicialização do projeto Flutter):

```bash
cd mobile/app_mobile
flutter pub get
flutter run
```

---

## 📝 Documentação Detalhada

Para informações específicas de cada módulo, consulte as pastas `docs/`:

- **Web:** [web/docs/especificacoes-projeto-jurislead-crm.md](web/docs/especificacoes-projeto-jurislead-crm.md)
- **Mobile:** [mobile/docs/especificacoes-projeto-jurislead-crm-mobile.md](mobile/docs/especificacoes-projeto-jurislead-crm-mobile.md)
- **API Endpoints:** [web/docs/api-endpoints.md](web/docs/api-endpoints.md)

---

## 🛡️ Cibersegurança e LGPD

O projeto adota boas práticas de segurança, incluindo:
- Autenticação via **JWT** para o app mobile e Sessões Seguras para Web.
- Criptografia de dados sensíveis e variáveis de ambiente.
- Conformidade com a **LGPD** no tratamento de dados de leads e clientes.

---

## 👥 Equipe
- **Antonio André Barcelos Chagas**
- **Fabíola Gomes da Rocha**
