# JurisLead CRM - Mobile App

Este diretório contém o código-fonte do aplicativo móvel multiplataforma (Android e iOS) do JurisLead, desenvolvido com Flutter.

## 🛠️ Tecnologias
- **Linguagem:** [Dart](https://dart.dev/)
- **Framework:** [Flutter](https://flutter.dev/)
- **Gerenciamento de Estado:** Provider / Riverpod (Recomendado)
- **Consumo de API:** Http / Dio
- **Persistência Segura:** Flutter Secure Storage (para tokens JWT)
- **UI:** Material Design 3

## 📂 Estrutura de Pastas
```text
mobile/
 ├─ app_mobile/            # Projeto Flutter (Criar nesta pasta)
 │   ├─ lib/
 │   │   ├─ models/        # Classes de dados (JSON Serialization)
 │   │   ├─ views/         # Telas (UI)
 │   │   ├─ viewmodels/    # Lógica de estado
 │   │   └─ services/      # Integração com a API Flask
 │   └─ pubspec.yaml       # Dependências do projeto
 └─ docs/                  # Especificações técnicas do Mobile
```

## 🚀 Como Preparar o Ambiente

1. **Requisitos:**
   - Flutter SDK instalado.
   - Android Studio ou VS Code com extensões Flutter/Dart.

2. **Inicializar o Projeto (Se ainda não existir):**
   ```bash
   cd mobile
   flutter create app_mobile
   ```

3. **Rodar o Aplicativo:**
   ```bash
   cd app_mobile
   flutter pub get
   flutter run
   ```

## 📱 Funcionalidades Principais
- Login persistente via JWT.
- Dashboard com métricas em tempo real.
- Gestão de Leads com triagem por IA.
- Agenda de consultas integrada.
- Consulta de processos e movimentações.

---
**Documentação completa em:** [mobile/docs/especificacoes-projeto-jurislead-crm-mobile.md](docs/especificacoes-projeto-jurislead-crm-mobile.md)
