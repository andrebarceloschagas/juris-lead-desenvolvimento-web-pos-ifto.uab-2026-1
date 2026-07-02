# Inspeção de Cibersegurança: JurisLead CRM Mobile

## IFTO / UAB - Campus Araguatins
## Curso de Pós-Graduação Lato Sensu em Desenvolvimento de Sistemas Computacionais
## Disciplina: Desenvolvimento Mobile
## Data da Inspeção: 01/07/2026
## Auditor: AI Security Assistant

---

## 1. Resumo Executivo

Esta inspeção detalhada analisou o código-fonte do módulo `mobile/app_mobile` com base no **OWASP Mobile Top 10** e nas melhores práticas de desenvolvimento seguro. O foco foi identificar falhas que pudessem comprometer a integridade dos dados jurídicos e a privacidade dos usuários.

### Contagem de Achados por Severidade:
| Severidade | Quantidade |
| :--- | :--- |
| 🔴 **Crítica** | 1 |
| 🟠 **Alta** | 2 |
| 🟡 **Média** | 2 |
| 🔵 **Baixa** | 1 |

### Top 5 Ações Mais Urgentes:
1.  **Migrar de SharedPreferences para Secure Storage** (Armazenamento de Token).
2.  **Desabilitar tráfego HTTP (Cleartext)** no AndroidManifest.
3.  **Implementar SSL Pinning** para evitar ataques de interceptação (MitM).
4.  **Remover logs sensíveis** em modo de produção (kDebugMode leaks).
5.  **Aprimorar validação de entrada** contra injeção de caracteres especiais em formulários.

---

## 2. Vulnerabilidades Identificadas

### VULN-001: Armazenamento Inseguro de Credenciais (OWASP M2: Insecure Data Storage)
*   **Localização:** `lib/services/api_service.dart` (Linha 24), `lib/services/auth_service.dart` (Linha 17).
*   **Descrição:** O token de autenticação JWT é armazenado utilizando o pacote `shared_preferences`. Em dispositivos Android, o `shared_preferences` salva os dados em um arquivo XML em texto simples na pasta de dados do app. Se o dispositivo sofrer root ou acesso físico, o token pode ser facilmente extraído.
*   **Evidência:**
    ```dart
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    ```
*   **Impacto:** Sequestro de sessão (Session Hijacking). Um invasor com acesso ao sistema de arquivos do dispositivo pode roubar o token e acessar a conta do advogado sem senha.
*   **Severidade:** 🔴 **Crítica**
*   **Recomendação:** Substituir o `shared_preferences` pelo pacote `flutter_secure_storage`, que utiliza Keystore (Android) e Keychain (iOS) para criptografar os dados em repouso.
*   **CWE:** [CWE-312: Cleartext Storage of Sensitive Information](https://cwe.mitre.org/data/definitions/312.html).

---

### VULN-002: Tráfego de Dados em Texto Simples (OWASP M3: Insecure Communication)
*   **Localização:** `android/app/src/main/AndroidManifest.xml` (Linha 6), `lib/config/app_config.dart` (Linha 7).
*   **Descrição:** A aplicação está configurada para permitir tráfego via HTTP não criptografado (`usesCleartextTraffic="true"`) e a `baseUrl` aponta para um endereço `http`.
*   **Evidência:**
    ```xml
    <application ... android:usesCleartextTraffic="true">
    ```
    ```dart
    return 'http://10.0.2.2:5000/api/v1';
    ```
*   **Impacto:** Ataques de Man-in-the-Middle (MitM). Dados sensíveis como senhas de login e detalhes de processos podem ser interceptados em redes Wi-Fi públicas ou comprometidas.
*   **Severidade:** 🟠 **Alta**
*   **Recomendação:** Alterar a `baseUrl` para `https` e definir `android:usesCleartextTraffic="false"` no manifesto Android para produção.
*   **CWE:** [CWE-319: Cleartext Transmission of Sensitive Information](https://cwe.mitre.org/data/definitions/319.html).

---

### VULN-003: Exposição de Informações Sensíveis em Logs (OWASP M10: Extraneous Functionality)
*   **Localização:** `lib/services/api_service.dart` (Linhas 39-44 e 72-76).
*   **Descrição:** Embora o código utilize `kDebugMode`, ele imprime cabeçalhos (que contêm o Bearer Token) e o corpo das requisições (que contêm senhas no login) no console. Se o app for compilado em modo debug ou se houver falha na flag de compilação, dados críticos vazam para o logcat/syslog.
*   **Evidência:**
    ```dart
    if (kDebugMode) {
      print('Headers: $headers'); // Expõe o Token JWT
      print('Body: $body');       // Expõe Senhas no Login
    }
    ```
*   **Impacto:** Vazamento de credenciais para ferramentas de monitoramento de log no dispositivo.
*   **Severidade:** 🟠 **Alta**
*   **Recomendação:** Nunca imprimir cabeçalhos de autorização ou campos sensíveis (`password`, `access_token`), mesmo em modo debug. Use uma ferramenta de logging estruturada que filtre dados sensíveis.
*   **CWE:** [CWE-532: Insertion of Sensitive Information into Log File](https://cwe.mitre.org/data/definitions/532.html).

---

### VULN-004: Falha na Proteção de Integridade da Comunicação (OWASP M3: Insecure Communication)
*   **Localização:** `lib/services/api_service.dart`.
*   **Descrição:** A aplicação não implementa **SSL Pinning**. Ela confia em qualquer certificado emitido por uma Autoridade Certificadora (CA) confiável pelo sistema operacional.
*   **Evidência:** O cliente `http` padrão é utilizado sem validação de certificado específica.
*   **Impacto:** Um invasor pode instalar um certificado raiz malicioso no dispositivo do usuário para interceptar e descriptografar todo o tráfego HTTPS do aplicativo.
*   **Severidade:** 🟡 **Média**
*   **Recomendação:** Implementar SSL Pinning utilizando o pacote `http_certificate_pinning` ou configurando o `SecurityContext` do cliente I/O para validar a chave pública do servidor.
*   **CWE:** [CWE-295: Improper Certificate Validation](https://cwe.mitre.org/data/definitions/295.html).

---

### VULN-005: Validação de Entrada Insuficiente (OWASP M7: Client-Side Injection)
*   **Localização:** `lib/screens/leads/lead_form_screen.dart` (Linha 93), `lib/screens/auth/register_screen.dart`.
*   **Descrição:** Os validadores de formulário verificam apenas se o campo está vazio ou se o formato do e-mail é válido. Não há sanitização contra caracteres especiais que possam ser usados em injeções (como `'`, `"`, `<>`, `\`).
*   **Evidência:**
    ```dart
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Por favor, insira o nome.';
      }
      return null;
    },
    ```
*   **Impacto:** Embora o risco maior seja no backend, falhas de validação no cliente facilitam ataques de XSS Armazenado ou Injeção de SQL se o backend for vulnerável. Além disso, pode causar erros de renderização ou quebra de lógica local.
*   **Severidade:** 🟡 **Média**
*   **Recomendação:** Implementar uma lista de caracteres permitidos (Allowlist) e sanitizar inputs removendo caracteres de controle HTML/SQL antes do envio para a API.
*   **CWE:** [CWE-20: Improper Input Validation](https://cwe.mitre.org/data/definitions/20.html).

---

### VULN-006: Configuração de Identidade do Aplicativo (OWASP M10: Security Misconfiguration)
*   **Localização:** `android/app/src/main/AndroidManifest.xml` (Linha 9).
*   **Descrição:** A `activity` principal está marcada como `android:exported="true"`. Embora necessário para o launcher, se outras activities internas forem marcadas assim sem proteção, elas podem ser invocadas por apps maliciosos.
*   **Evidência:**
    ```xml
    <activity android:name=".MainActivity" android:exported="true">
    ```
*   **Impacto:** Injeção de Intent ou bypass de telas de autenticação (se houver outras activities exportadas).
*   **Severidade:** 🔵 **Baixa**
*   **Recomendação:** Garantir que apenas a `MainActivity` seja exportada. Usar permissões personalizadas para intents sensíveis.
*   **CWE:** [CWE-926: Improper Export of Android Application Components](https://cwe.mitre.org/data/definitions/926.html).

---

## 3. Conclusão

A aplicação demonstra boas práticas básicas, como o uso de HTTPS (planejado) e validação de formato de e-mail. No entanto, o armazenamento do token em `SharedPreferences` e a permissão de tráfego `cleartext` representam riscos significativos em um contexto jurídico (SaaS), onde o sigilo profissional é imperativo. A correção imediata das vulnerabilidades 🔴 Crítica e 🟠 Altas é essencial antes da publicação em ambiente de produção.
