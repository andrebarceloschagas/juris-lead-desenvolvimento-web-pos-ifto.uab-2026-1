from . import db, login_manager
from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash


class User(UserMixin, db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(128), nullable=False)
    email = db.Column(db.String(128), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(256), nullable=False)
    bio = db.Column(db.Text, nullable=True)
    role = db.Column(db.String(32), nullable=False, default='user')
    is_active_account = db.Column(db.Boolean, nullable=False, default=True)
    created_at = db.Column(db.DateTime, server_default=db.func.now())
    updated_at = db.Column(db.DateTime, server_default=db.func.now(), onupdate=db.func.now())

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'bio': self.bio,
            'role': self.role,
            'is_active_account': self.is_active_account,
        }

    @property
    def is_active(self):
        return self.is_active_account



class Lead(db.Model):
    __tablename__ = 'leads'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(128), nullable=False)
    email = db.Column(db.String(128), unique=True, nullable=True)
    documento = db.Column(db.String(32), unique=True, nullable=True)
    phone = db.Column(db.String(32), nullable=True)
    origin = db.Column(db.String(64), nullable=True)
    status = db.Column(db.String(32), nullable=False, default='new')
    triage_summary = db.Column(db.Text, nullable=True)
    triage_classification = db.Column(db.String(64), nullable=True)
    created_at = db.Column(db.DateTime, server_default=db.func.now())
    updated_at = db.Column(db.DateTime, server_default=db.func.now(), onupdate=db.func.now())

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'documento': self.documento,
            'phone': self.phone,
            'origin': self.origin,
            'status': self.status,
        }

class Cliente(db.Model):
    __tablename__ = 'clientes'
    id = db.Column(db.Integer, primary_key=True)
    lead_id = db.Column(db.Integer, db.ForeignKey('leads.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=True)
    name = db.Column(db.String(128), nullable=False)
    documento = db.Column(db.String(32), unique=True, nullable=True)
    created_at = db.Column(db.DateTime, server_default=db.func.now())
    
    lead = db.relationship('Lead', backref=db.backref('cliente', uselist=False))
    user = db.relationship('User', backref=db.backref('cliente', uselist=False))

    def to_dict(self):
        return {
            'id': self.id,
            'lead_id': self.lead_id,
            'user_id': self.user_id,
            'name': self.name,
            'documento': self.documento
        }

@login_manager.user_loader
def load_user(user_id):
    return db.session.get(User, int(user_id))


class Consulta(db.Model):
    __tablename__ = 'consultas'
    id = db.Column(db.Integer, primary_key=True)
    lead_id = db.Column(db.Integer, db.ForeignKey('leads.id'), nullable=False)
    scheduled_at = db.Column(db.DateTime, nullable=False)
    status = db.Column(db.String(32), nullable=False, default='scheduled')
    created_at = db.Column(db.DateTime, server_default=db.func.now())
    cancelled_at = db.Column(db.DateTime, nullable=True)

    lead = db.relationship('Lead', backref=db.backref('consultas', lazy=True))

    def to_dict(self):
        return {
            'id': self.id,
            'lead_id': self.lead_id,
            'lead_name': self.lead.name if self.lead else '',
            'scheduled_at': self.scheduled_at.isoformat() if self.scheduled_at else None,
            'status': self.status,
        }


class Processo(db.Model):
    __tablename__ = 'processos'
    id = db.Column(db.Integer, primary_key=True)
    lead_id = db.Column(db.Integer, db.ForeignKey('leads.id'), nullable=False)
    title = db.Column(db.String(256), nullable=False)
    description = db.Column(db.Text, nullable=True)
    status = db.Column(db.String(64), nullable=False, default='open')
    created_at = db.Column(db.DateTime, server_default=db.func.now())

    lead = db.relationship('Lead', backref=db.backref('processos', lazy=True))

    def to_dict(self, include_movs=False):
        base = {
            'id': self.id,
            'lead_id': self.lead_id,
            'lead_name': self.lead.name if self.lead else '',
            'title': self.title,
            'description': self.description,
            'status': self.status,
        }
        if include_movs:
            base['movimentacoes'] = [m.to_dict() for m in self.movimentacoes]
        return base


class Movimentacao(db.Model):
    __tablename__ = 'movimentacoes'
    id = db.Column(db.Integer, primary_key=True)
    processo_id = db.Column(db.Integer, db.ForeignKey('processos.id'), nullable=False)
    description = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, server_default=db.func.now())

    processo = db.relationship('Processo', backref=db.backref('movimentacoes', lazy=True, order_by=created_at))

    def to_dict(self):
        return {
            'id': self.id,
            'processo_id': self.processo_id,
            'description': self.description,
            'created_at': self.created_at.isoformat() if self.created_at else None,
        }


class Mensagem(db.Model):
    __tablename__ = 'mensagens'
    id = db.Column(db.Integer, primary_key=True)
    lead_id = db.Column(db.Integer, db.ForeignKey('leads.id'), nullable=False)
    channel = db.Column(db.String(32), nullable=False, default='whatsapp')
    content = db.Column(db.Text, nullable=False)
    status = db.Column(db.String(32), nullable=False, default='sent')
    created_at = db.Column(db.DateTime, server_default=db.func.now())

    lead = db.relationship('Lead', backref=db.backref('mensagens', lazy=True))

    def to_dict(self):
        return {
            'id': self.id,
            'lead_id': self.lead_id,
            'channel': self.channel,
            'content': self.content,
            'status': self.status,
            'created_at': self.created_at.isoformat() if self.created_at else None,
        }
