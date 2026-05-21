def test_create_lead_requires_auth(client):
    resp = client.post('/leads', json={'name': 'João', 'email': 'joao@example.com', 'phone': '123'})
    assert resp.status_code == 401
    assert resp.get_json()['error'] == 'Autenticação necessária'


def test_create_lead_success(auth_client):
    resp = auth_client.post('/leads', json={'name': 'João', 'email': 'joao@example.com', 'phone': '123'})
    assert resp.status_code == 201
    data = resp.get_json()
    assert 'id' in data
    assert data['status'] == 'new'


def test_create_lead_missing_name(auth_client):
    resp = auth_client.post('/leads', json={'email': 'no-name@example.com'})
    assert resp.status_code == 400
    data = resp.get_json()
    assert 'error' in data
