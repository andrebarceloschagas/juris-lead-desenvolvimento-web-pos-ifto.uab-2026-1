import pytest
from app import create_app, db


@pytest.fixture
def app():
    test_config = {
        'TESTING': True,
        'SQLALCHEMY_DATABASE_URI': 'sqlite:///:memory:',
        'SQLALCHEMY_TRACK_MODIFICATIONS': False,
    }
    app = create_app(test_config)

    with app.app_context():
        db.create_all()
        yield app


@pytest.fixture
def client(app):
    return app.test_client()


@pytest.fixture
def auth_client(client):
    client.post('/usuarios/cadastro', json={
        'name': 'Usuario Teste',
        'email': 'usuario@example.com',
        'password': 'secret123',
        'confirm_password': 'secret123',
        'role': 'user',
    })
    client.post('/entrar', json={'email': 'usuario@example.com', 'password': 'secret123'})
    return client


@pytest.fixture
def admin_client(client):
    client.post('/usuarios/cadastro', json={
        'name': 'Admin Teste',
        'email': 'admin@example.com',
        'password': 'secret123',
        'confirm_password': 'secret123',
        'role': 'admin',
    })
    client.post('/entrar', json={'email': 'admin@example.com', 'password': 'secret123'})
    return client
