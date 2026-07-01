from app import scheduler
import logging

logger = logging.getLogger(__name__)

def check_upcoming_consultas(app):
    from datetime import datetime, timedelta, timezone
    from app import db
    from app.models import Consulta, Mensagem
    from app.services.whatsapp_service import send_whatsapp_message

    logger.info("Checando consultas pendentes para envio de WhatsApp...")
    with app.app_context():
        now = datetime.now(timezone.utc).replace(tzinfo=None)
        tomorrow = now + timedelta(hours=24)
        
        consultas = Consulta.query.filter(
            Consulta.status == 'scheduled',
            Consulta.scheduled_at >= now,
            Consulta.scheduled_at <= tomorrow
        ).all()
        
        for consulta in consultas:
            lead = consulta.lead
            if not lead or not lead.phone:
                continue
                
            scheduled_str = consulta.scheduled_at.isoformat()
            message = f"Lembrete: sua consulta está agendada para {scheduled_str}."
            
            # Check if already notified
            already_sent = Mensagem.query.filter(
                Mensagem.lead_id == lead.id,
                Mensagem.channel == 'whatsapp',
                Mensagem.content.like(f"%{scheduled_str}%"),
                Mensagem.status == 'sent'
            ).first()
            
            if already_sent:
                continue
                
            try:
                send_whatsapp_message(lead.phone, message)
                msg_log = Mensagem(
                    lead_id=lead.id,
                    channel='whatsapp',
                    content=message,
                    status='sent'
                )
                db.session.add(msg_log)
                db.session.commit()
                logger.info(f"Lembrete enviado com sucesso para o lead {lead.id}")
            except Exception as exc:
                msg_log = Mensagem(
                    lead_id=lead.id,
                    channel='whatsapp',
                    content=message,
                    status='failed'
                )
                db.session.add(msg_log)
                db.session.commit()
                logger.error(f"Erro ao enviar lembrete para o lead {lead.id}: {exc}")

def register_jobs(app):
    scheduler.add_job(
        func=check_upcoming_consultas,
        trigger="interval",
        minutes=60,
        id='whatsapp_reminder_job',
        replace_existing=True,
        args=[app]
    )
