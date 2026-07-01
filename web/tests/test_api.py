import json
from datetime import datetime, timedelta, timezone

def test_api_login_success(client, app):
    # Cadastrar um usuário normal
    client.post('/usuarios/cadastro', json={
        'name': 'API User',
        'email': 'api@example.com',
        'password': 'secretpassword',
        'confirm_password': 'secretpassword'
    })
    
    # Login com credenciais válidas
    resp = client.post('/api/v1/auth/login', json={
        'email': 'api@example.com',
        'password': 'secretpassword'
    })
    assert resp.status_code == 200
    data = resp.get_json()
    assert 'access_token' in data
    assert data['user']['email'] == 'api@example.com'

def test_api_login_invalid_credentials(client):
    resp = client.post('/api/v1/auth/login', json={
        'email': 'nonexistent@example.com',
        'password': 'wrong'
    })
    assert resp.status_code == 401
    assert resp.get_json()['error'] == 'Credenciais invalidas'

def test_api_endpoint_protection(client):
    # Acesso a rotas protegidas sem token
    resp = client.get('/api/v1/leads')
    assert resp.status_code == 401
    assert 'Missing Authorization Header' in resp.get_json()['msg']

def test_api_endpoint_authorization_role_restriction(client, app):
    # Cadastrar usuário comum
    client.post('/usuarios/cadastro', json={
        'name': 'Common User',
        'email': 'common@example.com',
        'password': 'password123',
        'confirm_password': 'password123'
    })
    
    # Login comum
    login = client.post('/api/v1/auth/login', json={
        'email': 'common@example.com',
        'password': 'password123'
    })
    token = login.get_json()['access_token']
    headers = {'Authorization': f'Bearer {token}'}
    
    # Usuário comum tenta acessar rotas de leads (que exigem privilégios operacionais)
    resp = client.get('/api/v1/leads', headers=headers)
    assert resp.status_code == 403
    assert resp.get_json()['error'] == 'Acesso restrito a este perfil'

def test_api_leads_workflow_for_advogado(client, app):
    # Cadastrar e promover para advogado
    client.post('/usuarios/cadastro', json={
        'name': 'Advogado API',
        'email': 'advogado.api@example.com',
        'password': 'password123',
        'confirm_password': 'password123'
    })
    with app.app_context():
        from app.models import User
        from app import db
        u = User.query.filter_by(email='advogado.api@example.com').first()
        u.role = 'advogado'
        db.session.add(u)
        db.session.commit()
        
    # Login
    login = client.post('/api/v1/auth/login', json={
        'email': 'advogado.api@example.com',
        'password': 'password123'
    })
    token = login.get_json()['access_token']
    headers = {'Authorization': f'Bearer {token}'}
    
    # 1. Criar Lead via API
    create_lead_resp = client.post('/api/v1/leads', json={
        'name': 'Lead API Test',
        'email': 'leadapi@example.com',
        'phone': '123456789',
        'documento': '12345678901'
    }, headers=headers)
    assert create_lead_resp.status_code == 201
    lead_id = create_lead_resp.get_json()['id']
    
    # 2. Obter lista de Leads
    list_leads_resp = client.get('/api/v1/leads', headers=headers)
    assert list_leads_resp.status_code == 200
    leads = list_leads_resp.get_json()
    assert len(leads) >= 1
    assert any(l['id'] == lead_id for l in leads)

    # 3. Agendar Consulta
    future = (datetime.now(timezone.utc).replace(tzinfo=None) + timedelta(days=2)).isoformat()
    consulta_resp = client.post('/api/v1/consultas', json={
        'lead_id': lead_id,
        'scheduled_at': future
    }, headers=headers)
    assert consulta_resp.status_code == 201
    consulta_id = consulta_resp.get_json()['id']
    assert consulta_resp.get_json()['status'] == 'scheduled'

    # 4. Cancelar Consulta
    cancel_resp = client.post(f'/api/v1/consultas/{consulta_id}/cancel', json={}, headers=headers)
    assert cancel_resp.status_code == 200
    assert cancel_resp.get_json()['status'] == 'cancelled'

    # 5. Criar Processo
    proc_resp = client.post('/api/v1/processos', json={
        'lead_id': lead_id,
        'title': 'Processo API',
        'description': 'Descricao API'
    }, headers=headers)
    assert proc_resp.status_code == 201
    proc_id = proc_resp.get_json()['id']

    # 6. Adicionar Movimentação
    mov_resp = client.post(f'/api/v1/processos/{proc_id}/movimentacoes', json={
        'description': 'Audiência agendada via API'
    }, headers=headers)
    assert mov_resp.status_code == 201
    
    # 7. Obter Processo com histórico de movimentações
    get_proc_resp = client.get(f'/api/v1/processos/{proc_id}', headers=headers)
    assert get_proc_resp.status_code == 200
    proc_data = get_proc_resp.get_json()
    assert proc_data['title'] == 'Processo API'
    assert len(proc_data['movimentacoes']) == 1
    assert proc_data['movimentacoes'][0]['description'] == 'Audiência agendada via API'
