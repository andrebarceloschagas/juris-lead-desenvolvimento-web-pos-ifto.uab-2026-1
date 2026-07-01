FROM python:3.11-slim

# Evitar gravação de arquivos pyc e habilitar buffer de saída imediata para logs
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Variáveis padrão de escuta para o run.py
ENV HOST=0.0.0.0
ENV PORT=5000
ENV FLASK_ENV=production

WORKDIR /app

# Instalar dependências
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Criar diretório para persistência do SQLite
RUN mkdir -p /app/data

# Copiar código-fonte
COPY . /app/

EXPOSE 5000

CMD ["python", "run.py"]
