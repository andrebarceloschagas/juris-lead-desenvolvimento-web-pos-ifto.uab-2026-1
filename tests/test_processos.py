def test_create_processo_with_lead(auth_client):
    # criar lead
    r = auth_client.post('/leads', json={'name': 'Cliente Proc'})
    lead_id = r.get_json()['id']

    resp = auth_client.post('/processos', json={'lead_id': lead_id, 'title': 'Processo X', 'description': 'Descrição'})
    assert resp.status_code == 201
    data = resp.get_json()
    proc_id = data['id']

    # obter processo e conferir vínculo
    g = auth_client.get(f'/processos/{proc_id}')
    assert g.status_code == 200
    pdata = g.get_json()
    assert pdata['lead_id'] == lead_id
    assert pdata['title'] == 'Processo X'


def test_add_movimentacao_and_preserve_history(auth_client):
    r = auth_client.post('/leads', json={'name': 'Cliente Mov'})
    lead_id = r.get_json()['id']
    resp = auth_client.post('/processos', json={'lead_id': lead_id, 'title': 'Proc Mov'})
    proc_id = resp.get_json()['id']

    # adicionar movimentação
    mv = auth_client.post(f'/processos/{proc_id}/movimentacoes', json={'description': 'Primeira movimentação'})
    assert mv.status_code == 201

    # obter processo e conferir movimentação
    g = auth_client.get(f'/processos/{proc_id}')
    pdata = g.get_json()
    assert 'movimentacoes' in pdata
    assert any(m['description'] == 'Primeira movimentação' for m in pdata['movimentacoes'])


def test_create_processo_requires_auth(client):
    resp = client.post('/processos', json={'lead_id': 1, 'title': 'Sem acesso'})
    assert resp.status_code == 401
    assert resp.get_json()['error'] == 'Autenticação necessária'
