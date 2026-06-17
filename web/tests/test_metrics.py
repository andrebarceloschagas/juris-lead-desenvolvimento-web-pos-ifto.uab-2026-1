def test_public_landing_page_and_capture(client):
    landing = client.get('/')
    assert landing.status_code == 200
    assert b'Capte leads' in landing.data or b'Fale com o escrit' in landing.data

    capture = client.post('/captacao', json={'name': 'Lead Publico', 'email': 'publico@example.com', 'phone': '999'})
    assert capture.status_code == 201
    data = capture.get_json()
    assert data['status'] == 'new'


def test_metrics_page_requires_admin(client):
    resp = client.get('/metricas')
    assert resp.status_code == 401
    assert resp.get_json()['error'] == 'Autenticação necessária'


def test_metrics_page_for_admin(admin_client):
    admin_client.post('/leads', json={'name': 'Lead A'})
    admin_client.post('/leads', json={'name': 'Lead B'})
    lead_resp = admin_client.post('/leads', json={'name': 'Lead C'})
    lead_id = lead_resp.get_json()['id']
    admin_client.post('/processos', json={'lead_id': lead_id, 'title': 'Proc 1'})

    resp = admin_client.get('/metricas')
    assert resp.status_code == 200
    html = resp.data.decode('utf-8')
    assert 'Total leads' in html
    assert 'Processos recentes' in html
    assert 'Lead A' in html


def test_dashboard_shows_admin_badge(admin_client):
    resp = admin_client.get('/')
    assert resp.status_code == 200
    html = resp.data.decode('utf-8')
    assert 'Admin' in html
    assert 'Acesso total ao sistema' in html


def test_home_page_varies_by_profile(app, client):
    user_client = app.test_client()
    user_client.post('/usuarios/cadastro', json={
        'name': 'Usuario Home',
        'email': 'home-user@example.com',
        'password': 'secret123',
        'confirm_password': 'secret123',
        'role': 'user',
    })
    user_client.post('/entrar', json={'email': 'home-user@example.com', 'password': 'secret123'})

    user_home = user_client.get('/')
    assert user_home.status_code == 200
    user_html = user_home.data.decode('utf-8')
    assert 'Área do atendimento' in user_html
    assert 'captação, agenda e organização dos contatos' in user_html
    assert 'Novo Lead' in user_html
    assert 'Painel gerencial' not in user_html

    manager_client = app.test_client()
    manager_client.post('/usuarios/cadastro', json={
        'name': 'Manager Home',
        'email': 'home-manager@example.com',
        'password': 'secret123',
        'confirm_password': 'secret123',
        'role': 'manager',
    })
    manager_client.post('/entrar', json={'email': 'home-manager@example.com', 'password': 'secret123'})

    manager_home = manager_client.get('/')
    assert manager_home.status_code == 200
    manager_html = manager_home.data.decode('utf-8')
    assert 'Área do advogado' in manager_html
    assert 'processos, movimentações e acompanhamento de prazos' in manager_html
    assert 'Ver Processos' in manager_html
    assert 'Área do atendimento' not in manager_html

    admin_client = app.test_client()
    admin_client.post('/usuarios/cadastro', json={
        'name': 'Admin Home',
        'email': 'home-admin@example.com',
        'password': 'secret123',
        'confirm_password': 'secret123',
        'role': 'admin',
    })
    admin_client.post('/entrar', json={'email': 'home-admin@example.com', 'password': 'secret123'})

    admin_home = admin_client.get('/')
    assert admin_home.status_code == 200
    admin_html = admin_home.data.decode('utf-8')
    assert 'Painel gerencial' in admin_html
    assert 'Área do atendimento' not in admin_html


def test_operational_process_views_allow_manager(app):
    manager_client = app.test_client()
    manager_client.post('/usuarios/cadastro', json={
        'name': 'Manager Processes',
        'email': 'manager-processos@example.com',
        'password': 'secret123',
        'confirm_password': 'secret123',
        'role': 'manager',
    })
    manager_client.post('/entrar', json={'email': 'manager-processos@example.com', 'password': 'secret123'})

    resp = manager_client.get('/web/processos')
    assert resp.status_code == 200
