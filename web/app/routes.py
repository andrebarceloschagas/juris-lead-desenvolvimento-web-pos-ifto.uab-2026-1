from flask import Blueprint, request, jsonify, render_template, redirect, url_for, flash, current_app
from flask_login import login_user, logout_user, login_required, current_user
from . import db, login_manager
from .models import User, Lead, Cliente, Processo, Movimentacao, Consulta, Mensagem
from .services.whatsapp_service import send_whatsapp_message
from .services.ia_service import triage_lead
from datetime import datetime, timezone
from urllib.parse import quote

bp = Blueprint('main', __name__)

OPERATIONAL_ROLES = {'user', 'manager', 'advogado', 'atendente'}


@login_manager.unauthorized_handler
def unauthorized():
    message = 'Autenticação necessária'
    is_ajax = request.headers.get('X-Requested-With') == 'XMLHttpRequest'
    # Se o GET for especificamente o logout, redireciona para login/landing (melhor UX)
    try:
        logout_path = url_for('main.logout')
    except Exception:
        logout_path = '/sair'

    if request.method == 'GET' and request.path == logout_path and not request.is_json and not is_ajax:
        flash(message, 'warning')
        return redirect(url_for('main.login'))

    # Para requests de API/AJAX (ou qualquer outro caso), mantenha a resposta JSON 401
    if _should_return_json():
        return jsonify({'error': message}), 401

    flash(message, 'warning')
    return redirect(url_for('main.login'))


def roles_required(*roles):
    from functools import wraps

    allowed_roles = set(roles)

    def decorator(fn):
        @wraps(fn)
        def wrapper(*args, **kwargs):
            if not current_user.is_authenticated:
                return login_manager.unauthorized()
            if current_user.role not in allowed_roles:
                message = 'Acesso restrito a este perfil'
                return (jsonify({'error': message}), 403) if _should_return_json() else (flash(message, 'danger') or redirect(url_for('main.index')))
            return fn(*args, **kwargs)

        return wrapper

    return decorator


def admin_required(fn):
    return roles_required('admin')(fn)


def _dashboard_metrics():
    return {
        'total_leads': Lead.query.count(),
        'new_leads': Lead.query.filter_by(status='new').count(),
        'triaged_leads': Lead.query.filter(Lead.triage_classification.isnot(None)).count(),
        'total_consultas': Consulta.query.count(),
        'scheduled_consultas': Consulta.query.filter_by(status='scheduled').count(),
        'cancelled_consultas': Consulta.query.filter_by(status='cancelled').count(),
        'total_processos': Processo.query.count(),
        'open_processos': Processo.query.filter_by(status='open').count(),
        'total_users': User.query.count(),
        'active_users': User.query.filter_by(is_active_account=True).count(),
    }


def _operational_role_key():
    return 'advogado' if current_user.role in {'manager', 'advogado'} else 'atendente'


def _operational_home_context():
    metrics = _dashboard_metrics()
    role_key = _operational_role_key()

    if role_key == 'advogado':
        return {
            'role_label': 'Área do advogado',
            'role_focus': 'processos, movimentações e acompanhamento de prazos',
            'primary_actions': [
                {'label': 'Ver Processos', 'href': '/web/processos', 'variant': 'primary'},
                {'label': 'Novo Lead', 'href': '/web/leads/new', 'variant': 'outline-primary'},
                {'label': 'Meu perfil', 'href': '/perfil', 'variant': 'outline-dark'},
            ],
            'summary_cards': [
                {'label': 'Processos abertos', 'value': metrics['open_processos']},
                {'label': 'Leads triados', 'value': metrics['triaged_leads']},
                {'label': 'Consultas agendadas', 'value': metrics['scheduled_consultas']},
                {'label': 'Total leads', 'value': metrics['total_leads']},
            ],
            'priority_title': 'Prioridades do advogado',
            'priority_items': [
                {'title': '1. Revisar processos abertos', 'text': 'Foque nos casos com movimentação pendente ou prazo próximo.'},
                {'title': '2. Acompanhar triagem', 'text': 'Use a classificação dos leads para priorizar conversão.'},
                {'title': '3. Conferir consultas', 'text': 'Verifique os atendimentos agendados e os retornos críticos.'},
            ],
            'workflow_title': 'Fluxo do dia',
            'workflow_items': [
                {'title': 'Processos', 'text': 'Atualize movimentações e mantenha o histórico do caso em dia.'},
                {'title': 'Leads qualificados', 'text': 'Analise contatos triados para decidir a próxima ação.'},
                {'title': 'Consultas', 'text': 'Revise os agendamentos que exigem atuação jurídica.'},
            ],
        }

    return {
        'role_label': 'Área do atendimento',
        'role_focus': 'captação, agenda e organização dos contatos',
        'primary_actions': [
            {'label': 'Novo Lead', 'href': '/web/leads/new', 'variant': 'primary'},
            {'label': 'Ver Processos', 'href': '/web/processos', 'variant': 'outline-primary'},
            {'label': 'Meu perfil', 'href': '/perfil', 'variant': 'outline-dark'},
        ],
        'summary_cards': [
            {'label': 'Leads novos', 'value': metrics['new_leads']},
            {'label': 'Consultas agendadas', 'value': metrics['scheduled_consultas']},
            {'label': 'Total leads', 'value': metrics['total_leads']},
            {'label': 'Leads triados', 'value': metrics['triaged_leads']},
        ],
        'priority_title': 'Prioridades do atendimento',
        'priority_items': [
            {'title': '1. Captar e registrar leads', 'text': 'Inclua nome, contato e origem logo no primeiro atendimento.'},
            {'title': '2. Organizar agenda', 'text': 'Confirme consultas futuras e atualize pendências de retorno.'},
            {'title': '3. Encaminhar para triagem', 'text': 'Separe os contatos que já podem seguir para análise jurídica.'},
        ],
        'workflow_title': 'Fluxo do dia',
        'workflow_items': [
            {'title': 'Captação', 'text': 'Transforme novos contatos em leads qualificados.'},
            {'title': 'Agenda', 'text': 'Mantenha consultas e retornos sob controle.'},
            {'title': 'Repasse', 'text': 'Direcione os casos que precisam de atuação do advogado.'},
        ],
    }


def _is_html_form_request():
    content_type = request.content_type or ''
    return content_type.startswith('application/x-www-form-urlencoded') or content_type.startswith('multipart/form-data')


def _should_return_json():
    return request.is_json or request.headers.get('X-Requested-With') == 'XMLHttpRequest' or not _is_html_form_request()


def _payload():
    return request.get_json(silent=True) or request.form


def _auth_response(success_payload=None, redirect_endpoint='main.index', success_message=None, status_code=200, redirect_kwargs=None):
    if _should_return_json():
        return jsonify(success_payload or {}), status_code
    if success_message:
        flash(success_message, 'success')
    return redirect(url_for(redirect_endpoint, **(redirect_kwargs or {})))


@bp.route('/captacao', methods=['POST'])
def public_capture_lead():
    data = _payload()
    name = (data.get('name') or '').strip()
    if not name:
        message = 'name is required'
        return (jsonify({'error': message}), 400) if _should_return_json() else (flash(message, 'danger') or redirect(url_for('main.index')))

    email = data.get('email')
    documento = data.get('documento')
    if email and Lead.query.filter_by(email=email).first():
        msg = 'E-mail ou documento ja cadastrado'
        return (jsonify({'error': msg}), 409) if _should_return_json() else (flash(msg, 'danger') or redirect(url_for('main.index')))
    if documento and Lead.query.filter_by(documento=documento).first():
        msg = 'E-mail ou documento ja cadastrado'
        return (jsonify({'error': msg}), 409) if _should_return_json() else (flash(msg, 'danger') or redirect(url_for('main.index')))

    lead = Lead(
        name=name,
        email=email,
        documento=documento,
        phone=data.get('phone'),
        origin=data.get('origin') or 'landing',
        status='new',
    )
    db.session.add(lead)
    db.session.commit()

    if _should_return_json():
        return jsonify({'id': lead.id, 'status': lead.status}), 201

    flash('Contato enviado com sucesso. Em breve entraremos em contato.', 'success')
    return redirect(url_for('main.index'))


@bp.route('/usuarios/cadastro', methods=['GET', 'POST'])
def register():
    if request.method == 'GET':
        return render_template('register.html')

    data = _payload()
    name = (data.get('name') or '').strip()
    email = (data.get('email') or '').strip().lower()
    password = data.get('password') or ''
    confirm_password = data.get('confirm_password') or ''

    if not name or not email or not password:
        message = 'name, email e password são obrigatórios'
        return (jsonify({'error': message}), 400) if _should_return_json() else (flash(message, 'danger') or render_template('register.html'), 400)

    if password != confirm_password:
        message = 'password e confirm_password não conferem'
        return (jsonify({'error': message}), 400) if _should_return_json() else (flash(message, 'danger') or render_template('register.html'), 400)

    existing = User.query.filter_by(email=email).first()
    if existing:
        message = 'email já cadastrado'
        return (jsonify({'error': message}), 400) if _should_return_json() else (flash(message, 'danger') or render_template('register.html'), 400)

    user = User(name=name, email=email, bio=data.get('bio'), role='user')
    user.set_password(password)
    db.session.add(user)
    db.session.commit()

    if _should_return_json():
        return jsonify({'id': user.id, 'name': user.name, 'email': user.email, 'redirect_url': url_for('main.login')}), 201

    flash('Usuário cadastrado com sucesso.', 'success')
    return redirect(url_for('main.login'))


@bp.route('/entrar', methods=['GET', 'POST'])
def login():
    if request.method == 'GET':
        return render_template('login.html')

    data = _payload()
    email = (data.get('email') or '').strip().lower()
    password = data.get('password') or ''
    user = User.query.filter_by(email=email).first()

    if not user or not user.check_password(password):
        message = 'Credenciais inválidas'
        return (jsonify({'error': message}), 401) if _should_return_json() else (flash(message, 'danger') or render_template('login.html'), 401)

    if not user.is_active_account:
        message = 'Conta inativa'
        return (jsonify({'error': message}), 403) if _should_return_json() else (flash(message, 'danger') or render_template('login.html'), 403)

    login_user(user)
    if _should_return_json():
        return jsonify({'id': user.id, 'name': user.name, 'email': user.email, 'redirect_url': url_for('main.index')}), 200
    flash('Login realizado com sucesso.', 'success')
    return redirect(url_for('main.index'))


@bp.route('/sair', methods=['POST', 'GET'])
@login_required
def logout():
    is_ajax = request.headers.get('X-Requested-With') == 'XMLHttpRequest'
    accept = (request.headers.get('Accept') or '')

    # Navegação direta do navegador (GET) com preferência por HTML: redireciona para a landing
    if request.method == 'GET' and not is_ajax and 'text/html' in accept:
        logout_user()
        flash('Logout realizado com sucesso.', 'success')
        return redirect(url_for('main.index'))

    # Caso contrário, trate como API/AJAX e retorne JSON
    logout_user()
    if _should_return_json():
        return jsonify({'ok': True, 'redirect_url': url_for('main.index')}), 200
    flash('Logout realizado com sucesso.', 'success')
    return redirect(url_for('main.index'))


@bp.route('/perfil', methods=['GET'])
@login_required
def profile():
    return render_template('profile.html', user=current_user)


@bp.route('/perfil/editar', methods=['GET', 'POST'])
@login_required
def edit_profile():
    if request.method == 'GET':
        return render_template('profile_edit.html', user=current_user)

    data = _payload()
    name = (data.get('name') or '').strip()
    email = (data.get('email') or '').strip().lower()
    bio = data.get('bio')
    password = data.get('password') or ''

    if not name or not email:
        message = 'name e email são obrigatórios'
        return (jsonify({'error': message}), 400) if _should_return_json() else (flash(message, 'danger') or render_template('profile_edit.html', user=current_user), 400)

    other = User.query.filter(User.email == email, User.id != current_user.id).first()
    if other:
        message = 'email já está em uso'
        return (jsonify({'error': message}), 400) if _should_return_json() else (flash(message, 'danger') or render_template('profile_edit.html', user=current_user), 400)

    current_user.name = name
    current_user.email = email
    current_user.bio = bio
    if password:
        current_user.set_password(password)

    db.session.add(current_user)
    db.session.commit()

    if _should_return_json():
        return jsonify(current_user.to_dict()), 200

    flash('Perfil atualizado com sucesso.', 'success')
    return redirect(url_for('main.profile'))


@bp.route('/usuarios', methods=['GET'])
@admin_required
def users_list():
    users = User.query.order_by(User.id.desc()).all()
    return render_template('users_list.html', users=users)


@bp.route('/usuarios/<int:user_id>', methods=['GET'])
@admin_required
def user_detail(user_id):
    user = db.session.get(User, user_id)
    if not user:
        return render_template('404.html'), 404
    return render_template('user_detail.html', user=user)


@bp.route('/usuarios/<int:user_id>/editar', methods=['GET', 'POST'])
@admin_required
def edit_user(user_id):
    user = db.session.get(User, user_id)
    if not user:
        return render_template('404.html'), 404

    if request.method == 'GET':
        return render_template('user_edit.html', user=user)

    data = _payload()
    name = (data.get('name') or '').strip()
    email = (data.get('email') or '').strip().lower()
    bio = data.get('bio')
    role = data.get('role') or user.role
    active_value = data.get('is_active_account')
    is_active_account = str(active_value).lower() in {'1', 'true', 'on', 'yes'} if active_value is not None else user.is_active_account

    if not name or not email:
        message = 'name e email são obrigatórios'
        return (jsonify({'error': message}), 400) if _should_return_json() else (flash(message, 'danger') or render_template('user_edit.html', user=user), 400)

    other = User.query.filter(User.email == email, User.id != user.id).first()
    if other:
        message = 'email já está em uso'
        return (jsonify({'error': message}), 400) if _should_return_json() else (flash(message, 'danger') or render_template('user_edit.html', user=user), 400)

    password = data.get('password') or ''
    user.name = name
    user.email = email
    user.bio = bio
    user.role = role
    user.is_active_account = is_active_account
    if password:
        user.set_password(password)

    db.session.add(user)
    db.session.commit()

    if _should_return_json():
        return jsonify(user.to_dict()), 200

    flash('Usuário atualizado com sucesso.', 'success')
    return redirect(url_for('main.user_detail', user_id=user.id))


@bp.route('/usuarios/<int:user_id>/excluir', methods=['POST'])
@admin_required
def delete_user(user_id):
    user = db.session.get(User, user_id)
    if not user:
        return jsonify({'error': 'user not found'}) if _should_return_json() else (render_template('404.html'), 404)

    db.session.delete(user)
    db.session.commit()

    if _should_return_json():
        return jsonify({'ok': True}), 200

    flash('Usuário excluído com sucesso.', 'success')
    return redirect(url_for('main.users_list'))


@bp.route('/usuarios/<int:user_id>/ativar', methods=['POST'])
@admin_required
def activate_user(user_id):
    user = db.session.get(User, user_id)
    if not user:
        return jsonify({'error': 'user not found'}) if _should_return_json() else (render_template('404.html'), 404)

    user.is_active_account = True
    db.session.add(user)
    db.session.commit()

    if _should_return_json():
        return jsonify({'id': user.id, 'is_active_account': user.is_active_account}), 200

    flash('Usuário ativado com sucesso.', 'success')
    return redirect(url_for('main.user_detail', user_id=user.id))


@bp.route('/usuarios/<int:user_id>/desativar', methods=['POST'])
@admin_required
def deactivate_user(user_id):
    if current_user.id == user_id:
        message = 'Você não pode desativar sua própria conta'
        return (jsonify({'error': message}), 400) if _should_return_json() else (flash(message, 'danger') or redirect(url_for('main.user_detail', user_id=user_id)))

    user = db.session.get(User, user_id)
    if not user:
        return jsonify({'error': 'user not found'}) if _should_return_json() else (render_template('404.html'), 404)

    user.is_active_account = False
    db.session.add(user)
    db.session.commit()

    if _should_return_json():
        return jsonify({'id': user.id, 'is_active_account': user.is_active_account}), 200

    flash('Usuário desativado com sucesso.', 'warning')
    return redirect(url_for('main.user_detail', user_id=user.id))


@bp.route('/metricas', methods=['GET'])
@admin_required
def metrics():
    metrics_data = _dashboard_metrics()
    recent_leads = Lead.query.order_by(Lead.id.desc()).limit(5).all()
    recent_processos = Processo.query.order_by(Processo.id.desc()).limit(5).all()
    return render_template('metrics.html', metrics=metrics_data, recent_leads=recent_leads, recent_processos=recent_processos)


@bp.route('/')
def index():
    if current_user.is_authenticated:
        if current_user.role == 'admin':
            return render_template('dashboard.html', metrics=_dashboard_metrics())
        return render_template('operational_home.html', **_operational_home_context())
    return render_template('landing.html')


@bp.route('/web/leads/new')
@login_required
def web_new_lead():
    return render_template('leads_new.html')


@bp.route('/web/leads')
@login_required
def web_leads():
    status = (request.args.get('status') or '').strip()
    origin = (request.args.get('origin') or '').strip()
    page = request.args.get('page', type=int) or 1
    per_page = request.args.get('per_page', type=int) or 10

    query = Lead.query
    if status:
        query = query.filter_by(status=status)
    if origin:
        query = query.filter_by(origin=origin)

    pagination = query.order_by(Lead.id.desc()).paginate(page=page, per_page=per_page, error_out=False)
    leads = pagination.items
    statuses = [row[0] for row in db.session.query(Lead.status).filter(Lead.status.isnot(None)).distinct().order_by(Lead.status).all()]
    origins = [row[0] for row in db.session.query(Lead.origin).filter(Lead.origin.isnot(None)).distinct().order_by(Lead.origin).all()]

    return render_template(
        'leads_list.html',
        leads=leads,
        pagination=pagination,
        status_filter=status,
        origin_filter=origin,
        statuses=statuses,
        origins=origins,
    )


@bp.route('/web/leads/<int:lead_id>')
@login_required
def web_lead_detail(lead_id):
    lead = db.session.get(Lead, lead_id)
    if not lead:
        return render_template('404.html'), 404

    phone_digits = ''.join(ch for ch in (lead.phone or '') if ch.isdigit())
    whatsapp_message = (
        f'Olá, {lead.name}! Vi seu contato no JurisLead e gostaria de dar continuidade ao atendimento.'
    )
    whatsapp_url = (
        f'https://web.whatsapp.com/send?phone={phone_digits}&text={quote(whatsapp_message)}'
        if phone_digits else None
    )
    return render_template('lead_detail.html', lead=lead, whatsapp_url=whatsapp_url, whatsapp_message=whatsapp_message)


@bp.route('/leads/<int:lead_id>/excluir', methods=['POST'])
@roles_required('admin', *OPERATIONAL_ROLES)
def delete_lead(lead_id):
    lead = db.session.get(Lead, lead_id)
    if not lead:
        message = 'lead not found'
        return (jsonify({'error': message}), 404) if _should_return_json() else (render_template('404.html'), 404)

    related_consultas = Consulta.query.filter_by(lead_id=lead_id).count()
    related_processos = Processo.query.filter_by(lead_id=lead_id).count()
    if related_consultas or related_processos:
        message = 'lead possui consultas ou processos vinculados'
        return (jsonify({'error': message}), 400) if _should_return_json() else (flash(message, 'danger') or redirect(url_for('main.web_lead_detail', lead_id=lead_id)))

    db.session.delete(lead)
    db.session.commit()

    if _should_return_json():
        return jsonify({'ok': True}), 200

    flash('Lead excluído com sucesso.', 'success')
    return redirect(url_for('main.web_leads'))


@bp.route('/web/processos')
@roles_required('admin', *OPERATIONAL_ROLES)
def web_processos():
    procs = Processo.query.order_by(Processo.id.desc()).all()
    return render_template('processos_list.html', processos=procs)


@bp.route('/web/processos/<int:proc_id>')
@roles_required('admin', *OPERATIONAL_ROLES)
def web_processo_detail(proc_id):
    proc = db.session.get(Processo, proc_id)
    if not proc:
        return render_template('404.html'), 404
    return render_template('processo_detail.html', processo=proc)


@bp.route('/leads', methods=['POST'])
@login_required
def create_lead():
    data = _payload()
    name = (data.get('name') or '').strip()
    if not name:
        return jsonify({'error': 'name is required'}), 400

    email = data.get('email')
    documento = data.get('documento')

    if email:
        existing_email = Lead.query.filter_by(email=email).first()
        if existing_email:
            return jsonify({'error': 'E-mail ou documento ja cadastrado'}), 409
            
    if documento:
        existing_doc = Lead.query.filter_by(documento=documento).first()
        if existing_doc:
            return jsonify({'error': 'E-mail ou documento ja cadastrado'}), 409

    lead = Lead(
        name=name,
        email=email,
        documento=documento,
        phone=data.get('phone'),
        origin=data.get('origin'),
        status='new',
    )
    db.session.add(lead)
    db.session.commit()
    if _should_return_json():
        return jsonify({'id': lead.id, 'status': lead.status}), 201
    flash('Lead cadastrado com sucesso.', 'success')
    return redirect(url_for('main.index'))



@bp.route('/leads/<int:lead_id>/triage', methods=['POST'])
@admin_required
def lead_triage(lead_id):
    lead = db.session.get(Lead, lead_id)
    if not lead:
        return jsonify({'error': 'lead not found'}), 404
    try:
        result = triage_lead(lead)
    except Exception:
        current_app.logger.exception('Falha na triagem do lead')
        return jsonify({'error': 'ai_service_failure'}), 502

    lead.triage_summary = result.get('summary')
    lead.triage_classification = result.get('classification')
    # Optionally update status based on classification if present
    if lead.triage_classification:
        lead.status = lead.triage_classification

    db.session.add(lead)
    db.session.commit()
    if _should_return_json():
        return jsonify({'id': lead.id, 'triage_summary': lead.triage_summary, 'classification': lead.triage_classification}), 200
    flash('Triagem concluída.', 'success')
    return redirect(url_for('main.index'))


@bp.route('/leads/<int:lead_id>/convert', methods=['POST'])
@roles_required('admin', 'manager', 'advogado', 'atendente')
def convert_lead(lead_id):
    lead = db.session.get(Lead, lead_id)
    if not lead:
        return jsonify({'error': 'lead not found'}), 404

    # Verifica se já não foi convertido
    if getattr(lead, 'cliente', None) or lead.status == 'converted':
        return jsonify({'error': 'lead already converted'}), 400

    data = _payload()
    create_user = data.get('create_user', False)

    # Cria usuário se requisitado
    user_id = None
    if create_user and lead.email:
        existing_user = User.query.filter_by(email=lead.email).first()
        if not existing_user:
            import secrets
            new_user = User(
                name=lead.name,
                email=lead.email,
                role='cliente'
            )
            # Senha aleatória para o cliente, recomenda-se "esqueci a senha" para ele assumir
            new_user.set_password(secrets.token_urlsafe(16))
            db.session.add(new_user)
            db.session.flush()
            user_id = new_user.id
        else:
            user_id = existing_user.id

    cliente = Cliente(
        lead_id=lead.id,
        user_id=user_id,
        name=lead.name,
        documento=lead.documento
    )
    lead.status = 'converted'
    db.session.add(cliente)
    db.session.add(lead)
    db.session.commit()

    if _should_return_json():
        return jsonify({'ok': True, 'cliente_id': cliente.id, 'user_id': user_id}), 200
    
    flash('Lead convertido em cliente com sucesso.', 'success')
    return redirect(url_for('main.web_lead_detail', lead_id=lead.id))



@bp.route('/consultas', methods=['POST'])
@login_required
def create_consulta():
    data = _payload()
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
    if _should_return_json():
        return jsonify({'id': consulta.id, 'status': consulta.status}), 201
    flash('Consulta agendada com sucesso.', 'success')
    return redirect(url_for('main.index'))


@bp.route('/consultas/<int:consulta_id>/cancel', methods=['POST'])
@login_required
def cancel_consulta(consulta_id):
    consulta = db.session.get(Consulta, consulta_id)
    if not consulta:
        return jsonify({'error': 'consulta not found'}), 404
    consulta.status = 'cancelled'
    consulta.cancelled_at = datetime.now(timezone.utc).replace(tzinfo=None)
    db.session.add(consulta)
    db.session.commit()
    if _should_return_json():
        return jsonify({'id': consulta.id, 'status': consulta.status}), 200
    flash('Consulta cancelada.', 'warning')
    return redirect(url_for('main.index'))


@bp.route('/processos', methods=['POST'])
@login_required
def create_processo():
    data = _payload()
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
    if _should_return_json():
        return jsonify({'id': proc.id, 'lead_id': proc.lead_id}), 201
    flash('Processo criado com sucesso.', 'success')
    return redirect(url_for('main.web_processos'))


@bp.route('/processos/<int:proc_id>/movimentacoes', methods=['POST'])
@login_required
def add_movimentacao(proc_id):
    proc = db.session.get(Processo, proc_id)
    if not proc:
        return jsonify({'error': 'processo not found'}), 404
    data = _payload()
    desc = data.get('description')
    if not desc:
        return jsonify({'error': 'description is required'}), 400
    mov = Movimentacao(processo_id=proc_id, description=desc)
    db.session.add(mov)
    db.session.commit()
    if _should_return_json():
        return jsonify({'id': mov.id, 'processo_id': proc_id}), 201
    flash('Movimentação adicionada.', 'success')
    return redirect(url_for('main.web_processo_detail', proc_id=proc_id))


@bp.route('/processos/<int:proc_id>', methods=['GET'])
@roles_required('admin', *OPERATIONAL_ROLES)
def get_processo(proc_id):
    proc = db.session.get(Processo, proc_id)
    if not proc:
        return jsonify({'error': 'processo not found'}), 404
    return jsonify(proc.to_dict(include_movs=True)), 200


@bp.route('/consultas/<int:consulta_id>/notify', methods=['POST'])
@login_required
def notify_consulta_whatsapp(consulta_id):
    consulta = db.session.get(Consulta, consulta_id)
    if not consulta:
        return jsonify({'error': 'consulta not found'}), 404
    lead = consulta.lead
    phone = lead.phone
    if not phone:
        return jsonify({'error': 'lead phone not available'}), 400

    # montar mensagem simples de lembrete
    scheduled = consulta.scheduled_at.isoformat()
    message = f"Lembrete: sua consulta está agendada para {scheduled}."
    try:
        result = send_whatsapp_message(phone, message)
        
        # Gravar histórico com status 'sent'
        msg_log = Mensagem(
            lead_id=lead.id,
            channel='whatsapp',
            content=message,
            status='sent'
        )
        db.session.add(msg_log)
        db.session.commit()
    except Exception:
        # Gravar histórico com status 'failed'
        msg_log = Mensagem(
            lead_id=lead.id,
            channel='whatsapp',
            content=message,
            status='failed'
        )
        db.session.add(msg_log)
        db.session.commit()
        
        current_app.logger.exception('Falha no envio de notificação via WhatsApp')
        return jsonify({'error': 'whatsapp_service_failure'}), 502

    if _should_return_json():
        return jsonify({'ok': True, 'result': result}), 200
    flash('Notificação enviada via WhatsApp (ou mock).', 'success')
    return redirect(url_for('main.index'))

