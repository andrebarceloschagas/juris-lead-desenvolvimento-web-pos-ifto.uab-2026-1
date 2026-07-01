import os
import atexit
from flask import Flask, request, session, abort
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager
from flask_jwt_extended import JWTManager
from apscheduler.schedulers.background import BackgroundScheduler
from sqlalchemy import text

db = SQLAlchemy()
login_manager = LoginManager()
login_manager.login_view = 'main.login'
jwt = JWTManager()
scheduler = BackgroundScheduler()

def create_app(test_config: dict | None = None):
    app = Flask(__name__, instance_relative_config=False)

    from config import config
    env = os.getenv('FLASK_ENV', 'default')
    app.config.from_object(config.get(env, config['default']))

    if test_config:
        app.config.update(test_config)

    db.init_app(app)
    login_manager.init_app(app)
    
    app.config["JWT_SECRET_KEY"] = os.getenv("JWT_SECRET_KEY", app.config["SECRET_KEY"])
    jwt.init_app(app)

    @app.context_processor
    def inject_csrf_token():
        import secrets
        if 'csrf_token' not in session:
            session['csrf_token'] = secrets.token_hex(32)
        return dict(csrf_token=lambda: session['csrf_token'])

    @app.before_request
    def csrf_protect():
        if app.config.get('TESTING'):
            return
        # Ignore CSRF for API requests (e.g. prefix /api/) since API uses JWT and not session cookies
        if request.path.startswith('/api/'):
            return
        if request.method in ("POST", "PUT", "DELETE", "PATCH"):
            csrf_token = session.get('csrf_token')
            if not csrf_token:
                abort(400, description="CSRF session token missing.")
            
            sent_token = request.headers.get('X-CSRF-Token')
            if not sent_token:
                if request.is_json:
                    body = request.get_json(silent=True) or {}
                    sent_token = body.get('csrf_token')
                else:
                    sent_token = request.form.get('csrf_token')
            
            if not sent_token or sent_token != csrf_token:
                abort(400, description="CSRF token mismatch.")

    with app.app_context():
        from . import routes  # noqa: F401
        from . import models  # noqa: F401
        from .api_routes import api_bp
        app.register_blueprint(routes.bp)
        app.register_blueprint(api_bp)
        db.create_all()

        # Lightweight schema migration for existing databases:
        # - add 'documento' column to 'leads' if missing (backwards-compatible, nullable)
        try:
            with db.engine.connect() as conn:
                res = conn.execute(text("PRAGMA table_info('leads')")).mappings().all()
                cols = [r['name'] for r in res]
                if 'documento' not in cols:
                    conn.execute(text("ALTER TABLE leads ADD COLUMN documento VARCHAR(32)"))
        except Exception:
            # If anything fails here, do not prevent app startup; errors will surface later in tests.
            pass

    # Inicia o APScheduler se não estivermos em testes
    if not app.config.get('TESTING'):
        from .services import tasks
        tasks.register_jobs(app)
        scheduler.start()
        atexit.register(lambda: scheduler.shutdown(wait=False))

    return app
