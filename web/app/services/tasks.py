from app import scheduler
import logging

logger = logging.getLogger(__name__)

def check_upcoming_consultas():
    # Isso seria importado num contexto de app, ou ter app_context manual
    logger.info("Checando consultas pendentes para envio de WhatsApp...")

def register_jobs():
    scheduler.add_job(func=check_upcoming_consultas, trigger="interval", minutes=60, id='whatsapp_reminder_job', replace_existing=True)
