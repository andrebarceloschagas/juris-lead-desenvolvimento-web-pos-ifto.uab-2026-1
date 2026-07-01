from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from app import db
from app.models import User, Lead, Cliente, Processo, Movimentacao, Consulta, Mensagem
from app.services.whatsapp_service import send_whatsapp_message
from app.services.ia_service import triage_lead
from datetime import datetime, timezone, timedelta

api_bp = Blueprint('api', __name__, url_prefix='/api/v1')

def get_current_user():
    try:
        identity = get_jwt_identity()
        if not identity:
            return None
        return db.session.get(User, int(identity))
    except Exception:
        return None

@api_bp.route('/auth/login', methods=['POST'])
def login():
    data = request.get_json(silent=True) or {}
    email = (data.get('email') or '').strip().lower()
    password = data.get('password') or ''
    
    if not email or not password:
        return jsonify({'error': 'email and password are required'}), 400
        
    user = User.query.filter_by(email=email).first()
    if not user or not user.check_password(password):
        return jsonify({'error': 'Credenciais invalidas'}), 401
        
    if not user.is_active_account:
        return jsonify({'error': 'Conta inativa'}), 403
        
    # Gera o token JWT com expiração de 30 dias para uso mobile
    access_token = create_access_token(identity=str(user.id), expires_delta=timedelta(days=30))
    return jsonify({
        'access_token': access_token,
        'user': {
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'role': user.role
        }
    }), 200

@api_bp.route('/leads', methods=['GET'])
@jwt_required()
def get_leads():
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Unauthorized'}), 401
        
    # Apenas administradores e operacionais visualizam a lista geral de leads
    if user.role not in {'admin', 'manager', 'advogado', 'atendente'}:
        return jsonify({'error': 'Acesso restrito a este perfil'}), 403
        
    status = request.args.get('status')
    origin = request.args.get('origin')
    
    query = Lead.query
    if status:
        query = query.filter_by(status=status)
    if origin:
        query = query.filter_by(origin=origin)
        
    leads = query.order_by(Lead.id.desc()).all()
    return jsonify([lead.to_dict() for lead in leads]), 200

@api_bp.route('/leads', methods=['POST'])
@jwt_required()
def create_lead():
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Unauthorized'}), 401
        
    if user.role not in {'admin', 'manager', 'advogado', 'atendente'}:
        return jsonify({'error': 'Acesso restrito a este perfil'}), 403
        
    data = request.get_json(silent=True) or {}
    name = (data.get('name') or '').strip()
    if not name:
        return jsonify({'error': 'name is required'}), 400
        
    email = data.get('email')
    documento = data.get('documento')
    
    if email and Lead.query.filter_by(email=email).first():
        return jsonify({'error': 'E-mail ou documento ja cadastrado'}), 409
    if documento and Lead.query.filter_by(documento=documento).first():
        return jsonify({'error': 'E-mail ou documento ja cadastrado'}), 409
        
    lead = Lead(
        name=name,
        email=email,
        documento=documento,
        phone=data.get('phone'),
        origin=data.get('origin') or 'mobile_api',
        status='new'
    )
    db.session.add(lead)
    db.session.commit()
    return jsonify(lead.to_dict()), 201

@api_bp.route('/leads/<int:lead_id>/triage', methods=['POST'])
@jwt_required()
def lead_triage(lead_id):
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Unauthorized'}), 401
        
    if user.role not in {'admin', 'manager', 'advogado', 'atendente'}:
        return jsonify({'error': 'Acesso restrito a este perfil'}), 403
        
    lead = db.session.get(Lead, lead_id)
    if not lead:
        return jsonify({'error': 'lead not found'}), 404
        
    try:
        result = triage_lead(lead)
    except Exception:
        current_app.logger.exception('Falha na triagem do lead via API')
        return jsonify({'error': 'ai_service_failure'}), 502
        
    lead.triage_summary = result.get('summary')
    lead.triage_classification = result.get('classification')
    if lead.triage_classification:
        lead.status = lead.triage_classification
        
    db.session.add(lead)
    db.session.commit()
    return jsonify({
        'id': lead.id,
        'triage_summary': lead.triage_summary,
        'classification': lead.triage_classification
    }), 200

@api_bp.route('/leads/<int:lead_id>/convert', methods=['POST'])
@jwt_required()
def convert_lead(lead_id):
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Unauthorized'}), 401
        
    if user.role not in {'admin', 'manager', 'advogado', 'atendente'}:
        return jsonify({'error': 'Acesso restrito a este perfil'}), 403
        
    lead = db.session.get(Lead, lead_id)
    if not lead:
        return jsonify({'error': 'lead not found'}), 404
        
    if getattr(lead, 'cliente', None) or lead.status == 'converted':
        return jsonify({'error': 'lead already converted'}), 400
        
    data = request.get_json(silent=True) or {}
    create_user = data.get('create_user', False)
    
    created_user_id = None
    if create_user and lead.email:
        existing_user = User.query.filter_by(email=lead.email).first()
        if not existing_user:
            import secrets
            new_user = User(
                name=lead.name,
                email=lead.email,
                role='cliente'
            )
            new_user.set_password(secrets.token_urlsafe(16))
            db.session.add(new_user)
            db.session.flush()
            created_user_id = new_user.id
        else:
            created_user_id = existing_user.id
            
    cliente = Cliente(
        lead_id=lead.id,
        user_id=created_user_id,
        name=lead.name,
        documento=lead.documento
    )
    lead.status = 'converted'
    db.session.add(cliente)
    db.session.add(lead)
    db.session.commit()
    
    return jsonify({'ok': True, 'cliente_id': cliente.id, 'user_id': created_user_id}), 200

@api_bp.route('/consultas', methods=['POST'])
@jwt_required()
def create_consulta():
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Unauthorized'}), 401
        
    if user.role not in {'admin', 'manager', 'advogado', 'atendente'}:
        return jsonify({'error': 'Acesso restrito a este perfil'}), 403
        
    data = request.get_json(silent=True) or {}
    lead_id = data.get('lead_id')
    scheduled_at = data.get('scheduled_at')
    
    if not lead_id or not scheduled_at:
        return jsonify({'error': 'lead_id and scheduled_at are required'}), 400
        
    lead = db.session.get(Lead, int(lead_id))
    if not lead:
        return jsonify({'error': 'lead not found'}), 404
        
    try:
        scheduled_dt = datetime.fromisoformat(scheduled_at)
    except Exception:
        return jsonify({'error': 'invalid datetime format'}), 400
        
    now = datetime.now(timezone.utc).replace(tzinfo=None)
    if scheduled_dt <= now:
        return jsonify({'error': 'scheduled_at must be in the future'}), 400
        
    consulta = Consulta(lead_id=lead_id, scheduled_at=scheduled_dt, status='scheduled')
    db.session.add(consulta)
    db.session.commit()
    return jsonify(consulta.to_dict()), 201

@api_bp.route('/consultas/<int:consulta_id>/cancel', methods=['POST'])
@jwt_required()
def cancel_consulta(consulta_id):
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Unauthorized'}), 401
        
    if user.role not in {'admin', 'manager', 'advogado', 'atendente'}:
        return jsonify({'error': 'Acesso restrito a este perfil'}), 403
        
    consulta = db.session.get(Consulta, consulta_id)
    if not consulta:
        return jsonify({'error': 'consulta not found'}), 404
        
    consulta.status = 'cancelled'
    consulta.cancelled_at = datetime.now(timezone.utc).replace(tzinfo=None)
    db.session.add(consulta)
    db.session.commit()
    return jsonify(consulta.to_dict()), 200

@api_bp.route('/processos', methods=['POST'])
@jwt_required()
def create_processo():
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Unauthorized'}), 401
        
    if user.role not in {'admin', 'manager', 'advogado', 'atendente'}:
        return jsonify({'error': 'Acesso restrito a este perfil'}), 403
        
    data = request.get_json(silent=True) or {}
    lead_id = data.get('lead_id')
    title = data.get('title')
    
    if not lead_id or not title:
        return jsonify({'error': 'lead_id and title are required'}), 400
        
    lead = db.session.get(Lead, int(lead_id))
    if not lead:
        return jsonify({'error': 'lead not found'}), 404
        
    proc = Processo(lead_id=lead_id, title=title, description=data.get('description'))
    db.session.add(proc)
    db.session.commit()
    return jsonify(proc.to_dict()), 201

@api_bp.route('/processos/<int:proc_id>/movimentacoes', methods=['POST'])
@jwt_required()
def add_movimentacao(proc_id):
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Unauthorized'}), 401
        
    if user.role not in {'admin', 'manager', 'advogado', 'atendente'}:
        return jsonify({'error': 'Acesso restrito a este perfil'}), 403
        
    proc = db.session.get(Processo, proc_id)
    if not proc:
        return jsonify({'error': 'processo not found'}), 404
        
    data = request.get_json(silent=True) or {}
    desc = data.get('description')
    if not desc:
        return jsonify({'error': 'description is required'}), 400
        
    mov = Movimentacao(processo_id=proc_id, description=desc)
    db.session.add(mov)
    db.session.commit()
    return jsonify(mov.to_dict()), 201

@api_bp.route('/processos/<int:proc_id>', methods=['GET'])
@jwt_required()
def get_processo(proc_id):
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Unauthorized'}), 401
        
    if user.role not in {'admin', 'manager', 'advogado', 'atendente'}:
        return jsonify({'error': 'Acesso restrito a este perfil'}), 403
        
    proc = db.session.get(Processo, proc_id)
    if not proc:
        return jsonify({'error': 'processo not found'}), 404
        
    return jsonify(proc.to_dict(include_movs=True)), 200

@api_bp.route('/metrics', methods=['GET'])
@jwt_required()
def get_metrics():
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Unauthorized'}), 401
        
    if user.role not in {'admin', 'manager', 'advogado', 'atendente'}:
        return jsonify({'error': 'Acesso restrito a este perfil'}), 403
        
    total_leads = Lead.query.count()
    pending_consultas = Consulta.query.filter(Consulta.status == 'scheduled').count()
    open_processos = Processo.query.filter(Processo.status == 'open').count()
    
    return jsonify({
        'total_leads': total_leads,
        'pending_consultas': pending_consultas,
        'open_processos': open_processos
    }), 200
