import os
import requests

WHATSAPP_API_URL = os.getenv('WHATSAPP_API_URL', 'https://example-whatsapp.local/send')
WHATSAPP_API_TOKEN = os.getenv('WHATSAPP_API_TOKEN')


def send_whatsapp_message(phone: str, message: str, timeout: int = 5):
    """Envia uma mensagem via API de WhatsApp configurada.

    Retorna o JSON da resposta em caso de sucesso. Lança requests.RequestException em erro.
    """
    headers = {'Content-Type': 'application/json'}
    if WHATSAPP_API_TOKEN:
        headers['Authorization'] = f'Bearer {WHATSAPP_API_TOKEN}'

    payload = {'to': phone, 'message': message}
    resp = requests.post(WHATSAPP_API_URL, json=payload, headers=headers, timeout=timeout)
    resp.raise_for_status()
    return resp.json()
