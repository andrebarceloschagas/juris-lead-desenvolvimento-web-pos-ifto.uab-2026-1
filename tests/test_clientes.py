def test_convert_lead_to_cliente(auth_client, app):
    # Criar um lead
    resp = auth_client.post('/leads', json={
        'name': 'Lead Convertido',
        'email': 'converter@example.com',
        'phone': '123456',
        'documento': '11122233344',
        'origin': 'landing',
    })
    assert resp.status_code == 201
    lead_id = resp.get_json()['id']

    # TST-CLI-01: Converter lead em cliente
    convert_resp = auth_client.post(f'/leads/{lead_id}/convert', json={
        'create_user': True
    })
    assert convert_resp.status_code == 200
    data = convert_resp.get_json()
    assert data['ok'] is True
    assert 'cliente_id' in data

    with app.app_context():
        from app.models import Lead, Cliente, User
        from app import db
        lead = db.session.get(Lead, lead_id)
        assert lead.status == 'converted'
        
        cliente = db.session.get(Cliente, data['cliente_id'])
        assert cliente is not None
        assert cliente.lead_id == lead_id
        assert cliente.name == 'Lead Convertido'
        assert cliente.documento == '11122233344'
        assert cliente.user_id is not None
        
        user = db.session.get(User, cliente.user_id)
        assert user is not None
        assert user.role == 'cliente'
        assert user.email == 'converter@example.com'
