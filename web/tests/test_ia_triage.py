import json
import responses
import requests


@responses.activate
def test_ia_triage_success(admin_client):
    # criar lead
    r = admin_client.post('/leads', json={'name': 'Maria', 'email': 'maria@example.com'})
    assert r.status_code == 201
    lead_id = r.get_json()['id']

    # mockar resposta da API de IA
    ai_url = 'https://example-ai.local/triage'
    responses.add(responses.POST, ai_url, json={'summary': 'Resumo do caso', 'classification': 'civil'}, status=200)

    resp = admin_client.post(f'/leads/{lead_id}/triage')
    assert resp.status_code == 200
    data = resp.get_json()
    assert data['classification'] == 'civil'
    assert 'Resumo do caso' in data['triage_summary']


@responses.activate
def test_ia_triage_api_unavailable(admin_client):
    r = admin_client.post('/leads', json={'name': 'Carlos'})
    lead_id = r.get_json()['id']

    ai_url = 'https://example-ai.local/triage'
    # Simular erro de conexão
    responses.add(responses.POST, ai_url, body=requests.exceptions.ConnectionError('connection error'))

    resp = admin_client.post(f'/leads/{lead_id}/triage')
    assert resp.status_code == 502
    data = resp.get_json()
    assert data['error'] == 'ai_service_failure'


def test_ia_triage_rejected_for_common_user(auth_client):
    r = auth_client.post('/leads', json={'name': 'Maria Comum'})
    lead_id = r.get_json()['id']

    resp = auth_client.post(f'/leads/{lead_id}/triage')
    assert resp.status_code == 403
    assert resp.get_json()['error'] == 'Acesso restrito a este perfil'
