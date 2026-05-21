import responses
import requests
from datetime import datetime, timedelta, timezone


@responses.activate
def test_whatsapp_reminder_sent(auth_client):
    # criar lead com phone
    r = auth_client.post('/leads', json={'name': 'Remetente', 'phone': '+5511999999999'})
    lead_id = r.get_json()['id']
    future = (datetime.now(timezone.utc).replace(tzinfo=None) + timedelta(days=1)).isoformat()
    resp = auth_client.post('/consultas', json={'lead_id': lead_id, 'scheduled_at': future})
    consulta_id = resp.get_json()['id']

    wa_url = 'https://example-whatsapp.local/send'
    responses.add(responses.POST, wa_url, json={'message_id': 'msg_123'}, status=200)

    notify = auth_client.post(f'/consultas/{consulta_id}/notify')
    assert notify.status_code == 200
    data = notify.get_json()
    assert data['ok'] is True
    assert data['result']['message_id'] == 'msg_123'


@responses.activate
def test_whatsapp_api_failure(auth_client):
    r = auth_client.post('/leads', json={'name': 'SemFone', 'phone': '+5511888888888'})
    lead_id = r.get_json()['id']
    future = (datetime.now(timezone.utc).replace(tzinfo=None) + timedelta(days=1)).isoformat()
    resp = auth_client.post('/consultas', json={'lead_id': lead_id, 'scheduled_at': future})
    consulta_id = resp.get_json()['id']

    wa_url = 'https://example-whatsapp.local/send'
    # simular retorno 500
    responses.add(responses.POST, wa_url, json={'error': 'server'}, status=500)

    notify = auth_client.post(f'/consultas/{consulta_id}/notify')
    assert notify.status_code == 502
    data = notify.get_json()
    assert data['error'] == 'whatsapp_service_failure'
