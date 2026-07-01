import responses
import requests
from datetime import datetime, timedelta, timezone


@responses.activate
def test_whatsapp_reminder_sent(auth_client, app):
    # criar lead com phone
    r = auth_client.post('/leads', json={'name': 'Remetente', 'phone': '+5511999999999'})
    lead_id = r.get_json()['id']
    future = (datetime.now(timezone.utc).replace(tzinfo=None) + timedelta(days=1)).isoformat()
    resp = auth_client.post('/consultas', json={'lead_id': lead_id, 'scheduled_at': future})
    consulta_id = resp.get_json()['id']

    wa_url = 'https://example-whatsapp.local/send'
    responses.add(responses.POST, wa_url, json={'message_id': 'msg_123'}, status=200)

    notify = auth_client.post(f'/consultas/{consulta_id}/notify')
    assert notify.status_code == 200
    data = notify.get_json()
    assert data['ok'] is True
    assert data['result']['message_id'] == 'msg_123'

    # Verificar histórico gravado no banco com sucesso
    with app.app_context():
        from app.models import Mensagem
        msg = Mensagem.query.filter_by(lead_id=lead_id).first()
        assert msg is not None
        assert msg.status == 'sent'
        assert msg.channel == 'whatsapp'


@responses.activate
def test_whatsapp_api_failure(auth_client, app):
    r = auth_client.post('/leads', json={'name': 'SemFone', 'phone': '+5511888888888'})
    lead_id = r.get_json()['id']
    future = (datetime.now(timezone.utc).replace(tzinfo=None) + timedelta(days=1)).isoformat()
    resp = auth_client.post('/consultas', json={'lead_id': lead_id, 'scheduled_at': future})
    consulta_id = resp.get_json()['id']

    wa_url = 'https://example-whatsapp.local/send'
    # simular retorno 500
    responses.add(responses.POST, wa_url, json={'error': 'server'}, status=500)

    notify = auth_client.post(f'/consultas/{consulta_id}/notify')
    assert notify.status_code == 502
    data = notify.get_json()
    assert data['error'] == 'whatsapp_service_failure'

    # Verificar histórico gravado no banco com falha
    with app.app_context():
        from app.models import Mensagem
        msg = Mensagem.query.filter_by(lead_id=lead_id).first()
        assert msg is not None
        assert msg.status == 'failed'


@responses.activate
def test_background_whatsapp_reminder(auth_client, app):
    # criar lead com phone
    r = auth_client.post('/leads', json={'name': 'Lead Scheduler', 'phone': '+5511777777777'})
    lead_id = r.get_json()['id']
    
    # Criar consulta futura para amanhã (dentro das 24h)
    future = (datetime.now(timezone.utc).replace(tzinfo=None) + timedelta(hours=12)).isoformat()
    resp = auth_client.post('/consultas', json={'lead_id': lead_id, 'scheduled_at': future})
    assert resp.status_code == 201

    wa_url = 'https://example-whatsapp.local/send'
    responses.add(responses.POST, wa_url, json={'message_id': 'msg_background'}, status=200)

    # Executar a tarefa de background diretamente
    from app.services.tasks import check_upcoming_consultas
    check_upcoming_consultas(app)

    # Verificar se registrou a mensagem 'sent' no banco
    with app.app_context():
        from app.models import Mensagem
        msg = Mensagem.query.filter_by(lead_id=lead_id).first()
        assert msg is not None
        assert msg.status == 'sent'
        assert "Lembrete: sua consulta está agendada para" in msg.content

    # Limpar responses (se tentar chamar a API de novo, falhará por falta de mock)
    responses.reset()
    
    # Executar de novo e garantir que ignora (não tenta chamar o serviço novamente por já estar notificado)
    check_upcoming_consultas(app)
