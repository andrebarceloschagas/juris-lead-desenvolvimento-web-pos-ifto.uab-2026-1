def test_leads_list_filters_and_pagination(auth_client, app):
    created_ids = []
    for index in range(7):
        resp = auth_client.post('/leads', json={
            'name': f'Lead {index + 1}',
            'email': f'lead{index + 1}@example.com',
            'phone': f'119999900{index + 1}',
            'origin': 'whatsapp' if index < 3 else 'landing',
        })
        assert resp.status_code == 201
        created_ids.append(resp.get_json()['id'])

    with app.app_context():
        from app.models import Lead
        from app import db
        db.session.get(Lead, created_ids[0]).status = 'contacted'
        db.session.get(Lead, created_ids[1]).status = 'contacted'
        db.session.get(Lead, created_ids[6]).status = 'qualified'
        db.session.commit()

    filtered = auth_client.get('/web/leads?status=contacted&origin=whatsapp')
    assert filtered.status_code == 200
    html = filtered.data.decode('utf-8')
    assert 'Lead 1' in html
    assert 'Lead 2' in html
    assert 'Lead 3' not in html
    assert 'Lead 7' not in html

    page = auth_client.get('/web/leads?per_page=3&page=2')
    assert page.status_code == 200
    page_html = page.data.decode('utf-8')
    assert 'Página 2 de 3' in page_html
    assert 'Lead 4' in page_html or 'Lead 3' in page_html


def test_lead_detail_has_whatsapp_link(auth_client):
    resp = auth_client.post('/leads', json={
        'name': 'Contato WhatsApp',
        'email': 'contato@example.com',
        'phone': '+55 (11) 99999-1111',
        'origin': 'landing',
    })
    lead_id = resp.get_json()['id']

    detail = auth_client.get(f'/web/leads/{lead_id}')
    assert detail.status_code == 200
    html = detail.data.decode('utf-8')
    assert 'Contato WhatsApp' in html
    assert 'https://web.whatsapp.com/send?phone=5511999991111&amp;text=' in html
    assert 'Olá, Contato WhatsApp! Vi seu contato no JurisLead e gostaria de dar continuidade ao atendimento.' in html


def test_delete_lead(auth_client, app):
    resp = auth_client.post('/leads', json={
        'name': 'Lead para excluir',
        'email': 'excluir@example.com',
        'phone': '62999999999',
        'origin': 'landing',
    })
    lead_id = resp.get_json()['id']

    detail = auth_client.get(f'/web/leads/{lead_id}')
    assert detail.status_code == 200
    assert 'Excluir lead' in detail.data.decode('utf-8')

    deleted = auth_client.post(f'/leads/{lead_id}/excluir', json={})
    assert deleted.status_code == 200
    assert deleted.get_json()['ok'] is True

    with app.app_context():
        from app.models import Lead
        from app import db
        assert db.session.get(Lead, lead_id) is None
