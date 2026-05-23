import os
import atexit
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager
from apscheduler.schedulers.background import BackgroundScheduler

db = SQLAlchemy()
login_manager = LoginManager()
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
    login_manager.login_view = 'main.login'

    with app.app_context():
        from . import routes  # noqa: F401
        from . import models  # noqa: F401
        app.register_blueprint(routes.bp)
        db.create_all()

    # Inicia o APScheduler se não estivermos em testes
    if not app.config.get('TESTING'):
        from .services import tasks
        tasks.register_jobs()
        scheduler.start()
        atexit.register(lambda: scheduler.shutdown(wait=False))

    return app
