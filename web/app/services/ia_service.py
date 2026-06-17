import os
import requests

AI_API_URL = os.getenv('AI_API_URL', 'https://example-ai.local/triage')
AI_API_KEY = os.getenv('AI_API_KEY')


def triage_lead_payload(lead):
    return {
        'name': lead.name,
        'email': lead.email,
        'phone': lead.phone,
        'origin': lead.origin,
        'context': getattr(lead, 'triage_summary', None) or '',
    }


def triage_lead(lead, timeout=5):
    """Chama a API externa de IA para triagem do lead.

    Retorna um dicionário com keys: `summary` e `classification`.
    Lança `requests.RequestException` em caso de falha de rede.
    """
    payload = triage_lead_payload(lead)
    headers = {'Content-Type': 'application/json'}
    if AI_API_KEY:
        headers['Authorization'] = f'Bearer {AI_API_KEY}'

    resp = requests.post(AI_API_URL, json=payload, headers=headers, timeout=timeout)
    resp.raise_for_status()
    data = resp.json()
    # Esperamos que o provedor retorne {'summary': ..., 'classification': ...}
    return {
        'summary': data.get('summary'),
        'classification': data.get('classification'),
    }
