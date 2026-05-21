def test_user_registration_and_login(client):
    register = client.post('/usuarios/cadastro', json={
        'name': 'Ana Silva',
        'email': 'ana@example.com',
        'password': 'secret123',
        'confirm_password': 'secret123',
        'bio': 'Advogada'
    })
    assert register.status_code == 201
    data = register.get_json()
    assert data['name'] == 'Ana Silva'
    assert data['email'] == 'ana@example.com'
    assert data['redirect_url'] == '/entrar'

    login = client.post('/entrar', json={'email': 'ana@example.com', 'password': 'secret123'})
    assert login.status_code == 200
    login_data = login.get_json()
    assert login_data['email'] == 'ana@example.com'
    assert login_data['redirect_url'] == '/'


def test_user_profile_requires_login(client):
    resp = client.get('/perfil')
    assert resp.status_code in (302, 401)


def test_profile_update(client, app):
    client.post('/usuarios/cadastro', json={
        'name': 'Bruno',
        'email': 'bruno@example.com',
        'password': 'secret123',
        'confirm_password': 'secret123'
    })
    client.post('/entrar', json={'email': 'bruno@example.com', 'password': 'secret123'})

    update = client.post('/perfil/editar', json={
        'name': 'Bruno Costa',
        'email': 'bruno.costa@example.com',
        'bio': 'Perfil atualizado'
    })
    assert update.status_code == 200

    with app.app_context():
        from app.models import User
        user = User.query.filter_by(email='bruno.costa@example.com').first()
        assert user is not None
        assert user.name == 'Bruno Costa'
        assert user.bio == 'Perfil atualizado'


def test_user_edit_page_shows_role_badge(client):
    client.post('/usuarios/cadastro', json={
        'name': 'Edit Badge Admin',
        'email': 'edit.badge.admin@example.com',
        'password': 'secret123',
        'confirm_password': 'secret123',
        'role': 'admin'
    })
    client.post('/entrar', json={'email': 'edit.badge.admin@example.com', 'password': 'secret123'})

    client.post('/usuarios/cadastro', json={
        'name': 'Edit Badge User',
        'email': 'edit.badge@example.com',
        'password': 'secret123',
        'confirm_password': 'secret123',
        'role': 'user'
    })

    with client.application.app_context():
        from app.models import User
        user = User.query.filter_by(email='edit.badge@example.com').first()
        user_id = user.id

    page = client.get(f'/usuarios/{user_id}/editar')
    assert page.status_code == 200
    html = page.data.decode('utf-8')
    assert 'Editar Usuário' in html
    assert 'Usuário comum' in html


def test_user_list_edit_and_delete(client, app):
    client.post('/usuarios/cadastro', json={
        'name': 'Admin',
        'email': 'admin@example.com',
        'password': 'secret123',
        'confirm_password': 'secret123',
        'role': 'admin'
    })
    client.post('/entrar', json={'email': 'admin@example.com', 'password': 'secret123'})

    second = client.post('/usuarios/cadastro', json={
        'name': 'Cliente',
        'email': 'cliente@example.com',
        'password': 'secret123',
        'confirm_password': 'secret123',
        'role': 'user'
    })
    assert second.status_code == 201
    user_id = second.get_json()['id']

    listing = client.get('/usuarios')
    assert listing.status_code == 200
    listing_html = listing.data.decode('utf-8')
    assert 'Admin' in listing_html
    assert 'Usuário comum' in listing_html

    edit = client.post(f'/usuarios/{user_id}/editar', json={
        'name': 'Cliente Atualizado',
        'email': 'cliente.atualizado@example.com',
        'bio': 'Bio nova',
        'role': 'manager',
        'is_active_account': True
    })
    assert edit.status_code == 200
    edited = edit.get_json()
    assert edited['name'] == 'Cliente Atualizado'

    delete = client.post(f'/usuarios/{user_id}/excluir', json={})
    assert delete.status_code == 200

    with app.app_context():
        from app.models import User
        from app import db
        assert db.session.get(User, user_id) is None


def test_user_detail_shows_role_badge(client, app):
    admin = client.post('/usuarios/cadastro', json={
        'name': 'Admin Badge',
        'email': 'admin.badge@example.com',
        'password': 'secret123',
        'confirm_password': 'secret123',
        'role': 'admin'
    })
    admin_id = admin.get_json()['id']

    client.post('/entrar', json={'email': 'admin.badge@example.com', 'password': 'secret123'})
    detail = client.get(f'/usuarios/{admin_id}')
    assert detail.status_code == 200
    html = detail.data.decode('utf-8')
    assert 'Admin' in html
    assert 'Acesso total ao sistema' not in html


def test_user_activation_and_inactive_login(client, app):
    admin = client.post('/usuarios/cadastro', json={
        'name': 'Admin 2',
        'email': 'admin2@example.com',
        'password': 'secret123',
        'confirm_password': 'secret123',
        'role': 'admin'
    })
    assert admin.status_code == 201
    client.post('/entrar', json={'email': 'admin2@example.com', 'password': 'secret123'})

    target = client.post('/usuarios/cadastro', json={
        'name': 'Usuario Inativo',
        'email': 'inativo@example.com',
        'password': 'secret123',
        'confirm_password': 'secret123'
    })
    user_id = target.get_json()['id']

    deactivate = client.post(f'/usuarios/{user_id}/desativar', json={})
    assert deactivate.status_code == 200
    assert deactivate.get_json()['is_active_account'] is False

    client.post('/sair')
    inactive_login = client.post('/entrar', json={'email': 'inativo@example.com', 'password': 'secret123'})
    assert inactive_login.status_code == 403
    assert inactive_login.get_json()['error'] == 'Conta inativa'

    client.post('/entrar', json={'email': 'admin2@example.com', 'password': 'secret123'})
    activate = client.post(f'/usuarios/{user_id}/ativar', json={})
    assert activate.status_code == 200
    assert activate.get_json()['is_active_account'] is True


def test_duplicate_email_rejected(client):
    first = client.post('/usuarios/cadastro', json={
        'name': 'Maria',
        'email': 'maria@example.com',
        'password': 'secret123',
        'confirm_password': 'secret123'
    })
    assert first.status_code == 201

    dup = client.post('/usuarios/cadastro', json={
        'name': 'Maria 2',
        'email': 'maria@example.com',
        'password': 'secret123',
        'confirm_password': 'secret123'
    })
    assert dup.status_code == 400
    assert 'email' in dup.get_json()['error']
