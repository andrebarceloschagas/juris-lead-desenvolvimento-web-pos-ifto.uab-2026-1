from freezegun import freeze_time
from datetime import datetime, timedelta, timezone


def test_create_consulta_requires_auth(client):
    resp = client.post('/consultas', json={'lead_id': 1, 'scheduled_at': '2026-01-02T09:00:00'})
    assert resp.status_code == 401
    assert resp.get_json()['error'] == 'Autenticação necessária'


@freeze_time('2026-01-01T09:00:00')
def test_create_consulta_future_date(auth_client):
    # criar lead
    r = auth_client.post('/leads', json={'name': 'Paciente'})
    lead_id = r.get_json()['id']

    future = (datetime.now(timezone.utc).replace(tzinfo=None) + timedelta(days=2)).isoformat()
    resp = auth_client.post('/consultas', json={'lead_id': lead_id, 'scheduled_at': future})
    assert resp.status_code == 201
    data = resp.get_json()
    assert data['status'] == 'scheduled'


@freeze_time('2026-01-01T09:00:00')
def test_cancel_consulta(auth_client):
    r = auth_client.post('/leads', json={'name': 'Paciente2'})
    lead_id = r.get_json()['id']
    future = (datetime.now(timezone.utc).replace(tzinfo=None) + timedelta(days=1)).isoformat()
    resp = auth_client.post('/consultas', json={'lead_id': lead_id, 'scheduled_at': future})
    consulta_id = resp.get_json()['id']

    cancel_resp = auth_client.post(f'/consultas/{consulta_id}/cancel')
    assert cancel_resp.status_code == 200
    data = cancel_resp.get_json()
    assert data['status'] == 'cancelled'
